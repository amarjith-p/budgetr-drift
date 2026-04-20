import 'package:budget/core/database/app_database.dart';
import 'package:get_it/get_it.dart';
import 'package:drift/drift.dart';
import '../../notifications/services/system_notification_service.dart';
import '../models/reminder_dto.dart';
import '../database/reminders_table.dart';

class ReminderService {
  final AppDatabase _db = GetIt.I<AppDatabase>();
  final SystemNotificationService _notifService =
      GetIt.I<SystemNotificationService>();

  // We add an offset to the Reminder IDs so they don't clash with recurring/daily notif IDs
  static const int _notifOffset = 90000;

  Stream<List<ReminderEntry>> watchActiveReminders() {
    final now = DateTime.now();
    return (_db.select(_db.remindersTable)
          ..orderBy([
            // 1. Sort by Status: Active (False/0) first, Expired (True/1) last
            (t) => OrderingTerm(
                expression: t.targetDate.isSmallerThanValue(now),
                mode: OrderingMode.asc),
            // 2. Sort by proximity to the current time
            (t) =>
                OrderingTerm(expression: t.targetDate, mode: OrderingMode.asc)
          ]))
        .watch();
  }

  Future<void> addReminder(ReminderModel reminder) async {
    final id = await _db.into(_db.remindersTable).insert(
          RemindersTableCompanion.insert(
            title: reminder.title,
            notes: Value(reminder.notes),
            targetDate: reminder.targetDate,
            isNotificationEnabled: Value(reminder.isNotificationEnabled),
          ),
        );

    if (reminder.isNotificationEnabled &&
        reminder.targetDate.isAfter(DateTime.now())) {
      // Utilizing your existing robust notification service to bypass Doze Mode
      await _notifService.scheduleNotification(
        id: id + _notifOffset,
        title: reminder.title,
        body: reminder.notes ?? 'You have a scheduled reminder.',
        scheduledDate: reminder.targetDate,
        payload: 'REMINDER_$id',
      );
    }
  }

  Future<void> updateReminder(
      ReminderEntry existing, ReminderModel newReminder) async {
    // 1. Cancel the old scheduled notification
    await _notifService.cancelNotification(existing.id + _notifOffset);

    // 2. Update the database record
    await (_db.update(_db.remindersTable)
          ..where((t) => t.id.equals(existing.id)))
        .write(
      RemindersTableCompanion(
        title: Value(newReminder.title),
        notes: Value(newReminder.notes),
        targetDate: Value(newReminder.targetDate),
        isNotificationEnabled: Value(newReminder.isNotificationEnabled),
      ),
    );

    // 3. Schedule the new notification if required
    if (newReminder.isNotificationEnabled &&
        newReminder.targetDate.isAfter(DateTime.now())) {
      await _notifService.scheduleNotification(
        id: existing.id + _notifOffset,
        title: newReminder.title,
        body: newReminder.notes ?? 'You have a scheduled reminder.',
        scheduledDate: newReminder.targetDate,
        payload: 'REMINDER_${existing.id}',
      );
    }
  }

  Future<void> deleteReminder(int id) async {
    await (_db.delete(_db.remindersTable)..where((t) => t.id.equals(id))).go();
    await _notifService.cancelNotification(id + _notifOffset);
  }
}
