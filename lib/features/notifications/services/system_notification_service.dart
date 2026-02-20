import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:permission_handler/permission_handler.dart';

class SystemNotificationService {
  final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  bool _isInitialized = false;

  Future<void> init() async {
    if (_isInitialized) return;

    tz.initializeTimeZones();

    try {
      final String timeZoneName = await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(timeZoneName));
    } catch (e) {
      debugPrint("Could not set local timezone: $e");
    }

    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings iosSettings =
        DarwinInitializationSettings(
      requestSoundPermission: false,
      requestBadgePermission: false,
      requestAlertPermission: false,
    );

    const InitializationSettings initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notificationsPlugin.initialize(
      initSettings,
      onDidReceiveNotificationResponse: (details) {
        debugPrint("Notification Clicked: ${details.payload}");
      },
    );

    _isInitialized = true;
  }

  Future<void> requestPermissions() async {
    if (Platform.isAndroid) {
      final AndroidFlutterLocalNotificationsPlugin? androidImplementation =
          _notificationsPlugin.resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();

      if (androidImplementation != null) {
        debugPrint("Requesting Notification Permission...");
        await androidImplementation.requestNotificationsPermission();

        debugPrint("Requesting Exact Alarms Permission...");
        await androidImplementation.requestExactAlarmsPermission();
      }

      debugPrint("Requesting Battery Optimization Whitelist...");
      if (await Permission.ignoreBatteryOptimizations.isDenied) {
        await Permission.ignoreBatteryOptimizations.request();
      }
    }
  }

  Future<void> showInstantNotification({
    required int id,
    required String title,
    required String body,
    String? payload,
  }) async {
    await _notificationsPlugin.show(
      id,
      title,
      body,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'budgetr_critical',
          'Critical Alerts',
          channelDescription: 'Immediate alerts for spending and balance',
          importance: Importance.max,
          priority: Priority.high,
          color: Color(0xFF0D1B2A),
        ),
        iOS: DarwinNotificationDetails(presentSound: true),
      ),
      payload: payload,
    );
  }

  Future<void> scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
    String? payload,
  }) async {
    if (scheduledDate.isBefore(DateTime.now())) return;

    // [NEW] Embed the exact ISO date into the payload for the UI to read later
    final String enhancedPayload =
        "${payload ?? ''}|DATE:${scheduledDate.toIso8601String()}";

    try {
      await _notificationsPlugin.zonedSchedule(
        id,
        title,
        body,
        tz.TZDateTime.from(scheduledDate, tz.local),
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'budgetr_scheduled_v2',
            'Scheduled Reminders',
            channelDescription: 'Reminders for bills and loans',
            importance: Importance.high,
            priority: Priority.high,
            color: Color(0xFF0D1B2A),
            enableVibration: true,
            playSound: true,
          ),
          iOS: DarwinNotificationDetails(
              presentSound: true, presentAlert: true, presentBadge: true),
        ),
        androidScheduleMode: AndroidScheduleMode.alarmClock,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        payload: enhancedPayload, // Use the new payload
      );
      debugPrint("Scheduled Notif ($id) for $scheduledDate");
    } catch (e) {
      debugPrint("Error Scheduling Notification: $e");
    }
  }

  Future<void> scheduleDailyNotification({
    required int id,
    required String title,
    required String body,
    required int hour,
    required int minute,
    String? payload,
  }) async {
    final now = tz.TZDateTime.now(tz.local);
    tz.TZDateTime scheduledDate =
        tz.TZDateTime(tz.local, now.year, now.month, now.day, hour, minute);

    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    // [NEW] Embed the repeat time info into the payload
    final String enhancedPayload = "${payload ?? ''}|REPEAT:$hour:$minute";

    try {
      await _notificationsPlugin.zonedSchedule(
        id,
        title,
        body,
        scheduledDate,
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'budgetr_daily_v3',
            'Daily Check-in',
            channelDescription: 'Daily generic reminders',
            importance: Importance.high,
            priority: Priority.high,
            color: Color(0xFF0D1B2A),
            enableVibration: true,
            playSound: true,
          ),
          iOS: DarwinNotificationDetails(
              presentSound: true, presentAlert: true, presentBadge: true),
        ),
        androidScheduleMode: AndroidScheduleMode.alarmClock,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.time,
        payload: enhancedPayload, // Use the new payload
      );
      debugPrint("Scheduled Daily Notif ($id) for $hour:$minute");
    } catch (e) {
      debugPrint("Error Scheduling Daily Notification: $e");
    }
  }

  Future<void> cancelNotification(int id) async {
    await _notificationsPlugin.cancel(id);
  }

  Future<void> cancelAll() async {
    await _notificationsPlugin.cancelAll();
  }

  Future<List<PendingNotificationRequest>> getPendingNotifications() async {
    return await _notificationsPlugin.pendingNotificationRequests();
  }
}
