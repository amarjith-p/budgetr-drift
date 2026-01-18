import 'dart:convert';
import 'package:drift/drift.dart';
import 'package:rxdart/rxdart.dart';
import '../../../core/database/app_database.dart' as db;
import '../../../core/models/financial_record_model.dart';
import '../models/dashboard_transaction.dart';

class DashboardService {
  final db.AppDatabase _db = db.AppDatabase.instance;

  // --- Helper to safely decode Maps ---
  Map<String, double> _decodeMap(String jsonStr) {
    try {
      final Map<String, dynamic> decoded = jsonDecode(jsonStr);
      return decoded.map((k, v) => MapEntry(k, (v as num).toDouble()));
    } catch (e) {
      return {};
    }
  }

  // --- FINANCIAL RECORDS ---

  Stream<List<FinancialRecord>> getFinancialRecords() {
    return (_db.select(_db.financialRecords)
          ..orderBy(
              [(t) => OrderingTerm(expression: t.id, mode: OrderingMode.desc)]))
        .watch()
        .map((rows) => rows.map((r) {
              return FinancialRecord(
                id: r.id,
                year: r.year,
                month: r.month,
                salary: r.salary,
                extraIncome: r.extraIncome,
                emi: r.emi,
                effectiveIncome: r.effectiveIncome,
                allocations: _decodeMap(r.allocations),
                allocationPercentages: _decodeMap(r.allocationPercentages),
                bucketOrder: (jsonDecode(r.bucketOrder) as List<dynamic>)
                    .map((e) => e.toString())
                    .toList(),
                createdAt: r.createdAt,
                updatedAt: r.updatedAt,
              );
            }).toList());
  }

  Future<FinancialRecord?> getRecordForMonth(int year, int month) async {
    final id = "${year}${month.toString().padLeft(2, '0')}";
    final row = await (_db.select(_db.financialRecords)
          ..where((t) => t.id.equals(id)))
        .getSingleOrNull();

    if (row == null) return null;

    return FinancialRecord(
      id: row.id,
      year: row.year,
      month: row.month,
      salary: row.salary,
      extraIncome: row.extraIncome,
      emi: row.emi,
      effectiveIncome: row.effectiveIncome,
      allocations: _decodeMap(row.allocations),
      allocationPercentages: _decodeMap(row.allocationPercentages),
      bucketOrder: (jsonDecode(row.bucketOrder) as List<dynamic>)
          .map((e) => e.toString())
          .toList(),
      createdAt: row.createdAt,
      updatedAt: row.updatedAt,
    );
  }

  // [FIX] Added missing method
  Future<void> setFinancialRecord(FinancialRecord record) async {
    await _db.into(_db.financialRecords).insert(
          db.FinancialRecordsCompanion.insert(
            id: record.id,
            year: record.year,
            month: record.month,
            salary: Value(record.salary),
            extraIncome: Value(record.extraIncome),
            emi: Value(record.emi),
            effectiveIncome: Value(record.effectiveIncome),
            allocations: jsonEncode(record.allocations),
            allocationPercentages: jsonEncode(record.allocationPercentages),
            bucketOrder: jsonEncode(record.bucketOrder),
            createdAt: record.createdAt,
            updatedAt: record.updatedAt,
          ),
          mode: InsertMode.insertOrReplace,
        );
  }

  // [FIX] Added missing method
  Future<void> deleteFinancialRecord(String id) async {
    await (_db.delete(_db.financialRecords)..where((t) => t.id.equals(id)))
        .go();
  }

  // --- DASHBOARD TRANSACTIONS ---

  Stream<List<DashboardTransaction>> getRecentTransactions({int limit = 5}) {
    final expenseStream = (_db.select(_db.expenseTransactions)
          ..orderBy([
            (t) => OrderingTerm(expression: t.date, mode: OrderingMode.desc)
          ])
          ..limit(limit))
        .watch();

    final creditStream = (_db.select(_db.creditTransactions)
          ..orderBy([
            (t) => OrderingTerm(expression: t.date, mode: OrderingMode.desc)
          ])
          ..limit(limit))
        .watch();

    return Rx.combineLatest2(expenseStream, creditStream,
        (List<db.ExpenseTransaction> exps, List<db.CreditTransaction> crds) {
      final list = <DashboardTransaction>[];

      list.addAll(exps.map((e) => DashboardTransaction(
          id: e.id,
          amount: e.amount,
          date: e.date,
          type: e.type,
          category: e.category,
          subCategory: e.subCategory,
          notes: e.notes,
          bucket: e.bucket,
          sourceId: e.accountId ?? '',
          sourceType: TransactionSourceType.bankAccount)));

      list.addAll(crds.map((c) => DashboardTransaction(
          id: c.id,
          amount: c.amount,
          date: c.date,
          type: c.type,
          category: c.category,
          subCategory: c.subCategory,
          notes: c.notes,
          bucket: c.bucket,
          sourceId: c.cardId,
          sourceType: TransactionSourceType.creditCard)));

      list.sort((a, b) => b.date.compareTo(a.date));
      return list.take(limit).toList();
    });
  }

