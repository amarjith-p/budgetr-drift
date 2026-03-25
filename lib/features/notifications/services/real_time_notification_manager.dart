// import 'dart:async';
// import 'package:drift/drift.dart';
// import 'package:flutter/material.dart';
// import 'package:get_it/get_it.dart';
// import 'package:flutter/foundation.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import '../../../core/database/app_database.dart';
// import 'notification_service.dart';
// import 'system_notification_service.dart';

// class RealTimeNotificationManager {
//   final AppDatabase _db = AppDatabase.instance;
//   final NotificationService _notificationService =
//       GetIt.I<NotificationService>();
//   final SystemNotificationService _systemService =
//       GetIt.I<SystemNotificationService>();

//   StreamSubscription? _expenseAccSub;
//   StreamSubscription? _expenseTxnSub;
//   StreamSubscription? _creditSub;
//   StreamSubscription? _goalSub;
//   StreamSubscription? _loanSub;
//   StreamSubscription? _budgetSub;
//   StreamSubscription? _investmentSub;

//   Timer? _debounceTimer;
//   bool _isRescheduling = false;

//   // Global offset counter to prevent notification collisions
//   int _schedulerOffsetSeconds = 0;

//   static const String kPrefDailyEnabled = 'notif_enable_daily_reminder';
//   static const String kPrefDailyTime = 'notif_time_daily';

//   static const String kPrefLoanGoalEnabled = 'notif_enable_loangoal';
//   static const String kPrefLoanGoalTime = 'notif_time_loangoal';

//   static const String kPrefBackupEnabled = 'notif_enable_backup';
//   static const String kPrefBackupTime = 'notif_time_backup';

//   static const String kPrefCreditEnabled = 'notif_enable_credit';
//   // [NEW] Unique time key for Credit Cards
//   static const String kPrefCreditTime = 'notif_time_credit';

//   void init() {
//     debugPrint("Initializing Real-Time Notification Engine...");
//     _initDbListeners();
//     rescheduleAll();
//   }

//   void _initDbListeners() {
//     _expenseAccSub = _db.expenseAccounts
//         .select()
//         .watch()
//         .listen((_) => _onDatabaseChanged());
//     _expenseTxnSub = _db.expenseTransactions
//         .select()
//         .watch()
//         .listen((_) => _onDatabaseChanged());
//     _creditSub =
//         _db.creditCards.select().watch().listen((_) => _onDatabaseChanged());
//     _investmentSub = _db.investmentRecords
//         .select()
//         .watch()
//         .listen((_) => _onDatabaseChanged());
//     _budgetSub = _db.financialRecords
//         .select()
//         .watch()
//         .listen((_) => _onDatabaseChanged());
//     _goalSub = _db.goals.select().watch().listen((_) => _onDatabaseChanged());
//     _loanSub = _db.loans.select().watch().listen((_) => _onDatabaseChanged());
//   }

//   void _onDatabaseChanged() {
//     if (_debounceTimer?.isActive ?? false) _debounceTimer!.cancel();

//     _debounceTimer = Timer(const Duration(seconds: 2), () async {
//       await _notificationService.runLogicChecks();

//       final loans = await _db.loans.select().get();
//       final goals = await _db.goals.select().get();
//       final cards = await _db.creditCards.select().get();

//       // Reschedule modules with staggering
//       _scheduleWithStaggering(loans, goals, cards);
//     });
//   }

//   Future<void> rescheduleAll() async {
//     if (_isRescheduling) return;
//     _isRescheduling = true;

//     try {
//       final loans = await _db.loans.select().get();
//       final goals = await _db.goals.select().get();
//       final cards = await _db.creditCards.select().get();

//       await _systemService.cancelAll();

//       // Reset the offset counter
//       _schedulerOffsetSeconds = 0;

//       // Schedule fixed items
//       await _scheduleDailyAppReminder();
//       await _scheduleBackupReminder();

//       // Schedule modules with staggering
//       await _scheduleWithStaggering(loans, goals, cards);
//     } finally {
//       await Future.delayed(const Duration(milliseconds: 300));
//       _isRescheduling = false;
//     }
//   }

