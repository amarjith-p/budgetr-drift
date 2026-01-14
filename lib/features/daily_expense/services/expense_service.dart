import 'package:budget/features/credit_tracker/services/credit_service.dart';
import 'package:drift/drift.dart';
import 'package:get_it/get_it.dart';
import 'package:uuid/uuid.dart';
import '../../../core/database/app_database.dart' as db;
import '../models/expense_models.dart';
import '../../../core/database/tables.dart';

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
      accountId: row.accountId ?? '',
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
    if (accountId != null && accountId.isNotEmpty) {
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

  Future<void> addTransaction(ExpenseTransactionModel txn) async {
    await _db.transaction(() async {
      final docId = txn.id.isNotEmpty ? txn.id : _uuid.v4();
      final String? dbAccountId =
          (txn.accountId.isEmpty) ? null : txn.accountId;

      await _db
          .into(_db.expenseTransactions)
          .insert(db.ExpenseTransactionsCompanion.insert(
            id: docId,
            accountId: Value(dbAccountId),
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

      if (dbAccountId != null) {
        await _updateAccountBalance(dbAccountId, txn.amount, txn.type,
            isAdding: true);
      }

      if (txn.linkedCreditCardId != null) {
        final isPayment = txn.type == 'Transfer Out' &&
            txn.transferAccountId == txn.linkedCreditCardId;
        await _updateCreditBalance(txn.linkedCreditCardId!, txn.amount,
            isExpense: !isPayment);
        await _addCreditTransaction(txn, docId, isPayment);
      }

      if ((txn.type == 'Transfer Out' || txn.type == 'Transfer In') &&
          txn.transferAccountId != null &&
          txn.transferAccountId != txn.linkedCreditCardId) {
        final partnerType =
            txn.type == 'Transfer Out' ? 'Transfer In' : 'Transfer Out';

        String sourceName = "Linked Account";
        String sourceBank = "";

        if (dbAccountId != null) {
          final sourceAcc = await (_db.select(_db.expenseAccounts)
                ..where((t) => t.id.equals(dbAccountId)))
              .getSingleOrNull();
          sourceName = sourceAcc?.name ?? "Linked Account";
          sourceBank = sourceAcc?.bankName ?? "";
        }

        await _db
            .into(_db.expenseTransactions)
            .insert(db.ExpenseTransactionsCompanion.insert(
              id: _uuid.v4(),
              accountId: Value(txn.transferAccountId),
              amount: txn.amount,
              date: txn.date,
              bucket: Value(txn.bucket),
              type: Value(partnerType),
              category: Value(txn.category),
              subCategory: Value(txn.subCategory),
              notes: Value(txn.notes),
              transferAccountId: Value(dbAccountId),
              transferAccountName: Value(sourceName),
              transferAccountBankName: Value(sourceBank),
              linkedCreditCardId: Value(txn.linkedCreditCardId),
            ));

        await _updateAccountBalance(
            txn.transferAccountId!, txn.amount, partnerType,
            isAdding: true);
      }
    });
  }

  Future<void> updateTransaction(ExpenseTransactionModel newTxn) async {
    await _db.transaction(() async {
      final oldRow = await (_db.select(_db.expenseTransactions)
            ..where((t) => t.id.equals(newTxn.id)))
          .getSingleOrNull();

      if (oldRow == null) return;

      final oldTxn = _mapTransaction(oldRow);
      final String? oldAccountId =
          oldTxn.accountId.isEmpty ? null : oldTxn.accountId;
      final String? newAccountId =
          newTxn.accountId.isEmpty ? null : newTxn.accountId;

      ExpenseTransactionModel? oldPartnerTxn;
      if (oldTxn.type.contains('Transfer') &&
          oldTxn.linkedCreditCardId == null) {
        oldPartnerTxn = await findLinkedTransfer(oldTxn);
      }

      if (oldAccountId != null) {
        await _updateAccountBalance(oldAccountId, oldTxn.amount, oldTxn.type,
            isAdding: false);
      }
      if (oldTxn.linkedCreditCardId != null) {
        final isPayment = oldTxn.type == 'Transfer Out' &&
            oldTxn.transferAccountId == oldTxn.linkedCreditCardId;
        await _updateCreditBalance(oldTxn.linkedCreditCardId!, oldTxn.amount,
            isExpense: isPayment);
        await (_db.delete(_db.creditTransactions)
              ..where((t) => t.linkedExpenseId.equals(oldTxn.id)))
            .go();
      }

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

      final isNewTransfer = newTxn.type.contains('Transfer');

      await _db
          .into(_db.expenseTransactions)
          .insert(db.ExpenseTransactionsCompanion.insert(
            id: newTxn.id,
            accountId: Value(newAccountId),
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

      if (newAccountId != null) {
        await _updateAccountBalance(newAccountId, newTxn.amount, newTxn.type,
            isAdding: true);
      }

      if (newTxn.linkedCreditCardId != null) {
        final isPayment = newTxn.type == 'Transfer Out' &&
            newTxn.transferAccountId == newTxn.linkedCreditCardId;
        await _updateCreditBalance(newTxn.linkedCreditCardId!, newTxn.amount,
            isExpense: !isPayment);
        await _addCreditTransaction(newTxn, newTxn.id, isPayment);
      }

      if (isNewTransfer &&
          newTxn.transferAccountId != null &&
          newTxn.transferAccountId != newTxn.linkedCreditCardId) {
        final partnerType =
            newTxn.type == 'Transfer Out' ? 'Transfer In' : 'Transfer Out';

        String sourceName = "Linked Account";
        if (newAccountId != null) {
          final mainAcc = await (_db.select(_db.expenseAccounts)
                ..where((t) => t.id.equals(newAccountId)))
              .getSingleOrNull();
          sourceName = mainAcc?.name ?? "Linked Account";
        }

        await _db
            .into(_db.expenseTransactions)
            .insert(db.ExpenseTransactionsCompanion.insert(
              id: _uuid.v4(),
              accountId: Value(newTxn.transferAccountId),
              amount: newTxn.amount,
              date: newTxn.date,
              bucket: Value(newTxn.bucket),
              type: Value(partnerType),
              category: Value(newTxn.category),
              subCategory: Value(newTxn.subCategory),
              notes: Value(newTxn.notes),
              transferAccountId: Value(newAccountId),
              transferAccountName: Value(sourceName),
              transferAccountBankName: Value(""),
            ));

        await _updateAccountBalance(
            newTxn.transferAccountId!, newTxn.amount, partnerType,
            isAdding: true);
      }
    });
  }

  Future<void> deleteTransaction(ExpenseTransactionModel txn) async {
    await _db.transaction(() async {
      final String? dbAccountId = txn.accountId.isEmpty ? null : txn.accountId;

      await (_db.delete(_db.expenseTransactions)
            ..where((t) => t.id.equals(txn.id)))
          .go();

      if (dbAccountId != null) {
        await _updateAccountBalance(dbAccountId, txn.amount, txn.type,
            isAdding: false);
      }

      if (txn.linkedCreditCardId != null) {
        final isPayment = txn.type == 'Transfer Out' &&
            txn.transferAccountId == txn.linkedCreditCardId;
        await _updateCreditBalance(txn.linkedCreditCardId!, txn.amount,
            isExpense: isPayment);
        await (_db.delete(_db.creditTransactions)
              ..where((t) => t.linkedExpenseId.equals(txn.id)))
            .go();
      }

      if (txn.transferAccountId != null &&
          txn.transferAccountId != txn.linkedCreditCardId) {
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
  }

  // [RESTORED] Missing Method - Fixes compilation error
  Future<void> deleteTransactionSingle(ExpenseTransactionModel txn) async {
    await _db.transaction(() async {
      await (_db.delete(_db.expenseTransactions)
            ..where((t) => t.id.equals(txn.id)))
          .go();
      if (txn.accountId.isNotEmpty) {
        await _updateAccountBalance(txn.accountId, txn.amount, txn.type,
            isAdding: false);
      }
    });
  }

  Future<void> deleteTransactionFromCredit(String txnId) async {
    await _db.transaction(() async {
      final row = await (_db.select(_db.expenseTransactions)
            ..where((t) => t.id.equals(txnId)))
          .getSingleOrNull();

      if (row == null) return;
      final txn = _mapTransaction(row);

      await (_db.delete(_db.expenseTransactions)
            ..where((t) => t.id.equals(txnId)))
          .go();

      if (txn.accountId.isNotEmpty) {
        await _updateAccountBalance(txn.accountId, txn.amount, txn.type,
            isAdding: false);
      }
    });
  }

  Future<void> updateTransactionFromCredit(String txnId,
      {required double amount,
      required DateTime date,
      required String notes,
      required String category,
      required String subCategory}) async {
    await _db.transaction(() async {
      final row = await (_db.select(_db.expenseTransactions)
            ..where((t) => t.id.equals(txnId)))
          .getSingleOrNull();

      if (row == null) return;
      final txn = _mapTransaction(row);

      if (txn.accountId.isNotEmpty) {
        await _updateAccountBalance(txn.accountId, txn.amount, txn.type,
            isAdding: false);
      }

      await (_db.update(_db.expenseTransactions)
            ..where((t) => t.id.equals(txnId)))
          .write(db.ExpenseTransactionsCompanion(
        amount: Value(amount),
        date: Value(date),
        notes: Value(notes),
        category: Value(category),
        subCategory: Value(subCategory),
      ));

      if (txn.accountId.isNotEmpty) {
        await _updateAccountBalance(txn.accountId, amount, txn.type,
            isAdding: true);
      }
    });
  }

  // --- INTERNAL HELPERS ---
  Future<void> _updateCreditBalance(String cardId, double amount,
      {required bool isExpense}) async {
    final card = await (_db.select(_db.creditCards)
          ..where((t) => t.id.equals(cardId)))
        .getSingleOrNull();
    if (card != null) {
      double change = isExpense ? amount : -amount;
      await (_db.update(_db.creditCards)..where((t) => t.id.equals(cardId)))
          .write(db.CreditCardsCompanion(
              currentBalance: Value(card.currentBalance + change)));
    }
  }

  Future<void> _addCreditTransaction(
      ExpenseTransactionModel txn, String expenseId, bool isPayment) async {
    await _db
        .into(_db.creditTransactions)
        .insert(db.CreditTransactionsCompanion.insert(
          id: _uuid.v4(),
          cardId: txn.linkedCreditCardId!,
          amount: txn.amount,
          date: txn.date,
          description: txn.notes.isEmpty ? txn.category : txn.notes,
          bucket: Value(txn.bucket),
          type: isPayment ? 'Payment' : 'Expense',
          category: txn.category,
          subCategory: txn.subCategory,
          notes: txn.notes,
          linkedExpenseId: Value(expenseId),
        ));
  }

  Future<ExpenseTransactionModel?> findLinkedTransfer(
      ExpenseTransactionModel txn) async {
    if (txn.transferAccountId == null) return null;
    final linkedType =
        txn.type == 'Transfer Out' ? 'Transfer In' : 'Transfer Out';

    var row = await (_db.select(_db.expenseTransactions)
          ..where((t) => t.accountId.equals(txn.transferAccountId!))
          ..where((t) => t.transferAccountId.equals(txn.accountId))
          ..where((t) => t.amount.equals(txn.amount))
          ..where((t) => t.type.equals(linkedType))
          ..where((t) => t.date.equals(txn.date))
          ..limit(1))
        .getSingleOrNull();

    if (row == null) {
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
