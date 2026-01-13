// import 'dart:async';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import '../../../core/constants/firebase_constants.dart';
// import '../../../core/models/financial_record_model.dart';
// import '../../credit_tracker/models/credit_models.dart';
// import '../../daily_expense/models/expense_models.dart';
// import '../models/dashboard_transaction.dart';

// class DashboardService {
//   final FirebaseFirestore _db = FirebaseFirestore.instance;

//   // --- FINANCIAL RECORDS (Budgets) ---

//   Stream<List<FinancialRecord>> getFinancialRecords() {
//     return _db
//         .collection(FirebaseConstants.financialRecords)
//         .orderBy('id', descending: true)
//         .snapshots()
//         .map(
//           (snapshot) => snapshot.docs
//               .map((doc) => FinancialRecord.fromFirestore(doc))
//               .toList(),
//         );
//   }

//   Future<FinancialRecord?> getRecordForMonth(int year, int month) async {
//     final snapshot = await _db
//         .collection(FirebaseConstants.financialRecords)
//         .where('year', isEqualTo: year)
//         .where('month', isEqualTo: month)
//         .limit(1)
//         .get();

//     if (snapshot.docs.isNotEmpty) {
//       return FinancialRecord.fromFirestore(snapshot.docs.first);
//     }
//     return null;
//   }

//   Future<void> setFinancialRecord(FinancialRecord record) {
//     return _db
//         .collection(FirebaseConstants.financialRecords)
//         .doc(record.id)
//         .set(record.toMap());
//   }

//   Future<FinancialRecord> getRecordById(String id) async {
//     final doc =
//         await _db.collection(FirebaseConstants.financialRecords).doc(id).get();
//     return FinancialRecord.fromFirestore(doc);
//   }

//   Future<void> deleteFinancialRecord(String id) async {
//     final batch = _db.batch();
//     final financeRef =
//         _db.collection(FirebaseConstants.financialRecords).doc(id);
//     batch.delete(financeRef);
//     final settlementRef = _db.collection(FirebaseConstants.settlements).doc(id);
//     batch.delete(settlementRef);
//     await batch.commit();
//   }

//   // --- UNIFIED SPENDING ANALYSIS ---

//   /// Fetches ALL transactions for a specific month from both Credit & Expense sources.
//   /// This is used for the "Monthly Overview" screen.
//   Stream<List<DashboardTransaction>> getMonthlyTransactions(
//     int year,
//     int month,
//   ) {
//     final controller = StreamController<List<DashboardTransaction>>();
//     final start = DateTime(year, month, 1);
//     final end = DateTime(year, month + 1, 0, 23, 59, 59);

//     List<DashboardTransaction> credits = [];
//     List<DashboardTransaction> expenses = [];

//     // Flags to ensure we don't emit partial data on first load
//     bool creditsLoaded = false;
//     bool expensesLoaded = false;

//     void emit() {
//       if (!creditsLoaded || !expensesLoaded) return;

//       final merged = [...credits, ...expenses];
//       merged.sort((a, b) => b.date.compareTo(a.date)); // Sort Descending
//       controller.add(merged);
//     }

//     // 1. Listen to Credit Transactions
//     final sub1 = _db
//         .collection(FirebaseConstants.creditTransactions)
//         .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(start))
//         .where('date', isLessThanOrEqualTo: Timestamp.fromDate(end))
//         .snapshots()
//         .listen((snapshot) {
//       creditsLoaded = true;
//       credits = snapshot.docs
//           .map((doc) => CreditTransactionModel.fromFirestore(doc))
//           .where((txn) => txn.type == 'Expense') // Only Expenses count
//           .map((txn) => DashboardTransaction(
//                 id: txn.id,
//                 amount: txn.amount,
//                 date: txn.date,
//                 category: txn.category,
//                 subCategory: txn.subCategory,
//                 notes: txn.notes,
//                 bucket: txn.bucket,
//                 sourceId: txn.cardId,
//                 sourceType: TransactionSourceType.creditCard,
//               ))
//           .toList();
//       emit();
//     });

