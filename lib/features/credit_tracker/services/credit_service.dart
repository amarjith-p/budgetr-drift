// lib/features/credit_tracker/services/credit_service.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../core/constants/firebase_constants.dart';
import '../../daily_expense/services/expense_service.dart';
import '../models/credit_models.dart';

class CreditService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // --- CARDS ---
  Stream<List<CreditCardModel>> getCreditCards() {
    return _db
        .collection(FirebaseConstants.creditCards)
        .where('isArchived', isEqualTo: false)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (s) => s.docs.map((d) => CreditCardModel.fromFirestore(d)).toList(),
        );
  }

  Future<void> addCreditCard(CreditCardModel card) {
    return _db.collection(FirebaseConstants.creditCards).add(card.toMap());
  }

  Future<void> updateCreditCard(CreditCardModel card) async {
    await _db
        .collection(FirebaseConstants.creditCards)
        .doc(card.id)
        .update(card.toMap());
  }

  Future<void> deleteCreditCard(String cardId) async {
    final batch = _db.batch();
    final cardRef = _db.collection(FirebaseConstants.creditCards).doc(cardId);
    batch.delete(cardRef);

    final txnsSnapshot = await _db
        .collection(FirebaseConstants.creditTransactions)
        .where('cardId', isEqualTo: cardId)
        .get();

    for (final doc in txnsSnapshot.docs) {
      batch.delete(doc.reference);
    }
    await batch.commit();
  }

  // --- TRANSACTIONS ---

  // [NEW] Added global fetch for Dashboard/Charts
  Stream<List<CreditTransactionModel>> getAllTransactions() {
    return _db
        .collection(FirebaseConstants.creditTransactions)
        .orderBy('date', descending: true)
        .snapshots()
        .map(
          (s) => s.docs
              .map((d) => CreditTransactionModel.fromFirestore(d))
              .toList(),
        );
  }

  Stream<List<CreditTransactionModel>> getTransactionsForCard(String cardId) {
    return _db
        .collection(FirebaseConstants.creditTransactions)
        .where('cardId', isEqualTo: cardId)
        .orderBy('date', descending: true)
        .snapshots()
        .map(
          (s) => s.docs
              .map((d) => CreditTransactionModel.fromFirestore(d))
              .toList(),
        );
  }

  Future<void> addTransaction(CreditTransactionModel txn) async {
    final batch = _db.batch();
    final txnRef = _db.collection(FirebaseConstants.creditTransactions).doc();

    final newTxn = CreditTransactionModel(
      id: txnRef.id,
      cardId: txn.cardId,
      amount: txn.amount,
      date: txn.date,
      bucket: txn.bucket,
      type: txn.type,
      category: txn.category,
      subCategory: txn.subCategory,
      notes: txn.notes,
      linkedExpenseId: txn.linkedExpenseId,
    );

    batch.set(txnRef, newTxn.toMap());

    final cardRef =
        _db.collection(FirebaseConstants.creditCards).doc(txn.cardId);
    double delta = txn.type == 'Expense' ? txn.amount : -txn.amount;

    batch.update(cardRef, {'currentBalance': FieldValue.increment(delta)});
    await batch.commit();
  }

  Future<void> deleteTransaction(CreditTransactionModel txn) async {
    final batch = _db.batch();
    final txnRef =
        _db.collection(FirebaseConstants.creditTransactions).doc(txn.id);
    final cardRef =
        _db.collection(FirebaseConstants.creditCards).doc(txn.cardId);

    batch.delete(txnRef);

    double reverseDelta = txn.type == 'Expense' ? -txn.amount : txn.amount;
    batch.update(cardRef, {
      'currentBalance': FieldValue.increment(reverseDelta),
    });

    await batch.commit();

    if (txn.linkedExpenseId != null && txn.linkedExpenseId!.isNotEmpty) {
      await ExpenseService().deleteTransactionFromCredit(txn.linkedExpenseId!);
    }
  }

  Future<void> updateTransaction(CreditTransactionModel newTxn) async {
    await _db.runTransaction((transaction) async {
      final txnRef =
          _db.collection(FirebaseConstants.creditTransactions).doc(newTxn.id);
      final cardRef =
          _db.collection(FirebaseConstants.creditCards).doc(newTxn.cardId);

      final docSnapshot = await transaction.get(txnRef);
      if (!docSnapshot.exists) throw Exception("Transaction does not exist!");
      final oldTxn = CreditTransactionModel.fromFirestore(docSnapshot);

      double oldEffect =
          oldTxn.type == 'Expense' ? oldTxn.amount : -oldTxn.amount;
      double newEffect =
          newTxn.type == 'Expense' ? newTxn.amount : -newTxn.amount;
      double netChange = newEffect - oldEffect;

      transaction.update(cardRef, {
        'currentBalance': FieldValue.increment(netChange),
      });

      transaction.update(txnRef, newTxn.toMap());
    });

    if (newTxn.linkedExpenseId != null && newTxn.linkedExpenseId!.isNotEmpty) {
      await ExpenseService().updateTransactionFromCredit(
          newTxn.linkedExpenseId!, newTxn.amount, newTxn.date);
    }
  }

  // --- INTERNAL / SYNC HELPERS ---

  Future<void> updateTransactionFromExpense(
      String expenseId, double newAmount, Timestamp newDate) async {
    final snapshot = await _db
        .collection(FirebaseConstants.creditTransactions)
        .where('linkedExpenseId', isEqualTo: expenseId)
        .get();

    for (var doc in snapshot.docs) {
      final oldTxn = CreditTransactionModel.fromFirestore(doc);

      await _db.runTransaction((transaction) async {
        final cardRef =
            _db.collection(FirebaseConstants.creditCards).doc(oldTxn.cardId);

        double oldEffect =
            oldTxn.type == 'Expense' ? oldTxn.amount : -oldTxn.amount;
        double newEffect = oldTxn.type == 'Expense' ? newAmount : -newAmount;
        double netChange = newEffect - oldEffect;

        transaction.update(cardRef, {
          'currentBalance': FieldValue.increment(netChange),
        });
        transaction.update(doc.reference, {
          'amount': newAmount,
          'date': newDate,
        });
      });
    }
  }

  Future<void> deleteTransactionFromExpense(String expenseId) async {
    final snapshot = await _db
        .collection(FirebaseConstants.creditTransactions)
        .where('linkedExpenseId', isEqualTo: expenseId)
        .get();

    for (var doc in snapshot.docs) {
      final txn = CreditTransactionModel.fromFirestore(doc);
      final batch = _db.batch();
      batch.delete(doc.reference);

      final cardRef =
          _db.collection(FirebaseConstants.creditCards).doc(txn.cardId);
      double reverseDelta = txn.type == 'Expense' ? -txn.amount : txn.amount;
      batch.update(cardRef, {
        'currentBalance': FieldValue.increment(reverseDelta),
      });

      await batch.commit();
    }
  }
}
