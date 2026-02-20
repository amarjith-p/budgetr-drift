import 'dart:convert';
import 'package:drift/drift.dart';
import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/database/app_database.dart';
import '../../../core/database/tables.dart';
import '../database/notification_tables.dart';
import 'system_notification_service.dart';

class NotificationCheckLogic {
  final AppDatabase db;
  final SystemNotificationService systemService;

  NotificationCheckLogic(this.db, this.systemService);

  // --- PREF KEYS ---
  static const String kPrefCreditEnabled = 'notif_enable_credit';
  static const String kPrefBudgetEnabled = 'notif_enable_budget';
  static const String kPrefAccountEnabled = 'notif_enable_account';
  static const String kPrefInvestEnabled = 'notif_enable_invest';
  static const String kPrefLoanGoalEnabled = 'notif_enable_loangoal';
  static const String kPrefLowBalanceThreshold = 'notif_config_low_balance';

  // --- CONFIG HELPER ---
  Future<bool> _isEnabled(String key) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(key) ?? true;
  }

  Future<double> _getThreshold(String key, double defaultVal) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getDouble(key) ?? defaultVal;
  }

  Future<bool> _shouldNotify(String key) async {
    final prefs = await SharedPreferences.getInstance();
    return !prefs.containsKey(key);
  }

  Future<void> _markNotified(String key) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(key, true);
  }

  String _getDailyKey(String type, String id) {
    final dateStr = DateFormat('yyyyMMdd').format(DateTime.now());
    return 'notif_${type}_${id}_$dateStr';
  }

  String _getMonthlyKey(String type, String id) {
    final dateStr = DateFormat('yyyyMM').format(DateTime.now());
    return 'notif_${type}_${id}_$dateStr';
  }

  Future<void> createNotification({
    required String type,
    required String title,
    required String message,
    String? payload,
    bool pushSystem = true, // [NEW] Allows silent history sync
  }) async {
    final exists = await (db.select(db.appNotifications)
          ..where((t) {
            final basicCheck = t.type.equals(type) & t.isRead.equals(false);
            final payloadCheck = payload != null
                ? t.payload.equals(payload)
                : t.payload.isNull();
            return basicCheck & payloadCheck;
          }))
        .getSingleOrNull();

    if (exists != null) return;

    await db.into(db.appNotifications).insert(AppNotificationsCompanion.insert(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          type: type,
          title: title,
          message: message,
          payload: Value(payload),
          isRead: const Value(false),
          createdAt: DateTime.now(),
        ));

    if (pushSystem) {
      final sysId = DateTime.now().millisecondsSinceEpoch ~/ 1000;
      try {
        await systemService.showInstantNotification(
            id: sysId, title: title, body: message, payload: payload);
      } catch (e) {
        debugPrint("System Notification Error: $e");
      }
    }
  }

  // ===========================================================================
  // [NEW] HISTORY SYNCHRONIZATION
  // Syncs OS-Scheduled alarms into the local database so they appear in the UI
  // ===========================================================================
  Future<void> syncScheduledToHistory() async {
    final now = DateTime.now();

    // 1. Sync Loans
    if (await _isEnabled(kPrefLoanGoalEnabled)) {
      final loans = await db.loans.select().get();
      for (var loan in loans) {
        final remaining = loan.totalAmount - loan.paidAmount;
        if (loan.isClosed || remaining <= 0) continue;
        final int emiDay = loan.nextPaymentDate?.day ?? loan.startDate.day;

        if (now.day == emiDay) {
          final key = _getDailyKey('emi_due_history', loan.id);
          if (await _shouldNotify(key)) {
            await createNotification(
              type: 'due_date',
              title: 'EMI Repayment Due',
              message: 'Your EMI for ${loan.title} is due today.',
              payload: loan.id,
              pushSystem: false, // Don't pop up again, just write to DB
            );
            await _markNotified(key);
          }
        }
      }
    }

    // 2. Sync Goals
    if (await _isEnabled(kPrefLoanGoalEnabled)) {
      final goals = await db.goals.select().get();
      for (var goal in goals) {
        if (goal.isCompleted || goal.deadline == null) continue;
        if (goal.deadline!.year == now.year &&
            goal.deadline!.month == now.month &&
            goal.deadline!.day == now.day) {
          final key = _getDailyKey('goal_due_history', goal.id);
          if (await _shouldNotify(key)) {
            await createNotification(
              type: 'goal_deadline',
              title: 'Goal Deadline Reached',
              message: 'Time is up for your goal: ${goal.name}.',
              payload: goal.id,
              pushSystem: false,
            );
            await _markNotified(key);
          }
        }
      }
    }

    // 3. Sync Credit Cards
    if (await _isEnabled(kPrefCreditEnabled)) {
      final cards = await db.creditCards.select().get();
      for (var card in cards) {
        if (card.dueDate == now.day) {
          final key = _getDailyKey('cc_due_history', card.id);
          if (await _shouldNotify(key)) {
            await createNotification(
              type: 'due_date',
              title: 'Credit Card Bill Due',
              message: 'Your bill for ${card.name} is due today.',
              payload: card.id,
              pushSystem: false,
            );
            await _markNotified(key);
          }
          if (card.billDate == now.day) {
            final key = _getDailyKey('cc_stmt_history', card.id);
            if (await _shouldNotify(key)) {
              await createNotification(
                type: 'statement',
                title: 'Statement Generated',
                message: 'Your bill for ${card.name} is generated today.',
                payload: card.id,
                pushSystem: false,
              );
              await _markNotified(key);
            }
          }
        }
      }
    }
  }

  // ===========================================================================
  // MODULE CHECKS
  // ===========================================================================

  Future<void> checkCreditHealth() async {
    if (!await _isEnabled(kPrefCreditEnabled)) return;

    try {
      final cards = await db.creditCards.select().get();

      for (var card in cards) {
        // [REMOVED Statement Generation Check from here]

        // Keep only the reactive state checks: Utilization & Limit Exceeded
        if (card.creditLimit > 0) {
          final utilization = (card.currentBalance / card.creditLimit) * 100;
          if (card.currentBalance > card.creditLimit) {
            final key = _getDailyKey('limit_exceeded', card.id);
            if (await _shouldNotify(key)) {
              await createNotification(
                type: 'limit_exceeded',
                title: 'Credit Limit Exceeded!',
                message: 'You have exceeded the limit on ${card.name}!',
                payload: card.id,
              );
              await _markNotified(key);
            }
          } else if (utilization >= 90) {
            final key = _getDailyKey('high_util', card.id);
            if (await _shouldNotify(key)) {
              await createNotification(
                type: 'high_util',
                title: 'High Utilization Alert',
                message:
                    'You have used ${utilization.toStringAsFixed(2)}% of ${card.name}.',
                payload: card.id,
              );
              await _markNotified(key);
            }
          }
        }
      }
    } catch (e) {
      debugPrint("Logic Check (Credit) Error: $e");
    }
  }

  Future<void> checkBudgetHealth() async {
    if (!await _isEnabled(kPrefBudgetEnabled)) return;

    try {
      final now = DateTime.now();
      final currentMonthId =
          '${now.year}${now.month.toString().padLeft(2, '0')}';

      final currentRecord = await (db.select(db.financialRecords)
            ..where((t) => t.id.equals(currentMonthId)))
          .getSingleOrNull();

      if (currentRecord == null) {
        if (now.day <= 5) {
          final key = _getMonthlyKey('budget_not_set', 'global');
          if (await _shouldNotify(key)) {
            await createNotification(
              type: 'budget_not_set',
              title: 'Set Your Budget',
              message: 'Welcome to a new month! Plan your finances now.',
              payload: 'dashboard',
            );
            await _markNotified(key);
          }
        }
        return;
      }

      final prevDate = DateTime(now.year, now.month - 1);
      final prevMonthId =
          '${prevDate.year}${prevDate.month.toString().padLeft(2, '0')}';

      final prevRecord = await (db.select(db.financialRecords)
            ..where((t) => t.id.equals(prevMonthId)))
          .getSingleOrNull();

      if (prevRecord != null) {
        final settlement = await (db.select(db.settlements)
              ..where((t) => t.id.equals(prevMonthId)))
            .getSingleOrNull();

        if (settlement == null) {
          final key = _getMonthlyKey('budget_closure_pending', 'prev_month');
          if (await _shouldNotify(key)) {
            await createNotification(
              type: 'budget_closure_pending',
              title: 'Close Previous Budget',
              message: 'You haven\'t closed your budget for last month yet.',
              payload: 'settlement',
            );
            await _markNotified(key);
          }
        }
      }

      final startOfMonth = DateTime(now.year, now.month, 1);
      final endOfMonth = DateTime(now.year, now.month + 1, 0, 23, 59, 59);

      final transactions = await (db.select(db.expenseTransactions)
            ..where((t) => t.date.isBetweenValues(startOfMonth, endOfMonth))
            ..where((t) => t.type.equals('Expense')))
          .get();

      Map<String, double> bucketSpending = {};
      double totalSpent = 0;

      for (var txn in transactions) {
        bucketSpending[txn.bucket] =
            (bucketSpending[txn.bucket] ?? 0) + txn.amount;
        totalSpent += txn.amount;
      }

      try {
        final Map<String, dynamic> allocationsMap =
            jsonDecode(currentRecord.allocations);

        allocationsMap.forEach((bucketName, val) async {
          if (bucketName == 'Income') return;
          double allocated = (val as num).toDouble();
          double spent = bucketSpending[bucketName] ?? 0.0;

          if (allocated > 0) {
            if (spent > allocated) {
              final key = _getDailyKey('bucket_overflow', bucketName);
              _checkAndNotifyBucket(
                  key,
                  'bucket_overflow',
                  'Budget Exceeded: $bucketName',
                  'You exceeded your $bucketName budget.',
                  bucketName);
            } else if (spent >= (allocated * 0.9)) {
              final key = _getDailyKey('budget_approaching', bucketName);
              _checkAndNotifyBucket(
                  key,
                  'budget_approaching',
                  'Approaching Limit: $bucketName',
                  'You have used 90% of your $bucketName budget.',
                  bucketName);
            }
          }
        });
      } catch (e) {
        debugPrint("Allocations Parse Error: $e");
      }

      if (currentRecord.effectiveIncome > 0 &&
          totalSpent > currentRecord.effectiveIncome) {
        final key = _getDailyKey('global_overrun', 'total');
        if (await _shouldNotify(key)) {
          await createNotification(
            type: 'global_overrun',
            title: 'Critical: Income Exceeded',
            message: 'Your total spending is higher than your income!',
            payload: 'dashboard',
          );
          await _markNotified(key);
        }
      }
    } catch (e) {
      debugPrint("Logic Check (Budget) Error: $e");
    }
  }

  Future<void> _checkAndNotifyBucket(
      String key, String type, String title, String msg, String payload) async {
    if (await _shouldNotify(key)) {
      await createNotification(
        type: type,
        title: title,
        message: msg,
        payload: payload,
      );
      await _markNotified(key);
    }
  }

  Future<void> checkDailyExpenseHealth() async {
    if (!await _isEnabled(kPrefAccountEnabled)) return;

    final lowThreshold = await _getThreshold(kPrefLowBalanceThreshold, 1000.0);

    try {
      final accounts = await db.select(db.expenseAccounts).get();

      for (var acc in accounts) {
        if (acc.currentBalance < 0) {
          final key = _getDailyKey('negative_balance', acc.id);
          if (await _shouldNotify(key)) {
            await createNotification(
              type: 'negative_balance',
              title: 'Negative Balance Alert',
              message: '${acc.name} is in negative.',
              payload: acc.id,
            );
            await _markNotified(key);
          }
        } else if (acc.currentBalance < lowThreshold) {
          final key = _getDailyKey('low_balance', acc.id);
          if (await _shouldNotify(key)) {
            await createNotification(
              type: 'low_balance',
              title: 'Low Balance: ${acc.name}',
              message:
                  'Balance is low (INR ${acc.currentBalance.toStringAsFixed(2)}).',
              payload: acc.id,
            );
            await _markNotified(key);
          }
        }
      }

      final now = DateTime.now();
      final yesterday = now.subtract(const Duration(days: 1));
      final yesterdayStr = DateFormat('yyyyMMdd').format(yesterday);
      final logKey = 'notif_forgot_log_$yesterdayStr';

      if (await _shouldNotify(logKey)) {
        final startOfYesterday =
            DateTime(yesterday.year, yesterday.month, yesterday.day);
        final endOfYesterday = DateTime(
            yesterday.year, yesterday.month, yesterday.day, 23, 59, 59);

        final yesterdayTxns = await (db.select(db.expenseTransactions)
              ..where((t) =>
                  t.date.isBetweenValues(startOfYesterday, endOfYesterday)))
            .get();

        if (yesterdayTxns.isEmpty) {
          await createNotification(
            type: 'forgot_log',
            title: 'Forgot to Log?',
            message: 'You have no expenses recorded for yesterday.',
            payload: 'daily_expense',
          );
          await _markNotified(logKey);
        }
      }

      final currentMonthId =
          '${now.year}${now.month.toString().padLeft(2, '0')}';
      final limitRecord = await (db.select(db.heatmapLimits)
            ..where((t) => t.id.equals(currentMonthId)))
          .getSingleOrNull();

      if (limitRecord != null && limitRecord.severeLimit > 0) {
        final startOfToday = DateTime(now.year, now.month, now.day);
        final endOfToday = DateTime(now.year, now.month, now.day, 23, 59, 59);

        final todayTxns = await (db.select(db.expenseTransactions)
              ..where((t) =>
                  t.date.isBetweenValues(startOfToday, endOfToday) &
                  t.type.equals('Expense')))
            .get();

        double todayTotal = 0.0;
        for (var t in todayTxns) todayTotal += t.amount;

        if (todayTotal > limitRecord.severeLimit) {
          final key = _getDailyKey('daily_spike', 'total');
          if (await _shouldNotify(key)) {
            await createNotification(
              type: 'daily_spike',
              title: 'High Spending Alert',
              message:
                  'You spent INR ${todayTotal.toStringAsFixed(2)} today, exceeding your limit.',
              payload: 'spending_calendar',
            );
            await _markNotified(key);
          }
        }
      }
    } catch (_) {}
  }

  Future<void> checkInvestmentHealth() async {
    if (!await _isEnabled(kPrefInvestEnabled)) return;

    try {
      final investments = await db.select(db.investmentRecords).get();
      if (investments.isEmpty) return;

      final lastUpdated = investments.first.lastUpdated;
      final daysSinceUpdate = DateTime.now().difference(lastUpdated).inDays;

      if (daysSinceUpdate >= 3) {
        final key = _getDailyKey('inv_stale_data', 'global');
        if (await _shouldNotify(key)) {
          await createNotification(
            type: 'inv_stale',
            title: 'Outdated Prices',
            message:
                'Portfolio prices haven\'t been updated in $daysSinceUpdate days.',
            payload: 'investment',
          );
          await _markNotified(key);
        }
      }

      double totalCurrent = 0;
      double totalPrev = 0;

      for (var inv in investments) {
        totalCurrent += (inv.quantity * inv.currentPrice);
        totalPrev += (inv.quantity * inv.previousClose);

        double retPercent = 0.0;
        if (inv.averagePrice > 0) {
          retPercent =
              ((inv.currentPrice - inv.averagePrice) / inv.averagePrice) * 100;
        }

        if (retPercent >= 50) {
          int milestone = 0;
          if (retPercent >= 100)
            milestone = 100;
          else if (retPercent >= 50) milestone = 50;

          final key = 'notif_milestone_${inv.symbol}_$milestone';
          if (await _shouldNotify(key)) {
            await createNotification(
              type: 'inv_milestone',
              title: 'Milestone Alert: ${inv.symbol}',
              message: '${inv.name} has crossed +$milestone% returns!',
              payload: 'investment',
            );
            await _markNotified(key);
          }
        }
      }

      if (totalPrev > 0) {
        final changePercent = (totalCurrent - totalPrev) / totalPrev;
        final absChange = changePercent.abs();

        if (absChange >= 0.03) {
          final key = _getDailyKey('inv_volatility', 'portfolio');
          if (await _shouldNotify(key)) {
            final direction = changePercent > 0 ? "up" : "down";
            final percentStr = (absChange * 100).toStringAsFixed(2);

            await createNotification(
              type: 'inv_volatility',
              title: 'Market Alert',
              message: 'Your portfolio is $direction by $percentStr% today.',
              payload: 'investment',
            );
            await _markNotified(key);
          }
        }
      }
    } catch (e) {
      debugPrint("Inv Check Error: $e");
    }
  }

  Future<void> checkGoalLoanState() async {
    if (!await _isEnabled(kPrefLoanGoalEnabled)) return;
    try {
      final now = DateTime.now();

      final loans = await db.select(db.loans).get();
      for (var loan in loans) {
        final remaining = loan.totalAmount - loan.paidAmount;

        // 1. Closed Loan Check
        if (loan.isClosed || remaining <= 0) {
          final key = 'notif_loan_closed_${loan.id}';
          if (await _shouldNotify(key)) {
            await createNotification(
              type: 'loan_closed',
              title: 'Loan Paid Off! 🎉',
              message:
                  'Fantastic! You have successfully closed your loan: ${loan.title}.',
              payload: loan.id,
            );
            await _markNotified(key);
          }
          continue;
        }

        // 2. Overdue Check [FIXED: Relies precisely on nextPaymentDate]
        bool isOverdue = false;
        if (loan.nextPaymentDate != null) {
          isOverdue = loan.nextPaymentDate!
              .isBefore(DateTime(now.year, now.month, now.day));
        } else {
          // Fallback if user hasn't set nextPaymentDate
          DateTime thisMonthEmi =
              DateTime(now.year, now.month, loan.startDate.day);
          // If they missed it by up to 5 days, remind them (prevents forever-spam if ignored)
          if (now.isAfter(thisMonthEmi) &&
              now.difference(thisMonthEmi).inDays <= 5) {
            isOverdue = true;
          }
        }

        if (isOverdue) {
          final key = _getDailyKey('loan_overdue', loan.id);
          if (await _shouldNotify(key)) {
            await createNotification(
              type: 'loan_overdue',
              title: 'Loan Overdue Alert',
              message: 'The repayment for ${loan.title} is overdue!',
              payload: loan.id,
            );
            await _markNotified(key);
          }
        }
      }

      final goals = await db.select(db.goals).get();
      for (var goal in goals) {
        if (goal.isCompleted) {
          final key = 'notif_goal_achieved_${goal.id}';
          if (await _shouldNotify(key)) {
            await createNotification(
              type: 'goal_achieved',
              title: 'Goal Achieved! 🎉',
              message:
                  'Congratulations! You have reached your goal: ${goal.name}.',
              payload: goal.id,
            );
            await _markNotified(key);
          }
        }
      }
    } catch (e) {
      debugPrint("Goal/Loan Check Error: $e");
    }
  }
}
