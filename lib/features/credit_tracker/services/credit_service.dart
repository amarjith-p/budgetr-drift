import 'package:budget/features/credit_tracker/services/credit_notification_scheduler.dart';
import 'package:budget/features/daily_expense/services/expense_service.dart';
import 'package:budget/features/trip_mode/services/trip_service.dart';
import 'package:drift/drift.dart';
import 'package:get_it/get_it.dart';
import 'package:uuid/uuid.dart';
import '../../../core/database/app_database.dart' as db;
import '../models/credit_models.dart';
import '../../../core/database/tables.dart';
import '../utils/billing_cycle_utils.dart'; // [NEW IMPORT for calculations]

class CreditService {
  final db.AppDatabase _db = db.AppDatabase.instance;
  final _uuid = const Uuid();
  final _scheduler = CreditNotificationScheduler();

  // --- MAPPERS ---

  CreditCardModel _mapCard(db.CreditCard row) {
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
      createdAt: row.createdAt,
    );
  }

  CreditTransactionModel _mapTxn(db.CreditTransaction row) {
    return CreditTransactionModel(
      id: row.id,
      cardId: row.cardId,
      amount: row.amount,
      date: row.date,
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

  // =============================================================
  // --- [NEW] SMART DASHBOARD AGGREGATOR (Preserves pure DB) ---
  // =============================================================
  Stream<List<CreditCardDashboardData>> getSmartCreditCardsDashboard() {
    return (_db.select(_db.creditCards)
          ..where((t) => t.isArchived.equals(false))
          ..orderBy([
            (t) =>
                OrderingTerm(expression: t.createdAt, mode: OrderingMode.desc)
          ]))
        .watch()
        .asyncMap((cardRows) async {
      List<CreditCardDashboardData> dashboardData = [];

      for (var row in cardRows) {
        final cardModel = _mapCard(row);

        // Fetch specific transactions for this card to calculate balances
        final txns = await (_db.select(_db.creditTransactions)
              ..where((t) => t.cardId.equals(cardModel.id)))
            .get();

        double unbilledExpenses = 0.0;

        for (var txnRow in txns) {
          final txn = _mapTxn(txnRow);
          if (txn.type == 'Expense') {
            final isUnbilled =
                BillingCycleUtils.isUnbilled(txn, cardModel.billDate);
            if (isUnbilled) {
              unbilledExpenses += txn.amount;
            }
          }
        }

        // The brilliance of this formula: Total Balance - Unbilled = Owed Statement
        double statementBalance = cardModel.currentBalance - unbilledExpenses;

        // Safety clamp in case of overpayment refunds
        if (statementBalance < 0) statementBalance = 0;

        dashboardData.add(CreditCardDashboardData(
          card: cardModel,
          statementBalance: statementBalance,
          unbilledBalance: unbilledExpenses,
        ));
      }
      return dashboardData;
    });
  }
  // =============================================================

  // --- CARDS ---

  Stream<List<CreditCardModel>> getCreditCards() {
    return (_db.select(_db.creditCards)
          ..where((t) => t.isArchived.equals(false))
          ..orderBy([
            (t) =>
                OrderingTerm(expression: t.createdAt, mode: OrderingMode.desc)
          ]))
        .watch()
        .map((rows) => rows.map(_mapCard).toList());
  }

  Future<void> addCreditCard(CreditCardModel card) async {
    await _db.into(_db.creditCards).insert(db.CreditCardsCompanion.insert(
          id: card.id.isEmpty ? _uuid.v4() : card.id,
          name: card.name,
          bankName: card.bankName,
          lastFourDigits: Value(card.lastFourDigits),
          creditLimit: card.creditLimit,
          currentBalance: const Value(0.0),
          billDate: card.billDate,
          dueDate: card.dueDate,
          color: Value(card.color),
          isArchived: const Value(false),
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ));
    _triggerNotificationSync();
  }

  Future<void> updateCreditCard(CreditCardModel card) async {
    await (_db.update(_db.creditCards)..where((t) => t.id.equals(card.id)))
        .write(db.CreditCardsCompanion(
      name: Value(card.name),
      bankName: Value(card.bankName),
      lastFourDigits: Value(card.lastFourDigits),
      creditLimit: Value(card.creditLimit),
      billDate: Value(card.billDate),
      dueDate: Value(card.dueDate),
      color: Value(card.color),
      updatedAt: Value(DateTime.now()),
    ));
    _triggerNotificationSync();
  }

  Future<void> deleteCreditCard(String cardId) async {
    await _db.transaction(() async {
      await (_db.delete(_db.creditTransactions)
            ..where((t) => t.cardId.equals(cardId)))
          .go();
      await (_db.delete(_db.creditCards)..where((t) => t.id.equals(cardId)))
          .go();
    });
    _triggerNotificationSync();
  }

  // --- TRANSACTIONS ---

  Stream<List<CreditTransactionModel>> getTransactionsForCard(String cardId) {
    return (_db.select(_db.creditTransactions)
          ..where((t) => t.cardId.equals(cardId))
          ..orderBy([
            (t) => OrderingTerm(expression: t.date, mode: OrderingMode.desc)
          ]))
        .watch()
        .map((rows) => rows.map(_mapTxn).toList());
  }

  Stream<List<CreditTransactionModel>> getAllTransactions() {
    return (_db.select(_db.creditTransactions)
          ..orderBy([
            (t) => OrderingTerm(expression: t.date, mode: OrderingMode.desc)
          ]))
        .watch()
        .map((rows) => rows.map(_mapTxn).toList());
  }

  Future<List<String>> getDistinctNotes() async {
    final query = _db.selectOnly(_db.creditTransactions, distinct: true)
      ..addColumns([_db.creditTransactions.notes])
      ..where(_db.creditTransactions.notes.isNotNull() &
          _db.creditTransactions.notes.equals('').not());

    final results = await query.get();
    return results
        .map((row) => row.read(_db.creditTransactions.notes)!)
        .toList();
  }

  Future<void> addTransaction(CreditTransactionModel txn) async {
    await _db.transaction(() async {
      final newId = txn.id.isNotEmpty ? txn.id : _uuid.v4();

      await _db
          .into(_db.creditTransactions)
          .insert(db.CreditTransactionsCompanion.insert(
            id: newId,
            cardId: txn.cardId,
            amount: txn.amount,
            date: txn.date,
            bucket: Value(txn.bucket),
            type: txn.type,
            category: txn.category,
            subCategory: txn.subCategory,
            notes: txn.notes,
            linkedExpenseId: Value(txn.linkedExpenseId),
            includeInNextStatement: Value(txn.includeInNextStatement),
            isSettlementVerified: Value(txn.isSettlementVerified),
            description: txn.category,
          ));

      try {
        final tripService = GetIt.I<TripService>();
        final activeTrip = await tripService.getActiveTripFuture();
        if (activeTrip != null && activeTrip.isPaused) {
          await tripService.excludeTransaction(activeTrip.id, newId);
        }
      } catch (_) {}

      final double balanceChange =
          txn.type == 'Expense' ? txn.amount : -txn.amount;
      await _updateCardBalance(txn.cardId, balanceChange);
    });
    _triggerNotificationSync();
  }

  Future<void> updateTransaction(CreditTransactionModel txn) async {
    await _db.transaction(() async {
      final oldRow = await (_db.select(_db.creditTransactions)
            ..where((t) => t.id.equals(txn.id)))
          .getSingle();

      double oldEffect =
          oldRow.type == 'Expense' ? oldRow.amount : -oldRow.amount;
      double newEffect = txn.type == 'Expense' ? txn.amount : -txn.amount;
      double netChange = newEffect - oldEffect;

      await _updateCardBalance(txn.cardId, netChange);

      await (_db.update(_db.creditTransactions)
            ..where((t) => t.id.equals(txn.id)))
          .write(db.CreditTransactionsCompanion(
        amount: Value(txn.amount),
        date: Value(txn.date),
        bucket: Value(txn.bucket),
        type: Value(txn.type),
        category: Value(txn.category),
        subCategory: Value(txn.subCategory),
        notes: Value(txn.notes),
        includeInNextStatement: Value(txn.includeInNextStatement),
        isSettlementVerified: Value(txn.isSettlementVerified),
      ));

      if (txn.linkedExpenseId != null) {
        await GetIt.I<ExpenseService>().updateTransactionFromCredit(
          txn.linkedExpenseId!,
          amount: txn.amount,
          date: txn.date,
          notes: txn.notes,
          category: txn.category,
          subCategory: txn.subCategory,
        );
      }
    });
    _triggerNotificationSync();
  }

  Future<void> deleteTransaction(String id) async {
    await _db.transaction(() async {
      final oldRow = await (_db.select(_db.creditTransactions)
            ..where((t) => t.id.equals(id)))
          .getSingleOrNull();
      if (oldRow == null) return;

      double reverseEffect =
          oldRow.type == 'Expense' ? -oldRow.amount : oldRow.amount;
      await _updateCardBalance(oldRow.cardId, reverseEffect);

      await (_db.delete(_db.creditTransactions)..where((t) => t.id.equals(id)))
          .go();

      if (oldRow.linkedExpenseId != null) {
        await GetIt.I<ExpenseService>()
            .deleteTransactionFromCredit(oldRow.linkedExpenseId!);
      }
    });
    _triggerNotificationSync();
  }

  Future<void> payCreditCardBill(
      String cardId, double amount, DateTime date, String notes) async {
    final txn = CreditTransactionModel(
      id: _uuid.v4(),
      cardId: cardId,
      amount: amount,
      date: date,
      bucket: 'General',
      type: 'Payment',
      category: 'Bill Payment',
      subCategory: 'Credit Card',
      notes: notes,
      includeInNextStatement: false,
      isSettlementVerified: false,
    );
    await addTransaction(txn);
    _triggerNotificationSync();
  }

  Future<void> updateTransactionFromExpense(
      String expenseId, double newAmount, DateTime newDate) async {
    await _db.transaction(() async {
      final relatedTxns = await (_db.select(_db.creditTransactions)
            ..where((t) => t.linkedExpenseId.equals(expenseId)))
          .get();

      for (var txn in relatedTxns) {
        double oldEffect = txn.type == 'Expense' ? txn.amount : -txn.amount;
        double newEffect = txn.type == 'Expense' ? newAmount : -newAmount;
        double netChange = newEffect - oldEffect;

        await _updateCardBalance(txn.cardId, netChange);

        await (_db.update(_db.creditTransactions)
              ..where((t) => t.id.equals(txn.id)))
            .write(db.CreditTransactionsCompanion(
          amount: Value(newAmount),
          date: Value(newDate),
        ));
      }
    });
    _triggerNotificationSync();
  }

  Future<void> deleteTransactionFromExpense(String expenseId) async {
    await _db.transaction(() async {
      final relatedTxns = await (_db.select(_db.creditTransactions)
            ..where((t) => t.linkedExpenseId.equals(expenseId)))
          .get();

      for (var txn in relatedTxns) {
        double reverseEffect = txn.type == 'Expense' ? -txn.amount : txn.amount;
        await _updateCardBalance(txn.cardId, reverseEffect);
        await (_db.delete(_db.creditTransactions)
              ..where((t) => t.id.equals(txn.id)))
            .go();
      }
    });
    _triggerNotificationSync();
  }

  Future<void> _updateCardBalance(String cardId, double change) async {
    final card = await (_db.select(_db.creditCards)
          ..where((t) => t.id.equals(cardId)))
        .getSingle();
    await (_db.update(_db.creditCards)..where((t) => t.id.equals(cardId)))
        .write(db.CreditCardsCompanion(
      currentBalance: Value(card.currentBalance + change),
    ));
  }

  Future<void> _triggerNotificationSync() async {
    final cards = await _db.select(_db.creditCards).get();
    await _scheduler.syncNotifications(cards);
  }
}
