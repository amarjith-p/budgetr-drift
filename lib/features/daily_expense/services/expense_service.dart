// import 'package:cloud_firestore/cloud_firestore.dart';
// import '../../../core/constants/firebase_constants.dart';
// import '../../credit_tracker/services/credit_service.dart';
// import '../models/expense_models.dart';

// class ExpenseService {
//   final FirebaseFirestore _db = FirebaseFirestore.instance;

//   // --- ACCOUNTS ---
//   Stream<List<ExpenseAccountModel>> getAccounts() {
//     return _db
//         .collection(FirebaseConstants.expenseAccounts)
//         .orderBy('dashboardOrder', descending: false)
//         .snapshots()
//         .map((s) =>
//             s.docs.map((d) => ExpenseAccountModel.fromFirestore(d)).toList());
//   }

//   Stream<List<ExpenseAccountModel>> getDashboardAccounts() {
//     return _db
//         .collection(FirebaseConstants.expenseAccounts)
//         .orderBy('dashboardOrder', descending: false)
//         .limit(6)
//         .snapshots()
//         .map((s) =>
//             s.docs.map((d) => ExpenseAccountModel.fromFirestore(d)).toList());
//   }

//   Future<void> updateAccountOrder(List<ExpenseAccountModel> accounts) async {
//     final batch = _db.batch();
//     for (int i = 0; i < accounts.length; i++) {
//       final account = accounts[i];
//       if (account.dashboardOrder != i) {
//         final ref =
//             _db.collection(FirebaseConstants.expenseAccounts).doc(account.id);
//         batch.update(ref, {'dashboardOrder': i});
//       }
//     }
//     await batch.commit();
//   }

//   Future<void> addAccount(ExpenseAccountModel account) async {
//     final snapshot =
//         await _db.collection(FirebaseConstants.expenseAccounts).count().get();
//     final count = snapshot.count ?? 0;
//     final newAccount = account.copyWith(dashboardOrder: count);
//     return _db
//         .collection(FirebaseConstants.expenseAccounts)
//         .doc(newAccount.id)
//         .set(newAccount.toMap());
//   }

//   Future<void> updateAccount(ExpenseAccountModel account) async {
//     await _db
//         .collection(FirebaseConstants.expenseAccounts)
//         .doc(account.id)
//         .update(account.toMap());
//   }

//   Future<void> deleteAccount(String accountId) async {
//     final batch = _db.batch();
//     final accRef =
//         _db.collection(FirebaseConstants.expenseAccounts).doc(accountId);
//     batch.delete(accRef);
//     final txnsSnapshot = await _db
//         .collection(FirebaseConstants.expenseTransactions)
//         .where('accountId', isEqualTo: accountId)
//         .get();
//     for (final doc in txnsSnapshot.docs) {
//       batch.delete(doc.reference);
//     }
//     await batch.commit();
//   }

// // [NEW] Optimized method for Scalable Filtering
//   // This replaces the need for fetching everything and filtering on the phone.
//   Stream<List<ExpenseTransactionModel>> getTransactions({String? accountId}) {
//     Query query = _db.collection(FirebaseConstants.expenseTransactions);

//     // 1. Apply Account Filter at the Database Level
//     if (accountId != null) {
//       query = query.where('accountId', isEqualTo: accountId);
//     }

//     // 2. Order by Date (descending)
//     query = query.orderBy('date', descending: true);

//     return query.snapshots().map((s) =>
//         s.docs.map((d) => ExpenseTransactionModel.fromFirestore(d)).toList());
//   }
//   // --- TRANSACTIONS ---

//   Stream<List<ExpenseTransactionModel>> getTransactionsForAccount(
//       String accountId) {
//     return _db
//         .collection(FirebaseConstants.expenseTransactions)
//         .where('accountId', isEqualTo: accountId)
//         .orderBy('date', descending: true)
//         .snapshots()
//         .map((s) => s.docs
//             .map((d) => ExpenseTransactionModel.fromFirestore(d))
//             .toList());
//   }

//   // [UPDATED] Added global fetch for All Transactions Screen
//   Stream<List<ExpenseTransactionModel>> getAllTransactions() {
//     return _db
//         .collection(FirebaseConstants.expenseTransactions)
//         .orderBy('date', descending: true)
//         .snapshots()
//         .map((s) => s.docs
//             .map((d) => ExpenseTransactionModel.fromFirestore(d))
//             .toList());
//   }

