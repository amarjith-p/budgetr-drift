import 'package:flutter/foundation.dart';
import 'package:get_it/get_it.dart';
import 'system_notification_service.dart';

class GroupedNotificationHelper {
  /// Schedules grouped notifications for a specific module
  /// [baseId] unique starting ID for this module (e.g., 1500000 for Balance Sheet)
  /// [titlePrefix] is the title used for the notification
  /// [dailyMessages] Map of "YYYY-MM-DD" to a List of message strings
  /// [triggerDates] Map of "YYYY-MM-DD" to the exact DateTime to trigger
  /// [payload] is the tap payload
  static Future<void> scheduleBatchedNotifications({
    required int baseId,
    required String titlePrefix,
    required Map<String, List<String>> dailyMessages,
    required Map<String, DateTime> triggerDates,
    required String payload,
  }) async {
    try {
      final notifService = GetIt.I<SystemNotificationService>();

      // 1. Clear old pending notifications for this module's ID block (block of 100,000)
      // This ensures deleted/settled items are wiped automatically.
      final pending = await notifService.getPendingNotifications();
      for (var request in pending) {
        if (request.id >= baseId && request.id < baseId + 100000) {
          await notifService.cancelNotification(request.id);
        }
      }

      // 2. Schedule the new Batched Notifications
      for (var entry in dailyMessages.entries) {
        final dateKey = entry.key;
        final messages = entry.value;
        final tDate = triggerDates[dateKey]!;

        // Generate a deterministic ID based on the day (Unique per Day per Module)
        final id = baseId + tDate.difference(DateTime(2020, 1, 1)).inDays;

        String title = titlePrefix;
        String body = "";

        if (messages.length == 1) {
          // Single Item
          body = messages.first.replaceAll("• ", "");
        } else {
          // Inbox Style Grouping
          title = "${messages.length} $titlePrefix Alerts";
          body =
              "You have ${messages.length} items requiring attention today:\n${messages.join("\n")}";
        }

        await notifService.scheduleNotification(
          id: id,
          title: title,
          body: body,
          scheduledDate: tDate,
          payload: payload,
        );
      }
    } catch (e) {
      debugPrint("Error scheduling batched notifications: $e");
    }
  }

  /// Manually wipe a module's notifications if the user toggles it off
  static Future<void> clearBatchedNotifications(int baseId) async {
    try {
      final notifService = GetIt.I<SystemNotificationService>();
      final pending = await notifService.getPendingNotifications();
      for (var request in pending) {
        if (request.id >= baseId && request.id < baseId + 100000) {
          await notifService.cancelNotification(request.id);
        }
      }
    } catch (e) {
      debugPrint("Error clearing batched notifications: $e");
    }
  }
}
