import 'dart:async';
import 'dart:convert';
import 'package:drift/drift.dart' as drift;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:rxdart/rxdart.dart'; // Add rxdart to pubspec if missing, or use the helper below

import '../../../../core/database/app_database.dart';
// ALIAS THE MODEL IMPORT to avoid conflict with Drift class
import '../../../core/models/financial_record_model.dart' as domain;
import '../../daily_expense/models/expense_models.dart';
import '../../credit_tracker/models/credit_models.dart';
import '../models/dashboard_transaction.dart';
import 'dashboard_service.dart';

class DriftDashboardService extends DashboardService {
  final AppDatabase _db = AppDatabase.instance;

  // --- Helpers ---
  // Input: Drift Row (FinancialRecord), Output: Domain Model (domain.FinancialRecord)
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
      createdAt: Timestamp.fromDate(row.createdAt),
      updatedAt: Timestamp.fromDate(row.updatedAt),
      allocationPercentages:
          Map<String, double>.from(jsonDecode(row.allocationPercentages)),
    );
  }

  // --- Financial Records ---
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

  // --- Unified Transactions ---
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

    // Combine streams manually without RxUtils
    return CombineLatestStream.list([
      creditQuery.watch(),
      expenseQuery.watch(),
    ]).map((data) {
      final cList = data[0] as List<CreditTransaction>;
      final eList = data[1] as List<ExpenseTransaction>;

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