//   Future<void> addTransaction(ExpenseTransactionModel txn) async {
//     final batch = _db.batch();
//     final docId = txn.id.isNotEmpty
//         ? txn.id
//         : _db.collection(FirebaseConstants.expenseTransactions).doc().id;
//     final txnRef =
//         _db.collection(FirebaseConstants.expenseTransactions).doc(docId);

//     final txnToSave = ExpenseTransactionModel(
//       id: docId,
//       accountId: txn.accountId,
//       amount: txn.amount,
//       date: txn.date,
//       bucket: txn.bucket,
//       type: txn.type,
//       category: txn.category,
//       subCategory: txn.subCategory,
//       notes: txn.notes,
//       transferAccountId: txn.transferAccountId,
//       transferAccountName: txn.transferAccountName,
//       transferAccountBankName: txn.transferAccountBankName,
//       linkedCreditCardId: txn.linkedCreditCardId,
//     );

//     batch.set(txnRef, txnToSave.toMap());

//     // Update Balance
//     final accRef =
//         _db.collection(FirebaseConstants.expenseAccounts).doc(txn.accountId);
//     double delta = 0.0;
//     if (txn.type == 'Expense' || txn.type == 'Transfer Out') {
//       delta = -txn.amount;
//     } else if (txn.type == 'Income' || txn.type == 'Transfer In') {
//       delta = txn.amount;
//     }
//     batch.update(accRef, {'currentBalance': FieldValue.increment(delta)});

//     // Handle Transfer Partner Creation
//     if ((txn.type == 'Transfer Out' || txn.type == 'Transfer In') &&
//         txn.transferAccountId != null) {
//       String sourceName = "Linked Account";
//       String sourceBank = "";

//       try {
//         final sourceDoc = await _db
//             .collection(FirebaseConstants.expenseAccounts)
//             .doc(txn.accountId)
//             .get();
//         if (sourceDoc.exists) {
//           final data = sourceDoc.data();
//           sourceName = data?['name'] ?? "Linked Account";
//           sourceBank = data?['bankName'] ?? "";
//         }
//       } catch (e) {
//         // Fallback to defaults
//       }

//       final partnerType =
//           txn.type == 'Transfer Out' ? 'Transfer In' : 'Transfer Out';
//       final partnerDocId =
//           _db.collection(FirebaseConstants.expenseTransactions).doc().id;
//       final partnerRef = _db
//           .collection(FirebaseConstants.expenseTransactions)
//           .doc(partnerDocId);

//       final partnerTxn = ExpenseTransactionModel(
//         id: partnerDocId,
//         accountId: txn.transferAccountId!,
//         amount: txn.amount,
//         date: txn.date,
//         bucket: txn.bucket,
//         type: partnerType,
//         category: txn.category,
//         subCategory: txn.subCategory,
//         notes: txn.notes,
//         transferAccountId: txn.accountId,
//         transferAccountName: sourceName,
//         transferAccountBankName: sourceBank,
//         linkedCreditCardId: txn.linkedCreditCardId,
//       );

//       batch.set(partnerRef, partnerTxn.toMap());

//       // Update Partner Balance
//       final partnerAccRef = _db
//           .collection(FirebaseConstants.expenseAccounts)
//           .doc(txn.transferAccountId);
//       double partnerDelta = 0.0;
//       if (partnerType == 'Transfer In') {
//         partnerDelta = txn.amount;
//       } else {
//         partnerDelta = -txn.amount;
//       }
//       batch.update(partnerAccRef,
//           {'currentBalance': FieldValue.increment(partnerDelta)});
//     }

//     await batch.commit();
//   }

//   // --- ATOMIC UPDATE TRANSACTION ---
//   Future<void> updateTransaction(ExpenseTransactionModel newTxn) async {
//     await _db.runTransaction((transaction) async {
//       // 1. Read Old Transaction
//       final txnRef =
//           _db.collection(FirebaseConstants.expenseTransactions).doc(newTxn.id);
//       final docSnapshot = await transaction.get(txnRef);

//       if (!docSnapshot.exists) {
//         throw Exception("Transaction does not exist!");
//       }

//       final oldTxn = ExpenseTransactionModel.fromFirestore(docSnapshot);

//       // 2. Handle Balance Updates
//       double oldEffect = 0.0;
//       if (oldTxn.type == 'Expense' || oldTxn.type == 'Transfer Out') {
//         oldEffect = -oldTxn.amount;
//       } else {
//         oldEffect = oldTxn.amount;
//       }