//   Future<void> _scheduleWithStaggering(
//       List<Loan> loans, List<Goal> goals, List<CreditCard> cards) async {
//     await _scheduleLoanReminders(loans);
//     await _scheduleGoalDeadlines(goals);
//     await _scheduleCreditCardBills(cards);
//   }

//   // --- HELPER: Apply Staggering ---
//   DateTime _applyStagger(DateTime baseTime) {
//     final staggered = baseTime.add(Duration(seconds: _schedulerOffsetSeconds));
//     _schedulerOffsetSeconds += 15;
//     return staggered;
//   }

//   // --- HELPER: Safe Date Clamping (Prevents Feb 31st Bug) ---
//   DateTime _getValidDate(int year, int month, int day) {
//     final daysInMonth = DateTime(year, month + 1, 0).day;
//     final clampedDay = (day > daysInMonth) ? daysInMonth : day;
//     return DateTime(year, month, clampedDay);
//   }

//   Future<TimeOfDay> _fetchTime(
//       String key, int defaultHour, int defaultMinute) async {
//     final prefs = await SharedPreferences.getInstance();
//     final timeStr = prefs.getString(key);
//     if (timeStr == null || !timeStr.contains(":"))
//       return TimeOfDay(hour: defaultHour, minute: defaultMinute);
//     final parts = timeStr.split(":");
//     return TimeOfDay(
//         hour: int.tryParse(parts[0]) ?? defaultHour,
//         minute: int.tryParse(parts[1]) ?? defaultMinute);
//   }

//   Future<bool> _isEnabled(String key) async {
//     final prefs = await SharedPreferences.getInstance();
//     return prefs.getBool(key) ?? true;
//   }

//   // --- SCHEDULING LOGIC ---

//   Future<void> _scheduleDailyAppReminder() async {
//     if (!await _isEnabled(kPrefDailyEnabled)) return;
//     final time = await _fetchTime(kPrefDailyTime, 20, 0);
//     await _systemService.scheduleDailyNotification(
//       id: 9999,
//       title: 'Daily Check-in',
//       body:
//           'Keep your ledger accurate. Take a moment to record today\'s financial activity.',
//       hour: time.hour,
//       minute: time.minute,
//       payload: 'daily_expense',
//     );
//   }

//   Future<void> _scheduleBackupReminder() async {
//     if (!await _isEnabled(kPrefBackupEnabled)) return;
//     final time = await _fetchTime(kPrefBackupTime, 18, 0);
//     await _systemService.scheduleDailyNotification(
//       id: 8888,
//       title: 'Backup Verification',
//       body: 'Please Ensure your Data is Secured and Backed Up.',
//       hour: time.hour,
//       minute: time.minute,
//       payload: 'backup',
//     );
//   }

//   Future<void> _scheduleCreditCardBills(List<CreditCard> cards) async {
//     if (!await _isEnabled(kPrefCreditEnabled)) return;
//     // [UPDATED] Use independent Credit Time
//     final time = await _fetchTime(kPrefCreditTime, 10, 0);
//     final now = DateTime.now();

//     for (var card in cards) {
//       // 1. Due Date (Clamped safely)
//       DateTime nextDueDate = _getValidDate(now.year, now.month, card.dueDate);
//       if (nextDueDate.isBefore(DateTime(now.year, now.month, now.day))) {
//         nextDueDate = _getValidDate(now.year, now.month + 1, card.dueDate);
//       }

//       final dueTime = DateTime(nextDueDate.year, nextDueDate.month,
//           nextDueDate.day, time.hour, time.minute);

//       if (dueTime.isAfter(now)) {
//         await _systemService.scheduleNotification(
//           id: ('cc_${card.id}_today').hashCode.abs(),
//           title: 'Credit Card Bill Due',
//           body: 'Your Bill for ${card.bankName} - ${card.name} is Due Today.',
//           scheduledDate: _applyStagger(dueTime),
//           payload: card.id,
//         );
//       }

//       final oneDayBefore = dueTime.subtract(const Duration(days: 1));
//       if (oneDayBefore.isAfter(now)) {
//         await _systemService.scheduleNotification(
//           id: ('cc_${card.id}_1day').hashCode.abs(),
//           title: 'Credit Card Bill Tomorrow',
//           body:
//               'Your Bill for ${card.bankName} - ${card.name} is Due Tomorrow.',
//           scheduledDate: _applyStagger(oneDayBefore),
//           payload: card.id,
//         );
//       }

