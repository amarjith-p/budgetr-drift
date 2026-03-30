import 'package:drift/drift.dart';
import 'package:get_it/get_it.dart';
import 'package:flutter/foundation.dart';

import '../../../core/database/app_database.dart';
import '../database/notification_tables.dart';
import 'system_notification_service.dart';
import 'notification_check_logic.dart';

class NotificationService {
  final AppDatabase _db = AppDatabase.instance;

  SystemNotificationService get _systemService =>
      GetIt.I<SystemNotificationService>();

  late final NotificationCheckLogic _logic;

  NotificationService() {
    _logic = NotificationCheckLogic(_db, _systemService);
  }

  // --- CRUD OPERATIONS (For UI) ---
  Stream<List<AppNotification>> getNotifications() {
    return (_db.select(_db.appNotifications)
          // [NEW] Only show notifications where the trigger time has passed
          ..where((t) => t.createdAt.isSmallerOrEqualValue(DateTime.now()))
          ..orderBy([
            (t) =>
                OrderingTerm(expression: t.createdAt, mode: OrderingMode.desc)
          ]))
        .watch();
  }

  Stream<int> getUnreadCount() {
    return (_db.selectOnly(_db.appNotifications)
          ..addColumns([_db.appNotifications.id.count()])
          ..where(_db.appNotifications.isRead.equals(false))
          // [NEW] Do not count future/pending notifications
          ..where(_db.appNotifications.createdAt
              .isSmallerOrEqualValue(DateTime.now())))
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

  // --- CHECK RUNNER ---
  Future<void> runStartupChecks() async {
    try {
      await runLogicChecks();

      // [NEW] Write OS Scheduled alerts to the Local DB so you have a history!
      await _logic.syncScheduledToHistory();
    } catch (e) {
      debugPrint("Notification Check Error: $e");
    }
  }

  Future<void> runLogicChecks() async {
    await _logic.checkCreditHealth();
    await _logic.checkBudgetHealth();
    await _logic.checkDailyExpenseHealth();
    await _logic.checkInvestmentHealth();
    await _logic.checkGoalLoanState();
  }
}
