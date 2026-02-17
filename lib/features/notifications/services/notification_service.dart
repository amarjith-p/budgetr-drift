import 'package:drift/drift.dart';
import 'package:get_it/get_it.dart';
import 'package:uuid/uuid.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';

import '../../../core/database/app_database.dart';
import '../database/notification_tables.dart';

// Feature Imports
import '../../credit_tracker/services/credit_service.dart';
import '../../credit_tracker/models/credit_models.dart';
import '../../dashboard/services/dashboard_service.dart';
import '../../daily_expense/services/expense_service.dart';
import '../../backup_restore/services/backup_service.dart';
import '../../investment/services/investment_service.dart';
import '../../goals_loans/services/goal_loan_service.dart';
// [NEW] System Notification Import
import 'system_notification_service.dart';

class NotificationService {
  final AppDatabase _db = AppDatabase.instance;
  final _uuid = const Uuid();

  // Lazy access to System Service to ensure it's registered
  SystemNotificationService get _systemService =>
      GetIt.I<SystemNotificationService>();

  // --- CONFIGURATION ---
  static const double kLowBalanceThreshold = 1000.0;
  static const double kVolatilityThreshold = 0.03;

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
  }

  // --- INTERNAL HELPER: Add Notification & Trigger System Alert ---
  Future<void> _createNotification({
    required String type,
    required String title,
    required String message,
    String? payload,
  }) async {
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

    // 1. Save to Database (In-App History)
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

    // 2. Trigger System Notification (Push)
    // We generate a unique integer ID from the type/time to allow cancelling/updating
    final sysId = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    try {
      await _systemService.showInstantNotification(
          id: sysId, title: title, body: message, payload: payload);
    } catch (e) {
      debugPrint("System Notification Error: $e");
    }
  }

  // --- FREQUENCY CONTROL ---
  Future<bool> _shouldNotify(String key) async {
    final prefs = await SharedPreferences.getInstance();
    return !prefs.containsKey(key);
  }

  Future<void> _markNotified(String key) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(key, true);
  }

  String _getDailyKey(String type, String id) {
    final dateStr = DateFormat('yyyyMMdd').format(DateTime.now());
    return 'notif_${type}_${id}_$dateStr';
  }

  String _getMonthlyKey(String type, String id) {
    final dateStr = DateFormat('yyyyMM').format(DateTime.now());
    return 'notif_${type}_${id}_$dateStr';
  }

  // --- MASTER ENGINE: Run All Startup Checks ---

  Future<void> runStartupChecks() async {
    try {
      // Immediate Checks
      await checkCreditHealth();
      await checkBudgetHealth();
      await checkDailyExpenseHealth();
      await checkBackupStatus();
      await checkInvestmentHealth();
      await checkGoalLoanStatus();

      // [NEW] Future Scheduling (For Force Closed State)
      await scheduleFutureNotifications();
    } catch (e) {
      debugPrint("Notification Check Error: $e");
    }
  }

  // --- [NEW] FORCE CLOSE HANDLER: Schedule Future Events ---
  Future<void> scheduleFutureNotifications() async {
    try {
      // 1. Schedule Loan Reminders
      final loans = await GetIt.I<GoalLoanService>().getActiveLoans().first;
      for (var loan in loans) {
        if (loan.remaining <= 0 || loan.dueDate == null) continue;

        final due = loan.dueDate!;
        if (due.isAfter(DateTime.now())) {
          // Schedule for 9:00 AM on Due Date
          final scheduleTime = DateTime(due.year, due.month, due.day, 9, 0);

          // Generate a stable ID based on Loan ID hash
          final notifId = loan.id.hashCode;

          await _systemService.scheduleNotification(
              id: notifId,
              title: 'Loan Repayment Due',
              body: 'Your loan ${loan.title} is due today.',
              scheduledDate: scheduleTime,
              payload: loan.id);
        }
      }

      // 2. Schedule Goal Deadlines
      final goals = await GetIt.I<GoalLoanService>().getActiveGoals().first;
      for (var goal in goals) {
        if (!goal.isCompleted && goal.deadline != null) {
          final dead = goal.deadline!;
          if (dead.isAfter(DateTime.now())) {
            final scheduleTime =
                DateTime(dead.year, dead.month, dead.day, 9, 0);
            final notifId = goal.id.hashCode;

            await _systemService.scheduleNotification(
                id: notifId,
                title: 'Goal Deadline Reached',
                body: 'Time is up for your goal: ${goal.name}.',
                scheduledDate: scheduleTime,
                payload: goal.id);
          }
        }
      }

      // 3. Schedule Credit Card Bill Dates (Optional - Logic similar to above)
    } catch (e) {
      debugPrint("Scheduling Error: $e");
    }
  }

  // --- PUBLIC CHECKS (Standard Logic) ---

  // 1. Credit Checks
  Future<void> checkCreditHealth() async {
    try {
      final creditService = GetIt.I<CreditService>();
      final cards = await creditService.getCreditCards().first;
      final today = DateTime.now();

      for (var card in cards) {
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

        int daysUntilDue = card.dueDate - today.day;
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

  // 2. Budget Checks
  Future<void> checkBudgetHealth() async {
    try {
      final dashboardService = GetIt.I<DashboardService>();
      final now = DateTime.now();

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
        return;
      }

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

      final spendingMap = await dashboardService
          .getMonthlyBucketSpending(now.year, now.month)
          .first;
      double totalSpent = 0;

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

  // 3. Daily Expense Checks
  Future<void> checkDailyExpenseHealth() async {
    try {
      final accounts = await _db.select(_db.expenseAccounts).get();

      for (var acc in accounts) {
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
        } else if (acc.currentBalance < kLowBalanceThreshold) {
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

  // 4. Backup Checks
  Future<void> checkBackupStatus() async {
    try {
      final backupService = BackupService();
      final wasRestored = await backupService.checkAndResetRestoreFlag();
      if (wasRestored) {
        await _createNotification(
          type: 'restore_success',
          title: 'Restore Complete',
          message: 'Your data has been successfully restored.',
          payload: 'settings',
        );
      }

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

  // 5. Investment Checks
  Future<void> checkInvestmentHealth() async {
    try {
      final invService = GetIt.I<InvestmentService>();
      final investments = await invService.getInvestments().first;

      if (investments.isEmpty) return;

      final lastUpdated = investments.first.lastUpdated;
      final daysSinceUpdate = DateTime.now().difference(lastUpdated).inDays;

      if (daysSinceUpdate >= 3) {
        final key = _getDailyKey('inv_stale_data', 'global');
        if (await _shouldNotify(key)) {
          await _createNotification(
            type: 'inv_stale',
            title: 'Outdated Prices',
            message:
                'Portfolio prices haven\'t been updated in $daysSinceUpdate days.',
            payload: 'investment',
          );
          await _markNotified(key);
        }
      }
    } catch (e) {
      debugPrint("Inv Startup Error: $e");
    }
  }

  // 6. Goals & Loans Checks
  Future<void> checkGoalLoanStatus() async {
    try {
      final glService = GetIt.I<GoalLoanService>();
      final now = DateTime.now();

      final goals = await glService.getActiveGoals().first;
      for (var goal in goals) {
        if (!goal.isCompleted && goal.currentAmount >= goal.targetAmount) {
          final key = 'notif_goal_achieved_${goal.id}';
          if (await _shouldNotify(key)) {
            await _createNotification(
              type: 'goal_achieved',
              title: 'Goal Achieved! 🎉',
              message:
                  'Congratulations! You have reached your goal: ${goal.name}.',
              payload: goal.id,
            );
            await _markNotified(key);
          }
        }

        if (!goal.isCompleted && goal.currentAmount < goal.targetAmount) {
          if (goal.deadline != null) {
            final daysLeft = goal.deadline!.difference(now).inDays;
            if (daysLeft == 7 || daysLeft == 1) {
              final key = 'notif_goal_deadline_${goal.id}_$daysLeft';
              if (await _shouldNotify(key)) {
                await _createNotification(
                  type: 'goal_deadline',
                  title: 'Goal Deadline Approaching',
                  message: '${goal.name} is due in $daysLeft days.',
                  payload: goal.id,
                );
                await _markNotified(key);
              }
            }
          }
        }
      }

      final loans = await glService.getActiveLoans().first;
      for (var loan in loans) {
        if (loan.remaining <= 0) continue;

        if (loan.dueDate != null) {
          final daysUntilDue = loan.dueDate!.difference(now).inDays;

          if (daysUntilDue < 0) {
            final key = _getDailyKey('loan_overdue', loan.id);
            if (await _shouldNotify(key)) {
              await _createNotification(
                type: 'loan_overdue',
                title: 'Loan Overdue Alert',
                message: 'The repayment for ${loan.title} is overdue!',
                payload: loan.id,
              );
              await _markNotified(key);
            }
          } else if (daysUntilDue == 3 || daysUntilDue == 1) {
            final key = 'notif_loan_due_${loan.id}_$daysUntilDue';
            if (await _shouldNotify(key)) {
              await _createNotification(
                type: 'loan_due',
                title: 'Loan Repayment Reminder',
                message: '${loan.title} is due in $daysUntilDue days.',
                payload: loan.id,
              );
              await _markNotified(key);
            }
          }
        }
      }
    } catch (e) {
      debugPrint("Goal/Loan Check Error: $e");
    }
  }

  // --- REAL-TIME HOOK (Investment) ---
  Future<void> checkInvestmentVolatilityAndMilestones() async {
    try {
      final invService = GetIt.I<InvestmentService>();
      final investments = await invService.getInvestments().first;

      if (investments.isEmpty) return;

      double totalCurrent = 0;
      double totalPrev = 0;

      for (var inv in investments) {
        totalCurrent += (inv.quantity * inv.currentPrice);
        totalPrev += (inv.quantity * inv.previousClose);

        final retPercent = inv.returnPercentage;
        if (retPercent >= 50) {
          int milestone = 0;
          if (retPercent >= 100)
            milestone = 100;
          else if (retPercent >= 50) milestone = 50;

          final key = 'notif_milestone_${inv.symbol}_$milestone';
          if (await _shouldNotify(key)) {
            await _createNotification(
              type: 'inv_milestone',
              title: 'Milestone Alert: ${inv.symbol}',
              message: '${inv.name} has crossed +$milestone% returns!',
              payload: 'investment',
            );
            await _markNotified(key);
          }
        }
      }

      if (totalPrev > 0) {
        final changePercent = (totalCurrent - totalPrev) / totalPrev;
        final absChange = changePercent.abs();

        if (absChange >= kVolatilityThreshold) {
          final key = _getDailyKey('inv_volatility', 'portfolio');
          if (await _shouldNotify(key)) {
            final direction = changePercent > 0 ? "up" : "down";
            final percentStr = (absChange * 100).toStringAsFixed(1);

            await _createNotification(
              type: 'inv_volatility',
              title: 'Market Alert',
              message: 'Your portfolio is $direction by $percentStr% today.',
              payload: 'investment',
            );
            await _markNotified(key);
          }
        }
      }
    } catch (e) {
      debugPrint("Inv Hook Error: $e");
    }
  }
}
