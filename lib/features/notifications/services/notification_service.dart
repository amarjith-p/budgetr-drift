import 'package:drift/drift.dart';
import 'package:get_it/get_it.dart';
import 'package:uuid/uuid.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';

import '../../../core/database/app_database.dart';
import '../database/notification_tables.dart';

// Module Imports
import '../../credit_tracker/services/credit_service.dart';
import '../../credit_tracker/models/credit_models.dart';
import '../../dashboard/services/dashboard_service.dart';
import '../../daily_expense/services/expense_service.dart';
import '../../backup_restore/services/backup_service.dart';

class NotificationService {
  final AppDatabase _db = AppDatabase.instance;
  final _uuid = const Uuid();

  // --- CONFIGURATION ---
  static const double kLowBalanceThreshold = 1000.0;

  // --- CRUD OPERATIONS ---

  Stream<List<AppNotification>> getNotifications() {
    return (_db.select(_db.appNotifications)
          ..orderBy([
            (t) =>
                OrderingTerm(expression: t.createdAt, mode: OrderingMode.desc)
          ]))
        .watch();
  }

  Stream<int> getUnreadCount() {
    return (_db.selectOnly(_db.appNotifications)
          ..addColumns([_db.appNotifications.id.count()])
          ..where(_db.appNotifications.isRead.equals(false)))
        .map((row) => row.read(_db.appNotifications.id.count()) ?? 0)
        .watchSingle();
  }

  Future<void> markAsRead(String id) async {
    await (_db.update(_db.appNotifications)..where((t) => t.id.equals(id)))
        .write(AppNotificationsCompanion(isRead: const Value(true)));
  }

  Future<void> markAllAsRead() async {
    await _db
        .update(_db.appNotifications)
        .write(const AppNotificationsCompanion(isRead: Value(true)));
  }

  Future<void> deleteNotification(String id) async {
    await (_db.delete(_db.appNotifications)..where((t) => t.id.equals(id)))
        .go();
  }

  Future<void> clearAll() async {
    await _db.delete(_db.appNotifications).go();

    // Optional: Clear history keys if you want a hard reset
    // final prefs = await SharedPreferences.getInstance();
    // await prefs.clear();
  }

  // --- INTERNAL HELPER: Add Notification ---
  Future<void> _createNotification({
    required String type,
    required String title,
    required String message,
    String? payload,
  }) async {
    // 1. Database Dedup (Double check to avoid immediate UI duplicates)
    final exists = await (_db.select(_db.appNotifications)
          ..where((t) {
            final basicCheck = t.type.equals(type) & t.isRead.equals(false);
            final payloadCheck = payload != null
                ? t.payload.equals(payload)
                : t.payload.isNull();
            return basicCheck & payloadCheck;
          }))
        .getSingleOrNull();

    if (exists != null) return;

    // 2. Insert
    await _db
        .into(_db.appNotifications)
        .insert(AppNotificationsCompanion.insert(
          id: _uuid.v4(),
          type: type,
          title: title,
          message: message,
          payload: Value(payload),
          isRead: const Value(false),
          createdAt: DateTime.now(),
        ));
  }

  // --- FREQUENCY CONTROL ENGINE ---

  /// Checks if we should notify based on frequency rules.
  /// [key] should be unique per event type + resource ID + time period.
  Future<bool> _shouldNotify(String key) async {
    final prefs = await SharedPreferences.getInstance();
    // If key exists, it means we already notified for this period.
    return !prefs.containsKey(key);
  }

