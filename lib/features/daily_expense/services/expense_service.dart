import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../core/constants/firebase_constants.dart';
import '../models/expense_models.dart';

class ExpenseService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // --- ACCOUNTS ---

  Stream<List<ExpenseAccountModel>> getAccounts() {
    return _db
        .collection(FirebaseConstants.expenseAccounts)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((s) =>
            s.docs.map((d) => ExpenseAccountModel.fromFirestore(d)).toList());
  }

  Future<void> addAccount(ExpenseAccountModel account) {
    // Use .set() with the generated ID to ensure Document ID matches Model ID
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

  // --- TRANSACTIONS ---

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
    // Use the ID generated in the sheet or generate a new one if empty
    final docId = txn.id.isNotEmpty
        ? txn.id
        : _db.collection(FirebaseConstants.expenseTransactions).doc().id;

    final txnRef =
        _db.collection(FirebaseConstants.expenseTransactions).doc(docId);

    // Ensure the ID in the model matches the Document ID
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
      transferAccountBankName: txn.transferAccountBankName, // NEW
    );

    batch.set(txnRef, txnToSave.toMap());

    // Update Balance Logic
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
    // 1. Delete Main Transaction
    await _db
        .collection(FirebaseConstants.expenseTransactions)
        .doc(txn.id)
        .delete();

    // 2. Revert Balance Effect
    await _updateAccountBalance(txn.accountId, txn.amount, txn.type,
        isAdding: false);

    // 3. Handle Linked Transfer Deletion
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

      // 1. Calculate Net Change
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

  // Helper to update balance cleanly
  Future<void> _updateAccountBalance(
      String accountId, double amount, String type,
      {required bool isAdding}) async {
    double change = 0.0;

    if (type == 'Expense' || type == 'Transfer Out') {
      change = -amount;
    } else if (type == 'Income' || type == 'Transfer In') {
      change = amount;
    }

    if (!isAdding) {
      change = -change;
    }

    await _db
        .collection(FirebaseConstants.expenseAccounts)
        .doc(accountId)
        .update({
      'currentBalance': FieldValue.increment(change),
    });
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