//     // 2. Listen to Daily Expense Transactions
//     final sub2 = _db
//         .collection(FirebaseConstants.expenseTransactions)
//         .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(start))
//         .where('date', isLessThanOrEqualTo: Timestamp.fromDate(end))
//         .snapshots()
//         .listen((snapshot) {
//       expensesLoaded = true;
//       expenses = snapshot.docs
//           .map((doc) => ExpenseTransactionModel.fromFirestore(doc))
//           .where((txn) => txn.type == 'Expense') // Exclude Transfers/Income
//           .map((txn) => DashboardTransaction(
//                 id: txn.id,
//                 amount: txn.amount,
//                 date: txn.date,
//                 category: txn.category,
//                 subCategory: txn.subCategory,
//                 notes: txn.notes,
//                 bucket: txn.bucket,
//                 sourceId: txn.accountId,
//                 sourceType: TransactionSourceType.bankAccount,
//               ))
//           .toList();
//       emit();
//     });

//     controller.onCancel = () {
//       sub1.cancel();
//       sub2.cancel();
//     };

//     return controller.stream;
//   }

//   /// Fetches transactions filtered by a specific Bucket (e.g., "Lifestyle")
//   /// Used for the "Bucket Details" screen.
//   Stream<List<DashboardTransaction>> getBucketTransactions(
//     int year,
//     int month,
//     String bucketName,
//   ) {
//     final controller = StreamController<List<DashboardTransaction>>();
//     final start = DateTime(year, month, 1);
//     final end = DateTime(year, month + 1, 0, 23, 59, 59);

//     List<DashboardTransaction> credits = [];
//     List<DashboardTransaction> expenses = [];

//     // Flags for safety
//     bool creditsLoaded = false;
//     bool expensesLoaded = false;

//     void emit() {
//       if (!creditsLoaded || !expensesLoaded) return;

//       final merged = [...credits, ...expenses];
//       merged.sort((a, b) => b.date.compareTo(a.date));
//       controller.add(merged);
//     }

//     // 1. Credit
//     final sub1 = _db
//         .collection(FirebaseConstants.creditTransactions)
//         .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(start))
//         .where('date', isLessThanOrEqualTo: Timestamp.fromDate(end))
//         .snapshots()
//         .listen((snapshot) {
//       creditsLoaded = true;
//       credits = snapshot.docs
//           .map((doc) => CreditTransactionModel.fromFirestore(doc))
//           .where((txn) => txn.bucket == bucketName && txn.type == 'Expense')
//           .map((txn) => DashboardTransaction(
//                 id: txn.id,
//                 amount: txn.amount,
//                 date: txn.date,
//                 category: txn.category,
//                 subCategory: txn.subCategory,
//                 notes: txn.notes,
//                 bucket: txn.bucket,
//                 sourceId: txn.cardId, // Maps to Credit Card ID
//                 sourceType: TransactionSourceType.creditCard,
//               ))
//           .toList();
//       emit();
//     });

//     // 2. Daily Expenses
//     final sub2 = _db
//         .collection(FirebaseConstants.expenseTransactions)
//         .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(start))
//         .where('date', isLessThanOrEqualTo: Timestamp.fromDate(end))
//         .snapshots()
//         .listen((snapshot) {
//       expensesLoaded = true;
//       expenses = snapshot.docs
//           .map((doc) => ExpenseTransactionModel.fromFirestore(doc))
//           .where((txn) => txn.bucket == bucketName && txn.type == 'Expense')
//           .map((txn) => DashboardTransaction(
//                 id: txn.id,
//                 amount: txn.amount,
//                 date: txn.date,
//                 category: txn.category,
//                 subCategory: txn.subCategory,
//                 notes: txn.notes,
//                 bucket: txn.bucket,
//                 sourceId: txn.accountId, // Maps to Expense Account ID
//                 sourceType: TransactionSourceType.bankAccount,
//               ))
//           .toList();
//       emit();
//     });

//     controller.onCancel = () {
//       sub1.cancel();
//       sub2.cancel();
//     };

//     return controller.stream;
//   }

//   /// Calculates total spending per bucket for the dashboard pie chart/progress bars.
//   Stream<Map<String, double>> getMonthlyBucketSpending(int year, int month) {
//     final controller = StreamController<Map<String, double>>();
//     final start = DateTime(year, month, 1);
//     final end = DateTime(year, month + 1, 0, 23, 59, 59);

//     Map<String, double> creditSpending = {};
//     Map<String, double> expenseSpending = {};

