import 'dart:async';
import 'dart:convert';
import 'package:drift/drift.dart' as drift;
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../core/database/app_database.dart';
import '../../../core/models/financial_record_model.dart';
import '../../daily_expense/models/expense_models.dart';
import '../../credit_tracker/models/credit_models.dart';
import '../models/dashboard_transaction.dart';
import 'dashboard_service.dart';

class DriftDashboardService extends DashboardService {
  final AppDatabase _db = AppDatabase.instance;

  // --- Helpers ---
  FinancialRecord _mapRecord(FinancialRecord row) {
    // Implement mapping from Table Row to Model using jsonDecode for Maps
    // Simulating for brevity:
    return FinancialRecord(
      id: row.id,
      month: row.month,
      year: row.year,
      salary: row.salary,
      extraIncome: row.extraIncome,
      emi: row.emi,
      allocations: Map<String, double>.from(jsonDecode(row.allocations)),
      bucketOrder: List<String>.from(jsonDecode(row.bucketOrder)),
      // ... other fields
    );
  }

  // --- Financial Records ---
  @override
  Stream<List<FinancialRecord>> getFinancialRecords() {
    return (_db.select(_db.financialRecords)
          ..orderBy([
            (t) => drift.OrderingTerm(
                expression: t.id, mode: drift.OrderingMode.desc)
          ]))
        .watch()
        .map((rows) => rows.map(_mapRecord).toList());
  }

  // --- Unified Transactions (The Hard Part) ---
  @override
  Stream<List<DashboardTransaction>> getMonthlyTransactions(
      int year, int month) {
    final start = DateTime(year, month, 1);
    final end = DateTime(year, month + 1, 0, 23, 59, 59);

    final creditQuery = _db.select(_db.creditTransactions)
      ..where((t) => t.date.isBetweenValues(start, end))
      ..where((t) => t.type.equals('Expense'));

    final expenseQuery = _db.select(_db.expenseTransactions)
      ..where((t) => t.date.isBetweenValues(start, end))
      ..where((t) => t.type.equals('Expense'));

    // Combine Streams using Rx or simple StreamController
    // Here using a simple merge approach
    return drift.RxUtils.combine2(creditQuery.watch(), expenseQuery.watch(),
        (List<CreditTransaction> cList, List<ExpenseTransaction> eList) {
      final merged = <DashboardTransaction>[];

      merged.addAll(cList.map((t) => DashboardTransaction(
            id: t.id,
            amount: t.amount,
            date: Timestamp.fromDate(t.date),
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
            date: Timestamp.fromDate(t.date),
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
