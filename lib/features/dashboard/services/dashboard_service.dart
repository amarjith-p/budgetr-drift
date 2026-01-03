import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../core/constants/firebase_constants.dart';
import '../../../core/models/financial_record_model.dart';
import '../../credit_tracker/models/credit_models.dart';
import '../../daily_expense/models/expense_models.dart';
import '../models/dashboard_transaction.dart'; // Ensure you have created this model file

class DashboardService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // --- FINANCIAL RECORDS (Budgets) ---

  Stream<List<FinancialRecord>> getFinancialRecords() {
    return _db
        .collection(FirebaseConstants.financialRecords)
        .orderBy('id', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => FinancialRecord.fromFirestore(doc))
              .toList(),
        );
  }

  Future<FinancialRecord?> getRecordForMonth(int year, int month) async {
    final snapshot = await _db
        .collection(FirebaseConstants.financialRecords)
        .where('year', isEqualTo: year)
        .where('month', isEqualTo: month)
        .limit(1)
        .get();

    if (snapshot.docs.isNotEmpty) {
      return FinancialRecord.fromFirestore(snapshot.docs.first);
    }
    return null;
  }

  Future<void> setFinancialRecord(FinancialRecord record) {
    return _db
        .collection(FirebaseConstants.financialRecords)
        .doc(record.id)
        .set(record.toMap());
  }

  Future<FinancialRecord> getRecordById(String id) async {
    final doc =
        await _db.collection(FirebaseConstants.financialRecords).doc(id).get();
    return FinancialRecord.fromFirestore(doc);
  }

  Future<void> deleteFinancialRecord(String id) async {
    final batch = _db.batch();
    final financeRef =
        _db.collection(FirebaseConstants.financialRecords).doc(id);
    batch.delete(financeRef);
    final settlementRef = _db.collection(FirebaseConstants.settlements).doc(id);
    batch.delete(settlementRef);
    await batch.commit();
  }

  // --- UNIFIED SPENDING ANALYSIS ---

  /// Fetches ALL transactions for a specific month from both Credit & Expense sources.
  /// This is used for the "Monthly Overview" screen.
  Stream<List<DashboardTransaction>> getMonthlyTransactions(
    int year,
    int month,
  ) {
    final controller = StreamController<List<DashboardTransaction>>();
    final start = DateTime(year, month, 1);
    final end = DateTime(year, month + 1, 0, 23, 59, 59);

    List<DashboardTransaction> credits = [];
    List<DashboardTransaction> expenses = [];

    void emit() {
      final merged = [...credits, ...expenses];
      merged.sort((a, b) => b.date.compareTo(a.date)); // Sort Descending
      controller.add(merged);
    }

    // 1. Listen to Credit Transactions
    final sub1 = _db
        .collection(FirebaseConstants.creditTransactions)
        .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(start))
        .where('date', isLessThanOrEqualTo: Timestamp.fromDate(end))
        .snapshots()
        .listen((snapshot) {
      credits = snapshot.docs
          .map((doc) => CreditTransactionModel.fromFirestore(doc))
          .where((txn) => txn.type == 'Expense') // Only Expenses count
          .map((txn) => DashboardTransaction(
                id: txn.id,
                amount: txn.amount,
                date: txn.date,
                category: txn.category,
                subCategory: txn.subCategory,
                notes: txn.notes,
                bucket: txn.bucket,
                sourceId: txn.cardId,
                sourceType: TransactionSourceType.creditCard,
              ))
          .toList();
      emit();
    });

    // 2. Listen to Daily Expense Transactions
    final sub2 = _db
        .collection(FirebaseConstants.expenseTransactions)
        .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(start))
        .where('date', isLessThanOrEqualTo: Timestamp.fromDate(end))
        .snapshots()
        .listen((snapshot) {
      expenses = snapshot.docs
          .map((doc) => ExpenseTransactionModel.fromFirestore(doc))
          .where((txn) => txn.type == 'Expense') // Exclude Transfers/Income
          .map((txn) => DashboardTransaction(
                id: txn.id,
                amount: txn.amount,
                date: txn.date,
                category: txn.category,
                subCategory: txn.subCategory,
                notes: txn.notes,
                bucket: txn.bucket,
                sourceId: txn.accountId,
                sourceType: TransactionSourceType.bankAccount,
              ))
          .toList();
      emit();
    });

    controller.onCancel = () {
      sub1.cancel();
      sub2.cancel();
    };

    return controller.stream;
  }

  /// Fetches transactions filtered by a specific Bucket (e.g., "Lifestyle")
  /// Used for the "Bucket Details" screen.
  Stream<List<DashboardTransaction>> getBucketTransactions(
    int year,
    int month,
    String bucketName,
  ) {
    final controller = StreamController<List<DashboardTransaction>>();
    final start = DateTime(year, month, 1);
    final end = DateTime(year, month + 1, 0, 23, 59, 59);

    List<DashboardTransaction> credits = [];
    List<DashboardTransaction> expenses = [];

    void emit() {
      final merged = [...credits, ...expenses];
      merged.sort((a, b) => b.date.compareTo(a.date));
      controller.add(merged);
    }

    // 1. Credit
    final sub1 = _db
        .collection(FirebaseConstants.creditTransactions)
        .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(start))
        .where('date', isLessThanOrEqualTo: Timestamp.fromDate(end))
        .snapshots()
        .listen((snapshot) {
      credits = snapshot.docs
          .map((doc) => CreditTransactionModel.fromFirestore(doc))
          .where((txn) => txn.bucket == bucketName && txn.type == 'Expense')
          .map((txn) => DashboardTransaction(
                id: txn.id,
                amount: txn.amount,
                date: txn.date,
                category: txn.category,
                subCategory: txn.subCategory,
                notes: txn.notes,
                bucket: txn.bucket,
                sourceId: txn.cardId, // Maps to Credit Card ID
                sourceType: TransactionSourceType.creditCard,
              ))
          .toList();
      emit();
    });

    // 2. Daily Expenses
    final sub2 = _db
        .collection(FirebaseConstants.expenseTransactions)
        .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(start))
        .where('date', isLessThanOrEqualTo: Timestamp.fromDate(end))
        .snapshots()
        .listen((snapshot) {
      expenses = snapshot.docs
          .map((doc) => ExpenseTransactionModel.fromFirestore(doc))
          .where((txn) => txn.bucket == bucketName && txn.type == 'Expense')
          .map((txn) => DashboardTransaction(
                id: txn.id,
                amount: txn.amount,
                date: txn.date,
                category: txn.category,
                subCategory: txn.subCategory,
                notes: txn.notes,
                bucket: txn.bucket,
                sourceId: txn.accountId, // Maps to Expense Account ID
                sourceType: TransactionSourceType.bankAccount,
              ))
          .toList();
      emit();
    });

    controller.onCancel = () {
      sub1.cancel();
      sub2.cancel();
    };

    return controller.stream;
  }

  /// Calculates total spending per bucket for the dashboard pie chart/progress bars.
  Stream<Map<String, double>> getMonthlyBucketSpending(int year, int month) {
    final controller = StreamController<Map<String, double>>();
    final start = DateTime(year, month, 1);
    final end = DateTime(year, month + 1, 0, 23, 59, 59);

    Map<String, double> creditSpending = {};
    Map<String, double> expenseSpending = {};

    void emit() {
      final merged = <String, double>{};
      final allKeys = {...creditSpending.keys, ...expenseSpending.keys};

      for (var key in allKeys) {
        merged[key] =
            (creditSpending[key] ?? 0.0) + (expenseSpending[key] ?? 0.0);
      }
      controller.add(merged);
    }

    final sub1 = _db
        .collection(FirebaseConstants.creditTransactions)
        .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(start))
        .where('date', isLessThanOrEqualTo: Timestamp.fromDate(end))
        .snapshots()
        .listen((snapshot) {
      creditSpending = {};
      for (var doc in snapshot.docs) {
        final data = doc.data();
        if (data['type'] == 'Expense') {
          final bucket = data['bucket'] as String? ?? 'Unallocated';
          final amount = (data['amount'] as num?)?.toDouble() ?? 0.0;
          creditSpending[bucket] = (creditSpending[bucket] ?? 0.0) + amount;
        }
      }
      emit();
    });

    final sub2 = _db
        .collection(FirebaseConstants.expenseTransactions)
        .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(start))
        .where('date', isLessThanOrEqualTo: Timestamp.fromDate(end))
        .snapshots()
        .listen((snapshot) {
      expenseSpending = {};
      for (var doc in snapshot.docs) {
        final data = doc.data();
        if (data['type'] == 'Expense') {
          final bucket = data['bucket'] as String? ?? 'Unallocated';
          final amount = (data['amount'] as num?)?.toDouble() ?? 0.0;
          expenseSpending[bucket] = (expenseSpending[bucket] ?? 0.0) + amount;
        }
      }
      emit();
    });

    controller.onCancel = () {
      sub1.cancel();
      sub2.cancel();
    };

    return controller.stream;
  }
}
