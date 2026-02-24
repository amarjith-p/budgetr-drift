import 'dart:convert';
import 'package:budget/core/database/app_database.dart' as db;
import 'package:budget/features/credit_tracker/models/credit_models.dart';
import 'package:budget/features/credit_tracker/services/credit_service.dart';
import 'package:budget/features/daily_expense/models/expense_models.dart';
import 'package:budget/features/daily_expense/services/expense_service.dart';
import 'package:budget/features/recurring/models/recurring_models.dart';
import 'package:drift/drift.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:uuid/uuid.dart';

class RecurringService {
  final db.AppDatabase _db = db.AppDatabase.instance;
  final _uuid = const Uuid();

  // --- DATA FETCHING ---

  Future<List<String>> getCurrentDashboardBuckets() async {
    try {
      final record = await (_db.select(_db.financialRecords)
            ..orderBy([
              (t) =>
                  OrderingTerm(expression: t.createdAt, mode: OrderingMode.desc)
            ])
            ..limit(1))
          .getSingleOrNull();

      if (record != null && record.bucketOrder.isNotEmpty) {
        final List<dynamic> decoded = jsonDecode(record.bucketOrder);
        return decoded.map((e) => e.toString()).toList();
      }
    } catch (e) {
      debugPrint("Dashboard Buckets Fetch Error: $e");
    }
    return ['Needs', 'Wants', 'Savings', 'Investments'];
  }

  Stream<List<RecurringPatternModel>> getPatternsStream() {
    return (_db.select(_db.recurringPatterns)
          ..orderBy([
            (t) => OrderingTerm(expression: t.nextRunAt, mode: OrderingMode.asc)
          ]))
        .watch()
        .map((rows) => rows.map(_mapToModel).toList());
  }

  // --- ACTIONS ---

  Future<void> savePattern(RecurringPatternModel model) async {
    final timeStr =
        "${model.executionTime.hour.toString().padLeft(2, '0')}:${model.executionTime.minute.toString().padLeft(2, '0')}";

    DateTime nextRun = _calculateNextRunFromBaseline(
        model.startDate,
        model.frequency,
        model.interval,
        model.scheduleType,
        model.weekParam,
        model.dayParam,
        model.executionTime);

    final now = DateTime.now();
    if (nextRun.isBefore(now)) {
      while (nextRun.isBefore(now)) {
        nextRun = _calculateNextRunFromBaseline(
            nextRun,
            model.frequency,
            model.interval,
            model.scheduleType,
            model.weekParam,
            model.dayParam,
            model.executionTime,
            advance: true);
      }
    }

    final safeBucket = model.bucket.isEmpty ? 'Unallocated' : model.bucket;
    final safeCategory = model.category.isEmpty ? 'Transfer' : model.category;
    final safeSubCategory =
        model.subCategory.isEmpty ? 'Auto Transfer' : model.subCategory;

    await _db.into(_db.recurringPatterns).insertOnConflictUpdate(
          db.RecurringPatternsCompanion.insert(
            id: model.id.isEmpty ? _uuid.v4() : model.id,
            name: model.name,
            amount: model.amount,
            type: model.type,
            category: safeCategory,
            subCategory: safeSubCategory,
            bucket: Value(safeBucket),
            notes: Value(model.notes),
            sourceAccountId: Value(model.sourceAccountId),
            sourceCardId: Value(model.sourceCardId),
            destinationAccountId: Value(model.destinationAccountId),
            frequency: model.frequency,
            interval: Value(model.interval),
            startDate: model.startDate,
            executionTime: timeStr,
            scheduleType: Value(model.scheduleType),
            weekParam: Value(model.weekParam),
            dayParam: Value(model.dayParam),
            nextRunAt: nextRun,
            isActive: Value(model.isActive),
            autoExecute: Value(model.autoExecute),
          ),
        );

    if (model.autoExecute) processDuePayments();
  }

