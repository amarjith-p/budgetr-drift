import 'dart:async';
import 'package:drift/drift.dart';
import 'package:get_it/get_it.dart';
import 'package:flutter/foundation.dart';
import '../../../core/database/app_database.dart';
import 'notification_service.dart';

/// Central Nervous System for Notifications
/// Listens to:
/// 1. Database Changes (Data Events)
/// 2. Clock Ticks (Time Events)
class RealTimeNotificationManager {
  final AppDatabase _db = AppDatabase.instance;
  final NotificationService _notificationService =
      GetIt.I<NotificationService>();

  // Stream Subscriptions (Data Events)
  StreamSubscription? _expenseSub;
  StreamSubscription? _creditSub;
  StreamSubscription? _goalSub;
  StreamSubscription? _loanSub;
  StreamSubscription? _budgetSub;
  StreamSubscription? _investmentSub;

  // Debounce Timers
  Timer? _expenseTimer;
  Timer? _creditTimer;
  Timer? _goalTimer;
  Timer? _loanTimer;
  Timer? _budgetTimer;
  Timer? _investmentTimer;

  // Heartbeat Timer (Time Events)
  Timer? _heartbeatTimer;

  // --- INITIALIZATION ---
  void init() {
    debugPrint("Initializing Real-Time Notification Engine...");

    // 1. Start Database Listeners
    _initDbListeners();

    // 2. Start Time Heartbeat
    _startHeartbeat();
  }

  void _initDbListeners() {
    // 1. Daily Expenses & Accounts
    // Trigger: Spending Money -> Affects Account Balance AND Budget Limits
    _expenseSub = _db.expenseAccounts.select().watch().listen((_) {
      _debounce(_expenseTimer, () {
        debugPrint("RealTime: Expense/Account Change Detected");
        _notificationService
            .checkDailyExpenseHealth(); // Low Balance / Negative
        _notificationService.checkBudgetHealth(); // Budget Overflow
      });
    });

    // 2. Credit Cards
    // Trigger: Spending on Card -> Affects Utilization
    _creditSub = _db.creditCards.select().watch().listen((_) {
      _debounce(_creditTimer, () {
        debugPrint("RealTime: Credit Change Detected");
        _notificationService.checkCreditHealth();
        _notificationService.checkBudgetHealth();
      });
    });

    // 3. Goals
    // Trigger: Saving money -> Goal Achievement
    _goalSub = _db.goals.select().watch().listen((_) {
      _debounce(_goalTimer, () {
        debugPrint("RealTime: Goal Change Detected");
        _notificationService.checkGoalLoanStatus();
      });
    });

    // 4. Loans
    // Trigger: Paying off loan -> Loan Completion
    _loanSub = _db.loans.select().watch().listen((_) {
      _debounce(_loanTimer, () {
        debugPrint("RealTime: Loan Change Detected");
        _notificationService.checkGoalLoanStatus();
      });
    });

    // 5. Budget Settings
    // Trigger: Changing limits -> Re-validate spending
    _budgetSub = _db.financialRecords.select().watch().listen((_) {
      _debounce(_budgetTimer, () {
        debugPrint("RealTime: Budget Config Change Detected");
        _notificationService.checkBudgetHealth();
      });
    });

    // 6. Investments
    // Trigger: Price Refresh / New Asset -> Volatility / Milestones
    _investmentSub = _db.investmentRecords.select().watch().listen((_) {
      _debounce(_investmentTimer, () {
        debugPrint("RealTime: Investment Change Detected");
        _notificationService.checkInvestmentVolatilityAndMilestones();
        _notificationService.checkInvestmentHealth();
      });
    });
  }

  /// Runs periodic checks for events that depend on TIME, not Data.
  /// (e.g., Midnight crossover for Due Dates, Statements, Backup Overdue)
  void _startHeartbeat() {
    // Run every 60 seconds
    _heartbeatTimer = Timer.periodic(const Duration(seconds: 60), (timer) {
      debugPrint("RealTime: Heartbeat Check (Time-based Events)");

      // These checks rely on 'Today's Date'.
      // If the clock ticks past midnight while app is open, these will fire.

      // 1. Check for Statements & Due Dates
      _notificationService.checkCreditHealth();

      // 2. Check for Loan Deadlines
      _notificationService.checkGoalLoanStatus();

      // 3. Check for Backup Overdue
      _notificationService.checkBackupStatus();

      // 4. Check for Stale Investment Data
      _notificationService.checkInvestmentHealth();
    });
  }

  // --- HELPER: Debounce ---
  void _debounce(Timer? timer, Function action) {
    if (timer?.isActive ?? false) timer!.cancel();
    timer = Timer(const Duration(seconds: 2), () {
      action();
    });
  }

  // --- CLEANUP ---
  void dispose() {
    _expenseSub?.cancel();
    _creditSub?.cancel();
    _goalSub?.cancel();
    _loanSub?.cancel();
    _budgetSub?.cancel();
    _investmentSub?.cancel();

    _expenseTimer?.cancel();
    _creditTimer?.cancel();
    _goalTimer?.cancel();
    _loanTimer?.cancel();
    _budgetTimer?.cancel();
    _investmentTimer?.cancel();

    _heartbeatTimer?.cancel();
  }
}