//       final threeDaysBefore = dueTime.subtract(const Duration(days: 3));
//       if (threeDaysBefore.isAfter(now)) {
//         await _systemService.scheduleNotification(
//           id: ('cc_${card.id}_3days').hashCode.abs(),
//           title: 'Credit Card Bill Soon',
//           body:
//               'Your Bill for ${card.bankName} - ${card.name} is Due in 3 Days.',
//           scheduledDate: _applyStagger(threeDaysBefore),
//           payload: card.id,
//         );
//       }

//       // 2. Statement Date (Clamped safely)
//       DateTime nextBillDate = _getValidDate(now.year, now.month, card.billDate);
//       if (nextBillDate.isBefore(DateTime(now.year, now.month, now.day))) {
//         nextBillDate = _getValidDate(now.year, now.month + 1, card.billDate);
//       }

//       final billTime = DateTime(nextBillDate.year, nextBillDate.month,
//           nextBillDate.day, time.hour, time.minute);

//       if (billTime.isAfter(now)) {
//         await _systemService.scheduleNotification(
//           id: ('cc_${card.id}_stmt').hashCode.abs(),
//           title: 'Statement Generated',
//           body:
//               'Your Bill for ${card.bankName} - ${card.name} is Generated Today.',
//           scheduledDate: _applyStagger(billTime),
//           payload: card.id,
//         );
//       }
//     }
//   }

//   Future<void> _scheduleLoanReminders(List<Loan> loans) async {
//     if (!await _isEnabled(kPrefLoanGoalEnabled)) return;
//     final time = await _fetchTime(kPrefLoanGoalTime, 9, 0);
//     final now = DateTime.now();

//     for (var loan in loans) {
//       final remaining = loan.totalAmount - loan.paidAmount;
//       if (remaining <= 0 || loan.isClosed) continue;

//       final int emiDay = loan.nextPaymentDate?.day ?? loan.startDate.day;

//       DateTime nextEmiDate = _getValidDate(now.year, now.month, emiDay);

//       if (nextEmiDate.isBefore(DateTime(now.year, now.month, now.day))) {
//         nextEmiDate = _getValidDate(now.year, now.month + 1, emiDay);
//       }

//       if (loan.dueDate != null && nextEmiDate.isAfter(loan.dueDate!)) continue;

//       final dueTime = DateTime(nextEmiDate.year, nextEmiDate.month,
//           nextEmiDate.day, time.hour, time.minute);

//       if (dueTime.isAfter(now)) {
//         await _systemService.scheduleNotification(
//           id: ('loan_${loan.id}_today').hashCode.abs(),
//           title: 'EMI Repayment Due',
//           body: 'Your EMI for ${loan.title} is Due Today.',
//           scheduledDate: _applyStagger(dueTime),
//           payload: loan.id,
//         );
//       }

//       final oneDayBefore = dueTime.subtract(const Duration(days: 1));
//       if (oneDayBefore.isAfter(now)) {
//         await _systemService.scheduleNotification(
//           id: ('loan_${loan.id}_1day').hashCode.abs(),
//           title: 'EMI Due Tomorrow',
//           body: 'Your EMI for ${loan.title} is Due Tomorrow.',
//           scheduledDate: _applyStagger(oneDayBefore),
//           payload: loan.id,
//         );
//       }

//       final threeDaysBefore = dueTime.subtract(const Duration(days: 3));
//       if (threeDaysBefore.isAfter(now)) {
//         await _systemService.scheduleNotification(
//           id: ('loan_${loan.id}_3days').hashCode.abs(),
//           title: 'EMI Due Soon',
//           body: 'Your EMI for ${loan.title} is Due in 3 Days.',
//           scheduledDate: _applyStagger(threeDaysBefore),
//           payload: loan.id,
//         );
//       }
//     }
//   }

