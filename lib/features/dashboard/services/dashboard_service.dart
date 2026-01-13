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
                effectiveIncome: r.effectiveIncome, // Fixed: Now exists in DB
                createdAt: r.createdAt,
                updatedAt: r.updatedAt,
                allocations: _decodeMap(r.allocations),
                allocationPercentages: _decodeMap(
                    r.allocationPercentages), // Fixed: Now exists in DB
                bucketOrder: List<String>.from(jsonDecode(r.bucketOrder)),
              );
            }).toList());
  }

  Future<FinancialRecord?> getRecordForMonth(int year, int month) async {
    final row = await (_db.select(_db.financialRecords)
          ..where((t) => t.year.equals(year))
          ..where((t) => t.month.equals(month))
          ..limit(1))
        .getSingleOrNull();

    if (row != null) {
      return FinancialRecord(
        id: row.id,
        year: row.year,
        month: row.month,
        salary: row.salary,
        extraIncome: row.extraIncome,
        emi: row.emi,
        effectiveIncome: row.effectiveIncome, // Fixed
        createdAt: row.createdAt,
        updatedAt: row.updatedAt,
        allocations: _decodeMap(row.allocations),
        allocationPercentages: _decodeMap(row.allocationPercentages), // Fixed
        bucketOrder: List<String>.from(jsonDecode(row.bucketOrder)),
      );
    }
    return null;
  }

  Future<void> setFinancialRecord(FinancialRecord record) async {
    await _db
        .into(_db.financialRecords)
        .insertOnConflictUpdate(db.FinancialRecordsCompanion.insert(
          id: record.id,
          year: record.year,
          month: record.month,
          salary: Value(record.salary),
          extraIncome: Value(record.extraIncome),
          emi: Value(record.emi),
          effectiveIncome: Value(record.effectiveIncome), // Fixed
          budget: Value(
              record.effectiveIncome), // Usually Budget = Effective Income
          allocations: jsonEncode(record.allocations),
          allocationPercentages:
              jsonEncode(record.allocationPercentages), // Fixed
          bucketOrder: jsonEncode(record.bucketOrder),
          createdAt: record.createdAt,
          updatedAt: DateTime.now(),
        ));
  }

  Future<void> deleteFinancialRecord(String id) async {
    await _db.transaction(() async {
      await (_db.delete(_db.financialRecords)..where((t) => t.id.equals(id)))
          .go();
      await (_db.delete(_db.settlements)..where((t) => t.id.equals(id))).go();
    });
  }

  // --- ANALYSIS (No changes needed here, but kept for completeness) ---
  Stream<List<DashboardTransaction>> getMonthlyTransactions(
      int year, int month) {
    final start = DateTime(year, month, 1);
    final end = DateTime(year, month + 1, 0, 23, 59, 59);

    final expenses = (_db.select(_db.expenseTransactions)
          ..where((t) => t.date.isBetweenValues(start, end))
          ..where((t) => t.type.equals('Expense')))
        .watch();

    final credits = (_db.select(_db.creditTransactions)
          ..where((t) => t.date.isBetweenValues(start, end))
          ..where((t) => t.type.equals('Expense')))
        .watch();

    return Rx.combineLatest2(expenses, credits,
        (List<db.ExpenseTransaction> exps, List<db.CreditTransaction> crds) {
      final list = <DashboardTransaction>[];
      list.addAll(exps.map((e) => DashboardTransaction(
          id: e.id,
          amount: e.amount,
          date: e.date,
          category: e.category,
          subCategory: e.subCategory,
          notes: e.notes,
          bucket: e.bucket,
          sourceId: e.accountId,
          sourceType: TransactionSourceType.bankAccount)));
      list.addAll(crds.map((c) => DashboardTransaction(
          id: c.id,
          amount: c.amount,
          date: c.date,
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
        final bucket = t.bucket.isEmpty ? 'Unallocated' : t.bucket;
        map[bucket] = (map[bucket] ?? 0.0) + t.amount;
      }
      return map;
    });
  }

  Stream<List<DashboardTransaction>> getBucketTransactions(
      int year, int month, String bucketName) {
    return getMonthlyTransactions(year, month).map((txns) {
      return txns.where((t) => t.bucket == bucketName).toList();
    });
  }
}
