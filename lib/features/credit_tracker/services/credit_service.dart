import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../core/constants/firebase_constants.dart';
import '../models/credit_models.dart';

class CreditService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // --- Cards ---
  Stream<List<CreditCardModel>> getCreditCards() {
    return _db
        .collection(FirebaseConstants.creditCards)
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

  // --- Transactions ---
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
    batch.set(txnRef, txn.toMap());

    // Expense adds to debt (+), Income reduces debt (-)
    final cardRef = _db
        .collection(FirebaseConstants.creditCards)
        .doc(txn.cardId);
    double delta = txn.type == 'Expense' ? txn.amount : -txn.amount;

    batch.update(cardRef, {'currentBalance': FieldValue.increment(delta)});

    await batch.commit();
  }

  Future<void> deleteTransaction(CreditTransactionModel txn) async {
    final batch = _db.batch();

    final txnRef = _db
        .collection(FirebaseConstants.creditTransactions)
        .doc(txn.id);
    final cardRef = _db
        .collection(FirebaseConstants.creditCards)
        .doc(txn.cardId);

    batch.delete(txnRef);

    // Reverse the effect:
    // If it was Expense (+), we subtract (-).
    // If it was Income (-), we add (+).
    double reverseDelta = txn.type == 'Expense' ? -txn.amount : txn.amount;

    batch.update(cardRef, {
      'currentBalance': FieldValue.increment(reverseDelta),
    });

    await batch.commit();
  }

  Future<void> updateTransaction(CreditTransactionModel newTxn) async {
    // Run inside a transaction to safely read the OLD value and update balance
    return _db.runTransaction((transaction) async {
      final txnRef = _db
          .collection(FirebaseConstants.creditTransactions)
          .doc(newTxn.id);
      final cardRef = _db
          .collection(FirebaseConstants.creditCards)
          .doc(newTxn.cardId);

      // 1. Get Old Data
      final docSnapshot = await transaction.get(txnRef);
      if (!docSnapshot.exists) {
        throw Exception("Transaction does not exist!");
      }
      final oldTxn = CreditTransactionModel.fromFirestore(docSnapshot);

      // 2. Calculate Balance Adjustments
      // Remove old effect
      double oldEffect = oldTxn.type == 'Expense'
          ? oldTxn.amount
          : -oldTxn.amount;
      // Add new effect
      double newEffect = newTxn.type == 'Expense'
          ? newTxn.amount
          : -newTxn.amount;

      double netChange = newEffect - oldEffect;

      // 3. Update Card Balance
      transaction.update(cardRef, {
        'currentBalance': FieldValue.increment(netChange),
      });

      // 4. Update Transaction Document
      transaction.update(txnRef, newTxn.toMap());
    });
  }
}