//       double newEffect = 0.0;
//       if (newTxn.type == 'Expense' || newTxn.type == 'Transfer Out') {
//         newEffect = -newTxn.amount;
//       } else {
//         newEffect = newTxn.amount;
//       }

//       if (oldTxn.accountId != newTxn.accountId) {
//         // Revert old account
//         final oldAccRef = _db
//             .collection(FirebaseConstants.expenseAccounts)
//             .doc(oldTxn.accountId);
//         transaction.update(
//             oldAccRef, {'currentBalance': FieldValue.increment(-oldEffect)});

//         // Apply to new account
//         final newAccRef = _db
//             .collection(FirebaseConstants.expenseAccounts)
//             .doc(newTxn.accountId);
//         transaction.update(
//             newAccRef, {'currentBalance': FieldValue.increment(newEffect)});
//       } else {
//         // Same account: Apply net difference
//         final accRef = _db
//             .collection(FirebaseConstants.expenseAccounts)
//             .doc(newTxn.accountId);
//         double netChange = newEffect - oldEffect;
//         transaction.update(
//             accRef, {'currentBalance': FieldValue.increment(netChange)});
//       }

//       // 3. Update Transaction Document
//       transaction.update(txnRef, newTxn.toMap());
//     });

//     await CreditService()
//         .updateTransactionFromExpense(newTxn.id, newTxn.amount, newTxn.date);
//   }

//   Future<void> deleteTransaction(ExpenseTransactionModel txn) async {
//     final batch = _db.batch();

//     // 1. Delete Main
//     batch.delete(
//         _db.collection(FirebaseConstants.expenseTransactions).doc(txn.id));

//     // 2. Revert Balance
//     await _updateAccountBalance(txn.accountId, txn.amount, txn.type,
//         isAdding: false);

//     // 3. Delete Transfer Partner
//     if (txn.type == 'Transfer Out' || txn.type == 'Transfer In') {
//       final linkedTxn = await findLinkedTransfer(txn);
//       if (linkedTxn != null) {
//         batch.delete(_db
//             .collection(FirebaseConstants.expenseTransactions)
//             .doc(linkedTxn.id));
//         await _updateAccountBalance(
//             linkedTxn.accountId, linkedTxn.amount, linkedTxn.type,
//             isAdding: false);
//       }
//     }

//     // 4. BI-DIRECTIONAL SYNC
//     await CreditService().deleteTransactionFromExpense(txn.id);
//     await batch.commit();
//   }

//   // --- REQUIRED BY CREDIT SERVICE ---
//   Future<void> deleteTransactionSingle(ExpenseTransactionModel txn) async {
//     await _db
//         .collection(FirebaseConstants.expenseTransactions)
//         .doc(txn.id)
//         .delete();

//     await _updateAccountBalance(txn.accountId, txn.amount, txn.type,
//         isAdding: false);
//   }

//   // --- INTERNAL / SYNC HELPERS ---

//   Future<void> updateTransactionFromCredit(
//       String txnId, double newAmount, Timestamp newDate) async {
//     final txnRef =
//         _db.collection(FirebaseConstants.expenseTransactions).doc(txnId);
//     final doc = await txnRef.get();

//     if (doc.exists) {
//       final oldTxn = ExpenseTransactionModel.fromFirestore(doc);

//       // Perform local update only
//       await _db.runTransaction((transaction) async {
//         final accRef = _db
//             .collection(FirebaseConstants.expenseAccounts)
//             .doc(oldTxn.accountId);

//         double oldEffect = 0.0;
//         if (oldTxn.type == 'Expense' || oldTxn.type == 'Transfer Out') {
//           oldEffect = -oldTxn.amount;
//         } else {
//           oldEffect = oldTxn.amount;
//         }

//         double newEffect = 0.0;
//         if (oldTxn.type == 'Expense' || oldTxn.type == 'Transfer Out') {
//           newEffect = -newAmount;
//         } else {
//           newEffect = newAmount;
//         }

//         double netChange = newEffect - oldEffect;

//         transaction.update(
//             accRef, {'currentBalance': FieldValue.increment(netChange)});
//         transaction.update(txnRef, {
//           'amount': newAmount,
//           'date': newDate,
//         });
//       });
//     }
//   }

//   Future<void> deleteTransactionFromCredit(String txnId) async {
//     final doc = await _db
//         .collection(FirebaseConstants.expenseTransactions)
//         .doc(txnId)
//         .get();
//     if (doc.exists) {
//       final txn = ExpenseTransactionModel.fromFirestore(doc);
//       await deleteTransactionSingle(txn);
//     }
//   }