  /// Marks a notification as "Sent" for the specific period.
  Future<void> _markNotified(String key) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(key, true);
  }

  /// Helper to generate Time-Based Keys
  String _getDailyKey(String type, String id) {
    final dateStr = DateFormat('yyyyMMdd').format(DateTime.now());
    return 'notif_${type}_${id}_$dateStr';
  }

  String _getMonthlyKey(String type, String id) {
    final dateStr = DateFormat('yyyyMM').format(DateTime.now());
    return 'notif_${type}_${id}_$dateStr';
  }

  // --- MASTER ENGINE ---

  Future<void> runStartupChecks() async {
    try {
      await _runCreditChecks();
      await _runBudgetChecks();
      await _runDailyExpenseChecks();
      await _runBackupChecks();
    } catch (e) {
      debugPrint("Notification Check Error: $e");
    }
  }

  // --- SUB-ENGINE 1: Credit Checks ---
  Future<void> _runCreditChecks() async {
    try {
      final creditService = GetIt.I<CreditService>();
      final cards = await creditService.getCreditCards().first;
      final today = DateTime.now();

      for (var card in cards) {
        // 1. Statement Generated (Monthly)
        if (card.billDate == today.day) {
          final key = _getMonthlyKey('statement', card.id);
          if (await _shouldNotify(key)) {
            await _createNotification(
              type: 'statement',
              title: 'Statement Generated',
              message: 'Your bill for ${card.name} is generated today.',
              payload: card.id,
            );
            await _markNotified(key);
          }
        }

        // 2. Due Date (Daily Reminders when close)
        int daysUntilDue = card.dueDate - today.day;
        // Logic: Notify on Day 3, Day 1, and Day 0
        bool isDueDay = (card.dueDate == today.day) || (daysUntilDue == 3);

        if (isDueDay) {
          final key = _getDailyKey('due_date', card.id);
          if (await _shouldNotify(key)) {
            String msg = (card.dueDate == today.day)
                ? 'Bill for ${card.name} is due today.'
                : 'Bill for ${card.name} is due in 3 days.';

            await _createNotification(
              type: 'due_date',
              title: (card.dueDate == today.day)
                  ? 'Payment Due Today!'
                  : 'Payment Due Soon',
              message: msg,
              payload: card.id,
            );
            await _markNotified(key);
          }
        }

        // 3. Utilization (Daily Check)
        if (card.creditLimit > 0) {
          final utilization = (card.currentBalance / card.creditLimit) * 100;

          if (card.currentBalance > card.creditLimit) {
            final key = _getDailyKey('limit_exceeded', card.id);
            if (await _shouldNotify(key)) {
              await _createNotification(
                type: 'limit_exceeded',
                title: 'Credit Limit Exceeded!',
                message: 'You have exceeded the limit on ${card.name}!',
                payload: card.id,
              );
              await _markNotified(key);
            }
          } else if (utilization >= 90) {
            final key = _getDailyKey('high_util', card.id);
            if (await _shouldNotify(key)) {
              await _createNotification(
                type: 'high_util',
                title: 'High Utilization Alert',
                message:
                    'You have used ${utilization.toStringAsFixed(1)}% of ${card.name}.',
                payload: card.id,
              );
              await _markNotified(key);
            }
          }
        }
      }
    } catch (_) {}
  }

  // --- SUB-ENGINE 2: Budget Checks ---
  Future<void> _runBudgetChecks() async {
    try {
      final dashboardService = GetIt.I<DashboardService>();
      final now = DateTime.now();

      // 1. Budget Not Set (Monthly)
      final currentRecord =
          await dashboardService.getRecordForMonth(now.year, now.month);
      if (currentRecord == null) {
        if (now.day <= 5) {
          final key = _getMonthlyKey('budget_not_set', 'global');
          if (await _shouldNotify(key)) {
            await _createNotification(
              type: 'budget_not_set',
              title: 'Set Your Budget',
              message: 'Welcome to a new month! Plan your finances now.',
              payload: 'dashboard',
            );
            await _markNotified(key);
          }
        }
        return; // Exit if no budget
      }

      // 2. Closure Pending (Monthly - for previous month)
      final prevMonthDate = DateTime(now.year, now.month - 1);
      final prevRecord = await dashboardService.getRecordForMonth(
          prevMonthDate.year, prevMonthDate.month);
      if (prevRecord != null) {
        final settlement = await (_db.select(_db.settlements)
              ..where((t) =>
                  t.year.equals(prevMonthDate.year) &
                  t.month.equals(prevMonthDate.month)))
            .getSingleOrNull();

        if (settlement == null) {
          final key = _getMonthlyKey('budget_closure_pending', 'prev_month');
          if (await _shouldNotify(key)) {
            await _createNotification(
              type: 'budget_closure_pending',
              title: 'Close Previous Budget',
              message: 'You haven\'t closed your budget for last month yet.',
              payload: 'settlement',
            );
            await _markNotified(key);
          }
        }
      }

      // 3. Spending Health (Daily)
      final spendingMap = await dashboardService
          .getMonthlyBucketSpending(now.year, now.month)
          .first;
      double totalSpent = 0;

      // We use a loop with async capability
      for (var entry in currentRecord.allocations.entries) {
        final bucketName = entry.key;
        final allocated = entry.value;
        if (bucketName == 'Income') continue;

        final spent = spendingMap[bucketName] ?? 0.0;
        totalSpent += spent;

        if (allocated > 0) {
          if (spent > allocated) {
            final key = _getDailyKey('bucket_overflow', bucketName);
            if (await _shouldNotify(key)) {
              await _createNotification(
                type: 'bucket_overflow',
                title: 'Budget Exceeded: $bucketName',
                message: 'You exceeded your $bucketName budget.',
                payload: bucketName,
              );
              await _markNotified(key);
            }
          } else if (spent >= (allocated * 0.9)) {
            final key = _getDailyKey('budget_approaching', bucketName);
            if (await _shouldNotify(key)) {
              await _createNotification(
                type: 'budget_approaching',
                title: 'Approaching Limit: $bucketName',
                message: 'You have used 90% of your $bucketName budget.',
                payload: bucketName,
              );
              await _markNotified(key);
            }
          }
        }
      }

      if (currentRecord.effectiveIncome > 0 &&
          totalSpent > currentRecord.effectiveIncome) {
        final key = _getDailyKey('global_overrun', 'total');
        if (await _shouldNotify(key)) {
          await _createNotification(
            type: 'global_overrun',
            title: 'Critical: Income Exceeded',
            message: 'Your total spending is higher than your income!',
            payload: 'dashboard',
          );
          await _markNotified(key);
        }
      }
    } catch (_) {}
  }

  // --- SUB-ENGINE 3: Daily Expense Checks ---
  Future<void> _runDailyExpenseChecks() async {
    try {
      final accounts = await _db.select(_db.expenseAccounts).get();

      for (var acc in accounts) {
        // 1. Negative Balance (Daily)
        if (acc.currentBalance < 0) {
          final key = _getDailyKey('negative_balance', acc.id);
          if (await _shouldNotify(key)) {
            await _createNotification(
              type: 'negative_balance',
              title: 'Negative Balance Alert',
              message:
                  '${acc.name} is in negative (₹${acc.currentBalance.toStringAsFixed(0)}).',
              payload: acc.id,
            );
            await _markNotified(key);
          }
        }
        // 2. Low Balance (Daily)
        else if (acc.currentBalance < kLowBalanceThreshold) {
          final key = _getDailyKey('low_balance', acc.id);
          if (await _shouldNotify(key)) {
            await _createNotification(
              type: 'low_balance',
              title: 'Low Balance: ${acc.name}',
              message:
                  'Balance is low (₹${acc.currentBalance.toStringAsFixed(0)}).',
              payload: acc.id,
            );
            await _markNotified(key);
          }
        }
      }

      // 3. Forgot to Log (Daily)
      // Key is tied to Yesterday's Date to ensure we only ask once about yesterday
      final now = DateTime.now();
      final yesterday = now.subtract(const Duration(days: 1));
      final yesterdayStr = DateFormat('yyyyMMdd').format(yesterday);

      final logKey = 'notif_forgot_log_$yesterdayStr';

      if (await _shouldNotify(logKey)) {
        final startOfYesterday =
            DateTime(yesterday.year, yesterday.month, yesterday.day);
        final endOfYesterday = DateTime(
            yesterday.year, yesterday.month, yesterday.day, 23, 59, 59);

        final yesterdayTxns = await (_db.select(_db.expenseTransactions)
              ..where((t) =>
                  t.date.isBetweenValues(startOfYesterday, endOfYesterday)))
            .get();

        if (yesterdayTxns.isEmpty) {
          await _createNotification(
            type: 'forgot_log',
            title: 'Forgot to Log?',
            message: 'You have no expenses recorded for yesterday.',
            payload: 'daily_expense',
          );
          await _markNotified(logKey);
        }
      }

      // 4. Heatmap Spike (Daily)
      final expenseService = GetIt.I<ExpenseService>();
      final heatmapLimit = await expenseService.getMonthLimits(now);

      if (heatmapLimit.severeLimit > 0) {
        final startOfToday = DateTime(now.year, now.month, now.day);
        final endOfToday = DateTime(now.year, now.month, now.day, 23, 59, 59);

        final todayTxns = await (_db.select(_db.expenseTransactions)
              ..where((t) =>
                  t.date.isBetweenValues(startOfToday, endOfToday) &
                  t.type.equals('Expense')))
            .get();

        double todayTotal = 0.0;
        for (var t in todayTxns) todayTotal += t.amount;

        if (todayTotal > heatmapLimit.severeLimit) {
          final key = _getDailyKey('daily_spike', 'total');
          if (await _shouldNotify(key)) {
            await _createNotification(
              type: 'daily_spike',
              title: 'High Spending Alert',
              message:
                  'You spent ₹${todayTotal.toStringAsFixed(0)} today, exceeding your limit.',
              payload: 'spending_calendar',
            );
            await _markNotified(key);
          }
        }
      }
    } catch (e) {
      debugPrint("Daily Expense Check Error: $e");
    }
  }

  // --- SUB-ENGINE 4: Backup Checks ---
  Future<void> _runBackupChecks() async {
    try {
      final backupService = BackupService();

      // 1. Restore Success (Instant / Once)
      final wasRestored = await backupService.checkAndResetRestoreFlag();
      if (wasRestored) {
        // No freq check needed, the flag resets itself
        await _createNotification(
          type: 'restore_success',
          title: 'Restore Complete',
          message: 'Your data has been successfully restored.',
          payload: 'settings',
        );
      }

      // 2. Overdue (Daily)
      if (!wasRestored && await backupService.isBackupOverdue()) {
        final key = _getDailyKey('backup_overdue', 'global');
        if (await _shouldNotify(key)) {
          await _createNotification(
            type: 'backup_overdue',
            title: 'Backup Overdue',
            message: 'You haven\'t backed up your data recently.',
            payload: 'backup',
          );
          await _markNotified(key);
        }
      }
    } catch (e) {
      debugPrint("Backup Check Error: $e");
    }
  }
}
