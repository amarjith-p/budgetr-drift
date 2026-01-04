import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/credit_models.dart';
import '../utils/billing_cycle_utils.dart';

class CreditSummaryCard extends StatelessWidget {
  final double currentUnbilled;
  final DateTime lastBillDate;
  final List<CreditTransactionModel> lastBillTxns;
  final List<CreditTransactionModel> payments;
  final CreditCardModel card;

  const CreditSummaryCard({
    super.key,
    required this.currentUnbilled,
    required this.lastBillDate,
    required this.lastBillTxns,
    required this.payments,
    required this.card,
  });

  double _calculateTotal(List<CreditTransactionModel> txns) {
    double total = 0;
    for (var t in txns) {
      if (t.type == 'Expense')
        total += t.amount;
      else
        total -= t.amount;
    }
    return total;
  }

  @override
  Widget build(BuildContext context) {
    final currency =
        NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: 2);

    // Calculate Due Date
    final actualDueDate =
        BillingCycleUtils.getDueDateForStatement(lastBillDate, card.dueDate);
    final daysRemaining = actualDueDate.difference(DateTime.now()).inDays;

    final billExpenses = lastBillTxns
        .where((t) =>
            t.type == 'Expense' ||
            (t.type == 'Income' &&
                !BillingCycleUtils.isRepaymentCategory(t.category)))
        .toList();

    final billPayments = lastBillTxns
        .where((t) =>
            t.type == 'Income' &&
            BillingCycleUtils.isRepaymentCategory(t.category))
        .toList()
      ..addAll(payments);

    double billAmount = _calculateTotal(billExpenses);
    double totalPaid = billPayments.fold(0.0, (sum, t) => sum + t.amount);

    double netBillPosition = billAmount - totalPaid;
    double remainingDue = 0;
    double surplus = 0;

    if (netBillPosition > 0) {
      remainingDue = netBillPosition;
    } else {
      surplus = netBillPosition.abs();
    }

    double adjustedUnbilled = currentUnbilled - surplus;
    bool isNetLiability = adjustedUnbilled > 0;

    bool isPaidOff = billAmount > 0 && remainingDue <= 0;
    bool isOverPaid = surplus > 0;

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [const Color(0xFF1B263B), const Color(0xff0D1B2A)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
        boxShadow: [
          BoxShadow(color: Colors.black26, blurRadius: 10, offset: Offset(0, 5))
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "NEW SPENDS",
                  style: TextStyle(
                      color: Colors.white54,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1),
                ),
                const SizedBox(height: 4),
                Text(
                  isNetLiability
                      ? "- ${currency.format(adjustedUnbilled)}"
                      : "+ ${currency.format(adjustedUnbilled.abs())}",
                  style: TextStyle(
                      color: isNetLiability
                          ? Colors.redAccent
                          : Colors.greenAccent,
                      fontSize: 24,
                      fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(
                  isOverPaid ? "Adjusted with Surplus" : "Current Cycle",
                  style: TextStyle(color: Colors.white38, fontSize: 11),
                ),
              ],
            ),
          ),
          Container(width: 1, height: 50, color: Colors.white10),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "LAST BILL",
                      style: TextStyle(
                          color: Colors.white54,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1),
                    ),
                    if (isPaidOff && !isOverPaid)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                            color: Colors.green.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(4)),
                        child: Text("PAID",
                            style: TextStyle(
                                color: Colors.greenAccent,
                                fontSize: 10,
                                fontWeight: FontWeight.bold)),
                      ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  isOverPaid
                      ? "+ ${currency.format(surplus)}"
                      : currency.format(remainingDue),
                  style: TextStyle(
                      color: isOverPaid
                          ? Colors.greenAccent
                          : (isPaidOff ? Colors.white60 : Colors.redAccent),
                      fontSize: 24,
                      fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(
                  isOverPaid
                      ? "Surplus (Paid: ${currency.format(totalPaid)})"
                      : (isPaidOff
                          ? "Settled fully"
                          : "Bill: ${currency.format(billAmount)}  •  Paid: ${currency.format(totalPaid)}"),
                  style: TextStyle(color: Colors.white38, fontSize: 11),
                ),
                if (!isOverPaid && !isPaidOff)
                  Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Text(
                      "Due: ${DateFormat('dd MMM').format(actualDueDate)}",
                      style: TextStyle(
                        color: daysRemaining < 3
                            ? Colors.redAccent
                            : Colors.orangeAccent,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