//     // --- FIX: Add flags to prevent partial emission ---
//     bool creditsLoaded = false;
//     bool expensesLoaded = false;

//     void emit() {
//       // Only emit once BOTH streams have reported at least one snapshot
//       if (!creditsLoaded || !expensesLoaded) return;

//       final merged = <String, double>{};
//       final allKeys = {...creditSpending.keys, ...expenseSpending.keys};

//       for (var key in allKeys) {
//         merged[key] =
//             (creditSpending[key] ?? 0.0) + (expenseSpending[key] ?? 0.0);
//       }
//       controller.add(merged);
//     }

//     final sub1 = _db
//         .collection(FirebaseConstants.creditTransactions)
//         .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(start))
//         .where('date', isLessThanOrEqualTo: Timestamp.fromDate(end))
//         .snapshots()
//         .listen((snapshot) {
//       creditsLoaded = true; // Mark Credit as loaded
//       creditSpending = {};
//       for (var doc in snapshot.docs) {
//         final data = doc.data();
//         if (data['type'] == 'Expense') {
//           final bucket = data['bucket'] as String? ?? 'Unallocated';
//           final amount = (data['amount'] as num?)?.toDouble() ?? 0.0;
//           creditSpending[bucket] = (creditSpending[bucket] ?? 0.0) + amount;
//         }
//       }
//       emit();
//     });

//     final sub2 = _db
//         .collection(FirebaseConstants.expenseTransactions)
//         .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(start))
//         .where('date', isLessThanOrEqualTo: Timestamp.fromDate(end))
//         .snapshots()
//         .listen((snapshot) {
//       expensesLoaded = true; // Mark Expense as loaded
//       expenseSpending = {};
//       for (var doc in snapshot.docs) {
//         final data = doc.data();
//         if (data['type'] == 'Expense') {
//           final bucket = data['bucket'] as String? ?? 'Unallocated';
//           final amount = (data['amount'] as num?)?.toDouble() ?? 0.0;
//           expenseSpending[bucket] = (expenseSpending[bucket] ?? 0.0) + amount;
//         }
//       }
//       emit();
//     });

//     controller.onCancel = () {
//       sub1.cancel();
//       sub2.cancel();
//     };

//     return controller.stream;
//   }
// }

import 'package:drift/drift.dart';
import 'package:rxdart/rxdart.dart';
import '../../../core/database/app_database.dart';
import '../../../core/models/financial_record_model.dart';
import '../models/dashboard_transaction.dart';

class DashboardService {
  final AppDatabase _db = AppDatabase.instance;

  // --- Financial Records ---
  Stream<List<FinancialRecord>> getFinancialRecords() {
    return (_db.select(_db.financialRecords)
          ..orderBy(
              [(t) => OrderingTerm(expression: t.id, mode: OrderingMode.desc)]))
        .watch()
        .map((rows) => rows
            .map((r) => FinancialRecord(
                  id: r.id,
                  year: r.year,
                  month: r.month,
                  income: r.income,
                  budget: r.budget,
                  createdAt: r.createdAt,
                  updatedAt: r.updatedAt,
                ))
            .toList());
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
          income: row.income,
          budget: row.budget,
          createdAt: row.createdAt,
          updatedAt: row.updatedAt);
    }
    return null;
  }

  Future<void> setFinancialRecord(FinancialRecord record) async {
    await _db
        .into(_db.financialRecords)
        .insertOnConflictUpdate(FinancialRecordsCompanion.insert(
          id: record.id,
          year: record.year,
          month: record.month,
          income: record.income,
          budget: record.budget,
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

  // --- Analysis ---
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
        (List<ExpenseTransaction> exps, List<CreditTransaction> crds) {
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

  // Missing Method Fix
  Stream<Map<String, double>> getMonthlyBucketSpending(int year, int month) {
    return getMonthlyTransactions(year, month).map((txns) {
      final map = <String, double>{};
      for (var t in txns) {
        map[t.bucket] = (map[t.bucket] ?? 0.0) + t.amount;
      }
      return map;
    });
  }

  // Missing Method Fix
  Stream<List<DashboardTransaction>> getBucketTransactions(
      int year, int month, String bucketName) {
    return getMonthlyTransactions(year, month).map((txns) {
      return txns.where((t) => t.bucket == bucketName).toList();
    });
  }
}
