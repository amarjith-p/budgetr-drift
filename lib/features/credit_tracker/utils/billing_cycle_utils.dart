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
    // If Due Day is smaller than Bill Day (e.g. Bill 25th, Due 5th), it's next month.
    if (dueDay < statementDate.day) {
      dueDate =
          _getValidDate(statementDate.year, statementDate.month + 1, dueDay);
    } else {
      dueDate = _getValidDate(statementDate.year, statementDate.month, dueDay);
    }

    // Safety: Due date cannot be BEFORE Statement Date
    if (dueDate.isBefore(statementDate)) {
      dueDate =
          _getValidDate(statementDate.year, statementDate.month + 1, dueDay);
    }

    return dueDate;
  }

  /// Checks if a transaction is a Bill Payment for the specific [statementDate].
  ///
  /// STRICT LOGIC:
  /// 1. Must be 'Income'.
  /// 2. Category MUST contain "Repayment".
  /// 3. Date must be AFTER Statement Date but BEFORE (or on) Due Date.
  static bool isPaymentForStatement(
      CreditTransactionModel txn, DateTime statementDate, int dueDay) {
    if (txn.type != 'Income') return false;

    // --- STRICT FILTER ---
    // Only "Repayment" counts as a Bill Payment.
    // Refunds, Cashback, Reversals, etc. will return false here,
    // so they will stay in the "Unbilled" bucket and reduce current spend.
    if (!txn.category.toLowerCase().contains('repayment')) {
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

  /// Helper to safely get a date (e.g., asking for Feb 30 returns Feb 28/29)
  static DateTime _getValidDate(int year, int month, int day) {
    final firstDayNextMonth = DateTime(year, month + 1, 1);
    final lastDayThisMonth =
        firstDayNextMonth.subtract(const Duration(days: 1));

    final validDay = day > lastDayThisMonth.day ? lastDayThisMonth.day : day;
    // Set to end of day 23:59:59 to capture all transactions of that day
    return DateTime(year, month, validDay, 23, 59, 59);
  }
}