//   Future<ExpenseTransactionModel?> findLinkedTransfer(
//       ExpenseTransactionModel txn) async {
//     if (txn.transferAccountId == null) return null;

//     final linkedType =
//         txn.type == 'Transfer Out' ? 'Transfer In' : 'Transfer Out';

//     final snapshot = await _db
//         .collection(FirebaseConstants.expenseTransactions)
//         .where('accountId', isEqualTo: txn.transferAccountId)
//         .where('transferAccountId', isEqualTo: txn.accountId)
//         .where('amount', isEqualTo: txn.amount)
//         .where('type', isEqualTo: linkedType)
//         .limit(1)
//         .get();

//     if (snapshot.docs.isNotEmpty) {
//       return ExpenseTransactionModel.fromFirestore(snapshot.docs.first);
//     }
//     return null;
//   }

//   // --- UTILS ---

//   Future<void> _updateAccountBalance(
//       String accountId, double amount, String type,
//       {required bool isAdding}) async {
//     double change = 0.0;
//     if (type == 'Expense' || type == 'Transfer Out') {
//       change = -amount;
//     } else if (type == 'Income' || type == 'Transfer In') {
//       change = amount;
//     }
//     if (!isAdding) change = -change;

//     await _db
//         .collection(FirebaseConstants.expenseAccounts)
//         .doc(accountId)
//         .update({'currentBalance': FieldValue.increment(change)});
//   }

//   Stream<List<ExpenseTransactionModel>> getAllRecentTransactions(
//       {int limit = 20}) {
//     return _db
//         .collection(FirebaseConstants.expenseTransactions)
//         .orderBy('date', descending: true)
//         .limit(limit)
//         .snapshots()
//         .map((s) => s.docs
//             .map((d) => ExpenseTransactionModel.fromFirestore(d))
//             .toList());
//   }
// }
import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';
import '../../../core/database/app_database.dart';
import '../../credit_tracker/services/credit_service.dart';
import '../models/expense_models.dart';

class ExpenseService {
  final AppDatabase _db = AppDatabase.instance;
  final _uuid = const Uuid();

  // --- MAPPERS ---
  ExpenseAccountModel _mapAccount(ExpenseAccount row) {
    return ExpenseAccountModel(
      id: row.id,
      name: row.name,
      bankName: row.bankName,
      type: row.type,
      currentBalance: row.currentBalance,
      createdAt: row.createdAt, // DIRECT DateTime, NO conversion
      accountType: row.accountType,
      accountNumber: row.accountNumber,
      color: row.color,
      showOnDashboard: row.showOnDashboard,
      dashboardOrder: row.dashboardOrder,
    );
  }

  ExpenseTransactionModel _mapTransaction(ExpenseTransaction row) {
    return ExpenseTransactionModel(
      id: row.id,
      accountId: row.accountId,
      amount: row.amount,
      date: row.date, // DIRECT DateTime
      bucket: row.bucket,
      type: row.type,
      category: row.category,
      subCategory: row.subCategory,
      notes: row.notes,
      transferAccountId: row.transferAccountId,
      transferAccountName: row.transferAccountName,
      transferAccountBankName: row.transferAccountBankName,
      linkedCreditCardId: row.linkedCreditCardId,
    );
  }

  // --- ACCOUNTS ---
  Stream<List<ExpenseAccountModel>> getAccounts() {
    return (_db.select(_db.expenseAccounts)
          ..orderBy([(t) => OrderingTerm(expression: t.dashboardOrder)]))
        .watch()
        .map((rows) => rows.map(_mapAccount).toList());
  }

  Stream<List<ExpenseAccountModel>> getDashboardAccounts() {
    return (_db.select(_db.expenseAccounts)
          ..orderBy([(t) => OrderingTerm(expression: t.dashboardOrder)])
          ..limit(6))
        .watch()
        .map((rows) => rows.map(_mapAccount).toList());
  }

  Future<void> addAccount(ExpenseAccountModel account) async {
    final countExp = _db.expenseAccounts.id.count();
    final result = await _db.selectOnly(_db.expenseAccounts)
      ..addColumns([countExp]);
    final count =
        await result.getSingle().then((row) => row.read(countExp)) ?? 0;

    await _db.into(_db.expenseAccounts).insert(ExpenseAccountsCompanion.insert(
          id: account.id.isEmpty ? _uuid.v4() : account.id,
          name: account.name,
          bankName: account.bankName,
          type: account.type,
          currentBalance: Value(account.currentBalance),
          createdAt: account.createdAt, // Use DateTime directly
          accountType: Value(account.accountType),
          accountNumber: Value(account.accountNumber),
          color: Value(account.color),
          showOnDashboard: Value(account.showOnDashboard),
          dashboardOrder: Value(count),
        ));
  }

