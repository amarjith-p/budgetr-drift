import 'package:intl/intl.dart';
import '../models/credit_models.dart';

class BillingCycleUtils {
  /// Returns true if the transaction is 'Unbilled' (appears after the last generated bill)
  static bool isUnbilled(CreditTransactionModel txn, int billDay) {
    final now = DateTime.now();
    final lastBillDate = getLastBillDate(now, billDay);

    // If transaction is AFTER the last bill date, it is Unbilled
    return txn.date.toDate().isAfter(lastBillDate);
  }

  /// Calculates the "Statement Date" a transaction belongs to.
  static DateTime getStatementDateForTxn(DateTime txnDate, int billDay) {
    final billDateThisMonth =
        _getValidDate(txnDate.year, txnDate.month, billDay);

    if (txnDate.isAfter(billDateThisMonth)) {
      // It falls into next month's statement
      final nextMonth = txnDate.month == 12 ? 1 : txnDate.month + 1;
      final nextYear = txnDate.month == 12 ? txnDate.year + 1 : txnDate.year;
      return _getValidDate(nextYear, nextMonth, billDay);
    } else {
      // It belongs to this month's statement
      return billDateThisMonth;
    }
  }

  /// NEW: Calculates the Statement Date immediately preceding the given one
  static DateTime getPreviousStatementDate(
      DateTime currentStmtDate, int billDay) {
    final prevMonth =
        currentStmtDate.month == 1 ? 12 : currentStmtDate.month - 1;
    final prevYear = currentStmtDate.month == 1
        ? currentStmtDate.year - 1
        : currentStmtDate.year;
    return _getValidDate(prevYear, prevMonth, billDay);
  }

  /// Finds the most recent Bill Date that has already passed relative to [today]
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

  /// Calculates the exact Due Date for a given Statement Date.
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

  /// NEW: Helper to safely check category
  static bool isRepaymentCategory(String category) {
    return category.toLowerCase().contains('repayment');
  }

  /// Checks if a transaction is a Bill Payment for the specific [statementDate].
  static bool isPaymentForStatement(
      CreditTransactionModel txn, DateTime statementDate, int dueDay) {
    if (txn.type != 'Income') return false;

    // Only "Repayment" counts as a Bill Payment.
    if (!isRepaymentCategory(txn.category)) {
      return false;
    }

    final dueDate = getDueDateForStatement(statementDate, dueDay);
    final txnDate = txn.date.toDate();

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