//   Future<void> _scheduleGoalDeadlines(List<Goal> goals) async {
//     if (!await _isEnabled(kPrefLoanGoalEnabled)) return;
//     final time = await _fetchTime(kPrefLoanGoalTime, 9, 0);
//     final now = DateTime.now();

//     for (var goal in goals) {
//       if (goal.isCompleted || goal.deadline == null) continue;

//       final dead = goal.deadline!;
//       final dueTime =
//           DateTime(dead.year, dead.month, dead.day, time.hour, time.minute);

//       if (dueTime.isAfter(now)) {
//         await _systemService.scheduleNotification(
//           id: ('goal_${goal.id}_today').hashCode.abs(),
//           title: 'Goal Deadline Reached',
//           body: 'Time is up for your Goal: ${goal.name}.',
//           scheduledDate: _applyStagger(dueTime),
//           payload: goal.id,
//         );
//       }

//       final oneDayBefore = dead.subtract(const Duration(days: 1));
//       final warnTime1 = DateTime(oneDayBefore.year, oneDayBefore.month,
//           oneDayBefore.day, time.hour, time.minute);
//       if (warnTime1.isAfter(now)) {
//         await _systemService.scheduleNotification(
//           id: ('goal_${goal.id}_1day').hashCode.abs(),
//           title: 'Goal Deadline Tomorrow',
//           body: '${goal.name} is Due Tomorrow.',
//           scheduledDate: _applyStagger(warnTime1),
//           payload: goal.id,
//         );
//       }

//       final sevenDaysBefore = dead.subtract(const Duration(days: 7));
//       final warnTime7 = DateTime(sevenDaysBefore.year, sevenDaysBefore.month,
//           sevenDaysBefore.day, time.hour, time.minute);
//       if (warnTime7.isAfter(now)) {
//         await _systemService.scheduleNotification(
//           id: ('goal_${goal.id}_7days').hashCode.abs(),
//           title: 'Goal Deadline Approaching',
//           body: '${goal.name} is due in 7 days.',
//           scheduledDate: _applyStagger(warnTime7),
//           payload: goal.id,
//         );
//       }
//     }
//   }

//   void dispose() {
//     _expenseAccSub?.cancel();
//     _expenseTxnSub?.cancel();
//     _creditSub?.cancel();
//     _goalSub?.cancel();
//     _loanSub?.cancel();
//     _budgetSub?.cancel();
//     _investmentSub?.cancel();
//     _debounceTimer?.cancel();
//   }
// }

import 'dart:async';
import 'package:drift/drift.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/database/app_database.dart';
import 'notification_service.dart';
import 'system_notification_service.dart';

// --- [NEW IMPORTS] Batched Notification Schedulers ---
import '../../credit_tracker/services/credit_notification_scheduler.dart';
import '../../goals_loans/services/goals_loans_notification_scheduler.dart';

class RealTimeNotificationManager {
  final AppDatabase _db = AppDatabase.instance;
  final NotificationService _notificationService =
      GetIt.I<NotificationService>();
  final SystemNotificationService _systemService =
      GetIt.I<SystemNotificationService>();

  StreamSubscription? _expenseAccSub;
  StreamSubscription? _expenseTxnSub;
  StreamSubscription? _creditSub;
  StreamSubscription? _goalSub;
  StreamSubscription? _loanSub;
  StreamSubscription? _budgetSub;
  StreamSubscription? _investmentSub;

  Timer? _debounceTimer;
  bool _isRescheduling = false;

  static const String kPrefDailyEnabled = 'notif_enable_daily_reminder';
  static const String kPrefDailyTime = 'notif_time_daily';

  static const String kPrefBackupEnabled = 'notif_enable_backup';
  static const String kPrefBackupTime = 'notif_time_backup';

  void init() {
    debugPrint("Initializing Batched Real-Time Notification Engine...");
    _initDbListeners();
    rescheduleAll();
  }

