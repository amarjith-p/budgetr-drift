import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/material.dart';

class NotificationChannels {
  // -- Channel IDs --
  static const String dailyLogistics = 'daily_logistics_v1';
  static const String creditAlerts = 'credit_alerts_v1';
  static const String wealthUpdates = 'wealth_updates_v1';
  static const String budgetBreach = 'budget_breach_v1';

  // -- Channel Definitions --
  static List<AndroidNotificationChannel> get channels => [
        const AndroidNotificationChannel(
          dailyLogistics,
          'Daily Logistics',
          description: 'Reminders to update daily financial logs',
          importance: Importance.max,
          playSound: true,
          enableVibration: true,
        ),
        const AndroidNotificationChannel(
          creditAlerts,
          'Credit & Debt',
          description: 'Statement generation and payment due date alerts',
          importance: Importance.high,
          playSound: true,
          ledColor: Colors.red,
        ),
        const AndroidNotificationChannel(
          wealthUpdates,
          'Wealth Growth',
          description: 'Reminders for SIPs and Net Worth updates',
          importance: Importance.defaultImportance,
          playSound: true,
        ),
        const AndroidNotificationChannel(
          budgetBreach,
          'Budget Guardian',
          description: 'Immediate alerts when spending limits are crossed',
          importance: Importance.max,
          playSound: true,
          enableVibration: true,
        ),
      ];
}
