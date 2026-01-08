// import 'package:flutter_local_notifications/flutter_local_notifications.dart';
// import 'package:timezone/timezone.dart' as tz;
// import 'package:timezone/data/latest.dart' as tz;
// import 'package:flutter_timezone/flutter_timezone.dart'; // Ensure this package is installed
// import 'package:flutter/material.dart';
// import 'dart:io' show Platform;

// class NotificationService {
//   static final NotificationService _instance = NotificationService._internal();
//   factory NotificationService() => _instance;
//   NotificationService._internal();

//   final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
//       FlutterLocalNotificationsPlugin();

//   Future<void> init() async {
//     tz.initializeTimeZones();

//     // 1. Correctly set the Timezone (Critical for accurate alarms)
//     try {
//       final String timeZoneName = await FlutterTimezone.getLocalTimezone();
//       tz.setLocalLocation(tz.getLocation(timeZoneName));
//       print("✅ Timezone Set to: $timeZoneName");
//     } catch (e) {
//       print("⚠️ Timezone Error: $e");
//       tz.setLocalLocation(tz.getLocation('UTC'));
//     }

//     const AndroidInitializationSettings initializationSettingsAndroid =
//         AndroidInitializationSettings('@mipmap/ic_launcher');

//     const DarwinInitializationSettings initializationSettingsDarwin =
//         DarwinInitializationSettings(
//       requestSoundPermission: false,
//       requestBadgePermission: false,
//       requestAlertPermission: false,
//     );

//     const InitializationSettings initializationSettings =
//         InitializationSettings(
//       android: initializationSettingsAndroid,
//       iOS: initializationSettingsDarwin,
//       macOS: initializationSettingsDarwin,
//     );

//     await flutterLocalNotificationsPlugin.initialize(
//       initializationSettings,
//       onDidReceiveNotificationResponse: (details) {
//         print("🔔 Notification Clicked: ${details.payload}");
//       },
//     );
//   }

//   Future<bool> requestPermissions() async {
//     bool? result = false;
//     if (Platform.isAndroid) {
//       final androidImplementation =
//           flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<
//               AndroidFlutterLocalNotificationsPlugin>();

//       final bool? notificationsGranted =
//           await androidImplementation?.requestNotificationsPermission();

//       // This will now correctly open the "Alarms & Reminders" settings page
//       await androidImplementation?.requestExactAlarmsPermission();

//       result = notificationsGranted;
//     } else if (Platform.isIOS || Platform.isMacOS) {
//       result = true;
//     }
//     return result ?? false;
//   }

//   Future<void> showImmediateNotification() async {
//     const AndroidNotificationDetails androidDetails =
//         AndroidNotificationDetails(
//       'test_channel_v1',
//       'Test Channel',
//       importance: Importance.max,
//       priority: Priority.high,
//     );
//     const NotificationDetails details = NotificationDetails(
//       android: androidDetails,
//       iOS: DarwinNotificationDetails(),
//     );
//     await flutterLocalNotificationsPlugin.show(
//         999, 'Test Success!', 'Notifications are working.', details);
//   }

//   Future<void> scheduleDailyReminder(
//       {required TimeOfDay time, bool isActive = true}) async {
//     await flutterLocalNotificationsPlugin.cancel(1);

//     if (!isActive) return;

//     final scheduledTime = _nextInstanceOfTime(time);
//     print("⏰ Scheduling for: $scheduledTime");

//     await flutterLocalNotificationsPlugin.zonedSchedule(
//       1,
//       'System Sync Required',
//       'Financial vectors unaligned. Synchronization required.',
//       scheduledTime,
//       const NotificationDetails(
//         android: AndroidNotificationDetails(
//           'daily_reminders_final', // New ID
//           'Daily Logistics',
//           channelDescription: 'Reminders to update daily financial logs',
//           importance: Importance.max,
//           priority: Priority.high,
//           color: Color(0xFF3A86FF),
//         ),
//         iOS: DarwinNotificationDetails(),
//       ),
//       uiLocalNotificationDateInterpretation:
//           UILocalNotificationDateInterpretation.absoluteTime,
//       androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
//       matchDateTimeComponents: DateTimeComponents.time,
//     );
//   }

