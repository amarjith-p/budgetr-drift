import 'package:drift/drift.dart';

class PassiveIncomeLogs extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get investmentId => integer()(); // Links to your main Investment
  DateTimeColumn get date => dateTime()();
  RealColumn get amount => real()();
  TextColumn get type => text()
      .withDefault(const Constant('dividend'))(); // 'dividend' or 'interest'
  TextColumn get notes => text().nullable()();

  // Timestamps for audit
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}
