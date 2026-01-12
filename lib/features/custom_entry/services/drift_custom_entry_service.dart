import 'dart:async';
import 'dart:convert';
import 'package:budget/features/dashboard/models/dashboard_transaction.dart';
import 'package:budget/features/dashboard/services/dashboard_service.dart';
import 'package:drift/drift.dart' as drift;
import 'package:async/async.dart'; // Ensure 'async' package is available

import '../../../../core/database/app_database.dart';
import '../../../core/models/financial_record_model.dart' as domain;
import '../../daily_expense/models/expense_models.dart';
import '../../credit_tracker/models/credit_models.dart';

class DriftDashboardService extends DashboardService {
  final AppDatabase _db = AppDatabase.instance;

  // --- Helpers ---
  domain.FinancialRecord _mapRecord(FinancialRecord row) {
    return domain.FinancialRecord(
      id: row.id,
      month: row.month,
      year: row.year,
      salary: row.salary,
      extraIncome: row.extraIncome,
      emi: row.emi,
      allocations: Map<String, double>.from(jsonDecode(row.allocations)),
      bucketOrder: List<String>.from(jsonDecode(row.bucketOrder)),
      effectiveIncome: row.effectiveIncome,
      createdAt: row.createdAt, // Direct DateTime
      updatedAt: row.updatedAt, // Direct DateTime
      allocationPercentages:
          Map<String, double>.from(jsonDecode(row.allocationPercentages)),
    );
  }

  @override
  Stream<List<domain.FinancialRecord>> getFinancialRecords() {
    return (_db.select(_db.financialRecords)
          ..orderBy([
            (t) => drift.OrderingTerm(
                expression: t.id, mode: drift.OrderingMode.desc)
          ]))
        .watch()
        .map((rows) => rows.map(_mapRecord).toList());
  }

  @override
  Stream<List<DashboardTransaction>> getMonthlyTransactions(
      int year, int month) {
    final start = DateTime(year, month, 1);
    final end = DateTime(year, month + 1, 0, 23, 59, 59);

    final creditQuery = _db.select(_db.creditTransactions)
      ..where((t) => t.date.isBetween(drift.Value(start), drift.Value(end)))
      ..where((t) => t.type.equals('Expense'));

    final expenseQuery = _db.select(_db.expenseTransactions)
      ..where((t) => t.date.isBetween(drift.Value(start), drift.Value(end)))
      ..where((t) => t.type.equals('Expense'));

    return StreamZip([
      creditQuery.watch(),
      expenseQuery.watch(),
    ]).map((data) {
      final cList = data[0] as List<CreditTransaction>;
      final eList = data[1] as List<ExpenseTransaction>;

      final merged = <DashboardTransaction>[];

      // Assuming DashboardTransaction uses DateTime
      merged.addAll(cList.map((t) => DashboardTransaction(
            id: t.id,
            amount: t.amount,
            date: t.date,
            category: t.category,
            subCategory: t.subCategory,
            notes: t.notes,
            bucket: t.bucket,
            sourceId: t.cardId,
            sourceType: TransactionSourceType.creditCard,
          )));

      merged.addAll(eList.map((t) => DashboardTransaction(
            id: t.id,
            amount: t.amount,
            date: t.date,
            category: t.category,
            subCategory: t.subCategory,
            notes: t.notes,
            bucket: t.bucket,
            sourceId: t.accountId,
            sourceType: TransactionSourceType.bankAccount,
          )));

      merged.sort((a, b) => b.date.compareTo(a.date));
      return merged;
    });
  }
}
