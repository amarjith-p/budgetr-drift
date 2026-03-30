import 'package:intl/intl.dart';
import '../models/credit_models.dart';

// --- ENUM AND CLASS FOR CYCLE PROGRESS (LEGACY) ---
enum CyclePhase { payment, spending }

class CycleInfo {
  final CyclePhase phase;
  final DateTime startDate;
  final DateTime endDate;
  final int daysRemaining;
  final double progress;

  CycleInfo({
    required this.phase,
    required this.startDate,
    required this.endDate,
    required this.daysRemaining,
    required this.progress,
  });
}
// -----------------------------------------------

class BillingCycleUtils {
  // ========================================================
  // --- [NEW] INTELLIGENT SMART CYCLE ENGINE (FINANCIAL) ---
  // ========================================================
  static SmartCycleInfo getSmartCycleInfo(CreditCardDashboardData data) {
    final card = data.card;

    // 1. Check if completely debt-free
    if (card.currentBalance <= 0.01) {
      return SmartCycleInfo(
        phase: SmartCyclePhase.noActivity,
        daysRemaining: 0,
        progress: 0.0,
      );
    }

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    final lastBillDateRaw = getLastBillDate(now, card.billDate);
    final lastBillDate = DateTime(
        lastBillDateRaw.year, lastBillDateRaw.month, lastBillDateRaw.day);

    final nextBillDateRaw =
        _getValidDate(lastBillDate.year, lastBillDate.month + 1, card.billDate);
    final nextBillDate = DateTime(
        nextBillDateRaw.year, nextBillDateRaw.month, nextBillDateRaw.day);

    final currentDueDateRaw =
        getDueDateForStatement(lastBillDateRaw, card.dueDate);
    final currentDueDate = DateTime(
        currentDueDateRaw.year, currentDueDateRaw.month, currentDueDateRaw.day);

    final isInGracePeriod =
        !today.isBefore(lastBillDate) && !today.isAfter(currentDueDate);

    // 2. We are inside the Payment Window
    if (isInGracePeriod) {
      // Still owe statement money
      if (data.statementBalance > 0.01) {
        final totalDays = currentDueDate.difference(lastBillDate).inDays;
        final daysPassed = today.difference(lastBillDate).inDays;
        final daysRemaining = currentDueDate.difference(today).inDays;
        double progress = totalDays > 0 ? daysPassed / totalDays : 1.0;

        return SmartCycleInfo(
          phase: SmartCyclePhase.paymentDue,
          startDate: lastBillDate,
          endDate: currentDueDate,
          daysRemaining: daysRemaining < 0 ? 0 : daysRemaining,
          progress: progress.clamp(0.0, 1.0),
        );
      }
      // Statement is paid off, but card has unbilled spends
      else {
        DateTime start = currentDueDate;
        DateTime end = nextBillDate;
        if (today.isBefore(start)) start = lastBillDate;

        final totalDays = end.difference(start).inDays;
        final daysPassed = today.difference(start).inDays;
        final daysRemaining = end.difference(today).inDays;
        double progress = totalDays > 0 ? daysPassed / totalDays : 1.0;

        return SmartCycleInfo(
          phase: SmartCyclePhase.statementPaid,
          startDate: start,
          endDate: end,
          daysRemaining: daysRemaining < 0 ? 0 : daysRemaining,
          progress: progress.clamp(0.0, 1.0),
        );
      }
    }
    // 3. We are in the normal Spending Phase (Waiting for next bill)
    else {
      DateTime start = currentDueDate;
      DateTime end = nextBillDate;
      if (today.isBefore(start)) start = lastBillDate;

      final totalDays = end.difference(start).inDays;
      final daysPassed = today.difference(start).inDays;
      final daysRemaining = end.difference(today).inDays;
      double progress = totalDays > 0 ? daysPassed / totalDays : 1.0;

      return SmartCycleInfo(
        phase: SmartCyclePhase.unbilledSpending,
        startDate: start,
        endDate: end,
        daysRemaining: daysRemaining < 0 ? 0 : daysRemaining,
        progress: progress.clamp(0.0, 1.0),
      );
    }
  }

  // --- LEGACY CYCLE PROGRESS ENGINE ---
  static CycleInfo getCurrentCycleInfo(int billDay, int dueDay) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    final lastBillDateRaw = getLastBillDate(now, billDay);
    final lastBillDate = DateTime(
        lastBillDateRaw.year, lastBillDateRaw.month, lastBillDateRaw.day);

    final nextBillDateRaw =
        _getValidDate(lastBillDate.year, lastBillDate.month + 1, billDay);
    final nextBillDate = DateTime(
        nextBillDateRaw.year, nextBillDateRaw.month, nextBillDateRaw.day);

    final currentDueDateRaw = getDueDateForStatement(lastBillDateRaw, dueDay);
    final currentDueDate = DateTime(
        currentDueDateRaw.year, currentDueDateRaw.month, currentDueDateRaw.day);

