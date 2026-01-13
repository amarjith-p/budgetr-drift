import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';
import '../../../core/database/app_database.dart' as db;
import '../../../core/models/net_worth_model.dart';
import '../../../core/models/net_worth_split_model.dart';

class NetWorthService {
  final db.AppDatabase _db = db.AppDatabase.instance;
  final _uuid = const Uuid();

  // --- Total Net Worth ---

  Stream<List<NetWorthRecord>> getNetWorthRecords() {
    return (_db.select(_db.netWorthRecords)
          ..orderBy([
            (t) => OrderingTerm(expression: t.date, mode: OrderingMode.desc)
          ]))
        .watch()
        .map((rows) => rows
            .map((r) => NetWorthRecord(
                  id: r.id,
                  date: r.date,
                  amount: r.amount,
                ))
            .toList());
  }

  Future<void> addNetWorthRecord(NetWorthRecord record) async {
    final id = record.id.isNotEmpty ? record.id : _uuid.v4();
    await _db
        .into(_db.netWorthRecords)
        .insert(db.NetWorthRecordsCompanion.insert(
          id: id,
          date: record.date,
          amount: record.amount,
        ));
  }

  Future<void> deleteNetWorthRecord(String id) async {
    await (_db.delete(_db.netWorthRecords)..where((t) => t.id.equals(id))).go();
  }

  // --- Net Worth Splits ---

  Stream<List<NetWorthSplit>> getNetWorthSplits() {
    return (_db.select(_db.netWorthSplits)
          ..orderBy([
            (t) => OrderingTerm(expression: t.date, mode: OrderingMode.desc)
          ]))
        .watch()
        .map((rows) => rows
            .map((r) => NetWorthSplit(
                  id: r.id,
                  date: r.date,
                  netIncome: r.netIncome,
                  netExpense: r.netExpense,
                  capitalGain: r.capitalGain,
                  capitalLoss: r.capitalLoss,
                  nonCalcIncome: r.nonCalcIncome,
                  nonCalcExpense: r.nonCalcExpense,
                ))
            .toList());
  }

  Future<void> addNetWorthSplit(NetWorthSplit split) async {
    final id = split.id.isNotEmpty ? split.id : _uuid.v4();

    await _db.into(_db.netWorthSplits).insert(db.NetWorthSplitsCompanion.insert(
          id: id,
          date: split.date,
          // Using Value() wrappers since these columns have defaults in the new schema
          netIncome: Value(split.netIncome),
          netExpense: Value(split.netExpense),
          capitalGain: Value(split.capitalGain),
          capitalLoss: Value(split.capitalLoss),
          nonCalcIncome: Value(split.nonCalcIncome),
          nonCalcExpense: Value(split.nonCalcExpense),
        ));
  }

  Future<void> deleteNetWorthSplit(String id) async {
    await (_db.delete(_db.netWorthSplits)..where((t) => t.id.equals(id))).go();
  }
}
