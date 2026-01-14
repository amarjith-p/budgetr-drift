import 'package:budget/features/credit_tracker/services/credit_service.dart';
import 'package:drift/drift.dart';
import 'package:get_it/get_it.dart';
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

  // --- NUCLEAR UPDATE STRATEGY: Delete Both & Recreate Both ---
  // This ensures no "ghost" fields or wrong account mappings persist.

  Future<void> updateTransaction(ExpenseTransactionModel newTxn) async {
    // 1. Perform the "Nuclear" Update (Delete Old -> Recreate New)
    await _db.transaction(() async {
      final oldRow = await (_db.select(_db.expenseTransactions)
            ..where((t) => t.id.equals(newTxn.id)))
          .getSingleOrNull();

      if (oldRow == null) return;

      final oldTxn = _mapTransaction(oldRow);

      // Handle Transfer Partner Deletion
      ExpenseTransactionModel? oldPartnerTxn;
      if (oldTxn.type.contains('Transfer')) {
        oldPartnerTxn = await findLinkedTransfer(oldTxn);
      }

      // Revert & Delete Old State
      await _updateAccountBalance(oldTxn.accountId, oldTxn.amount, oldTxn.type,
          isAdding: false);
      await (_db.delete(_db.expenseTransactions)
            ..where((t) => t.id.equals(oldTxn.id)))
          .go();

      if (oldPartnerTxn != null) {
        await _updateAccountBalance(oldPartnerTxn!.accountId,
            oldPartnerTxn!.amount, oldPartnerTxn!.type,
            isAdding: false);
        await (_db.delete(_db.expenseTransactions)
              ..where((t) => t.id.equals(oldPartnerTxn!.id)))
            .go();
      }

      // Prepare & Validation
      final isNewTransfer = newTxn.type.contains('Transfer');
      if (isNewTransfer && newTxn.accountId == newTxn.transferAccountId) {
        throw Exception("Source and Destination accounts cannot be the same.");
      }

      // Insert New Main Transaction
      await _db
          .into(_db.expenseTransactions)
          .insert(db.ExpenseTransactionsCompanion.insert(
            id: newTxn.id, // Keep ID stable
            accountId: newTxn.accountId,
            amount: newTxn.amount,
            date: newTxn.date,
            bucket: Value(newTxn.bucket),
            type: Value(newTxn.type),
            category: Value(newTxn.category),
            subCategory: Value(newTxn.subCategory),
            notes: Value(newTxn.notes),
            transferAccountId:
                Value(isNewTransfer ? newTxn.transferAccountId : null),
            transferAccountName:
                Value(isNewTransfer ? newTxn.transferAccountName : null),
            transferAccountBankName:
                Value(isNewTransfer ? newTxn.transferAccountBankName : null),
            linkedCreditCardId: Value(newTxn.linkedCreditCardId),
          ));

      await _updateAccountBalance(newTxn.accountId, newTxn.amount, newTxn.type,
          isAdding: true);

      // Insert New Partner (If Transfer)
      if (isNewTransfer && newTxn.transferAccountId != null) {
        final partnerType =
            newTxn.type == 'Transfer Out' ? 'Transfer In' : 'Transfer Out';
        final mainAcc = await (_db.select(_db.expenseAccounts)
              ..where((t) => t.id.equals(newTxn.accountId)))
            .getSingleOrNull();

        await _db
            .into(_db.expenseTransactions)
            .insert(db.ExpenseTransactionsCompanion.insert(
              id: _uuid.v4(),
              accountId: newTxn.transferAccountId!,
              amount: newTxn.amount,
              date: newTxn.date,
              bucket: Value(newTxn.bucket),
              type: Value(partnerType),
              category: Value(newTxn.category),
              subCategory: Value(newTxn.subCategory),
              notes: Value(newTxn.notes),
              transferAccountId: Value(newTxn.accountId),
              transferAccountName: Value(mainAcc?.name ?? "Linked Account"),
              transferAccountBankName: Value(mainAcc?.bankName ?? ""),
            ));

        await _updateAccountBalance(
            newTxn.transferAccountId!, newTxn.amount, partnerType,
            isAdding: true);
      }
    });

    // 2. [NEW] SYNC TO CREDIT TRACKER
    // If this expense is linked to a credit card, we must update the credit module
    // We use GetIt.I to avoid circular dependency issues during constructor init.
    await GetIt.I<CreditService>()
        .updateTransactionFromExpense(newTxn.id, newTxn.amount, newTxn.date);
  }
  // Future<void> updateTransaction(ExpenseTransactionModel newTxn) async {
  //   await _db.transaction(() async {
  //     // 1. Fetch OLD transaction state
  //     final oldRow = await (_db.select(_db.expenseTransactions)
  //           ..where((t) => t.id.equals(newTxn.id)))
  //         .getSingle();
  //     final oldTxn = _mapTransaction(oldRow);

  //     // --- CRITICAL: PRESERVE TYPE & METADATA ---
  //     final isTransfer =
  //         (oldTxn.type == 'Transfer Out' || oldTxn.type == 'Transfer In');
  //     final effectiveType = isTransfer ? oldTxn.type : newTxn.type;

  //     final effectiveTransferId =
  //         newTxn.transferAccountId ?? oldTxn.transferAccountId;
  //     final effectiveTransferName =
  //         newTxn.transferAccountName ?? oldTxn.transferAccountName;
  //     final effectiveTransferBank =
  //         newTxn.transferAccountBankName ?? oldTxn.transferAccountBankName;

  //     // --- FIND LINKED TXN BEFORE UPDATING ---
  //     ExpenseTransactionModel? linkedTxn;
  //     if (isTransfer && oldTxn.transferAccountId != null) {
  //       linkedTxn = await findLinkedTransfer(oldTxn);
  //     }

  //     // 2. Revert Old Balance on MAIN Account
  //     await _updateAccountBalance(oldTxn.accountId, oldTxn.amount, oldTxn.type,
  //         isAdding: false);

  //     // 3. Apply New Balance on MAIN Account
  //     // SAFEGUARD: Use oldTxn.accountId to ensure we update the correct account even if UI sent bad ID
  //     await _updateAccountBalance(
  //         oldTxn.accountId, newTxn.amount, effectiveType,
  //         isAdding: true);

  //     // 4. Update MAIN Transaction Record
  //     await (_db.update(_db.expenseTransactions)
  //           ..where((t) => t.id.equals(newTxn.id)))
  //         .write(db.ExpenseTransactionsCompanion(
  //       amount: Value(newTxn.amount),
  //       date: Value(newTxn.date),
  //       bucket: Value(newTxn.bucket),
  //       type: Value(effectiveType),
  //       category: Value(newTxn.category),
  //       subCategory: Value(newTxn.subCategory),
  //       notes: Value(newTxn.notes),
  //       transferAccountId: Value(effectiveTransferId),
  //       transferAccountName: Value(effectiveTransferName),
  //       transferAccountBankName: Value(effectiveTransferBank),
  //     ));

  //     // --- 5. HANDLE LINKED TRANSFER UPDATE ---
  //     if (linkedTxn != null) {
  //       // A. Revert Balance on LINKED Account
  //       await _updateAccountBalance(
  //           linkedTxn.accountId, linkedTxn.amount, linkedTxn.type,
  //           isAdding: false);

  //       // B. Determine Linked Type
  //       final newLinkedType =
  //           effectiveType == 'Transfer Out' ? 'Transfer In' : 'Transfer Out';

  //       // C. Update LINKED Transaction Record
  //       await (_db.update(_db.expenseTransactions)
  //             ..where((t) => t.id.equals(linkedTxn!.id)))
  //           .write(db.ExpenseTransactionsCompanion(
  //         amount: Value(newTxn.amount),
  //         date: Value(newTxn.date),
  //         type: Value(newLinkedType),
  //         category: Value(newTxn.category),
  //         subCategory: Value(newTxn.subCategory),
  //         notes: Value(newTxn.notes),
  //       ));

  //       // D. Apply New Balance on LINKED Account
  //       await _updateAccountBalance(
  //           linkedTxn.accountId, newTxn.amount, newLinkedType,
  //           isAdding: true);
  //     }
  //   });
  // }

  Future<void> deleteTransaction(ExpenseTransactionModel txn) async {
    await _db.transaction(() async {
      // 1. Delete Main
      await (_db.delete(_db.expenseTransactions)
            ..where((t) => t.id.equals(txn.id)))
          .go();

      // 2. Revert Balance
      await _updateAccountBalance(txn.accountId, txn.amount, txn.type,
          isAdding: false);

      // 3. Handle Linked Transfer deletion
      if (txn.transferAccountId != null) {
        final linked = await findLinkedTransfer(txn);
        if (linked != null) {
          await (_db.delete(_db.expenseTransactions)
                ..where((t) => t.id.equals(linked.id)))
              .go();
          await _updateAccountBalance(
              linked.accountId, linked.amount, linked.type,
              isAdding: false);
        }
      }
    });

    // 4. [NEW] SYNC TO CREDIT TRACKER
    // If this expense was linked to a credit card, remove it from the credit module
    await GetIt.I<CreditService>().deleteTransactionFromExpense(txn.id);
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
  // --- UPDATED HELPER METHODS ---

  // --- IMPROVED HELPER TO FIND LINKED TRANSFER ---
  // Tries strict matching (with ID/Date) first, but has a fallback if data is slightly out of sync.

  Future<ExpenseTransactionModel?> findLinkedTransfer(
      ExpenseTransactionModel txn) async {
    if (txn.transferAccountId == null) return null;
    final linkedType =
        txn.type == 'Transfer Out' ? 'Transfer In' : 'Transfer Out';

    // 1. Strict Search (Date + Amounts match)
    var row = await (_db.select(_db.expenseTransactions)
          ..where((t) => t.accountId
              .equals(txn.transferAccountId!)) // It exists in the OTHER account
          ..where((t) => t.transferAccountId
              .equals(txn.accountId)) // It points back to THIS account
          ..where((t) => t.amount.equals(txn.amount))
          ..where((t) => t.type.equals(linkedType))
          ..where((t) => t.date.equals(txn.date))
          ..limit(1))
        .getSingleOrNull();

    // 2. Fallback Search (Ignore Date Time precision issues, just check Day)
    if (row == null) {
      // This handles cases where editing might have shifted the time slightly or different created_at
      row = await (_db.select(_db.expenseTransactions)
            ..where((t) => t.accountId.equals(txn.transferAccountId!))
            ..where((t) => t.transferAccountId.equals(txn.accountId))
            ..where((t) => t.amount.equals(txn.amount))
            ..where((t) => t.type.equals(linkedType))
            ..limit(1))
          .getSingleOrNull();
    }

    return row != null ? _mapTransaction(row) : null;
  }

  // Helper to fetch names for metadata updates
  Future<String> _getAccountName(String id) async {
    final acc = await (_db.select(_db.expenseAccounts)
          ..where((t) => t.id.equals(id)))
        .getSingleOrNull();
    return acc?.name ?? 'Unknown';
  }

  Future<String> _getAccountBank(String id) async {
    final acc = await (_db.select(_db.expenseAccounts)
          ..where((t) => t.id.equals(id)))
        .getSingleOrNull();
    return acc?.bankName ?? '';
  }

  // Future<ExpenseTransactionModel?> findLinkedTransfer(
  //     ExpenseTransactionModel txn) async {
  //   if (txn.transferAccountId == null) return null;
  //   final linkedType =
  //       txn.type == 'Transfer Out' ? 'Transfer In' : 'Transfer Out';

  //   // Fuzzy match
  //   final minDate = txn.date.subtract(const Duration(seconds: 2));
  //   final maxDate = txn.date.add(const Duration(seconds: 2));
  //   final minAmount = txn.amount - 0.01;
  //   final maxAmount = txn.amount + 0.01;

  //   final row = await (_db.select(_db.expenseTransactions)
  //         ..where((t) => t.accountId.equals(txn.transferAccountId!))
  //         ..where((t) => t.transferAccountId.equals(txn.accountId))
  //         ..where((t) => t.type.equals(linkedType))
  //         ..where((t) => t.date.isBetweenValues(minDate, maxDate))
  //         ..where((t) => t.amount.isBetweenValues(minAmount, maxAmount))
  //         ..limit(1))
  //       .getSingleOrNull();

  //   return row != null ? _mapTransaction(row) : null;
  // }

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
  // --- SYNC METHODS (Called by CreditService) ---

  Future<void> updateTransactionFromCredit(
      String txnId, double newAmount, DateTime newDate) async {
    await _db.transaction(() async {
      // 1. Fetch the existing Expense Transaction
      final row = await (_db.select(_db.expenseTransactions)
            ..where((t) => t.id.equals(txnId)))
          .getSingleOrNull();

      if (row == null) return; // Transaction not found

      final oldTxn = _mapTransaction(row);

      // 2. Revert the OLD Balance from the Account (Credit Pool)
      await _updateAccountBalance(oldTxn.accountId, oldTxn.amount, oldTxn.type,
          isAdding: false);

      // 3. Update the Transaction Record
      await (_db.update(_db.expenseTransactions)
            ..where((t) => t.id.equals(txnId)))
          .write(db.ExpenseTransactionsCompanion(
        amount: Value(newAmount),
        date: Value(newDate),
      ));

      // 4. Apply the NEW Balance to the Account
      await _updateAccountBalance(oldTxn.accountId, newAmount, oldTxn.type,
          isAdding: true);
    });
  }

  Future<void> deleteTransactionFromCredit(String txnId) async {
    await _db.transaction(() async {
      // 1. Fetch to get details for balance reversion
      final row = await (_db.select(_db.expenseTransactions)
            ..where((t) => t.id.equals(txnId)))
          .getSingleOrNull();

      if (row == null) return;

      final txn = _mapTransaction(row);

      // 2. Revert Balance
      await _updateAccountBalance(txn.accountId, txn.amount, txn.type,
          isAdding: false);

      // 3. Delete the Record
      await (_db.delete(_db.expenseTransactions)
            ..where((t) => t.id.equals(txnId)))
          .go();
    });
  }
}
