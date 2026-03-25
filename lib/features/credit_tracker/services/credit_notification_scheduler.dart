import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/database/app_database.dart'; // Drift Database
import '../../notifications/services/grouped_notification_helper.dart';

class CreditNotificationScheduler {
  // Unique block for Credit Cards to avoid overlapping with Balance Sheet or Loans
  static const int _baseId = 1600000;

  static const String kPrefCreditEnabled = 'notif_enable_credit';
  static const String kPrefCreditTime = 'notif_time_credit';

  Future<void> syncNotifications(List<CreditCard> cards) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final isEnabled = prefs.getBool(kPrefCreditEnabled) ?? true;

      // If user disabled the module, aggressively clear all OS alarms for it
      if (!isEnabled || cards.isEmpty) {
        await GroupedNotificationHelper.clearBatchedNotifications(_baseId);
        return;
      }

      final timeStr = prefs.getString(kPrefCreditTime) ?? "10:00";
      final parts = timeStr.split(':');
      final hour = int.tryParse(parts[0]) ?? 10;
      final minute = int.tryParse(parts[1]) ?? 0;

      Map<String, List<String>> dailyMessages = {};
      Map<String, DateTime> triggerDates = {};
      final now = DateTime.now();

      for (var card in cards) {
        // Calculate Next Bill Date
        DateTime nextBillDate =
            _getValidDate(now.year, now.month, card.billDate);
        if (nextBillDate.isBefore(DateTime(now.year, now.month, now.day))) {
          nextBillDate = _getValidDate(now.year, now.month + 1, card.billDate);
        }

        // Calculate Next Due Date
        DateTime nextDueDate = _getValidDate(now.year, now.month, card.dueDate);
        if (nextDueDate.isBefore(DateTime(now.year, now.month, now.day))) {
          nextDueDate = _getValidDate(now.year, now.month + 1, card.dueDate);
        }

        // Apply Time Preferences
        final billTrigger = _applyTime(nextBillDate, hour, minute);
        final dueTodayTrigger = _applyTime(nextDueDate, hour, minute);
        final due1DayTrigger =
            dueTodayTrigger.subtract(const Duration(days: 1));
        final due3DaysTrigger =
            dueTodayTrigger.subtract(const Duration(days: 3));

        // Inject into batch
        _addTrigger(
            billTrigger,
            now,
            '• Statement generated for ${card.bankName} - ${card.name}',
            dailyMessages,
            triggerDates);
        _addTrigger(
            dueTodayTrigger,
            now,
            '• Bill due TODAY for ${card.bankName} - ${card.name}',
            dailyMessages,
            triggerDates);
        _addTrigger(
            due1DayTrigger,
            now,
            '• Bill due Tomorrow for ${card.bankName} - ${card.name}',
            dailyMessages,
            triggerDates);
        _addTrigger(
            due3DaysTrigger,
            now,
            '• Bill due in 3 Days for ${card.bankName} - ${card.name}',
            dailyMessages,
            triggerDates);
      }

      // Hand off to the global batch engine
      await GroupedNotificationHelper.scheduleBatchedNotifications(
        baseId: _baseId,
        titlePrefix: "Credit Card",
        dailyMessages: dailyMessages,
        triggerDates: triggerDates,
        payload: "CREDIT_TRACKER_SYNC",
      );
    } catch (e) {
      debugPrint("Error syncing batched credit notifications: $e");
    }
  }

  // Safe clamping to prevent February 31st crashes
  DateTime _getValidDate(int year, int month, int day) {
    final daysInMonth = DateTime(year, month + 1, 0).day;
    final clampedDay = (day > daysInMonth) ? daysInMonth : day;
    return DateTime(year, month, clampedDay);
  }

  DateTime _applyTime(DateTime date, int hour, int minute) {
    return DateTime(date.year, date.month, date.day, hour, minute);
  }

  void _addTrigger(DateTime triggerDate, DateTime now, String message,
      Map<String, List<String>> messagesMap, Map<String, DateTime> datesMap) {
    if (triggerDate.isAfter(now)) {
      final dateKey =
          "${triggerDate.year}-${triggerDate.month.toString().padLeft(2, '0')}-${triggerDate.day.toString().padLeft(2, '0')}";
      datesMap[dateKey] = triggerDate;
      messagesMap.putIfAbsent(dateKey, () => []);
      messagesMap[dateKey]!.add(message);
    }
  }
}
