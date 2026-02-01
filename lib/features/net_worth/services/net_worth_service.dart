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

  // // --- Net Worth Splits ---

  // Stream<List<NetWorthSplit>> getNetWorthSplits() {
  //   return (_db.select(_db.netWorthSplits)
  //         ..orderBy([
  //           (t) => OrderingTerm(expression: t.date, mode: OrderingMode.desc)
  //         ]))
  //       .watch()
  //       .map((rows) => rows
  //           .map((r) => NetWorthSplit(
  //                 id: r.id,
  //                 date: r.date,
  //                 netIncome: r.netIncome,
  //                 netExpense: r.netExpense,
  //                 capitalGain: r.capitalGain,
  //                 capitalLoss: r.capitalLoss,
  //                 nonCalcIncome: r.nonCalcIncome,
  //                 nonCalcExpense: r.nonCalcExpense,
  //               ))
  //           .toList());
  // }

  // Future<void> addNetWorthSplit(NetWorthSplit split) async {
  //   final id = split.id.isNotEmpty ? split.id : _uuid.v4();

  //   await _db.into(_db.netWorthSplits).insert(db.NetWorthSplitsCompanion.insert(
  //         id: id,
  //         date: split.date,
  //         // Using Value() wrappers since these columns have defaults in the new schema
  //         netIncome: Value(split.netIncome),
  //         netExpense: Value(split.netExpense),
  //         capitalGain: Value(split.capitalGain),
  //         capitalLoss: Value(split.capitalLoss),
  //         nonCalcIncome: Value(split.nonCalcIncome),
  //         nonCalcExpense: Value(split.nonCalcExpense),
  //       ));
  // }

  // Future<void> deleteNetWorthSplit(String id) async {
  //   await (_db.delete(_db.netWorthSplits)..where((t) => t.id.equals(id))).go();
  // }

  // Map DB Row to Domain Model
  NetWorthSplitModel _mapSplit(db.NetWorthSplit row) {
    return NetWorthSplitModel(
      id: row.id,
      date: row.date,
      // Assets
      bankAccounts: row.bankAccounts,
      cashInHand: row.cashInHand,
      mutualFunds: row.mutualFunds,
      equity: row.equity,
      bonds: row.bonds,
      deposits: row.deposits,
      realEstate: row.realEstate,
      otherAssets: row.otherAssets,
      assetNotes: row.assetNotes,
      // Liabilities
      loans: row.loans,
      creditCardOutstanding: row.creditCardOutstanding,
      otherDebts: row.otherDebts,
      liabilityNotes: row.liabilityNotes,
      // Cashflow
      budgetedIncome: row.budgetedIncome,
      budgetedExpense: row.budgetedExpense,
      nonCalcIncome: row.nonCalcIncome,
      nonCalcExpense: row.nonCalcExpense,
      outOfBucketExpense: row.outOfBucketExpense,
    );
  }

  Stream<List<NetWorthSplitModel>> getSplits() {
    return (_db.select(_db.netWorthSplits)
          ..orderBy([
            (t) => OrderingTerm(expression: t.date, mode: OrderingMode.desc)
          ]))
        .watch()
        .map((rows) => rows.map(_mapSplit).toList());
  }

  Future<void> createSplit(NetWorthSplitModel split) async {
    await _db.into(_db.netWorthSplits).insert(db.NetWorthSplitsCompanion.insert(
          id: _uuid.v4(),
          date: split.date,
          bankAccounts: Value(split.bankAccounts),
          cashInHand: Value(split.cashInHand),
          mutualFunds: Value(split.mutualFunds),
          equity: Value(split.equity),
          bonds: Value(split.bonds),
          deposits: Value(split.deposits),
          realEstate: Value(split.realEstate),
          otherAssets: Value(split.otherAssets),
          assetNotes: Value(split.assetNotes),
          loans: Value(split.loans),
          creditCardOutstanding: Value(split.creditCardOutstanding),
          otherDebts: Value(split.otherDebts),
          liabilityNotes: Value(split.liabilityNotes),
          budgetedIncome: Value(split.budgetedIncome),
          budgetedExpense: Value(split.budgetedExpense),
          nonCalcIncome: Value(split.nonCalcIncome),
          nonCalcExpense: Value(split.nonCalcExpense),
          outOfBucketExpense: Value(split.outOfBucketExpense),
        ));
  }

  Future<void> updateSplit(NetWorthSplitModel split) async {
    await (_db.update(_db.netWorthSplits)..where((t) => t.id.equals(split.id)))
        .write(db.NetWorthSplitsCompanion(
      date: Value(split.date),
      bankAccounts: Value(split.bankAccounts),
      cashInHand: Value(split.cashInHand),
      mutualFunds: Value(split.mutualFunds),
      equity: Value(split.equity),
      bonds: Value(split.bonds),
      deposits: Value(split.deposits),
      realEstate: Value(split.realEstate),
      otherAssets: Value(split.otherAssets),
      assetNotes: Value(split.assetNotes),
      loans: Value(split.loans),
      creditCardOutstanding: Value(split.creditCardOutstanding),
      otherDebts: Value(split.otherDebts),
      liabilityNotes: Value(split.liabilityNotes),
      budgetedIncome: Value(split.budgetedIncome),
      budgetedExpense: Value(split.budgetedExpense),
      nonCalcIncome: Value(split.nonCalcIncome),
      nonCalcExpense: Value(split.nonCalcExpense),
      outOfBucketExpense: Value(split.outOfBucketExpense),
    ));
  }

  Future<void> deleteSplit(String id) async {
    await (_db.delete(_db.netWorthSplits)..where((t) => t.id.equals(id))).go();
  }
}