  Future<void> deletePattern(String id) async {
    await (_db.delete(_db.recurringPatterns)..where((t) => t.id.equals(id)))
        .go();
  }

  // --- SMART ENGINE UTILS ---

  List<DateTime> getNext3Dates(DateTime start, String freq, int interval,
      String type, int? week, int? day, TimeOfDay time) {
    List<DateTime> dates = [];
    final now = DateTime.now();
    DateTime calculated =
        _calculateNextRunFromBaseline(start, freq, 0, type, week, day, time);
    while (calculated.isBefore(now)) {
      calculated = _calculateNextRunFromBaseline(
          calculated, freq, interval, type, week, day, time,
          advance: true);
    }
    DateTime current = calculated;
    for (int i = 0; i < 3; i++) {
      dates.add(current);
      current = _calculateNextRunFromBaseline(
          current, freq, interval, type, week, day, time,
          advance: true);
    }
    return dates;
  }

  DateTime _calculateNextRunFromBaseline(DateTime current, String freq,
      int interval, String type, int? weekParam, int? dayParam, TimeOfDay time,
      {bool advance = false}) {
    DateTime targetBase =
        advance ? _addInterval(current, freq, interval) : current;
    if (type == 'Fixed') {
      return DateTime(targetBase.year, targetBase.month, targetBase.day,
          time.hour, time.minute);
    } else {
      return _findSmartDay(
          targetBase.year, targetBase.month, weekParam!, dayParam!, time);
    }
  }

  DateTime _addInterval(DateTime d, String freq, int interval) {
    switch (freq) {
      case 'Daily':
        return d.add(Duration(days: interval));
      case 'Weekly':
        return d.add(Duration(days: 7 * interval));
      case 'Monthly':
        return DateTime(d.year, d.month + interval, d.day);
      case 'Yearly':
        return DateTime(d.year + interval, d.month, d.day);
      default:
        return d;
    }
  }

  DateTime _findSmartDay(
      int year, int month, int weekRank, int weekday, TimeOfDay time) {
    if (weekRank == -1) {
      int lastDay = DateTime(year, month + 1, 0).day;
      DateTime dt = DateTime(year, month, lastDay, time.hour, time.minute);
      while (dt.weekday != weekday) dt = dt.subtract(const Duration(days: 1));
      return dt;
    } else {
      DateTime dt = DateTime(year, month, 1, time.hour, time.minute);
      while (dt.weekday != weekday) dt = dt.add(const Duration(days: 1));
      dt = dt.add(Duration(days: 7 * (weekRank - 1)));
      return dt;
    }
  }

  // --- HELPER: RESOLVE ACCOUNT NAMES (UPDATED) ---

  Future<String> _resolveAccountName(String id) async {
    // 1. Try Bank
    final bank = await (_db.select(_db.expenseAccounts)
          ..where((a) => a.id.equals(id)))
        .getSingleOrNull();
    if (bank != null)
      return "${bank.bankName} - ${bank.name}"; // [FIX] Format: SBI - Salary Acc

    // 2. Try Credit
    final card = await (_db.select(_db.creditCards)
          ..where((c) => c.id.equals(id)))
        .getSingleOrNull();
    if (card != null)
      return "${card.bankName} - ${card.name}"; // [FIX] Format: HDFC - Regalia

    return "Unknown";
  }

  Future<bool> _isCreditCard(String id) async {
    final card = await (_db.select(_db.creditCards)
          ..where((c) => c.id.equals(id)))
        .getSingleOrNull();
    return card != null;
  }

  // --- EXECUTION LOGIC ---

  Future<void> processDuePayments() async {
    final now = DateTime.now();
    final patterns = await (_db.select(_db.recurringPatterns)
          ..where((t) => t.isActive.equals(true))
          ..where((t) => t.autoExecute.equals(true)))
        .get();

    for (var row in patterns) {
      if (row.nextRunAt.isBefore(now) || row.nextRunAt.isAtSameMomentAs(now)) {
        await executeTransaction(_mapToModel(row));
      }
    }
  }

