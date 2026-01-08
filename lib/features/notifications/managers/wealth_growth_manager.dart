import 'package:timezone/timezone.dart' as tz;
import '../services/notification_service.dart';
import '../services/notification_channels.dart';

class WealthGrowthManager {
  // Uses ID range 3000-3099

  Future<void> scheduleWealthReminders(bool isEnabled) async {
    final service = NotificationService();
    const int netWorthId = 3001;
    const int sipId = 3002;

    // Clear previous schedules
    await service.cancel(netWorthId);
    await service.cancel(sipId);

    if (!isEnabled) return;

    // 1. Monthly Net Worth Review (Scheduled for 1st of next month at 10 AM)
    final netWorthDate = _getNextMonthStart();
    await service.scheduleNotification(
      id: netWorthId,
      title: 'Net Worth Review',
      body: 'A new month begins. Update your assets and liabilities.',
      scheduledDate: netWorthDate,
      channelId: NotificationChannels.wealthUpdates,
    );

    // 2. SIP/Investment Reminder (Scheduled for 5th of next month at 10 AM)
    final sipDate = _getNextMonthDay(5);
    await service.scheduleNotification(
      id: sipId,
      title: 'Investment Cycle',
      body: 'Execute planned SIPs and verify market positions.',
      scheduledDate: sipDate,
      channelId: NotificationChannels.wealthUpdates,
    );
  }

  tz.TZDateTime _getNextMonthStart() {
    final now = tz.TZDateTime.now(tz.local);
    // Schedule for the 1st day of the next month at 10:00 AM
    var date = tz.TZDateTime(tz.local, now.year, now.month + 1, 1, 10, 0);
    return date;
  }

  tz.TZDateTime _getNextMonthDay(int day) {
    final now = tz.TZDateTime.now(tz.local);
    // Schedule for specific day of THIS month
    var date = tz.TZDateTime(tz.local, now.year, now.month, day, 10, 0);

    // If that day has passed, move to next month
    if (date.isBefore(now)) {
      date = tz.TZDateTime(tz.local, now.year, now.month + 1, day, 10, 0);
    }
    return date;
  }
}
