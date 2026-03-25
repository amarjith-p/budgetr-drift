import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/database/app_database.dart'; // Drift Database
import '../../notifications/services/grouped_notification_helper.dart';

class GoalsLoansNotificationScheduler {
  // Unique block for Goals & Loans to avoid overlapping with other modules
  static const int _baseId = 1700000;

  static const String kPrefLoanGoalEnabled = 'notif_enable_loangoal';
  static const String kPrefLoanGoalTime = 'notif_time_loangoal';

  Future<void> syncNotifications(List<Loan> loans, List<Goal> goals) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final isEnabled = prefs.getBool(kPrefLoanGoalEnabled) ?? true;

      // If user disabled the module, clear OS alarms for it
      if (!isEnabled || (loans.isEmpty && goals.isEmpty)) {
        await GroupedNotificationHelper.clearBatchedNotifications(_baseId);
        return;
      }

      final timeStr = prefs.getString(kPrefLoanGoalTime) ?? "09:00";
      final parts = timeStr.split(':');
      final hour = int.tryParse(parts[0]) ?? 9;
      final minute = int.tryParse(parts[1]) ?? 0;

      Map<String, List<String>> dailyMessages = {};
      Map<String, DateTime> triggerDates = {};
      final now = DateTime.now();

      // --- PROCESS LOANS ---
      for (var loan in loans) {
        final remaining = loan.totalAmount - loan.paidAmount;
        if (remaining <= 0 || loan.isClosed) continue;

        final int emiDay = loan.nextPaymentDate?.day ?? loan.startDate.day;
        DateTime nextEmiDate = _getValidDate(now.year, now.month, emiDay);

        if (nextEmiDate.isBefore(DateTime(now.year, now.month, now.day))) {
          nextEmiDate = _getValidDate(now.year, now.month + 1, emiDay);
        }

        if (loan.dueDate != null && nextEmiDate.isAfter(loan.dueDate!))
          continue;

        final dueTodayTrigger = _applyTime(nextEmiDate, hour, minute);
        final due1DayTrigger =
            dueTodayTrigger.subtract(const Duration(days: 1));
        final due3DaysTrigger =
            dueTodayTrigger.subtract(const Duration(days: 3));

        _addTrigger(dueTodayTrigger, now, '• EMI due TODAY for ${loan.title}',
            dailyMessages, triggerDates);
        _addTrigger(due1DayTrigger, now, '• EMI due Tomorrow for ${loan.title}',
            dailyMessages, triggerDates);
        _addTrigger(
            due3DaysTrigger,
            now,
            '• EMI due in 3 Days for ${loan.title}',
            dailyMessages,
            triggerDates);
      }

      // --- PROCESS GOALS ---
      for (var goal in goals) {
        if (goal.isCompleted || goal.deadline == null) continue;

        final dead = goal.deadline!;
        final dueTodayTrigger = _applyTime(dead, hour, minute);
        final due1DayTrigger =
            dueTodayTrigger.subtract(const Duration(days: 1));
        final due7DaysTrigger =
            dueTodayTrigger.subtract(const Duration(days: 7));

        _addTrigger(dueTodayTrigger, now, '• Deadline Reached: ${goal.name}',
            dailyMessages, triggerDates);
        _addTrigger(due1DayTrigger, now, '• Deadline Tomorrow: ${goal.name}',
            dailyMessages, triggerDates);
        _addTrigger(
            due7DaysTrigger,
            now,
            '• 1 Week left for Goal: ${goal.name}',
            dailyMessages,
            triggerDates);
      }

      // Hand off to the global batch engine
      await GroupedNotificationHelper.scheduleBatchedNotifications(
        baseId: _baseId,
        titlePrefix: "Goals & Loans",
        dailyMessages: dailyMessages,
        triggerDates: triggerDates,
        payload: "GOAL_LOAN_SYNC",
      );
    } catch (e) {
      debugPrint("Error syncing batched Goals/Loans notifications: $e");
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
