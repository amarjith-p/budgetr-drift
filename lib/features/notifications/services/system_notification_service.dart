import 'dart:io'; // [NEW] Needed for Platform checks
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;

class SystemNotificationService {
  final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  bool _isInitialized = false;

  // Initialize the plugin & Request Permissions
  Future<void> init() async {
    if (_isInitialized) return;

    tz.initializeTimeZones();

    // Android Settings
    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    // iOS Settings
    // Note: We set these to false initially so we can request permissions
    // deliberately in the next step
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
        // Handle navigation here if needed
      },
    );

    // [NEW] Request Permissions Immediately on Launch
    await _requestPermissions();

    _isInitialized = true;
  }

  /// Handles Platform-specific permission requests
  Future<void> _requestPermissions() async {
    if (Platform.isAndroid) {
      final AndroidFlutterLocalNotificationsPlugin? androidImplementation =
          _notificationsPlugin.resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();

      if (androidImplementation != null) {
        // 1. Request Notification Permission (Android 13+)
        await androidImplementation.requestNotificationsPermission();

        // 2. Request Exact Alarms Permission (Android 12+)
        // Crucial for 'zonedSchedule' to work reliably for Future events
        await androidImplementation.requestExactAlarmsPermission();
      }
    } else if (Platform.isIOS) {
      // final DarwinFlutterLocalNotificationsPlugin? iOSImplementation =
      //     _notificationsPlugin.resolvePlatformSpecificImplementation<
      //         DarwinFlutterLocalNotificationsPlugin>();

      // if (iOSImplementation != null) {
      //   await iOSImplementation.requestPermissions(
      //     alert: true,
      //     badge: true,
      //     sound: true,
      //   );
      // }
    }
  }

  /// Show an instant notification (Mirroring In-App)
  Future<void> showInstantNotification({
    required int id,
    required String title,
    required String body,
    String? payload,
  }) async {
    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
      'budgetr_high_importance', // Channel ID
      'High Importance Notifications', // Channel Name
      channelDescription: 'Critical alerts for budget and spending',
      importance: Importance.max,
      priority: Priority.high,
      color: Color(0xFF0D1B2A),
    );

    const NotificationDetails details = NotificationDetails(
      android: androidDetails,
      iOS: DarwinNotificationDetails(presentSound: true),
    );

    await _notificationsPlugin.show(
      id,
      title,
      body,
      details,
      payload: payload,
    );
  }

  /// Schedule a notification for a future time (Works if App is Closed)
  Future<void> scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
    String? payload,
  }) async {
    // Don't schedule if date is in the past
    if (scheduledDate.isBefore(DateTime.now())) return;

    await _notificationsPlugin.zonedSchedule(
      id,
      title,
      body,
      tz.TZDateTime.from(scheduledDate, tz.local),
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'budgetr_scheduled',
          'Scheduled Reminders',
          channelDescription: 'Reminders for bills and loans',
          importance: Importance.high,
          priority: Priority.high,
          color: Color(0xFF0D1B2A),
        ),
        iOS: DarwinNotificationDetails(),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      payload: payload,
    );
  }

  /// Cancel a specific notification (e.g., if Loan is paid)
  Future<void> cancelNotification(int id) async {
    await _notificationsPlugin.cancel(id);
  }

  /// Cancel all to prevent stale alerts
  Future<void> cancelAll() async {
    await _notificationsPlugin.cancelAll();
  }
}
