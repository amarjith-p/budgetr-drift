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

    // 1. Delete the Card Document
    final cardRef = _db.collection(FirebaseConstants.creditCards).doc(cardId);
    batch.delete(cardRef);

    // 2. Delete all related Transactions
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

    // 1. Add Transaction
    final txnRef = _db.collection(FirebaseConstants.creditTransactions).doc();
    batch.set(txnRef, txn.toMap());

    // 2. Update Card Balance
    // Expense increases balance (debt), Income (Repayment) decreases it
    final cardRef = _db
        .collection(FirebaseConstants.creditCards)
        .doc(txn.cardId);

    // We use FieldValue.increment for atomic updates
    double delta = txn.type == 'Expense' ? txn.amount : -txn.amount;

    batch.update(cardRef, {'currentBalance': FieldValue.increment(delta)});

    await batch.commit();
  }
}
