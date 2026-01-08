import 'package:flutter/material.dart';
import 'package:timezone/timezone.dart' as tz;
import '../services/notification_service.dart';
import '../services/notification_channels.dart';

class DailyLogisticsManager {
  static const int _notificationId = 1001;

  /// Schedules (or cancels) the daily reminder based on the toggle.
  Future<void> scheduleDailyReminder(TimeOfDay time, bool isEnabled) async {
    final service = NotificationService();

    // Always cancel existing to ensure fresh time/state
    await service.cancel(_notificationId);

    if (!isEnabled) return;

    final now = tz.TZDateTime.now(tz.local);

    // Create the scheduled date object
    var scheduledDate = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      time.hour,
      time.minute,
    );

    // If time has passed today, schedule for tomorrow
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    await service.scheduleNotification(
      id: _notificationId,
      title: 'Daily Ledger Sync',
      body: 'Financial vectors unaligned. Time to log today\'s activity.',
      scheduledDate: scheduledDate,
      channelId: NotificationChannels.dailyLogistics,
    );
  }
}