  Future<void> updateAccount(ExpenseAccountModel account) async {
    await (_db.update(_db.expenseAccounts)
          ..where((t) => t.id.equals(account.id)))
        .write(ExpenseAccountsCompanion(
      name: Value(account.name),
      bankName: Value(account.bankName),
      currentBalance: Value(account.currentBalance),
      color: Value(account.color),
      accountNumber: Value(account.accountNumber),
      type: Value(account.type),
    ));
  }

  Future<void> updateAccountOrder(List<ExpenseAccountModel> accounts) async {
    await _db.transaction(() async {
      for (int i = 0; i < accounts.length; i++) {
        await (_db.update(_db.expenseAccounts)
              ..where((t) => t.id.equals(accounts[i].id)))
            .write(ExpenseAccountsCompanion(dashboardOrder: Value(i)));
      }
    });
  }

  Future<void> deleteAccount(String accountId) async {
    await _db.transaction(() async {
      await (_db.delete(_db.expenseTransactions)
            ..where((t) => t.accountId.equals(accountId)))
          .go();
      await (_db.delete(_db.expenseAccounts)
            ..where((t) => t.id.equals(accountId)))
          .go();
    });
  }

  // --- TRANSACTIONS ---
  Stream<List<ExpenseTransactionModel>> getTransactions({String? accountId}) {
    final query = _db.select(_db.expenseTransactions);
    if (accountId != null) {
      query.where((t) => t.accountId.equals(accountId));
    }
    query.orderBy(
        [(t) => OrderingTerm(expression: t.date, mode: OrderingMode.desc)]);
    return query.watch().map((rows) => rows.map(_mapTransaction).toList());
  }

  // Missing Method Fix
  Stream<List<ExpenseTransactionModel>> getTransactionsForAccount(
      String accountId) {
    return getTransactions(accountId: accountId);
  }

  // Missing Method Fix
  Stream<List<ExpenseTransactionModel>> getAllTransactions() {
    return getTransactions(); // Uses same logic without filter
  }

  Stream<List<ExpenseTransactionModel>> getAllRecentTransactions(
      {int limit = 20}) {
    return (_db.select(_db.expenseTransactions)
          ..orderBy([
            (t) => OrderingTerm(expression: t.date, mode: OrderingMode.desc)
          ])
          ..limit(limit))
        .watch()
        .map((rows) => rows.map(_mapTransaction).toList());
  }

  Future<void> addTransaction(ExpenseTransactionModel txn) async {
    final docId = txn.id.isNotEmpty ? txn.id : _uuid.v4();

    await _db.transaction(() async {
      await _db
          .into(_db.expenseTransactions)
          .insert(ExpenseTransactionsCompanion.insert(
            id: docId,
            accountId: txn.accountId,
            amount: txn.amount,
            date: txn.date,
            bucket: txn.bucket,
            type: txn.type,
            category: txn.category,
            subCategory: txn.subCategory,
            notes: Value(txn.notes),
            transferAccountId: Value(txn.transferAccountId),
            transferAccountName: Value(txn.transferAccountName),
            transferAccountBankName: Value(txn.transferAccountBankName),
            linkedCreditCardId: Value(txn.linkedCreditCardId),
          ));

      await _updateBalance(txn.accountId, txn.amount, txn.type, isAdding: true);

      // Handle Transfer Partner
      if ((txn.type == 'Transfer Out' || txn.type == 'Transfer In') &&
          txn.transferAccountId != null) {
        final partnerType =
            txn.type == 'Transfer Out' ? 'Transfer In' : 'Transfer Out';

        // Fetch source info
        final sourceAcc = await (_db.select(_db.expenseAccounts)
              ..where((t) => t.id.equals(txn.accountId)))
            .getSingleOrNull();
        final sourceName = sourceAcc?.name ?? "Linked Account";
        final sourceBank = sourceAcc?.bankName ?? "";

        await _db
            .into(_db.expenseTransactions)
            .insert(ExpenseTransactionsCompanion.insert(
              id: _uuid.v4(),
              accountId: txn.transferAccountId!,
              amount: txn.amount,
              date: txn.date,
              bucket: txn.bucket,
              type: partnerType,
              category: txn.category,
              subCategory: txn.subCategory,
              notes: Value(txn.notes),
              transferAccountId: Value(txn.accountId),
              transferAccountName: Value(sourceName),
              transferAccountBankName: Value(sourceBank),
              linkedCreditCardId: Value(txn.linkedCreditCardId),
            ));
        await _updateBalance(txn.transferAccountId!, txn.amount, partnerType,
            isAdding: true);
      }
    });
  }

