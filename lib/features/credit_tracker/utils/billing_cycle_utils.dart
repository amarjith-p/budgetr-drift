import 'package:intl/intl.dart';
import '../models/credit_models.dart';

class BillingCycleUtils {
  /// Checks if the transaction date is within [thresholdDays] BEFORE the bill date.
  static bool isDangerZone(DateTime txnDate, int billDay,
      {int thresholdDays = 3}) {
    final billDateThisMonth =
        _getValidDate(txnDate.year, txnDate.month, billDay);
    if (txnDate.isAfter(billDateThisMonth)) return false; // Already next cycle
    final difference = billDateThisMonth.difference(txnDate).inDays;
    return difference >= 0 && difference <= thresholdDays;
  }

  /// Calculates the "Statement Date" taking [includeInNextStatement] into account.
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
      // Shift to next billing cycle
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

  // --- STANDARD HELPERS ---

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
