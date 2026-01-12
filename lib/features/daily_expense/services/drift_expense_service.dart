import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:drift/drift.dart' as drift;
import 'package:uuid/uuid.dart';

// Import your existing code
import '../../../../core/constants/firebase_constants.dart';
import '../../../../core/database/app_database.dart';
import '../models/expense_models.dart';
import 'expense_service.dart';

class DriftExpenseService extends ExpenseService {
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
      createdAt: Timestamp.fromDate(row.createdAt),
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
      date: Timestamp.fromDate(row.date),
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

  // --- ACCOUNT METHODS ---

  @override
  Stream<List<ExpenseAccountModel>> getAccounts() {
    return (_db.select(_db.expenseAccounts)
          ..orderBy([(t) => drift.OrderingTerm(expression: t.dashboardOrder)]))
        .watch()
        .map((rows) => rows.map(_mapAccount).toList());
  }

  @override
  Stream<List<ExpenseAccountModel>> getDashboardAccounts() {
    return (_db.select(_db.expenseAccounts)
          ..orderBy([(t) => drift.OrderingTerm(expression: t.dashboardOrder)])
          ..limit(6))
        .watch()
        .map((rows) => rows.map(_mapAccount).toList());
  }

  @override
  Future<void> addAccount(ExpenseAccountModel account) async {
    final countExp = _db.expenseAccounts.id.count();
    final result = await _db.selectOnly(_db.expenseAccounts)
      ..addColumns([countExp]);
    final count =
        await result.getSingle().then((row) => row.read(countExp)) ?? 0;

    final newId = account.id.isEmpty ? _uuid.v4() : account.id;

    await _db.into(_db.expenseAccounts).insert(
          ExpenseAccountsCompanion.insert(
            id: newId,
            name: account.name,
            bankName: account.bankName,
            type: account.type,
            currentBalance: drift.Value(account.currentBalance),
            createdAt: account.createdAt.toDate(),
            accountType: drift.Value(account.accountType),
            accountNumber: drift.Value(account.accountNumber),
            color: drift.Value(account.color),
            showOnDashboard: drift.Value(account.showOnDashboard),
            dashboardOrder: drift.Value(count),
          ),
        );
  }

  @override
  Future<void> updateAccount(ExpenseAccountModel account) async {
    await (_db.update(_db.expenseAccounts)
          ..where((t) => t.id.equals(account.id)))
        .write(ExpenseAccountsCompanion(
      name: drift.Value(account.name),
      bankName: drift.Value(account.bankName),
      currentBalance: drift.Value(account.currentBalance),
      // Map other fields as necessary
    ));
  }

  @override
  Future<void> updateAccountOrder(List<ExpenseAccountModel> accounts) async {
    await _db.transaction(() async {
      for (int i = 0; i < accounts.length; i++) {
        await (_db.update(_db.expenseAccounts)
              ..where((t) => t.id.equals(accounts[i].id)))
            .write(ExpenseAccountsCompanion(dashboardOrder: drift.Value(i)));
      }
    });
  }

  @override
  Future<void> deleteAccount(String accountId) async {
    await _db.transaction(() async {
      // Delete transactions first
      await (_db.delete(_db.expenseTransactions)
            ..where((t) => t.accountId.equals(accountId)))
          .go();
      // Delete account
      await (_db.delete(_db.expenseAccounts)
            ..where((t) => t.id.equals(accountId)))
          .go();
    });
  }

  // --- TRANSACTION METHODS ---

  @override
  Stream<List<ExpenseTransactionModel>> getTransactions({String? accountId}) {
    final query = _db.select(_db.expenseTransactions);
    if (accountId != null) {
      query.where((t) => t.accountId.equals(accountId));
    }
    query.orderBy([
      (t) =>
          drift.OrderingTerm(expression: t.date, mode: drift.OrderingMode.desc)
    ]);
    return query.watch().map((rows) => rows.map(_mapTransaction).toList());
  }

  @override
  Stream<List<ExpenseTransactionModel>> getAllRecentTransactions(
      {int limit = 20}) {
    return (_db.select(_db.expenseTransactions)
          ..orderBy([
            (t) => drift.OrderingTerm(
                expression: t.date, mode: drift.OrderingMode.desc)
          ])
          ..limit(limit))
        .watch()
        .map((rows) => rows.map(_mapTransaction).toList());
  }