  Future<void> manualExecute(String id) async {
    final row = await (_db.select(_db.recurringPatterns)
          ..where((t) => t.id.equals(id)))
        .getSingle();
    await executeTransaction(_mapToModel(row));
  }

  Future<void> executeTransaction(RecurringPatternModel pattern) async {
    String? txnId;
    bool success = false;
    String? error;

    try {
      if (pattern.type == 'Transfer') {
        txnId = _uuid.v4();

        // Resolve Names for Description
        String sourceName = "Unknown";
        if (pattern.sourceCardId != null)
          sourceName = await _resolveAccountName(pattern.sourceCardId!);
        if (pattern.sourceAccountId != null)
          sourceName = await _resolveAccountName(pattern.sourceAccountId!);

        String destName = "Unknown";
        if (pattern.destinationAccountId != null)
          destName = await _resolveAccountName(pattern.destinationAccountId!);

        // CASE 1: Credit -> Bank (Cash Advance)
        if (pattern.sourceCardId != null) {
          await GetIt.I<CreditService>().addTransaction(CreditTransactionModel(
            id: txnId,
            cardId: pattern.sourceCardId!,
            amount: pattern.amount,
            date: DateTime.now(),
            bucket: 'Unallocated',
            type: 'Expense',
            category: 'Transfer',
            subCategory: 'Cash Advance',
            notes:
                "Auto: ${pattern.name} (To $destName)", // Context: Where it went
          ));

          if (pattern.destinationAccountId != null) {
            await GetIt.I<ExpenseService>()
                .addTransaction(ExpenseTransactionModel(
              id: _uuid.v4(),
              accountId: pattern.destinationAccountId!,
              amount: pattern.amount,
              date: DateTime.now(),
              bucket: 'Unallocated',
              type: 'Income',
              category: 'Transfer',
              subCategory: 'From Credit',
              notes:
                  "Auto: ${pattern.name} (From $sourceName)", // Context: Where it came from
            ));
          }
          success = true;
        }
        // CASE 2: Bank -> Destination
        else {
          // 1. Create Sender Transaction (Bank Transfer Out)
          await GetIt.I<ExpenseService>()
              .addTransaction(ExpenseTransactionModel(
            id: txnId,
            accountId: pattern.sourceAccountId ?? '',
            amount: pattern.amount,
            date: DateTime.now(),
            bucket: 'Unallocated',
            type: 'Transfer Out',
            category: 'Transfer',
            subCategory: 'Payment',
            notes: "Auto: ${pattern.name}",
            transferAccountId: pattern.destinationAccountId,
            transferAccountName:
                destName, // [FIX] Shows "Bank - Account" in list
          ));

          // 2. Create Receiver Transaction
          if (pattern.destinationAccountId != null) {
            final isDestCredit =
                await _isCreditCard(pattern.destinationAccountId!);

            if (isDestCredit) {
              // Bank -> Credit (Bill Payment)
              await GetIt.I<CreditService>()
                  .addTransaction(CreditTransactionModel(
                id: _uuid.v4(),
                cardId: pattern.destinationAccountId!,
                amount: -pattern.amount,
                date: DateTime.now(),
                bucket: 'Unallocated',
                type: 'Expense',
                category: 'Payment',
                subCategory: 'Auto Pay',
                notes:
                    "Auto: ${pattern.name} (From $sourceName)", // [FIX] Shows source in Credit Tracker
              ));
            } else {
              // Bank -> Bank
              await GetIt.I<ExpenseService>()
                  .addTransaction(ExpenseTransactionModel(
                id: _uuid.v4(),
                accountId: pattern.destinationAccountId!,
                amount: pattern.amount,
                date: DateTime.now(),
                bucket: 'Unallocated',
                type: 'Income',
                category: 'Transfer',
                subCategory: 'From Bank',
                notes:
                    "Auto: ${pattern.name} (From $sourceName)", // [FIX] Shows source in Bank Tracker
              ));
            }
          }
          success = true;
        }
      } else if (pattern.type == 'Income') {
        txnId = _uuid.v4();
        if (pattern.sourceCardId != null) {
          await GetIt.I<CreditService>().addTransaction(CreditTransactionModel(
            id: txnId,
            cardId: pattern.sourceCardId!,
            amount: -pattern.amount,
            date: DateTime.now(),
            bucket: 'Unallocated',
            type: 'Expense',
            category: 'Income',
            subCategory: 'Refund',
            notes: "Auto: ${pattern.name}",
          ));
        } else {
          await GetIt.I<ExpenseService>()
              .addTransaction(ExpenseTransactionModel(
            id: txnId,
            accountId: pattern.sourceAccountId ?? '',
            amount: pattern.amount,
            date: DateTime.now(),
            bucket: 'Unallocated',
            type: 'Income',
            category: pattern.category,
            subCategory: pattern.subCategory,
            notes: "Auto: ${pattern.name} ${pattern.notes}",
          ));
        }
        success = true;
      } else {
        // Expense
        txnId = _uuid.v4();
        if (pattern.sourceCardId != null) {
          await GetIt.I<CreditService>().addTransaction(CreditTransactionModel(
            id: txnId,
            cardId: pattern.sourceCardId!,
            amount: pattern.amount,
            date: DateTime.now(),
            bucket: pattern.bucket,
            type: 'Expense',
            category: pattern.category,
            subCategory: pattern.subCategory,
            notes: "Auto: ${pattern.name} ${pattern.notes}",
          ));
        } else {
          await GetIt.I<ExpenseService>()
              .addTransaction(ExpenseTransactionModel(
            id: txnId,
            accountId: pattern.sourceAccountId ?? '',
            amount: pattern.amount,
            date: DateTime.now(),
            bucket: pattern.bucket,
            type: 'Expense',
            category: pattern.category,
            subCategory: pattern.subCategory,
            notes: "Auto: ${pattern.name} ${pattern.notes}",
          ));
        }
        success = true;
      }
    } catch (e) {
      error = e.toString();
      debugPrint("Execution Error: $e");
    }

    await _db.into(_db.recurringLogs).insert(db.RecurringLogsCompanion.insert(
          id: _uuid.v4(),
          patternId: pattern.id,
          executedAt: DateTime.now(),
          isSuccess: success,
          error: Value(error),
          generatedTxnId: Value(txnId),
        ));

    if (success) {
      final next = _calculateNextRunFromBaseline(
          pattern.nextRunAt,
          pattern.frequency,
          pattern.interval,
          pattern.scheduleType,
          pattern.weekParam,
          pattern.dayParam,
          pattern.executionTime,
          advance: true);
      await (_db.update(_db.recurringPatterns)
            ..where((t) => t.id.equals(pattern.id)))
          .write(db.RecurringPatternsCompanion(nextRunAt: Value(next)));
    }
  }

  RecurringPatternModel _mapToModel(db.RecurringPattern row) {
    final t = row.executionTime.split(':');
    return RecurringPatternModel(
      id: row.id,
      name: row.name,
      amount: row.amount,
      type: row.type,
      category: row.category,
      subCategory: row.subCategory,
      bucket: row.bucket,
      notes: row.notes,
      sourceAccountId: row.sourceAccountId,
      sourceCardId: row.sourceCardId,
      destinationAccountId: row.destinationAccountId,
      frequency: row.frequency,
      interval: row.interval,
      startDate: row.startDate,
      executionTime: TimeOfDay(hour: int.parse(t[0]), minute: int.parse(t[1])),
      scheduleType: row.scheduleType,
      weekParam: row.weekParam,
      dayParam: row.dayParam,
      nextRunAt: row.nextRunAt,
      isActive: row.isActive,
      autoExecute: row.autoExecute,
    );
  }
}