//   tz.TZDateTime _nextInstanceOfTime(TimeOfDay time) {
//     final now = tz.TZDateTime.now(tz.local);
//     tz.TZDateTime scheduledDate = tz.TZDateTime(
//       tz.local,
//       now.year,
//       now.month,
//       now.day,
//       time.hour,
//       time.minute,
//     );
//     if (scheduledDate.isBefore(now)) {
//       scheduledDate = scheduledDate.add(const Duration(days: 1));
//     }
//     return scheduledDate;
//   }
// }
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import 'package:flutter_timezone/flutter_timezone.dart';
import 'dart:io' show Platform;
import 'notification_channels.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  bool _isInitialized = false;

  Future<void> init() async {
    if (_isInitialized) return;

    tz.initializeTimeZones();

    // 1. Setup Timezone
    try {
      final String timeZoneName = await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(timeZoneName));
    } catch (e) {
      print("⚠️ Timezone Error: $e");
      tz.setLocalLocation(tz.getLocation('UTC'));
    }

    // 2. Create Channels (Android)
    final androidImplementation =
        _flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();

    if (androidImplementation != null) {
      for (var channel in NotificationChannels.channels) {
        await androidImplementation.createNotificationChannel(channel);
      }
    }

    // 3. Initialization Settings
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings initializationSettingsDarwin =
        DarwinInitializationSettings(
      requestSoundPermission: false,
      requestBadgePermission: false,
      requestAlertPermission: false,
    );

    const InitializationSettings initializationSettings =
        InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsDarwin,
      macOS: initializationSettingsDarwin,
    );

    await _flutterLocalNotificationsPlugin.initialize(initializationSettings);
    _isInitialized = true;
    print("✅ Notification System Initialized");
  }

  Future<bool> requestPermissions() async {
    if (Platform.isAndroid) {
      final androidImplementation = _flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();

      final bool? notificationsGranted =
          await androidImplementation?.requestNotificationsPermission();

      await androidImplementation?.requestExactAlarmsPermission();

      return notificationsGranted ?? false;
    } else if (Platform.isIOS || Platform.isMacOS) {
      final iosImplementation = _flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin>();

      final bool? result = await iosImplementation?.requestPermissions(
        alert: true,
        badge: true,
        sound: true,
      );
      return result ?? false;
    }
    return false;
  }

  // -- Core Scheduling Methods --

  Future<void> scheduleNotification({
    required int id,
    required String title,
    required String body,
    required tz.TZDateTime scheduledDate,
    required String channelId,
  }) async {
    await _flutterLocalNotificationsPlugin.zonedSchedule(
      id,
      title,
      body,
      scheduledDate,
      NotificationDetails(
        android: AndroidNotificationDetails(
          channelId,
          _getChannelName(channelId),
          channelDescription: _getChannelDesc(channelId),
          // FIX: Add BigTextStyleInformation to allow expandable text
          styleInformation: BigTextStyleInformation(body),
        ),
        iOS: const DarwinNotificationDetails(),
      ),
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.dayOfMonthAndTime,
    );
    print("⏰ Scheduled ID: $id for $scheduledDate");
  }

  Future<void> showImmediate({
    required int id,
    required String title,
    required String body,
    required String channelId,
  }) async {
    await _flutterLocalNotificationsPlugin.show(
      id,
      title,
      body,
      NotificationDetails(
        android: AndroidNotificationDetails(
          channelId,
          _getChannelName(channelId),
          importance: Importance.max,
          priority: Priority.high,
          // FIX: Add BigTextStyleInformation to allow expandable text
          styleInformation: BigTextStyleInformation(body),
        ),
        iOS: const DarwinNotificationDetails(),
      ),
    );
  }

  Future<void> cancel(int id) async {
    await _flutterLocalNotificationsPlugin.cancel(id);
  }

  Future<void> cancelAll() async {
    await _flutterLocalNotificationsPlugin.cancelAll();
  }

  // Helpers to get details from the central channel registry
  String _getChannelName(String id) {
    return NotificationChannels.channels
        .firstWhere((c) => c.id == id,
            orElse: () => NotificationChannels.channels[0])
        .name;
  }

  String _getChannelDesc(String id) {
    return NotificationChannels.channels
            .firstWhere((c) => c.id == id,
                orElse: () => NotificationChannels.channels[0])
            .description ??
        '';
  }
}