  void _initDbListeners() {
    _expenseAccSub = _db.expenseAccounts
        .select()
        .watch()
        .listen((_) => _onDatabaseChanged());
    _expenseTxnSub = _db.expenseTransactions
        .select()
        .watch()
        .listen((_) => _onDatabaseChanged());
    _creditSub =
        _db.creditCards.select().watch().listen((_) => _onDatabaseChanged());
    _investmentSub = _db.investmentRecords
        .select()
        .watch()
        .listen((_) => _onDatabaseChanged());
    _budgetSub = _db.financialRecords
        .select()
        .watch()
        .listen((_) => _onDatabaseChanged());
    _goalSub = _db.goals.select().watch().listen((_) => _onDatabaseChanged());
    _loanSub = _db.loans.select().watch().listen((_) => _onDatabaseChanged());
  }

  void _onDatabaseChanged() {
    if (_debounceTimer?.isActive ?? false) _debounceTimer!.cancel();

    _debounceTimer = Timer(const Duration(seconds: 2), () async {
      // Logic checks remain exactly as before
      await _notificationService.runLogicChecks();

      final loans = await _db.loans.select().get();
      final goals = await _db.goals.select().get();
      final cards = await _db.creditCards.select().get();

      // Hand off to Batched Engines
      _scheduleBatchedModules(loans, goals, cards);
    });
  }

  Future<void> rescheduleAll() async {
    if (_isRescheduling) return;
    _isRescheduling = true;

    try {
      final loans = await _db.loans.select().get();
      final goals = await _db.goals.select().get();
      final cards = await _db.creditCards.select().get();

      // Clear legacy/static notifications
      await _systemService.cancelAll();

      // 1. Schedule Fixed Static Items
      await _scheduleDailyAppReminder();
      await _scheduleBackupReminder();

      // 2. Delegate Dynamic Items to Batched Engines
      await _scheduleBatchedModules(loans, goals, cards);
    } finally {
      await Future.delayed(const Duration(milliseconds: 300));
      _isRescheduling = false;
    }
  }

  Future<void> _scheduleBatchedModules(
      List<Loan> loans, List<Goal> goals, List<CreditCard> cards) async {
    // [UPGRADE TO BATCHED ENGINES]
    // The old staggered loops have been entirely deprecated and replaced.
    // Overlapping alarms are now successfully grouped into Inbox-Style summaries.

    final creditScheduler = CreditNotificationScheduler();
    await creditScheduler.syncNotifications(cards);

    final goalLoanScheduler = GoalsLoansNotificationScheduler();
    await goalLoanScheduler.syncNotifications(loans, goals);
  }

  Future<TimeOfDay> _fetchTime(
      String key, int defaultHour, int defaultMinute) async {
    final prefs = await SharedPreferences.getInstance();
    final timeStr = prefs.getString(key);
    if (timeStr == null || !timeStr.contains(":"))
      return TimeOfDay(hour: defaultHour, minute: defaultMinute);
    final parts = timeStr.split(":");
    return TimeOfDay(
        hour: int.tryParse(parts[0]) ?? defaultHour,
        minute: int.tryParse(parts[1]) ?? defaultMinute);
  }

  Future<bool> _isEnabled(String key) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(key) ?? true;
  }

  // --- STATIC SCHEDULING LOGIC ---

  Future<void> _scheduleDailyAppReminder() async {
    if (!await _isEnabled(kPrefDailyEnabled)) return;
    final time = await _fetchTime(kPrefDailyTime, 20, 0);
    await _systemService.scheduleDailyNotification(
      id: 9999,
      title: 'Daily Check-in',
      body:
          'Keep your ledger accurate. Take a moment to record today\'s financial activity.',
      hour: time.hour,
      minute: time.minute,
      payload: 'daily_expense',
    );
  }

  Future<void> _scheduleBackupReminder() async {
    if (!await _isEnabled(kPrefBackupEnabled)) return;
    final time = await _fetchTime(kPrefBackupTime, 18, 0);
    await _systemService.scheduleDailyNotification(
      id: 8888,
      title: 'Backup Verification',
      body: 'Please Ensure your Data is Secured and Backed Up.',
      hour: time.hour,
      minute: time.minute,
      payload: 'backup',
    );
  }

  void dispose() {
    _expenseAccSub?.cancel();
    _expenseTxnSub?.cancel();
    _creditSub?.cancel();
    _goalSub?.cancel();
    _loanSub?.cancel();
    _budgetSub?.cancel();
    _investmentSub?.cancel();
    _debounceTimer?.cancel();
  }
}
