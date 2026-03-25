import 'package:flutter/foundation.dart';
import 'package:get_it/get_it.dart';
import '../models/balance_sheet_model.dart';
import '../../notifications/services/system_notification_service.dart';
import '../../settings/services/settings_service.dart';

class BalanceSheetNotificationScheduler {
  // We reserve a unique block of IDs strictly for the Balance Sheet to avoid
  // overriding generic daily reminders or credit card alerts.
  final int _baseId = 1500000;

  Future<void> syncNotifications(List<BalanceSheetModel> allEntries) async {
    try {
      final notifService = GetIt.I<SystemNotificationService>();
      final settingsService = GetIt.I<SettingsService>();

      // 1. Get Preferred Time (Format: "HH:MM")
      final timeStr = await settingsService.getBalanceSheetReminderTime();
      final parts = timeStr.split(':');
      final hour = int.tryParse(parts[0]) ?? 9;
      final minute = int.tryParse(parts[1]) ?? 0;

      // 2. Clear ALL existing Balance Sheet notifications before rescheduling
      // This ensures if an item was settled or deleted, its alarm is wiped.
      final pending = await notifService.getPendingNotifications();
      for (var request in pending) {
        if (request.id >= _baseId && request.id < _baseId + 100000) {
          await notifService.cancelNotification(request.id);
        }
      }

      // 3. Filter only active (Unsettled) entries that have a Due Date
      final activeEntries =
          allEntries.where((e) => !e.isSettled && e.dueDate != null).toList();

      // 4. Group by Date to Prevent Notification Collision/Spam
      // Key: YYYY-MM-DD, Value: List of Messages for that specific day
      Map<String, List<String>> dailyMessages = {};
      Map<String, DateTime> triggerDates = {};

      final now = DateTime.now();

      for (var entry in activeEntries) {
        final dueDate = entry.dueDate!;

        // Calculate the 3 Lifecycle Triggers
        final triggers = [
          _applyTime(dueDate.subtract(const Duration(days: 1)), hour,
              minute), // 1 Day Before
          _applyTime(dueDate, hour, minute), // On Due Date
          _applyTime(dueDate.add(const Duration(days: 1)), hour,
              minute), // 1 Day Overdue
        ];

        for (int i = 0; i < triggers.length; i++) {
          final tDate = triggers[i];

          // Only schedule if the trigger is in the future
          if (tDate.isAfter(now)) {
            final dateKey =
                "${tDate.year}-${tDate.month.toString().padLeft(2, '0')}-${tDate.day.toString().padLeft(2, '0')}";

            triggerDates[dateKey] = tDate;
            dailyMessages.putIfAbsent(dateKey, () => []);

            String typeStr =
                entry.entryType == 'ASSET' ? 'Receivable' : 'Payable';
            String stateStr =
                i == 0 ? 'due tomorrow' : (i == 1 ? 'due today' : 'overdue');

            dailyMessages[dateKey]!
                .add("• ${entry.title} ($typeStr) is $stateStr.");
          }
        }
      }

      // 5. Schedule the Batched Notifications
      for (var entry in dailyMessages.entries) {
        final dateKey = entry.key;
        final messages = entry.value;
        final tDate = triggerDates[dateKey]!;

        // Generate a deterministic ID based on the day (Unique per Day)
        final id = _baseId + tDate.difference(DateTime(2020, 1, 1)).inDays;

        String title = "Balance Sheet Reminder";
        String body = "";

        if (messages.length == 1) {
          // Single Item
          body = messages.first
              .replaceAll("• ", ""); // Remove bullet for single item
        } else {
          // Inbox Style Grouping
          title = "${messages.length} Pending Actions";
          body =
              "You have ${messages.length} items requiring attention today:\n${messages.join("\n")}";
        }

        await notifService.scheduleNotification(
          id: id,
          title: title,
          body: body,
          scheduledDate: tDate,
          payload: "BALANCE_SHEET_SYNC",
        );
      }
    } catch (e) {
      debugPrint("Error syncing balance sheet notifications: $e");
    }
  }

  // Helper to attach user's preferred Hour/Minute to a Date
  DateTime _applyTime(DateTime date, int hour, int minute) {
    return DateTime(date.year, date.month, date.day, hour, minute);
  }
}
