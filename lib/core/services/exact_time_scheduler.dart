import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;

/// A standalone service to schedule exact-minute local notifications
/// bypassing Android Doze mode completely.
class ExactTimeScheduler {
  static final ExactTimeScheduler _instance = ExactTimeScheduler._internal();
  factory ExactTimeScheduler() => _instance;
  ExactTimeScheduler._internal();

  final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  /// Schedules a notification for an exact future time.
  /// Call this when a user creates a new recurring payment.
  Future<void> scheduleExactNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
  }) async {
    // Convert to timezone-aware date
    final tz.TZDateTime scheduledTzDate =
        tz.TZDateTime.from(scheduledDate, tz.local);

    // Do not schedule if the time has already passed
    if (scheduledTzDate.isBefore(tz.TZDateTime.now(tz.local))) return;

    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
      'exact_time_channel', // id
      'Scheduled Alerts', // title
      channelDescription: 'Perfectly timed alerts for payments and backups',
      importance: Importance.max,
      priority: Priority.high,
      // This is crucial: it tells the OS to wake the screen/device
      fullScreenIntent: true,
    );

    const NotificationDetails platformDetails = NotificationDetails(
      android: androidDetails,
      iOS: DarwinNotificationDetails(),
    );

    await _notificationsPlugin.zonedSchedule(
      id,
      title,
      body,
      scheduledTzDate,
      platformDetails,
      androidScheduleMode:
          AndroidScheduleMode.exactAllowWhileIdle, // Bypasses Doze
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  /// Cancels an exact notification if the user deletes the recurring payment
  Future<void> cancelScheduledNotification(int id) async {
    await _notificationsPlugin.cancel(id);
  }
}
