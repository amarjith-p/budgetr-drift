import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../core/constants/firebase_constants.dart';
import '../models/expense_models.dart';

class ExpenseService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // --- ACCOUNTS (Management Screen - All Accounts) ---
  Stream<List<ExpenseAccountModel>> getAccounts() {
    return _db
        .collection(FirebaseConstants.expenseAccounts)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((s) =>
            s.docs.map((d) => ExpenseAccountModel.fromFirestore(d)).toList());
  }

  // --- NEW: DASHBOARD ACCOUNTS (Filtered & Sorted) ---
  Stream<List<ExpenseAccountModel>> getDashboardAccounts() {
    return _db
        .collection(FirebaseConstants.expenseAccounts)
        .where('showOnDashboard', isEqualTo: true)
        .orderBy('dashboardOrder', descending: false)
        // Note: Firestore requires an index for 'showOnDashboard' + 'dashboardOrder'
        .limit(6)
        .snapshots()
        .map((s) =>
            s.docs.map((d) => ExpenseAccountModel.fromFirestore(d)).toList());
  }

  // --- NEW: UPDATE ORDER & VISIBILITY ---
  Future<void> updateDashboardConfig(List<ExpenseAccountModel> accounts) async {
    final batch = _db.batch();

    for (var account in accounts) {
      final ref =
          _db.collection(FirebaseConstants.expenseAccounts).doc(account.id);
      batch.update(ref, {
        'showOnDashboard': account.showOnDashboard,
        'dashboardOrder': account.dashboardOrder,
      });
    }

    await batch.commit();
  }

  // ... (Rest of existing add/update/delete methods remain unchanged)
  Future<void> addAccount(ExpenseAccountModel account) {
    return _db
        .collection(FirebaseConstants.expenseAccounts)
        .doc(account.id)
        .set(account.toMap());
  }

  Future<void> updateAccount(ExpenseAccountModel account) async {
    await _db
        .collection(FirebaseConstants.expenseAccounts)
        .doc(account.id)
        .update(account.toMap());
  }

  Future<void> deleteAccount(String accountId) async {
    final batch = _db.batch();
    final accRef =
        _db.collection(FirebaseConstants.expenseAccounts).doc(accountId);
    batch.delete(accRef);

    final txnsSnapshot = await _db
        .collection(FirebaseConstants.expenseTransactions)
        .where('accountId', isEqualTo: accountId)
        .get();

    for (final doc in txnsSnapshot.docs) {
      batch.delete(doc.reference);
    }
    await batch.commit();
  }

  Stream<List<ExpenseTransactionModel>> getTransactionsForAccount(
      String accountId) {
    return _db
        .collection(FirebaseConstants.expenseTransactions)
        .where('accountId', isEqualTo: accountId)
        .orderBy('date', descending: true)
        .snapshots()
        .map((s) => s.docs
            .map((d) => ExpenseTransactionModel.fromFirestore(d))
            .toList());
  }

  Future<void> addTransaction(ExpenseTransactionModel txn) async {
    final batch = _db.batch();
    final docId = txn.id.isNotEmpty
        ? txn.id
        : _db.collection(FirebaseConstants.expenseTransactions).doc().id;
    final txnRef =
        _db.collection(FirebaseConstants.expenseTransactions).doc(docId);

    final txnToSave = ExpenseTransactionModel(
      id: docId,
      accountId: txn.accountId,
      amount: txn.amount,
      date: txn.date,
      bucket: txn.bucket,
      type: txn.type,
      category: txn.category,
      subCategory: txn.subCategory,
      notes: txn.notes,
      transferAccountId: txn.transferAccountId,
      transferAccountName: txn.transferAccountName,
      transferAccountBankName: txn.transferAccountBankName,
    );

    batch.set(txnRef, txnToSave.toMap());

    final accRef =
        _db.collection(FirebaseConstants.expenseAccounts).doc(txn.accountId);
    double delta = 0.0;

    if (txn.type == 'Expense' || txn.type == 'Transfer Out') {
      delta = -txn.amount;
    } else if (txn.type == 'Income' || txn.type == 'Transfer In') {
      delta = txn.amount;
    }

    batch.update(accRef, {'currentBalance': FieldValue.increment(delta)});
    await batch.commit();
  }

  Future<void> deleteTransaction(ExpenseTransactionModel txn) async {
    await _db
        .collection(FirebaseConstants.expenseTransactions)
        .doc(txn.id)
        .delete();

    await _updateAccountBalance(txn.accountId, txn.amount, txn.type,
        isAdding: false);

    if (txn.type == 'Transfer Out' || txn.type == 'Transfer In') {
      final linkedType =
          txn.type == 'Transfer Out' ? 'Transfer In' : 'Transfer Out';

      final linkedSnapshot = await _db
          .collection(FirebaseConstants.expenseTransactions)
          .where('accountId', isEqualTo: txn.transferAccountId)
          .where('transferAccountId', isEqualTo: txn.accountId)
          .where('amount', isEqualTo: txn.amount)
          .where('date', isEqualTo: txn.date)
          .where('type', isEqualTo: linkedType)
          .limit(1)
          .get();

      for (var doc in linkedSnapshot.docs) {
        final linkedTxn = ExpenseTransactionModel.fromFirestore(doc);
        await doc.reference.delete();
        await _updateAccountBalance(
            linkedTxn.accountId, linkedTxn.amount, linkedTxn.type,
            isAdding: false);
      }
    }
  }

  Future<void> updateTransaction(ExpenseTransactionModel newTxn) async {
    return _db.runTransaction((transaction) async {
      final txnRef =
          _db.collection(FirebaseConstants.expenseTransactions).doc(newTxn.id);
      final accRef = _db
          .collection(FirebaseConstants.expenseAccounts)
          .doc(newTxn.accountId);

      final docSnapshot = await transaction.get(txnRef);
      if (!docSnapshot.exists) throw Exception("Transaction does not exist!");

      final oldTxn = ExpenseTransactionModel.fromFirestore(docSnapshot);

      double oldEffect = 0.0;
      if (oldTxn.type == 'Expense' || oldTxn.type == 'Transfer Out') {
        oldEffect = -oldTxn.amount;
      } else {
        oldEffect = oldTxn.amount;
      }

      double newEffect = 0.0;
      if (newTxn.type == 'Expense' || newTxn.type == 'Transfer Out') {
        newEffect = -newTxn.amount;
      } else {
        newEffect = newTxn.amount;
      }

      double netChange = newEffect - oldEffect;

      transaction
          .update(accRef, {'currentBalance': FieldValue.increment(netChange)});
      transaction.update(txnRef, newTxn.toMap());
    });
  }

  Future<void> _updateAccountBalance(
      String accountId, double amount, String type,
      {required bool isAdding}) async {
    double change = 0.0;
    if (type == 'Expense' || type == 'Transfer Out') {
      change = -amount;
    } else if (type == 'Income' || type == 'Transfer In') {
      change = amount;
    }
    if (!isAdding) change = -change;

    await _db
        .collection(FirebaseConstants.expenseAccounts)
        .doc(accountId)
        .update({'currentBalance': FieldValue.increment(change)});
  }

  Stream<List<ExpenseTransactionModel>> getAllRecentTransactions(
      {int limit = 20}) {
    return _db
        .collection(FirebaseConstants.expenseTransactions)
        .orderBy('date', descending: true)
        .limit(limit)
        .snapshots()
        .map((s) => s.docs
            .map((d) => ExpenseTransactionModel.fromFirestore(d))
            .toList());
  }
}
