import 'package:drift/drift.dart';

@DataClassName("TripRecord")
class TripRecords extends Table {
  TextColumn get id => text()();
  TextColumn get tripName => text()();
  RealColumn get budget => real().nullable()();
  DateTimeColumn get startDate => dateTime()();
  DateTimeColumn get endDate => dateTime().nullable()();
  BoolColumn get isActive => boolean().withDefault(const Constant(true))();

  // [NEW] Pause flag to temporarily stop tracking expenses
  BoolColumn get isPaused => boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {id};
}

class TripExclusions extends Table {
  TextColumn get tripId => text()();
  TextColumn get transactionId => text()();

  @override
  Set<Column> get primaryKey => {tripId, transactionId};
}
