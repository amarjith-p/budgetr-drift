import 'dart:io';
import 'package:drift/drift.dart'; // [NEW] Added for Value and InsertMode
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../../core/database/app_database.dart'; // [NEW] Added for Database Insert

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
      NotificationDetails(
        android: AndroidNotificationDetails(
          'budgetr_critical',
          'Critical Alerts',
          channelDescription: 'Immediate alerts for spending and balance',
          importance: Importance.max,
          priority: Priority.high,
          color: const Color(0xFF0D1B2A),
          // [FIX] Enables Expandable Text
          styleInformation: BigTextStyleInformation(body),
        ),
        iOS: const DarwinNotificationDetails(presentSound: true),
      ),
      payload: payload,
    );
  }

  // -------------------------------------------------------------
  // [NEW] Background Backup Reminder Notification
  // -------------------------------------------------------------
  Future<void> showBackupReminderNotification() async {
    const String bodyText =
        'It has been over 12 hours since your last backup. Please open FinStack 360 to secure your data.';

    final androidDetails = AndroidNotificationDetails(
      'backup_alerts_channel_v1',
      'Backup Alerts',
      channelDescription:
          'Notifications reminding you to backup your financial data',
      importance: Importance.high,
      priority: Priority.high,
      color: const Color(0xFF0D1B2A), // Matches your app's theme
      styleInformation: const BigTextStyleInformation(bodyText),
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    await _notificationsPlugin.show(
      8888, // Unique ID for Backup Notifications
      'Data Backup Overdue! ⚠️',
      bodyText,
      NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      ),
    );
  }
  // -------------------------------------------------------------

  Future<void> scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
    String? payload,
  }) async {
    if (scheduledDate.isBefore(DateTime.now())) return;

    final String enhancedPayload =
        "${payload ?? ''}|DATE:${scheduledDate.toIso8601String()}";

    try {
      await _notificationsPlugin.zonedSchedule(
        id,
        title,
        body,
        tz.TZDateTime.from(scheduledDate, tz.local),
        NotificationDetails(
          android: AndroidNotificationDetails(
            'budgetr_scheduled_v2',
            'Scheduled Reminders',
            channelDescription: 'Reminders for bills and loans',
            importance: Importance.high,
            priority: Priority.high,
            color: const Color(0xFF0D1B2A),
            enableVibration: true,
            playSound: true,
            // [FIX] Enables Expandable Text
            styleInformation: BigTextStyleInformation(body),
          ),
          iOS: const DarwinNotificationDetails(
              presentSound: true, presentAlert: true, presentBadge: true),
        ),
        androidScheduleMode: AndroidScheduleMode.alarmClock,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        payload: enhancedPayload,
      );

      // --- [NEW] PRE-INSERT INTO LOCAL DATABASE ---
      try {
        final db = AppDatabase.instance;
        await db.into(db.appNotifications).insert(
              AppNotificationsCompanion.insert(
                id: 'sched_${id}_${scheduledDate.millisecondsSinceEpoch}',
                type: 'scheduled_alert',
                title: title,
                message: body,
                payload: Value(payload),
                isRead: const Value(false),
                createdAt: scheduledDate, // Set to the FUTURE trigger date
              ),
              mode: InsertMode.insertOrReplace, // Prevents duplicate crashes
            );
      } catch (dbError) {
        debugPrint("Error saving scheduled notification to DB: $dbError");
      }
      // ------------------------------------------

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

    final String enhancedPayload = "${payload ?? ''}|REPEAT:$hour:$minute";

    try {
      await _notificationsPlugin.zonedSchedule(
        id,
        title,
        body,
        scheduledDate,
        NotificationDetails(
          android: AndroidNotificationDetails(
            'budgetr_daily_v3',
            'Daily Check-in',
            channelDescription: 'Daily generic reminders',
            importance: Importance.high,
            priority: Priority.high,
            color: const Color(0xFF0D1B2A),
            enableVibration: true,
            playSound: true,
            // [FIX] Enables Expandable Text
            styleInformation: BigTextStyleInformation(body),
          ),
          iOS: const DarwinNotificationDetails(
              presentSound: true, presentAlert: true, presentBadge: true),
        ),
        androidScheduleMode: AndroidScheduleMode.alarmClock,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.time,
        payload: enhancedPayload,
      );

      // --- [NEW] PRE-INSERT DAILY TO LOCAL DATABASE ---
      try {
        final db = AppDatabase.instance;
        await db.into(db.appNotifications).insert(
              AppNotificationsCompanion.insert(
                id: 'daily_${id}_${scheduledDate.millisecondsSinceEpoch}',
                type: 'daily_reminder',
                title: title,
                message: body,
                payload: Value(payload),
                isRead: const Value(false),
                createdAt: scheduledDate, // Set to FUTURE trigger date
              ),
              mode: InsertMode.insertOrReplace,
            );
      } catch (dbError) {
        debugPrint("Error saving daily notification to DB: $dbError");
      }
      // ----------------------------------------------

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

    // --- [NEW] PURGE ORPHANED FUTURE NOTIFICATIONS ---
    // Wipe pending future DB rows so the UI doesn't show canceled alerts.
    try {
      final db = AppDatabase.instance;
      await (db.delete(db.appNotifications)
            ..where((t) => t.createdAt.isBiggerThanValue(DateTime.now())))
          .go();
    } catch (e) {
      debugPrint("Error purging future notifications: $e");
    }
    // -------------------------------------------------
  }

  Future<List<PendingNotificationRequest>> getPendingNotifications() async {
    return await _notificationsPlugin.pendingNotificationRequests();
  }
}
