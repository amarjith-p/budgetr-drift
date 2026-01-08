import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart'; // Import this
import 'package:timezone/timezone.dart' as tz;
import '../services/notification_service.dart';
import '../services/notification_channels.dart';

class DailyLogisticsManager {
  static const int _notificationId = 1001;

  static final List<Map<String, String>> _messages = [
    {
      'title': 'Daily Ledger Sync',
      'body': 'Financial vectors unaligned. Time to log today\'s activity.',
    },
    {
      'title': 'Keep the Streak!',
      'body': 'Don\'t let your budget drift. Record your expenses now.',
    },
    {
      'title': 'Where did the money go?',
      'body': 'Track it before you forget it! Log your daily spend.',
    },
    {
      'title': 'Budget Check-in',
      'body': 'A minute of tracking saves hours of wondering. Update now.',
    },
    {
      'title': 'Stay on Top',
      'body': 'Your financial goals are waiting. Log today\'s transactions.',
    },
    {
      'title': 'Wallet Watch',
      'body': 'Did you spend anything today? Note it down quickly.',
    },
    {
      'title': 'Financial Mindfulness',
      'body': 'Take a moment to reflect on today\'s spending.',
    },
  ];

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

    // Pick a random message from the list
    // Note: Since we use 'DateTimeComponents.time', this specific title/body
    // will repeat every day until the user toggles the setting again.
    final random = Random();
    final selectedMessage = _messages[random.nextInt(_messages.length)];

    await service.scheduleNotification(
      id: _notificationId,
      title: selectedMessage['title']!,
      body: selectedMessage['body']!,
      scheduledDate: scheduledDate,
      channelId: NotificationChannels.dailyLogistics,
      // FIX: Ensure it repeats daily at the specified time
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }
}