  @override
  Future<void> addTransaction(ExpenseTransactionModel txn) async {
    final docId = txn.id.isNotEmpty ? txn.id : _uuid.v4();

    await _db.transaction(() async {
      // 1. Insert Main Transaction
      await _db.into(_db.expenseTransactions).insert(
            ExpenseTransactionsCompanion.insert(
              id: docId,
              accountId: txn.accountId,
              amount: txn.amount,
              date: txn.date.toDate(),
              bucket: txn.bucket,
              type: txn.type,
              category: txn.category,
              subCategory: txn.subCategory,
              notes: drift.Value(txn.notes),
              transferAccountId: drift.Value(txn.transferAccountId),
              transferAccountName: drift.Value(txn.transferAccountName),
              transferAccountBankName: drift.Value(txn.transferAccountBankName),
              linkedCreditCardId: drift.Value(txn.linkedCreditCardId),
            ),
          );

      // 2. Update Balance
      await _updateBalance(txn.accountId, txn.amount, txn.type, isAdding: true);

      // 3. Handle Transfer Partner
      if ((txn.type == 'Transfer Out' || txn.type == 'Transfer In') &&
          txn.transferAccountId != null) {
        final partnerType =
            txn.type == 'Transfer Out' ? 'Transfer In' : 'Transfer Out';
        final partnerDocId = _uuid.v4();

        // Fetch source details for the partner record
        final sourceAcc = await (_db.select(_db.expenseAccounts)
              ..where((t) => t.id.equals(txn.accountId)))
            .getSingleOrNull();
        final sourceName = sourceAcc?.name ?? "Linked Account";
        final sourceBank = sourceAcc?.bankName ?? "";

        await _db.into(_db.expenseTransactions).insert(
              ExpenseTransactionsCompanion.insert(
                id: partnerDocId,
                accountId: txn.transferAccountId!,
                amount: txn.amount,
                date: txn.date.toDate(),
                bucket: txn.bucket,
                type: partnerType,
                category: txn.category,
                subCategory: txn.subCategory,
                notes: drift.Value(txn.notes),
                transferAccountId: drift.Value(txn.accountId),
                transferAccountName: drift.Value(sourceName),
                transferAccountBankName: drift.Value(sourceBank),
                linkedCreditCardId: drift.Value(txn.linkedCreditCardId),
              ),
            );

        await _updateBalance(txn.transferAccountId!, txn.amount, partnerType,
            isAdding: true);
      }
    });
  }

  @override
  Future<void> updateTransaction(ExpenseTransactionModel newTxn) async {
    // This requires a read-before-write to calculate balance diffs, mirroring the Firestore Transaction logic.
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

      // Update the record
      await (_db.update(_db.expenseTransactions)
            ..where((t) => t.id.equals(newTxn.id)))
          .write(ExpenseTransactionsCompanion(
        amount: drift.Value(newTxn.amount),
        date: drift.Value(newTxn.date.toDate()),
        bucket: drift.Value(newTxn.bucket),
        type: drift.Value(newTxn.type),
        category: drift.Value(newTxn.category),
        subCategory: drift.Value(newTxn.subCategory),
        notes: drift.Value(newTxn.notes),
        accountId: drift.Value(newTxn.accountId),
      ));
    });
  }

  @override
  Future<void> deleteTransaction(ExpenseTransactionModel txn) async {
    await _db.transaction(() async {
      // 1. Delete Main
      await (_db.delete(_db.expenseTransactions)
            ..where((t) => t.id.equals(txn.id)))
          .go();

      // 2. Revert Balance
      await _updateBalance(txn.accountId, txn.amount, txn.type,
          isAdding: false);

      // 3. Delete Transfer Partner if exists
      if (txn.transferAccountId != null) {
        final linkedType =
            txn.type == 'Transfer Out' ? 'Transfer In' : 'Transfer Out';
        final partner = await (_db.select(_db.expenseTransactions)
              ..where((t) => t.accountId.equals(txn.transferAccountId!))
              ..where((t) => t.transferAccountId.equals(txn.accountId))
              ..where((t) => t.amount.equals(txn.amount))
              ..where((t) => t.type.equals(linkedType))
              ..limit(1))
            .getSingleOrNull();

        if (partner != null) {
          await (_db.delete(_db.expenseTransactions)
                ..where((t) => t.id.equals(partner.id)))
              .go();
          await _updateBalance(partner.accountId, partner.amount, partner.type,
              isAdding: false);
        }
      }
    });
  }

  // Helper
  Future<void> _updateBalance(String accId, double amount, String type,
      {required bool isAdding}) async {
    double change = 0.0;
    if (type == 'Expense' || type == 'Transfer Out') {
      change = -amount;
    } else if (type == 'Income' || type == 'Transfer In') {
      change = amount;
    }
    if (!isAdding) change = -change;

    final acc = await (_db.select(_db.expenseAccounts)
          ..where((t) => t.id.equals(accId)))
        .getSingle();
    await (_db.update(_db.expenseAccounts)..where((t) => t.id.equals(accId)))
        .write(ExpenseAccountsCompanion(
            currentBalance: drift.Value(acc.currentBalance + change)));
  }
}
