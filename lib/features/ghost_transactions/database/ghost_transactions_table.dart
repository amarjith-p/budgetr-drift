import 'package:drift/drift.dart';

@DataClassName('GhostTransactionEntry')
class GhostTransactions extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get rawText => text()();
  TextColumn get source => text()();
  RealColumn get detectedAmount => real().nullable()();
  DateTimeColumn get detectedDate => dateTime().nullable()();
  TextColumn get detectedType => text().nullable()();
  TextColumn get detectedAccount => text().nullable()();

  // --- NEW: FOR AUTO-SELECTION ROUTING ---
  TextColumn get detectedAccountId => text().nullable()();
  BoolColumn get isCreditCardMatch =>
      boolean().withDefault(const Constant(false))();

  TextColumn get status => text().withDefault(const Constant('PENDING'))();
}