    if (!today.isBefore(lastBillDate) && !today.isAfter(currentDueDate)) {
      final totalDays = currentDueDate.difference(lastBillDate).inDays;
      final daysPassed = today.difference(lastBillDate).inDays;
      final daysRemaining = currentDueDate.difference(today).inDays;
      double progress = totalDays > 0 ? daysPassed / totalDays : 1.0;

      return CycleInfo(
        phase: CyclePhase.payment,
        startDate: lastBillDate,
        endDate: currentDueDate,
        daysRemaining: daysRemaining,
        progress: progress.clamp(0.0, 1.0),
      );
    } else {
      DateTime start = currentDueDate;
      DateTime end = nextBillDate;
      if (today.isBefore(start)) start = lastBillDate;

      final totalDays = end.difference(start).inDays;
      final daysPassed = today.difference(start).inDays;
      final daysRemaining = end.difference(today).inDays;
      double progress = totalDays > 0 ? daysPassed / totalDays : 1.0;

      return CycleInfo(
        phase: CyclePhase.spending,
        startDate: start,
        endDate: end,
        daysRemaining: daysRemaining < 0 ? 0 : daysRemaining,
        progress: progress.clamp(0.0, 1.0),
      );
    }
  }

  static bool isDangerZone(DateTime txnDate, int billDay,
      {int thresholdDays = 3}) {
    final billDateThisMonth =
        _getValidDate(txnDate.year, txnDate.month, billDay);
    if (txnDate.isAfter(billDateThisMonth)) return false;
    final difference = billDateThisMonth.difference(txnDate).inDays;
    return difference >= 0 && difference <= thresholdDays;
  }

  static DateTime getStatementDateForTxn(DateTime txnDate, int billDay,
      {bool forceNextCycle = false}) {
    final billDateThisMonth =
        _getValidDate(txnDate.year, txnDate.month, billDay);

    DateTime calculatedDate;
    if (txnDate.isAfter(billDateThisMonth)) {
      final nextMonth = txnDate.month == 12 ? 1 : txnDate.month + 1;
      final nextYear = txnDate.month == 12 ? txnDate.year + 1 : txnDate.year;
      calculatedDate = _getValidDate(nextYear, nextMonth, billDay);
    } else {
      calculatedDate = billDateThisMonth;
    }

    if (forceNextCycle) {
      final nextMonth =
          calculatedDate.month == 12 ? 1 : calculatedDate.month + 1;
      final nextYear = calculatedDate.month == 12
          ? calculatedDate.year + 1
          : calculatedDate.year;
      return _getValidDate(nextYear, nextMonth, billDay);
    }

    return calculatedDate;
  }

  static bool isUnbilled(CreditTransactionModel txn, int billDay) {
    final now = DateTime.now();
    final lastBillDate = getLastBillDate(now, billDay);

    final stmtDate = getStatementDateForTxn(txn.date, billDay,
        forceNextCycle: txn.includeInNextStatement);

    return stmtDate.isAfter(lastBillDate);
  }

  static DateTime getPreviousStatementDate(
      DateTime currentStmtDate, int billDay) {
    final prevMonth =
        currentStmtDate.month == 1 ? 12 : currentStmtDate.month - 1;
    final prevYear = currentStmtDate.month == 1
        ? currentStmtDate.year - 1
        : currentStmtDate.year;
    return _getValidDate(prevYear, prevMonth, billDay);
  }

  static DateTime getLastBillDate(DateTime today, int billDay) {
    final billDateThisMonth = _getValidDate(today.year, today.month, billDay);
    if (today.isBefore(billDateThisMonth)) {
      final prevMonth = today.month == 1 ? 12 : today.month - 1;
      final prevYear = today.month == 1 ? today.year - 1 : today.year;
      return _getValidDate(prevYear, prevMonth, billDay);
    } else {
      return billDateThisMonth;
    }
  }

  static DateTime getDueDateForStatement(DateTime statementDate, int dueDay) {
    DateTime dueDate;
    if (dueDay < statementDate.day) {
      dueDate =
          _getValidDate(statementDate.year, statementDate.month + 1, dueDay);
    } else {
      dueDate = _getValidDate(statementDate.year, statementDate.month, dueDay);
    }
    if (dueDate.isBefore(statementDate)) {
      dueDate =
          _getValidDate(statementDate.year, statementDate.month + 1, dueDay);
    }
    return dueDate;
  }

  static bool isRepaymentCategory(String category) {
    return category.toLowerCase().contains('repayment');
  }

  static bool isPaymentForStatement(
      CreditTransactionModel txn, DateTime statementDate, int dueDay) {
    if (txn.type != 'Income') return false;
    if (!isRepaymentCategory(txn.category)) return false;

    final dueDate = getDueDateForStatement(statementDate, dueDay);
    final txnDate = txn.date;

    return txnDate.isAfter(statementDate) &&
        (txnDate.isBefore(dueDate) || isSameDay(txnDate, dueDate));
  }

  static bool isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  static DateTime _getValidDate(int year, int month, int day) {
    final firstDayNextMonth = DateTime(year, month + 1, 1);
    final lastDayThisMonth =
        firstDayNextMonth.subtract(const Duration(days: 1));
    final validDay = day > lastDayThisMonth.day ? lastDayThisMonth.day : day;
    return DateTime(year, month, validDay, 23, 59, 59);
  }
}