  Stream<List<DashboardTransaction>> getMonthlyTransactions(
      int year, int month) {
    final start = DateTime(year, month, 1);
    final end = DateTime(year, month + 1, 0, 23, 59, 59);

    final expenseStream = (_db.select(_db.expenseTransactions)
          ..where((t) => t.date.isBetweenValues(start, end))
          ..orderBy([
            (t) => OrderingTerm(expression: t.date, mode: OrderingMode.desc)
          ]))
        .watch();

    final creditStream = (_db.select(_db.creditTransactions)
          ..where((t) => t.date.isBetweenValues(start, end))
          ..orderBy([
            (t) => OrderingTerm(expression: t.date, mode: OrderingMode.desc)
          ]))
        .watch();

    return Rx.combineLatest2(expenseStream, creditStream,
        (List<db.ExpenseTransaction> exps, List<db.CreditTransaction> crds) {
      final list = <DashboardTransaction>[];
      list.addAll(exps.map((e) => DashboardTransaction(
          id: e.id,
          amount: e.amount,
          date: e.date,
          category: e.category,
          subCategory: e.subCategory,
          notes: e.notes,
          type: e.type,
          bucket: e.bucket,
          sourceId: e.accountId ?? '',
          sourceType: TransactionSourceType.bankAccount)));

      list.addAll(crds.map((c) => DashboardTransaction(
          id: c.id,
          amount: c.amount,
          date: c.date,
          type: c.type,
          category: c.category,
          subCategory: c.subCategory,
          notes: c.notes,
          bucket: c.bucket,
          sourceId: c.cardId,
          sourceType: TransactionSourceType.creditCard)));

      list.sort((a, b) => b.date.compareTo(a.date));
      return list;
    });
  }

  // [FIX] Added missing method
  Stream<List<DashboardTransaction>> getBucketTransactions(
      int year, int month, String bucket) {
    final start = DateTime(year, month, 1);
    final end = DateTime(year, month + 1, 0, 23, 59, 59);

    final expenseStream = (_db.select(_db.expenseTransactions)
          ..where((t) => t.date.isBetweenValues(start, end))
          ..where((t) => t.bucket.equals(bucket))
          ..orderBy([
            (t) => OrderingTerm(expression: t.date, mode: OrderingMode.desc)
          ]))
        .watch();

    final creditStream = (_db.select(_db.creditTransactions)
          ..where((t) => t.date.isBetweenValues(start, end))
          ..where((t) => t.bucket.equals(bucket))
          ..orderBy([
            (t) => OrderingTerm(expression: t.date, mode: OrderingMode.desc)
          ]))
        .watch();

    return Rx.combineLatest2(expenseStream, creditStream,
        (List<db.ExpenseTransaction> exps, List<db.CreditTransaction> crds) {
      final list = <DashboardTransaction>[];
      list.addAll(exps.map((e) => DashboardTransaction(
          id: e.id,
          amount: e.amount,
          date: e.date,
          type: e.type,
          category: e.category,
          subCategory: e.subCategory,
          notes: e.notes,
          bucket: e.bucket,
          sourceId: e.accountId ?? '',
          sourceType: TransactionSourceType.bankAccount)));

      list.addAll(crds.map((c) => DashboardTransaction(
          id: c.id,
          amount: c.amount,
          date: c.date,
          type: c.type,
          category: c.category,
          subCategory: c.subCategory,
          notes: c.notes,
          bucket: c.bucket,
          sourceId: c.cardId,
          sourceType: TransactionSourceType.creditCard)));

      list.sort((a, b) => b.date.compareTo(a.date));
      return list;
    });
  }

  Stream<Map<String, double>> getMonthlyBucketSpending(int year, int month) {
    return getMonthlyTransactions(year, month).map((txns) {
      final map = <String, double>{};
      for (var t in txns) {
        // Exclude income/unallocated from spending charts
        if (t.bucket == 'Income' ||
            t.bucket == 'Unallocated' ||
            t.sourceId == '') continue;

        final bucket = t.bucket.isEmpty ? 'Unallocated' : t.bucket;
        map[bucket] = (map[bucket] ?? 0.0) + t.amount;
      }
      return map;
    });
  }
}
