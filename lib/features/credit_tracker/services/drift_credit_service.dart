import 'dart:convert';
import 'package:drift/drift.dart' as drift;
import 'package:uuid/uuid.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // For Timestamp

import '../../../../core/database/app_database.dart';
import '../../daily_expense/services/expense_service.dart'; // To call Expense logic
import '../models/credit_models.dart';
import 'credit_service.dart';

class DriftCreditService extends CreditService {
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
      createdAt: Timestamp.fromDate(row.createdAt),
    );
  }

  CreditTransactionModel _mapTxn(CreditTransaction row) {
    return CreditTransactionModel(
      id: row.id,
      cardId: row.cardId,
      amount: row.amount,
      date: Timestamp.fromDate(row.date),
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
          createdAt: card.createdAt.toDate(),
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
            date: txn.date.toDate(),
            bucket: txn.bucket,
            type: txn.type,
            category: txn.category,
            subCategory: txn.subCategory,
            notes: drift.Value(txn.notes),
            linkedExpenseId: drift.Value(txn.linkedExpenseId),
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

    // Handle Linked Expense (Assumes ServiceLocator is set up or direct call)
    // Note: In real app, avoid direct instantiation if possible, but for now:
    // ExpenseService().deleteTransactionFromCredit(txn.linkedExpenseId!);
  }
}
