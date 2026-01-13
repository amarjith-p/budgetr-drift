import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';
import '../../../core/database/app_database.dart' as db;
import '../models/expense_models.dart';

class ExpenseService {
  final db.AppDatabase _db = db.AppDatabase.instance;
  final _uuid = const Uuid();

  // --- MAPPERS ---

  ExpenseAccountModel _mapAccount(db.ExpenseAccount row) {
    return ExpenseAccountModel(
      id: row.id,
      name: row.name,
      bankName: row.bankName,
      type: row.type,
      currentBalance: row.currentBalance,
      createdAt: row.createdAt,
      accountType: row.accountType,
      accountNumber: row.accountNumber,
      color: row.color,
      showOnDashboard: row.showOnDashboard,
      dashboardOrder: row.dashboardOrder,
    );
  }

  ExpenseTransactionModel _mapTransaction(db.ExpenseTransaction row) {
    return ExpenseTransactionModel(
      id: row.id,
      accountId: row.accountId,
      amount: row.amount,
      date: row.date,
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
          ..orderBy([
            (t) => OrderingTerm(
                expression: t.dashboardOrder, mode: OrderingMode.asc)
          ]))
        .watch()
        .map((rows) => rows.map(_mapAccount).toList());
  }

  Stream<List<ExpenseAccountModel>> getDashboardAccounts() {
    return (_db.select(_db.expenseAccounts)
          ..orderBy([
            (t) => OrderingTerm(
                expression: t.dashboardOrder, mode: OrderingMode.asc)
          ])
          ..limit(6))
        .watch()
        .map((rows) => rows.map(_mapAccount).toList());
  }

  Future<void> addAccount(ExpenseAccountModel account) async {
    await _db
        .into(_db.expenseAccounts)
        .insert(db.ExpenseAccountsCompanion.insert(
          id: account.id.isEmpty ? _uuid.v4() : account.id,
          name: account.name,
          bankName: account.bankName,
          type: Value(account.type),
          currentBalance: Value(account.currentBalance),
          createdAt: account.createdAt,
          accountType: Value(account.accountType),
          accountNumber: Value(account.accountNumber),
          color: Value(account.color),
          showOnDashboard: Value(account.showOnDashboard),
          dashboardOrder: Value(account.dashboardOrder),
        ));
  }

  Future<void> updateAccount(ExpenseAccountModel account) async {
    await (_db.update(_db.expenseAccounts)
          ..where((t) => t.id.equals(account.id)))
        .write(db.ExpenseAccountsCompanion(
      name: Value(account.name),
      bankName: Value(account.bankName),
      type: Value(account.type),
      currentBalance: Value(account.currentBalance),
      accountType: Value(account.accountType),
      accountNumber: Value(account.accountNumber),
      color: Value(account.color),
      showOnDashboard: Value(account.showOnDashboard),
      dashboardOrder: Value(account.dashboardOrder),
    ));
  }

