import 'package:drift/drift.dart';
import 'package:get_it/get_it.dart';
import 'package:uuid/uuid.dart';
import 'package:flutter/foundation.dart';
import '../../../core/database/app_database.dart';
import '../database/notification_tables.dart';
import '../../credit_tracker/services/credit_service.dart';
import '../../credit_tracker/models/credit_models.dart';
import '../../dashboard/services/dashboard_service.dart';

class NotificationService {
  final AppDatabase _db = AppDatabase.instance;
  final _uuid = const Uuid();

  // --- CRUD OPERATIONS ---

  /// Get all notifications, sorted by newest first
  Stream<List<AppNotification>> getNotifications() {
    return (_db.select(_db.appNotifications)
          ..orderBy([
            (t) =>
                OrderingTerm(expression: t.createdAt, mode: OrderingMode.desc)
          ]))
        .watch();
  }

  /// Get count of unread notifications for the Badge
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

  // --- INTERNAL HELPER: Add Notification ---
  Future<void> _createNotification({
    required String type,
    required String title,
    required String message,
    String? payload,
  }) async {
    // Deduplication Logic with Null Safety
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

  // --- MASTER ENGINE: Run All Checks ---

  /// Call this Method in main.dart or Home Init
  Future<void> runStartupChecks() async {
    try {
      await _runCreditChecks();
      await _runBudgetChecks();
    } catch (e) {
      debugPrint("Notification Check Error: $e");
    }
  }

  // --- SUB-ENGINE 1: Credit Checks ---

  Future<void> _runCreditChecks() async {
    final creditService = GetIt.I<CreditService>();
    final cards = await creditService.getCreditCards().first;

    for (var card in cards) {
      await _checkStatementGenerated(card);
      await _checkDueDate(card);
      await _checkCreditUtilization(card);
    }
  }

  Future<void> _checkStatementGenerated(CreditCardModel card) async {
    final today = DateTime.now();
    if (card.billDate == today.day) {
      await _createNotification(
        type: 'statement',
        title: 'Statement Generated',
        message: 'Your bill for ${card.name} is generated today. Check amount.',
        payload: card.id,
      );
    }
  }

  Future<void> _checkDueDate(CreditCardModel card) async {
    final today = DateTime.now();
    int daysUntilDue = card.dueDate - today.day;

    if (card.dueDate == today.day) {
      await _createNotification(
        type: 'due_date',
        title: 'Payment Due Today!',
        message: 'Bill for ${card.name} is due today. Avoid late fees!',
        payload: card.id,
      );
    } else if (daysUntilDue == 3) {
      await _createNotification(
        type: 'due_date',
        title: 'Payment Due Soon',
        message: 'Bill for ${card.name} is due in 3 days.',
        payload: card.id,
      );
    }
  }

  Future<void> _checkCreditUtilization(CreditCardModel card) async {
    if (card.creditLimit <= 0) return;
    final utilization = (card.currentBalance / card.creditLimit) * 100;

    if (card.currentBalance > card.creditLimit) {
      await _createNotification(
        type: 'limit_exceeded',
        title: 'Credit Limit Exceeded!',
        message: 'You have exceeded the limit on ${card.name}!',
        payload: card.id,
      );
    } else if (utilization >= 90) {
      await _createNotification(
        type: 'high_util',
        title: 'High Utilization Alert',
        message:
            'You have used ${utilization.toStringAsFixed(1)}% of ${card.name}.',
        payload: card.id,
      );
    }
  }

  // --- SUB-ENGINE 2: Budget & Dashboard Checks ---

  Future<void> _runBudgetChecks() async {
    final dashboardService = GetIt.I<DashboardService>();
    final now = DateTime.now();

    // 1. Budget Not Set (For Current Month)
    final currentRecord =
        await dashboardService.getRecordForMonth(now.year, now.month);

    if (currentRecord == null) {
      // Only notify if it's the first few days of the month to avoid annoyance
      if (now.day <= 5) {
        await _createNotification(
          type: 'budget_not_set',
          title: 'Set Your Budget',
          message: 'Welcome to a new month! Plan your finances now.',
          payload: 'dashboard',
        );
      }
      return; // Cannot check spending if no budget exists
    }

    // 2. Budget Closure Pending (For Previous Month)
    // Calculate previous month logic
    final prevMonthDate = DateTime(now.year, now.month - 1);
    final prevRecord = await dashboardService.getRecordForMonth(
        prevMonthDate.year, prevMonthDate.month);

    if (prevRecord != null) {
      // Check if a settlement exists for that month
      final settlement = await (_db.select(_db.settlements)
            ..where((t) =>
                t.year.equals(prevMonthDate.year) &
                t.month.equals(prevMonthDate.month)))
          .getSingleOrNull();

      if (settlement == null) {
        await _createNotification(
          type: 'budget_closure_pending',
          title: 'Close Previous Budget',
          message: 'You haven\'t closed your budget for last month yet.',
          payload: 'settlement', // Logic to navigate to closure
        );
      }
    }

    // 3. Spending Health Checks (Bucket Overflow & Approaching Limit)
    // Get spending map
    final spendingMap = await dashboardService
        .getMonthlyBucketSpending(now.year, now.month)
        .first;

    double totalAllocated = 0;
    double totalSpent = 0;

    // Check individual buckets
    currentRecord.allocations.forEach((bucketName, allocated) {
      if (bucketName == 'Income') return; // Skip income

      totalAllocated += allocated;
      final spent = spendingMap[bucketName] ?? 0.0;
      totalSpent += spent;

      if (allocated > 0) {
        // SCENARIO: Bucket Overflow
        if (spent > allocated) {
          _createNotification(
            type: 'bucket_overflow',
            title: 'Budget Exceeded: $bucketName',
            message:
                'You exceeded your $bucketName budget by ${_formatCurrency(spent - allocated)}.',
            payload: bucketName,
          );
        }
        // SCENARIO: Approaching Limit (90%)
        // We add a check ensuring we haven't already overflowed (to avoid double notification)
        else if (spent >= (allocated * 0.9)) {
          _createNotification(
            type: 'budget_approaching',
            title: 'Approaching Limit: $bucketName',
            message: 'You have used 90% of your $bucketName budget.',
            payload: bucketName,
          );
        }
      }
    });

    // 4. Global Budget Overrun
    // Compare Total Effective Income vs Total Expenses (Global health)
    // Note: totalAllocated is budget, but 'EffectiveIncome' is the hard cap.
    if (currentRecord.effectiveIncome > 0 &&
        totalSpent > currentRecord.effectiveIncome) {
      await _createNotification(
        type: 'global_overrun',
        title: 'Critical: Income Exceeded',
        message:
            'Your total spending is higher than your income for this month!',
        payload: 'dashboard',
      );
    }
  }

  String _formatCurrency(double amount) {
    return '₹${amount.toStringAsFixed(0)}';
  }
}
