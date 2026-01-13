// // lib/features/credit_tracker/services/credit_service.dart

// import 'package:cloud_firestore/cloud_firestore.dart';
// import '../../../core/constants/firebase_constants.dart';
// import '../../daily_expense/services/expense_service.dart';
// import '../models/credit_models.dart';

// class CreditService {
//   final FirebaseFirestore _db = FirebaseFirestore.instance;

//   // --- CARDS ---
//   Stream<List<CreditCardModel>> getCreditCards() {
//     return _db
//         .collection(FirebaseConstants.creditCards)
//         .where('isArchived', isEqualTo: false)
//         .orderBy('createdAt', descending: true)
//         .snapshots()
//         .map(
//           (s) => s.docs.map((d) => CreditCardModel.fromFirestore(d)).toList(),
//         );
//   }

//   Future<void> addCreditCard(CreditCardModel card) {
//     return _db.collection(FirebaseConstants.creditCards).add(card.toMap());
//   }

//   Future<void> updateCreditCard(CreditCardModel card) async {
//     await _db
//         .collection(FirebaseConstants.creditCards)
//         .doc(card.id)
//         .update(card.toMap());
//   }

//   Future<void> deleteCreditCard(String cardId) async {
//     final batch = _db.batch();
//     final cardRef = _db.collection(FirebaseConstants.creditCards).doc(cardId);
//     batch.delete(cardRef);

//     final txnsSnapshot = await _db
//         .collection(FirebaseConstants.creditTransactions)
//         .where('cardId', isEqualTo: cardId)
//         .get();

//     for (final doc in txnsSnapshot.docs) {
//       batch.delete(doc.reference);
//     }
//     await batch.commit();
//   }

//   // --- TRANSACTIONS ---

//   // [NEW] Added global fetch for Dashboard/Charts
//   Stream<List<CreditTransactionModel>> getAllTransactions() {
//     return _db
//         .collection(FirebaseConstants.creditTransactions)
//         .orderBy('date', descending: true)
//         .snapshots()
//         .map(
//           (s) => s.docs
//               .map((d) => CreditTransactionModel.fromFirestore(d))
//               .toList(),
//         );
//   }

//   Stream<List<CreditTransactionModel>> getTransactionsForCard(String cardId) {
//     return _db
//         .collection(FirebaseConstants.creditTransactions)
//         .where('cardId', isEqualTo: cardId)
//         .orderBy('date', descending: true)
//         .snapshots()
//         .map(
//           (s) => s.docs
//               .map((d) => CreditTransactionModel.fromFirestore(d))
//               .toList(),
//         );
//   }

//   Future<void> addTransaction(CreditTransactionModel txn) async {
//     final batch = _db.batch();
//     final txnRef = _db.collection(FirebaseConstants.creditTransactions).doc();

//     final newTxn = CreditTransactionModel(
//       id: txnRef.id,
//       cardId: txn.cardId,
//       amount: txn.amount,
//       date: txn.date,
//       bucket: txn.bucket,
//       type: txn.type,
//       category: txn.category,
//       subCategory: txn.subCategory,
//       notes: txn.notes,
//       linkedExpenseId: txn.linkedExpenseId,
//     );

//     batch.set(txnRef, newTxn.toMap());

//     final cardRef =
//         _db.collection(FirebaseConstants.creditCards).doc(txn.cardId);
//     double delta = txn.type == 'Expense' ? txn.amount : -txn.amount;

//     batch.update(cardRef, {'currentBalance': FieldValue.increment(delta)});
//     await batch.commit();
//   }

//   Future<void> deleteTransaction(CreditTransactionModel txn) async {
//     final batch = _db.batch();
//     final txnRef =
//         _db.collection(FirebaseConstants.creditTransactions).doc(txn.id);
//     final cardRef =
//         _db.collection(FirebaseConstants.creditCards).doc(txn.cardId);

//     batch.delete(txnRef);

//     double reverseDelta = txn.type == 'Expense' ? -txn.amount : txn.amount;
//     batch.update(cardRef, {
//       'currentBalance': FieldValue.increment(reverseDelta),
//     });

//     await batch.commit();

//     if (txn.linkedExpenseId != null && txn.linkedExpenseId!.isNotEmpty) {
//       await ExpenseService().deleteTransactionFromCredit(txn.linkedExpenseId!);
//     }
//   }

//   Future<void> updateTransaction(CreditTransactionModel newTxn) async {
//     await _db.runTransaction((transaction) async {
//       final txnRef =
//           _db.collection(FirebaseConstants.creditTransactions).doc(newTxn.id);
//       final cardRef =
//           _db.collection(FirebaseConstants.creditCards).doc(newTxn.cardId);

