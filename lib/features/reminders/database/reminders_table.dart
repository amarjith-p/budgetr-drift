import 'package:drift/drift.dart';

@DataClassName('ReminderEntry')
class RemindersTable extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get title => text().withLength(min: 1, max: 100)();
  TextColumn get notes => text().nullable()();
  DateTimeColumn get targetDate => dateTime()();
  BoolColumn get isNotificationEnabled =>
      boolean().withDefault(const Constant(true))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}
