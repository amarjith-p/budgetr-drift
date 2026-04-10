import 'package:flutter/foundation.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:budget/features/backup_restore/services/backup_service.dart';
import 'package:budget/features/recurring/services/recurring_service.dart';
import 'package:budget/features/notifications/services/notification_service.dart';
import 'package:budget/features/notifications/services/system_notification_service.dart';

class TaskSyncEngine {
  static final TaskSyncEngine _instance = TaskSyncEngine._internal();
  factory TaskSyncEngine() => _instance;
  TaskSyncEngine._internal();

  bool _isRunning = false;

  // Storage keys for our "Snooze" buttons
  static const String _lastBackupPromptKey = 'last_backup_prompt_time';
  static const String _lastNotifCheckKey = 'last_notif_logic_check';

  Future<void> runCatchUpTasks() async {
    if (_isRunning) return;
    _isRunning = true;

    try {
      final prefs = await SharedPreferences.getInstance();
      final now = DateTime.now();

      // 1. Check Recurring Payments (ALWAYS INSTANT - No timers)
      try {
        await GetIt.I<RecurringService>().processDuePayments();
      } catch (e) {
        debugPrint('TaskSyncEngine: Failed to trigger RecurringService: $e');
      }

      // 2. Check Notifications (Throttled: Only runs once every 15 minutes to save battery & prevent spam)
      final lastNotifMillis = prefs.getInt(_lastNotifCheckKey) ?? 0;
      final lastNotifTime =
          DateTime.fromMillisecondsSinceEpoch(lastNotifMillis);

      if (now.difference(lastNotifTime).inMinutes >= 15) {
        try {
          await GetIt.I<NotificationService>().runStartupChecks();
          await prefs.setInt(_lastNotifCheckKey, now.millisecondsSinceEpoch);
        } catch (e) {
          debugPrint("TaskSyncEngine: Notification Check Failed: $e");
        }
      }

      // 3. Check Backups (Strict 12-Hour Throttle)
      final lastBackupMillis = prefs.getInt(_lastBackupPromptKey) ?? 0;
      final lastBackupPrompt =
          DateTime.fromMillisecondsSinceEpoch(lastBackupMillis);

      if (now.difference(lastBackupPrompt).inHours >= 12) {
        try {
          final backupService = GetIt.I<BackupService>();
          if (await backupService.isBackupOverdue()) {
            final systemService = GetIt.I<SystemNotificationService>();
            await systemService.showBackupReminderNotification();

            // Only hit the "snooze" button if we actually showed the notification
            await prefs.setInt(
                _lastBackupPromptKey, now.millisecondsSinceEpoch);
          }
        } catch (e) {
          debugPrint('TaskSyncEngine: Failed to trigger BackupService: $e');
        }
      }
    } finally {
      _isRunning = false;
    }
  }
}