//       final docSnapshot = await transaction.get(txnRef);
//       if (!docSnapshot.exists) throw Exception("Transaction does not exist!");
//       final oldTxn = CreditTransactionModel.fromFirestore(docSnapshot);

//       double oldEffect =
//           oldTxn.type == 'Expense' ? oldTxn.amount : -oldTxn.amount;
//       double newEffect =
//           newTxn.type == 'Expense' ? newTxn.amount : -newTxn.amount;
//       double netChange = newEffect - oldEffect;

//       transaction.update(cardRef, {
//         'currentBalance': FieldValue.increment(netChange),
//       });

//       transaction.update(txnRef, newTxn.toMap());
//     });

//     if (newTxn.linkedExpenseId != null && newTxn.linkedExpenseId!.isNotEmpty) {
//       await ExpenseService().updateTransactionFromCredit(
//           newTxn.linkedExpenseId!, newTxn.amount, newTxn.date);
//     }
//   }

//   // --- INTERNAL / SYNC HELPERS ---

//   Future<void> updateTransactionFromExpense(
//       String expenseId, double newAmount, Timestamp newDate) async {
//     final snapshot = await _db
//         .collection(FirebaseConstants.creditTransactions)
//         .where('linkedExpenseId', isEqualTo: expenseId)
//         .get();

//     for (var doc in snapshot.docs) {
//       final oldTxn = CreditTransactionModel.fromFirestore(doc);

//       await _db.runTransaction((transaction) async {
//         final cardRef =
//             _db.collection(FirebaseConstants.creditCards).doc(oldTxn.cardId);

//         double oldEffect =
//             oldTxn.type == 'Expense' ? oldTxn.amount : -oldTxn.amount;
//         double newEffect = oldTxn.type == 'Expense' ? newAmount : -newAmount;
//         double netChange = newEffect - oldEffect;

//         transaction.update(cardRef, {
//           'currentBalance': FieldValue.increment(netChange),
//         });
//         transaction.update(doc.reference, {
//           'amount': newAmount,
//           'date': newDate,
//         });
//       });
//     }
//   }

//   Future<void> deleteTransactionFromExpense(String expenseId) async {
//     final snapshot = await _db
//         .collection(FirebaseConstants.creditTransactions)
//         .where('linkedExpenseId', isEqualTo: expenseId)
//         .get();

//     for (var doc in snapshot.docs) {
//       final txn = CreditTransactionModel.fromFirestore(doc);
//       final batch = _db.batch();
//       batch.delete(doc.reference);

//       final cardRef =
//           _db.collection(FirebaseConstants.creditCards).doc(txn.cardId);
//       double reverseDelta = txn.type == 'Expense' ? -txn.amount : txn.amount;
//       batch.update(cardRef, {
//         'currentBalance': FieldValue.increment(reverseDelta),
//       });

//       await batch.commit();
//     }
//   }
// }

import 'package:drift/drift.dart' as drift;
import 'package:uuid/uuid.dart';

import '../../../../core/database/app_database.dart';
import '../models/credit_models.dart';
import 'credit_service.dart';

class CreditService {
  final AppDatabase _db = AppDatabase.instance;
  final _uuid = const Uuid();

  // --- Mappers ---
  CreditCardModel _mapCard(CreditCard row) {
    return CreditCardModel(
      id: row.id,
      name: row.name,
      bankName: row.bankName,
      lastFourDigits: row.lastFourDigits,
      creditLimit: row.creditLimit,
      currentBalance: row.currentBalance,
      billDate: row.billDate,
      dueDate: row.dueDate,
      color: row.color,
      isArchived: row.isArchived,
      // Fix: Convert DateTime -> Timestamp
      createdAt: DateTime.timestamp(),
    );
  }

  CreditTransactionModel _mapTxn(CreditTransaction row) {
    return CreditTransactionModel(
      id: row.id,
      cardId: row.cardId,
      amount: row.amount,
      // Fix: Convert DateTime -> Timestamp
      date: DateTime.timestamp(),
      bucket: row.bucket,
      type: row.type,
      category: row.category,
      subCategory: row.subCategory,
      notes: row.notes,
      linkedExpenseId: row.linkedExpenseId,
      includeInNextStatement: row.includeInNextStatement,
      isSettlementVerified: row.isSettlementVerified,
    );
  }

  // --- Cards ---
  @override
  Stream<List<CreditCardModel>> getCreditCards() {
    return (_db.select(_db.creditCards)
          ..where((t) => t.isArchived.equals(false))
          ..orderBy([
            (t) => drift.OrderingTerm(
                expression: t.createdAt, mode: drift.OrderingMode.desc)
          ]))
        .watch()
        .map((rows) => rows.map(_mapCard).toList());
  }

