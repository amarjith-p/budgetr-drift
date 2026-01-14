import 'package:budget/features/daily_expense/services/expense_service.dart';
import 'package:drift/drift.dart';
import 'package:get_it/get_it.dart';
import 'package:uuid/uuid.dart';
import '../../../core/database/app_database.dart' as db;
import '../models/credit_models.dart';

class CreditService {
  final db.AppDatabase _db = db.AppDatabase.instance;
  final _uuid = const Uuid();

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
          currentBalance: const Value(0.0), // Start with 0
          billDate: card.billDate,
          dueDate: card.dueDate,
          color: Value(card.color),
          isArchived: const Value(false),
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ));
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
  }

  Future<void> deleteCreditCard(String cardId) async {
    await _db.transaction(() async {
      await (_db.delete(_db.creditTransactions)
            ..where((t) => t.cardId.equals(cardId)))
          .go();
      await (_db.delete(_db.creditCards)..where((t) => t.id.equals(cardId)))
          .go();
    });
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

      final double balanceChange =
          txn.type == 'Expense' ? txn.amount : -txn.amount;
      await _updateCardBalance(txn.cardId, balanceChange);
    });
  }

  Future<void> updateTransaction(CreditTransactionModel txn) async {
    await _db.transaction(() async {
      // 1. Fetch Old Data to calculate balance difference
      final oldRow = await (_db.select(_db.creditTransactions)
            ..where((t) => t.id.equals(txn.id)))
          .getSingle();

      double oldEffect =
          oldRow.type == 'Expense' ? oldRow.amount : -oldRow.amount;
      double newEffect = txn.type == 'Expense' ? txn.amount : -txn.amount;
      double netChange = newEffect - oldEffect;

      // 2. Update Credit Card Balance
      await _updateCardBalance(txn.cardId, netChange);

      // 3. Update Credit Transaction Record
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

      // 4. SYNC BACK TO EXPENSE MODULE [UPDATED]
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
  }

  Future<void> deleteTransaction(String id) async {
    await _db.transaction(() async {
      final oldRow = await (_db.select(_db.creditTransactions)
            ..where((t) => t.id.equals(id)))
          .getSingleOrNull();
      if (oldRow == null) return;

      // 1. Revert Credit Card Balance
      double reverseEffect =
          oldRow.type == 'Expense' ? -oldRow.amount : oldRow.amount;
      await _updateCardBalance(oldRow.cardId, reverseEffect);

      // 2. Delete Credit Transaction
      await (_db.delete(_db.creditTransactions)..where((t) => t.id.equals(id)))
          .go();

      // 3. SYNC BACK TO EXPENSE MODULE [UPDATED]
      if (oldRow.linkedExpenseId != null) {
        // Direct delete to avoid undefined method issues if interface mismatches
        // But call service for balance revert safety
        await GetIt.I<ExpenseService>()
            .deleteTransactionFromCredit(oldRow.linkedExpenseId!);
      }
    });
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
}
