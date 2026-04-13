import 'package:workmanager/workmanager.dart';
import 'package:flutter/material.dart';
import '../../../core/database/app_database.dart';
import 'notification_check_logic.dart';
import 'system_notification_service.dart';
import '../../backup_restore/services/backup_service.dart';

const String kBackgroundCheckTask = "com.budgetr.background_check";

@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    try {
      // 1. Initialize Bindings
      WidgetsFlutterBinding.ensureInitialized();

      // 2. Initialize Database (Headless)
      final db = AppDatabase.instance;

      // 3. Initialize Notification Service
      final systemService = SystemNotificationService();
      await systemService.init();

      // 4. Run FULL Logic Suite
      final logic = NotificationCheckLogic(db, systemService);

      await logic.checkCreditHealth();
      await logic.checkBudgetHealth();
      await logic.checkDailyExpenseHealth();
      await logic.checkInvestmentHealth();
      await logic.checkGoalLoanState();

      // 5. Background Backup Overdue Check
      final backupService = BackupService();
      final isOverdue = await backupService.isBackupOverdue();

      if (isOverdue) {
        await systemService.showBackupReminderNotification();
      }

      // Note: Closed-app Ghost Transactions are safely handled via
      // the Telephony Headless Background Service in ghost_listener_service.dart

      return Future.value(true);
    } catch (e) {
      debugPrint("Background Worker Error: $e");
      return Future.value(false);
    }
  });
}