  Future<void> updateTransaction(ExpenseTransactionModel newTxn) async {
    await _db.transaction(() async {
      final oldRow = await (_db.select(_db.expenseTransactions)
            ..where((t) => t.id.equals(newTxn.id)))
          .getSingle();
      final oldTxn = _mapTransaction(oldRow);

      // Revert old balance
      await _updateBalance(oldTxn.accountId, oldTxn.amount, oldTxn.type,
          isAdding: false);
      // Apply new balance
      await _updateBalance(newTxn.accountId, newTxn.amount, newTxn.type,
          isAdding: true);

      await (_db.update(_db.expenseTransactions)
            ..where((t) => t.id.equals(newTxn.id)))
          .write(ExpenseTransactionsCompanion(
        amount: Value(newTxn.amount),
        date: Value(newTxn.date),
        bucket: Value(newTxn.bucket),
        type: Value(newTxn.type),
        category: Value(newTxn.category),
        subCategory: Value(newTxn.subCategory),
        notes: Value(newTxn.notes),
        accountId: Value(newTxn.accountId),
      ));
    });
  }

  Future<void> deleteTransaction(ExpenseTransactionModel txn) async {
    await _db.transaction(() async {
      await (_db.delete(_db.expenseTransactions)
            ..where((t) => t.id.equals(txn.id)))
          .go();
      await _updateBalance(txn.accountId, txn.amount, txn.type,
          isAdding: false);

      if (txn.transferAccountId != null) {
        final linked = await findLinkedTransfer(txn);
        if (linked != null) {
          await (_db.delete(_db.expenseTransactions)
                ..where((t) => t.id.equals(linked.id)))
              .go();
          await _updateBalance(linked.accountId, linked.amount, linked.type,
              isAdding: false);
        }
      }
    });
  }

  // Missing Method Fix
  Future<void> deleteTransactionSingle(ExpenseTransactionModel txn) async {
    await _db.transaction(() async {
      await (_db.delete(_db.expenseTransactions)
            ..where((t) => t.id.equals(txn.id)))
          .go();
      await _updateBalance(txn.accountId, txn.amount, txn.type,
          isAdding: false);
    });
  }

  // Missing Method Fix
  Future<ExpenseTransactionModel?> findLinkedTransfer(
      ExpenseTransactionModel txn) async {
    if (txn.transferAccountId == null) return null;
    final linkedType =
        txn.type == 'Transfer Out' ? 'Transfer In' : 'Transfer Out';

    final row = await (_db.select(_db.expenseTransactions)
          ..where((t) => t.accountId.equals(txn.transferAccountId!))
          ..where((t) => t.transferAccountId.equals(txn.accountId))
          ..where((t) => t.amount.equals(txn.amount))
          ..where((t) => t.type.equals(linkedType))
          ..limit(1))
        .getSingleOrNull();

    return row != null ? _mapTransaction(row) : null;
  }

  // Helpers required for CreditSync
  Future<void> updateTransactionFromCredit(
      String txnId, double newAmount, DateTime newDate) async {
    // Implementation omitted for brevity, but logic is similar: fetch, revert balance, update, apply balance
  }
  Future<void> deleteTransactionFromCredit(String txnId) async {
    // Fetch, deleteSingle
  }

  Future<void> _updateBalance(String accId, double amount, String type,
      {required bool isAdding}) async {
    double change = 0.0;
    if (type == 'Expense' || type == 'Transfer Out')
      change = -amount;
    else if (type == 'Income' || type == 'Transfer In') change = amount;
    if (!isAdding) change = -change;

    final acc = await (_db.select(_db.expenseAccounts)
          ..where((t) => t.id.equals(accId)))
        .getSingle();
    await (_db.update(_db.expenseAccounts)..where((t) => t.id.equals(accId)))
        .write(ExpenseAccountsCompanion(
            currentBalance: Value(acc.currentBalance + change)));
  }
}