  @override
  Future<void> addCreditCard(CreditCardModel card) async {
    final id = card.id.isEmpty ? _uuid.v4() : card.id;
    await _db.into(_db.creditCards).insert(CreditCardsCompanion.insert(
          id: id,
          name: card.name,
          bankName: card.bankName,
          lastFourDigits: drift.Value(card.lastFourDigits),
          creditLimit: card.creditLimit,
          currentBalance: drift.Value(card.currentBalance),
          billDate: card.billDate,
          dueDate: card.dueDate,
          color: drift.Value(card.color),
          isArchived: drift.Value(card.isArchived),
          // Fix: Convert Timestamp -> DateTime
          createdAt: DateTime.timestamp(),
        ));
  }

  @override
  Future<void> updateCreditCard(CreditCardModel card) async {
    await (_db.update(_db.creditCards)..where((t) => t.id.equals(card.id)))
        .write(CreditCardsCompanion(
      name: drift.Value(card.name),
      bankName: drift.Value(card.bankName),
      creditLimit: drift.Value(card.creditLimit),
      currentBalance: drift.Value(card.currentBalance),
      billDate: drift.Value(card.billDate),
      dueDate: drift.Value(card.dueDate),
      color: drift.Value(card.color),
      isArchived: drift.Value(card.isArchived),
    ));
  }

  @override
  Future<void> deleteCreditCard(String cardId) async {
    await _db.transaction(() async {
      await (_db.delete(_db.creditTransactions)
            ..where((t) => t.cardId.equals(cardId)))
          .go();
      await (_db.delete(_db.creditCards)..where((t) => t.id.equals(cardId)))
          .go();
    });
  }

  // --- Transactions ---
  @override
  Stream<List<CreditTransactionModel>> getAllTransactions() {
    return (_db.select(_db.creditTransactions)
          ..orderBy([
            (t) => drift.OrderingTerm(
                expression: t.date, mode: drift.OrderingMode.desc)
          ]))
        .watch()
        .map((rows) => rows.map(_mapTxn).toList());
  }

  @override
  Stream<List<CreditTransactionModel>> getTransactionsForCard(String cardId) {
    return (_db.select(_db.creditTransactions)
          ..where((t) => t.cardId.equals(cardId))
          ..orderBy([
            (t) => drift.OrderingTerm(
                expression: t.date, mode: drift.OrderingMode.desc)
          ]))
        .watch()
        .map((rows) => rows.map(_mapTxn).toList());
  }

  @override
  Future<void> addTransaction(CreditTransactionModel txn) async {
    final docId = txn.id.isNotEmpty ? txn.id : _uuid.v4();
    await _db.transaction(() async {
      await _db
          .into(_db.creditTransactions)
          .insert(CreditTransactionsCompanion.insert(
            id: docId,
            cardId: txn.cardId,
            amount: txn.amount,
            // Fix: Convert Timestamp -> DateTime
            date: DateTime.timestamp(),
            bucket: txn.bucket,
            type: txn.type,
            category: txn.category,
            subCategory: txn.subCategory,
            notes: drift.Value(txn.notes),
            linkedExpenseId: drift.Value(txn.linkedExpenseId),
            includeInNextStatement: drift.Value(txn.includeInNextStatement),
            isSettlementVerified: drift.Value(txn.isSettlementVerified),
          ));

      // Update Balance
      final card = await (_db.select(_db.creditCards)
            ..where((t) => t.id.equals(txn.cardId)))
          .getSingle();
      double delta = txn.type == 'Expense' ? txn.amount : -txn.amount;

      await (_db.update(_db.creditCards)..where((t) => t.id.equals(txn.cardId)))
          .write(CreditCardsCompanion(
              currentBalance: drift.Value(card.currentBalance + delta)));
    });
  }

  @override
  Future<void> deleteTransaction(CreditTransactionModel txn) async {
    await _db.transaction(() async {
      await (_db.delete(_db.creditTransactions)
            ..where((t) => t.id.equals(txn.id)))
          .go();

      final card = await (_db.select(_db.creditCards)
            ..where((t) => t.id.equals(txn.cardId)))
          .getSingle();
      double reverseDelta = txn.type == 'Expense' ? -txn.amount : txn.amount;

      await (_db.update(_db.creditCards)..where((t) => t.id.equals(txn.cardId)))
          .write(CreditCardsCompanion(
              currentBalance: drift.Value(card.currentBalance + reverseDelta)));
    });
  }
}