  Future<void> updateAccountOrder(List<ExpenseAccountModel> accounts) async {
    await _db.transaction(() async {
      for (int i = 0; i < accounts.length; i++) {
        await (_db.update(_db.expenseAccounts)
              ..where((t) => t.id.equals(accounts[i].id)))
            .write(db.ExpenseAccountsCompanion(dashboardOrder: Value(i)));
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

  Stream<List<ExpenseTransactionModel>> getTransactionsForAccount(
          String accountId) =>
      getTransactions(accountId: accountId);
  Stream<List<ExpenseTransactionModel>> getAllTransactions() =>
      getTransactions();

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

  // --- ATOMIC TRANSACTION LOGIC ---

  Future<void> addTransaction(ExpenseTransactionModel txn) async {
    await _db.transaction(() async {
      final docId = txn.id.isNotEmpty ? txn.id : _uuid.v4();

      // 1. Insert Main Transaction
      await _db
          .into(_db.expenseTransactions)
          .insert(db.ExpenseTransactionsCompanion.insert(
            id: docId,
            accountId: txn.accountId,
            amount: txn.amount,
            date: txn.date,
            bucket: Value(txn.bucket),
            type: Value(txn.type),
            category: Value(txn.category),
            subCategory: Value(txn.subCategory),
            notes: Value(txn.notes),
            transferAccountId: Value(txn.transferAccountId),
            transferAccountName: Value(txn.transferAccountName),
            transferAccountBankName: Value(txn.transferAccountBankName),
            linkedCreditCardId: Value(txn.linkedCreditCardId),
          ));

      // 2. Update Source Balance
      await _updateAccountBalance(txn.accountId, txn.amount, txn.type,
          isAdding: true);

      // 3. Handle Transfer (Create Counterpart)
      if ((txn.type == 'Transfer Out' || txn.type == 'Transfer In') &&
          txn.transferAccountId != null) {
        final partnerType =
            txn.type == 'Transfer Out' ? 'Transfer In' : 'Transfer Out';

        final sourceAcc = await (_db.select(_db.expenseAccounts)
              ..where((t) => t.id.equals(txn.accountId)))
            .getSingleOrNull();
        final sourceName = sourceAcc?.name ?? "Linked Account";
        final sourceBank = sourceAcc?.bankName ?? "";

        await _db
            .into(_db.expenseTransactions)
            .insert(db.ExpenseTransactionsCompanion.insert(
              id: _uuid.v4(),
              accountId: txn.transferAccountId!,
              amount: txn.amount,
              date: txn.date,
              bucket: Value(txn.bucket),
              type: Value(partnerType),
              category: Value(txn.category),
              subCategory: Value(txn.subCategory),
              notes: Value(txn.notes),
              transferAccountId: Value(txn.accountId),
              transferAccountName: Value(sourceName),
              transferAccountBankName: Value(sourceBank),
              linkedCreditCardId: Value(txn.linkedCreditCardId),
            ));

        // 4. Update Destination Balance
        await _updateAccountBalance(
            txn.transferAccountId!, txn.amount, partnerType,
            isAdding: true);
      }
    });
  }

  Future<void> updateTransaction(ExpenseTransactionModel newTxn) async {
    await _db.transaction(() async {
      // 1. Fetch OLD transaction state
      final oldRow = await (_db.select(_db.expenseTransactions)
            ..where((t) => t.id.equals(newTxn.id)))
          .getSingle();
      final oldTxn = _mapTransaction(oldRow);

      // --- CRITICAL: PRESERVE TYPE & METADATA ---
      final isTransfer =
          (oldTxn.type == 'Transfer Out' || oldTxn.type == 'Transfer In');
      final effectiveType = isTransfer ? oldTxn.type : newTxn.type;

      final effectiveTransferId =
          newTxn.transferAccountId ?? oldTxn.transferAccountId;
      final effectiveTransferName =
          newTxn.transferAccountName ?? oldTxn.transferAccountName;
      final effectiveTransferBank =
          newTxn.transferAccountBankName ?? oldTxn.transferAccountBankName;

      // --- FIND LINKED TXN BEFORE UPDATING ---
      ExpenseTransactionModel? linkedTxn;
      if (isTransfer && oldTxn.transferAccountId != null) {
        linkedTxn = await findLinkedTransfer(oldTxn);
      }

      // 2. Revert Old Balance on MAIN Account
      await _updateAccountBalance(oldTxn.accountId, oldTxn.amount, oldTxn.type,
          isAdding: false);

      // 3. Apply New Balance on MAIN Account
      // SAFEGUARD: Use oldTxn.accountId to ensure we update the correct account even if UI sent bad ID
      await _updateAccountBalance(
          oldTxn.accountId, newTxn.amount, effectiveType,
          isAdding: true);

      // 4. Update MAIN Transaction Record
      await (_db.update(_db.expenseTransactions)
            ..where((t) => t.id.equals(newTxn.id)))
          .write(db.ExpenseTransactionsCompanion(
        amount: Value(newTxn.amount),
        date: Value(newTxn.date),
        bucket: Value(newTxn.bucket),
        type: Value(effectiveType),
        category: Value(newTxn.category),
        subCategory: Value(newTxn.subCategory),
        notes: Value(newTxn.notes),
        transferAccountId: Value(effectiveTransferId),
        transferAccountName: Value(effectiveTransferName),
        transferAccountBankName: Value(effectiveTransferBank),
      ));

      // --- 5. HANDLE LINKED TRANSFER UPDATE ---
      if (linkedTxn != null) {
        // A. Revert Balance on LINKED Account
        await _updateAccountBalance(
            linkedTxn.accountId, linkedTxn.amount, linkedTxn.type,
            isAdding: false);

        // B. Determine Linked Type
        final newLinkedType =
            effectiveType == 'Transfer Out' ? 'Transfer In' : 'Transfer Out';

        // C. Update LINKED Transaction Record
        await (_db.update(_db.expenseTransactions)
              ..where((t) => t.id.equals(linkedTxn!.id)))
            .write(db.ExpenseTransactionsCompanion(
          amount: Value(newTxn.amount),
          date: Value(newTxn.date),
          type: Value(newLinkedType),
          category: Value(newTxn.category),
          subCategory: Value(newTxn.subCategory),
          notes: Value(newTxn.notes),
        ));

        // D. Apply New Balance on LINKED Account
        await _updateAccountBalance(
            linkedTxn.accountId, newTxn.amount, newLinkedType,
            isAdding: true);
      }
    });
  }

  Future<void> deleteTransaction(ExpenseTransactionModel txn) async {
    await _db.transaction(() async {
      ExpenseTransactionModel? linkedTxn;
      if ((txn.type == 'Transfer Out' || txn.type == 'Transfer In') &&
          txn.transferAccountId != null) {
        linkedTxn = await findLinkedTransfer(txn);
      }

      await (_db.delete(_db.expenseTransactions)
            ..where((t) => t.id.equals(txn.id)))
          .go();
      await _updateAccountBalance(txn.accountId, txn.amount, txn.type,
          isAdding: false);

      if (linkedTxn != null) {
        await (_db.delete(_db.expenseTransactions)
              ..where((t) => t.id.equals(linkedTxn!.id)))
            .go();
        await _updateAccountBalance(
            linkedTxn.accountId, linkedTxn.amount, linkedTxn.type,
            isAdding: false);
      }
    });
  }

  Future<void> deleteTransactionSingle(ExpenseTransactionModel txn) async {
    await _db.transaction(() async {
      await (_db.delete(_db.expenseTransactions)
            ..where((t) => t.id.equals(txn.id)))
          .go();
      await _updateAccountBalance(txn.accountId, txn.amount, txn.type,
          isAdding: false);
    });
  }

  Future<ExpenseTransactionModel?> findLinkedTransfer(
      ExpenseTransactionModel txn) async {
    if (txn.transferAccountId == null) return null;
    final linkedType =
        txn.type == 'Transfer Out' ? 'Transfer In' : 'Transfer Out';

    // Fuzzy match
    final minDate = txn.date.subtract(const Duration(seconds: 2));
    final maxDate = txn.date.add(const Duration(seconds: 2));
    final minAmount = txn.amount - 0.01;
    final maxAmount = txn.amount + 0.01;

    final row = await (_db.select(_db.expenseTransactions)
          ..where((t) => t.accountId.equals(txn.transferAccountId!))
          ..where((t) => t.transferAccountId.equals(txn.accountId))
          ..where((t) => t.type.equals(linkedType))
          ..where((t) => t.date.isBetweenValues(minDate, maxDate))
          ..where((t) => t.amount.isBetweenValues(minAmount, maxAmount))
          ..limit(1))
        .getSingleOrNull();

    return row != null ? _mapTransaction(row) : null;
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

    final acc = await (_db.select(_db.expenseAccounts)
          ..where((t) => t.id.equals(accountId)))
        .getSingleOrNull();
    if (acc != null) {
      await (_db.update(_db.expenseAccounts)
            ..where((t) => t.id.equals(accountId)))
          .write(db.ExpenseAccountsCompanion(
              currentBalance: Value(acc.currentBalance + change)));
    }
  }
}
