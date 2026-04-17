import 'dart:convert';
import 'package:budget/core/database/app_database.dart' as db;
import 'package:budget/features/credit_tracker/models/credit_models.dart';
import 'package:budget/features/credit_tracker/services/credit_service.dart';
import 'package:budget/features/daily_expense/models/expense_models.dart';
import 'package:budget/features/daily_expense/services/expense_service.dart';
import 'package:budget/features/recurring/models/recurring_models.dart';
import 'package:budget/features/notifications/database/notification_tables.dart';
import 'package:drift/drift.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:rxdart/rxdart.dart';
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

  // --- REACTIVE FORECASTING ---

  Stream<Map<String, double>> getForecastingStream() {
    final accountsStream = _db.select(_db.expenseAccounts).watch();

    final patternsStream = (_db.select(_db.recurringPatterns)
          ..where((t) => t.isActive.equals(true)))
        .watch();

    return Rx.combineLatest2(accountsStream, patternsStream,
        (List<db.ExpenseAccount> accounts, List<db.RecurringPattern> patterns) {
      double totalLiquidity = 0;
      for (var acc in accounts) {
        totalLiquidity += acc.currentBalance;
      }

      final now = DateTime.now();
      final next30 = now.add(const Duration(days: 30));
      double pendingBills = 0;

      for (var row in patterns) {
        final p = _mapToModel(row);
        if (p.type != 'Expense') continue;
        DateTime cursor = p.nextRunAt;

        while (cursor.isBefore(next30)) {
          pendingBills += p.amount;
          cursor = _calculateNextRunFromBaseline(
              cursor,
              p.frequency,
              p.interval,
              p.scheduleType,
              p.weekParam,
              p.dayParam,
              p.executionTime,
              advance: true);
        }
      }

      return {
        'liquidity': totalLiquidity,
        'bills': pendingBills,
        'safe': totalLiquidity - pendingBills
      };
    });
  }

  // --- ACTIONS ---

  Future<void> savePattern(RecurringPatternModel model) async {
    final timeStr =
        "${model.executionTime.hour.toString().padLeft(2, '0')}:${model.executionTime.minute.toString().padLeft(2, '0')}";

    DateTime nextRun = model.nextRunAt;

    if (model.id.isEmpty || model.occurrencesProcessed == 0) {
      nextRun = _calculateNextRunFromBaseline(
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
            isVariable: Value(model.isVariable),
            endDate: Value(model.endDate),
            maxOccurrences: Value(model.maxOccurrences),
            occurrencesProcessed: Value(model.occurrencesProcessed),
            website: Value(model.website),
            notifyBefore: Value(model.notifyBefore),
            nextRunAt: nextRun,
            isActive: Value(model.isActive),
            autoExecute: Value(model.autoExecute),
          ),
        );

    if (model.autoExecute && !model.isVariable) {
      processDuePayments();
    }
  }

  Future<void> deletePattern(String id) async {
    await (_db.delete(_db.recurringPatterns)..where((t) => t.id.equals(id)))
        .go();
  }

  Future<void> skipNextOccurrence(String id) async {
    final row = await (_db.select(_db.recurringPatterns)
          ..where((t) => t.id.equals(id)))
        .getSingle();
    final model = _mapToModel(row);

    final next = _calculateNextRunFromBaseline(
        model.nextRunAt,
        model.frequency,
        model.interval,
        model.scheduleType,
        model.weekParam,
        model.dayParam,
        model.executionTime,
        advance: true);

    await (_db.update(_db.recurringPatterns)..where((t) => t.id.equals(id)))
        .write(db.RecurringPatternsCompanion(nextRunAt: Value(next)));
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
      return _findSmartDay(targetBase.year, targetBase.month, weekParam ?? 1,
          dayParam ?? 1, time);
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

  // --- HELPER: RESOLVE ACCOUNT NAMES ---

  Future<String> _resolveAccountName(String id) async {
    final bank = await (_db.select(_db.expenseAccounts)
          ..where((a) => a.id.equals(id)))
        .getSingleOrNull();
    if (bank != null) return "${bank.bankName} - ${bank.name}";

    final card = await (_db.select(_db.creditCards)
          ..where((c) => c.id.equals(id)))
        .getSingleOrNull();
    if (card != null) return "${card.bankName} - ${card.name}";

    return "Unknown";
  }

  Future<bool> _isCreditCard(String id) async {
    final card = await (_db.select(_db.creditCards)
          ..where((c) => c.id.equals(id)))
        .getSingleOrNull();
    return card != null;
  }

  // LOW BALANCE GUARD
  Future<bool> _hasSufficientFunds(
      String? accountId, String? cardId, double amount) async {
    if (cardId != null) {
      final card = await (_db.select(_db.creditCards)
            ..where((c) => c.id.equals(cardId)))
          .getSingleOrNull();
      if (card == null) return false;
      return (card.creditLimit - card.currentBalance) >= amount;
    }
    if (accountId != null) {
      if (accountId == 'EXTERNAL_OPT') return true;
      final acc = await (_db.select(_db.expenseAccounts)
            ..where((a) => a.id.equals(accountId)))
          .getSingleOrNull();
      if (acc == null) return false;
      return acc.currentBalance >= amount;
    }
    return true;
  }

  // --- EXECUTION LOGIC ---

  Future<void> processDuePayments() async {
    final now = DateTime.now();
    final patterns = await (_db.select(_db.recurringPatterns)
          ..where((t) => t.isActive.equals(true)))
        .get();

    for (var row in patterns) {
      if (row.nextRunAt.isBefore(now) || row.nextRunAt.isAtSameMomentAs(now)) {
        final model = _mapToModel(row);

        // [REMOVED] Standard prompts and success alerts are now handled
        // entirely by RealTimeNotificationManager to prevent duplicates.

        if (model.isVariable) {
          continue;
        }

        if (model.autoExecute) {
          await executeTransaction(model);
        }
      }
    }
  }

  // [KEPT] This is required for dynamic runtime errors (like low balance)
  // that the OS scheduler cannot predict in advance.
  Future<void> _createNotification(
      {required String title,
      required String message,
      required String relatedId}) async {
    await _db.into(_db.appNotifications).insert(
        db.AppNotificationsCompanion.insert(
            id: _uuid.v4(),
            title: title,
            message: message,
            type: 'Recurring_Prompt',
            isRead: const Value(false),
            createdAt: DateTime.now(),
            payload: Value(relatedId)));
  }

  Future<void> manualExecute(String id, {double? overrideAmount}) async {
    final row = await (_db.select(_db.recurringPatterns)
          ..where((t) => t.id.equals(id)))
        .getSingle();

    var model = _mapToModel(row);
    if (overrideAmount != null) {
      model = RecurringPatternModel(
          id: model.id,
          name: model.name,
          amount: overrideAmount,
          type: model.type,
          category: model.category,
          subCategory: model.subCategory,
          bucket: model.bucket,
          notes: model.notes,
          sourceAccountId: model.sourceAccountId,
          sourceCardId: model.sourceCardId,
          destinationAccountId: model.destinationAccountId,
          frequency: model.frequency,
          interval: model.interval,
          startDate: model.startDate,
          executionTime: model.executionTime,
          nextRunAt: model.nextRunAt,
          isActive: model.isActive,
          autoExecute: model.autoExecute,
          isVariable: model.isVariable,
          endDate: model.endDate,
          maxOccurrences: model.maxOccurrences,
          occurrencesProcessed: model.occurrencesProcessed,
          website: model.website,
          notifyBefore: model.notifyBefore);
    }

    await executeTransaction(model);
  }

  Future<void> executeTransaction(RecurringPatternModel pattern) async {
    if (pattern.amount == 0.0 && pattern.isVariable) {
      debugPrint(
          "GUARD: Attempted to execute 0.00 variable payment. Aborting.");
      return;
    }

    // LOW BALANCE GUARD
    final hasFunds = await _hasSufficientFunds(
        pattern.sourceAccountId, pattern.sourceCardId, pattern.amount);
    if (!hasFunds) {
      // [KEPT] Trigger local notification ONLY on payment failure
      await _createNotification(
          title: "Payment Failed: ${pattern.name}",
          message: "Insufficient balance/limit.",
          relatedId: pattern.id);

      await _db.into(_db.recurringLogs).insert(db.RecurringLogsCompanion.insert(
            id: _uuid.v4(),
            patternId: pattern.id,
            executedAt: DateTime.now(),
            isSuccess: false,
            error: Value("Insufficient Funds Guard"),
          ));
      return;
    }

    String? txnId;
    bool success = false;
    String? error;

    try {
      if (pattern.type == 'Transfer') {
        txnId = _uuid.v4();
        String sourceName = "Unknown";
        if (pattern.sourceCardId != null)
          sourceName = await _resolveAccountName(pattern.sourceCardId!);
        if (pattern.sourceAccountId != null) {
          if (pattern.sourceAccountId == 'EXTERNAL_OPT') {
            sourceName = "External Account";
          } else {
            sourceName = await _resolveAccountName(pattern.sourceAccountId!);
          }
        }

        String destName = "Unknown";
        if (pattern.destinationAccountId != null) {
          if (pattern.destinationAccountId == 'EXTERNAL_OPT') {
            destName = "External Account";
          } else {
            destName = await _resolveAccountName(pattern.destinationAccountId!);
          }
        }

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
            notes: "Auto: ${pattern.name} (To $destName)",
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
              notes: "Auto: ${pattern.name} (From $sourceName)",
            ));
          }
          success = true;
        } else {
          if (pattern.destinationAccountId == 'EXTERNAL_OPT') {
            await GetIt.I<ExpenseService>()
                .addTransaction(ExpenseTransactionModel(
              id: txnId,
              accountId: pattern.sourceAccountId!,
              amount: pattern.amount,
              date: DateTime.now(),
              bucket: 'Unallocated',
              type: 'Transfer Out',
              category: 'Transfer',
              subCategory: 'To External',
              notes: "Auto: ${pattern.name}",
              transferAccountId: null,
              transferAccountName: 'External Account',
              transferAccountBankName: 'External',
            ));
          } else if (pattern.sourceAccountId == 'EXTERNAL_OPT') {
            await GetIt.I<ExpenseService>()
                .addTransaction(ExpenseTransactionModel(
              id: txnId,
              accountId: pattern.destinationAccountId!,
              amount: pattern.amount,
              date: DateTime.now(),
              bucket: 'Unallocated',
              type: 'Transfer In',
              category: 'Transfer',
              subCategory: 'From External',
              notes: "Auto: ${pattern.name}",
              transferAccountId: null,
              transferAccountName: 'External Account',
              transferAccountBankName: 'External',
            ));
          } else {
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
              transferAccountName: destName,
            ));

            if (pattern.destinationAccountId != null) {
              final isDestCredit =
                  await _isCreditCard(pattern.destinationAccountId!);

              if (isDestCredit) {
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
                  notes: "Auto: ${pattern.name} (From $sourceName)",
                ));
              } else {
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
                  notes: "Auto: ${pattern.name} (From $sourceName)",
                ));
              }
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
            bucket: 'Income',
            type: 'Income',
            category: pattern.category,
            subCategory: pattern.subCategory,
            notes: "Auto: ${pattern.name} ${pattern.notes}",
          ));
        }
        success = true;
      } else {
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

      final newCount = pattern.occurrencesProcessed + 1;

      bool shouldDeactivate = false;
      if (pattern.maxOccurrences != null &&
          newCount >= pattern.maxOccurrences!) {
        shouldDeactivate = true;
      }
      if (pattern.endDate != null && next.isAfter(pattern.endDate!)) {
        shouldDeactivate = true;
      }

      await (_db.update(_db.recurringPatterns)
            ..where((t) => t.id.equals(pattern.id)))
          .write(db.RecurringPatternsCompanion(
        nextRunAt: Value(next),
        occurrencesProcessed: Value(newCount),
        isActive: shouldDeactivate ? const Value(false) : const Value.absent(),
      ));
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
      isVariable: row.isVariable,
      endDate: row.endDate,
      maxOccurrences: row.maxOccurrences,
      occurrencesProcessed: row.occurrencesProcessed,
      website: row.website,
      notifyBefore: row.notifyBefore,
    );
  }
}
