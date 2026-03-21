import 'package:budget/features/credit_tracker/models/credit_models.dart';
import 'package:budget/features/credit_tracker/services/credit_service.dart';
import 'package:budget/features/daily_expense/models/filter_criteria.dart';
import 'package:budget/features/trip_mode/services/trip_service.dart';
// import 'package:budget/features/daily_expense/models/filter_criteria.dart';
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
    query.where((t) => t.accountId.isNotNull());
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

  // [NEW] Get distinct notes for suggestions
  Future<List<String>> getDistinctNotes() async {
    final query = _db.selectOnly(_db.expenseTransactions, distinct: true)
      ..addColumns([_db.expenseTransactions.notes])
      ..where(_db.expenseTransactions.notes.isNotNull() &
          _db.expenseTransactions.notes.equals('').not());

    final results = await query.get();
    return results
        .map((row) => row.read(_db.expenseTransactions.notes)!)
        .toList();
  }

  // [HELPER] Resolve Account Name
  Future<String> _resolveAccountName(String id) async {
    final bank = await (_db.select(_db.expenseAccounts)
          ..where((a) => a.id.equals(id)))
        .getSingleOrNull();
    if (bank != null) return "${bank.bankName} - ${bank.name}";

    final card = await (_db.select(_db.creditCards)
          ..where((c) => c.id.equals(id)))
        .getSingleOrNull();
    if (card != null) return "${card.bankName} - ${card.name}";

    return "Linked Account";
  }

  Future<void> addTransaction(ExpenseTransactionModel txn,
      {String? creditCategoryOverride,
      String? creditSubCategoryOverride}) async {
    await _db.transaction(() async {
      final docId = txn.id.isNotEmpty ? txn.id : _uuid.v4();
      final String? dbAccountId =
          (txn.accountId.isEmpty) ? null : txn.accountId;

      // Auto-detect Linked Credit Card
      String? finalLinkedCardId = txn.linkedCreditCardId;
      if (finalLinkedCardId == null && txn.transferAccountId != null) {
        final card = await (_db.select(_db.creditCards)
              ..where((c) => c.id.equals(txn.transferAccountId!)))
            .getSingleOrNull();
        if (card != null) finalLinkedCardId = card.id;
      }

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
            linkedCreditCardId: Value(finalLinkedCardId),
          ));

      // --- 🔴 NEW: Intercept & Exclude from Paused Trip ---
      try {
        final tripService = GetIt.I<TripService>();
        final activeTrip = await tripService.getActiveTripFuture();
        if (activeTrip != null && activeTrip.isPaused) {
          await tripService.excludeTransaction(activeTrip.id, docId);
        }
      } catch (_) {}
      // ----------------------------------------------------

      if (dbAccountId != null) {
        await _updateAccountBalance(dbAccountId, txn.amount, txn.type,
            isAdding: true);
      }

      if (finalLinkedCardId != null) {
        final isPayment = txn.type == 'Transfer Out' &&
            txn.transferAccountId == finalLinkedCardId;

        String creditNote = txn.notes;
        if (isPayment && dbAccountId != null) {
          final sourceName = await _resolveAccountName(dbAccountId);
          if (creditNote.isEmpty) {
            creditNote = "Transfer from $sourceName";
          } else {
            creditNote = "$creditNote (From $sourceName)";
          }
        }

        await _updateCreditBalance(finalLinkedCardId, txn.amount,
            isExpense: !isPayment);

        await _addCreditTransaction(txn, docId, isPayment,
            categoryOverride: creditCategoryOverride,
            subCategoryOverride: creditSubCategoryOverride,
            noteOverride: creditNote,
            targetCardId: finalLinkedCardId);
      }

      if ((txn.type == 'Transfer Out' || txn.type == 'Transfer In') &&
          txn.transferAccountId != null &&
          txn.transferAccountId != finalLinkedCardId) {
        final partnerType =
            txn.type == 'Transfer Out' ? 'Transfer In' : 'Transfer Out';
        final partnerTxnId = _uuid.v4(); // Generate ID for partner txn

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
              id: partnerTxnId,
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
              linkedCreditCardId: Value(finalLinkedCardId),
            ));

        // --- 🔴 NEW: Intercept Partner Transfer Txn ---
        try {
          final tripService = GetIt.I<TripService>();
          final activeTrip = await tripService.getActiveTripFuture();
          if (activeTrip != null && activeTrip.isPaused) {
            await tripService.excludeTransaction(activeTrip.id, partnerTxnId);
          }
        } catch (_) {}
        // ----------------------------------------------

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

      // [FIX] Auto-detect Linked Card
      String? finalLinkedCardId = newTxn.linkedCreditCardId;
      if (finalLinkedCardId == null && newTxn.transferAccountId != null) {
        final card = await (_db.select(_db.creditCards)
              ..where((c) => c.id.equals(newTxn.transferAccountId!)))
            .getSingleOrNull();
        if (card != null) finalLinkedCardId = card.id;
      }

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
            transferAccountName: Value(
                isNewTransfer ? newTxn.transferAccountName : null), // Reverted
            transferAccountBankName: Value(isNewTransfer
                ? newTxn.transferAccountBankName
                : null), // Reverted
            linkedCreditCardId: Value(finalLinkedCardId),
          ));

      if (newAccountId != null) {
        await _updateAccountBalance(newAccountId, newTxn.amount, newTxn.type,
            isAdding: true);
      }

      if (finalLinkedCardId != null) {
        final isPayment = newTxn.type == 'Transfer Out' &&
            newTxn.transferAccountId == finalLinkedCardId;

        // [FIX] Context-Aware Note
        String creditNote = newTxn.notes;
        if (isPayment && newAccountId != null) {
          final sourceName = await _resolveAccountName(newAccountId);
          if (creditNote.isEmpty) {
            creditNote = "Transfer from $sourceName";
          } else {
            creditNote = "$creditNote (From $sourceName)";
          }
        }

        await _updateCreditBalance(finalLinkedCardId, newTxn.amount,
            isExpense: !isPayment);
        await _addCreditTransaction(newTxn, newTxn.id, isPayment,
            noteOverride: creditNote, targetCardId: finalLinkedCardId);
      }

      if (isNewTransfer &&
          newTxn.transferAccountId != null &&
          newTxn.transferAccountId != finalLinkedCardId) {
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
      ExpenseTransactionModel txn, String expenseId, bool isPayment,
      {String? categoryOverride,
      String? subCategoryOverride,
      String? noteOverride,
      String? targetCardId}) async {
    final effectiveCategory =
        isPayment ? 'Payment' : (categoryOverride ?? txn.category);
    final effectiveSubCategory = isPayment
        ? 'Manual Transfer'
        : (subCategoryOverride ?? txn.subCategory);
    final effectiveBucket = isPayment ? 'Unallocated' : txn.bucket;
    final effectiveNote = noteOverride ?? txn.notes;
    final effectiveDesc = effectiveNote.isNotEmpty
        ? effectiveNote
        : (txn.notes.isEmpty ? txn.category : txn.notes);

    final creditTxnId = _uuid.v4(); // Capture ID explicitly

    await _db
        .into(_db.creditTransactions)
        .insert(db.CreditTransactionsCompanion.insert(
          id: creditTxnId,
          cardId: targetCardId ?? txn.linkedCreditCardId!,
          amount: txn.amount,
          date: txn.date,
          description: effectiveDesc,
          bucket: Value(effectiveBucket),
          type: isPayment ? 'Income' : 'Expense',
          category: categoryOverride ?? txn.category,
          subCategory: subCategoryOverride ?? txn.subCategory,
          notes: effectiveNote,
          linkedExpenseId: Value(expenseId),
        ));

    // --- 🔴 NEW: Intercept Linked Credit Txn ---
    try {
      final tripService = GetIt.I<TripService>();
      final activeTrip = await tripService.getActiveTripFuture();
      if (activeTrip != null && activeTrip.isPaused) {
        await tripService.excludeTransaction(activeTrip.id, creditTxnId);
      }
    } catch (_) {}
    // -------------------------------------------
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

  // 1. Get Limits for a specific month
  Future<db.HeatmapLimit> getMonthLimits(DateTime date) async {
    final id = "${date.year}${date.month.toString().padLeft(2, '0')}";

    final result = await (_db.select(_db.heatmapLimits)
          ..where((t) => t.id.equals(id)))
        .getSingleOrNull();

    // Return found limits or Defaults
    return result ??
        db.HeatmapLimit(
            id: id,
            safeLimit: 500.0,
            cautionLimit: 2000.0,
            severeLimit: 5000.0);
  }

// 2. Save Limits
  Future<void> saveMonthLimits(
      String monthId, double safe, double caution, double severe) async {
    await _db.into(_db.heatmapLimits).insertOnConflictUpdate(
          db.HeatmapLimitsCompanion.insert(
            id: monthId,
            safeLimit: Value(safe),
            cautionLimit: Value(caution),
            severeLimit: Value(severe),
          ),
        );
  }

  // Future<double> getTotalBalance() async {
  //   // 1. Fetch all expense accounts from the database
  //   final List<db.ExpenseAccount> accounts =
  //       await _db.select(_db.expenseAccounts).get();

  //   // 2. Sum up the currentBalance of each account
  //   double total = 0.0;
  //   for (var account in accounts) {
  //     total += account.currentBalance;
  //   }
  //   return total;
  // }

  // [NEW] Added for real-time updates on HomeScreen
  Stream<double> watchTotalBalance() {
    return _db.select(_db.expenseAccounts).watch().map((accounts) {
      double total = 0.0;
      for (var account in accounts) {
        total += account.currentBalance;
      }
      return total;
    });
  }

  Future<double> getTotalBalance() async {
    final List<db.ExpenseAccount> accounts =
        await _db.select(_db.expenseAccounts).get();

    double total = 0.0;
    for (var account in accounts) {
      total += account.currentBalance;
    }
    return total;
  }

// --- UPDATE THIS METHOD in ExpenseService ---
  Stream<List<ExpenseTransactionModel>> getFilteredTransactions(
      FilterCriteria criteria) {
    final query = _db.select(_db.expenseTransactions)
      ..where((t) => t.accountId.isNotNull() & t.accountId.equals('').not());

    // 1. Date Filter
    if (criteria.startDate != null && criteria.endDate != null) {
      query.where((t) =>
          t.date.isBetweenValues(criteria.startDate!, criteria.endDate!));
    }

    // 2. Amount Filter
    if (criteria.amountRange != null) {
      query.where((t) => t.amount.isBetweenValues(
          criteria.amountRange!.start, criteria.amountRange!.end));
    }

    // 3. Category Filter
    if (criteria.selectedCategories.isNotEmpty) {
      query.where((t) => t.category.isIn(criteria.selectedCategories));
    }

    // 4. Type Filter
    if (criteria.transactionTypes.isNotEmpty) {
      query.where((t) => t.type.isIn(criteria.transactionTypes));
    }

    // 5. Bucket Filter [NEW]
    if (criteria.selectedBuckets.isNotEmpty) {
      query.where((t) => t.bucket.isIn(criteria.selectedBuckets));
    }

    // 6. Sorting
    switch (criteria.sortOption) {
      case SortOption.newest:
        query.orderBy(
            [(t) => OrderingTerm(expression: t.date, mode: OrderingMode.desc)]);
        break;
      case SortOption.oldest:
        query.orderBy(
            [(t) => OrderingTerm(expression: t.date, mode: OrderingMode.asc)]);
        break;
      case SortOption.highestAmount:
        query.orderBy([
          (t) => OrderingTerm(expression: t.amount, mode: OrderingMode.desc)
        ]);
        break;
      case SortOption.lowestAmount:
        query.orderBy([
          (t) => OrderingTerm(expression: t.amount, mode: OrderingMode.asc)
        ]);
        break;
    }

    return query.watch().map((rows) => rows.map(_mapTransaction).toList());
  }
}
