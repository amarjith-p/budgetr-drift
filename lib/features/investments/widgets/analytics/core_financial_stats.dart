import 'package:budget/core/design/budgetr_colors.dart';
import 'package:budget/features/investments/models/investment_dto.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // [NEW] Import intl for formatting

class CoreFinancialStats extends StatelessWidget {
  final InvestmentDto investment;

  const CoreFinancialStats({super.key, required this.investment});

  // [NEW] Helper method to format currency to Indian format (e.g., ₹ 1,00,000.00)
  String _formatAmount(double amount, {bool showPlusSign = false}) {
    final format =
        NumberFormat.currency(locale: 'en_IN', symbol: '₹ ', decimalDigits: 2);
    final formattedStr = format.format(amount.abs());

    if (amount < 0) {
      return "-$formattedStr";
    } else if (showPlusSign && amount > 0) {
      return "+$formattedStr";
    }
    return formattedStr;
  }

  @override
  Widget build(BuildContext context) {
    final isPositive = investment.totalGainLoss >= 0;
    final color = isPositive ? BudgetrColors.success : BudgetrColors.error;

    return Column(
      children: [
        // [UPDATED] Current Market Value
        Text(
          _formatAmount(investment.currentMarketValue),
          style: const TextStyle(
            color: Colors.white,
            fontSize: 36,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            // [UPDATED] Gain/Loss with percentage
            "${_formatAmount(investment.totalGainLoss, showPlusSign: true)} (${investment.returnPercentage.toStringAsFixed(2)}%)",
            style: TextStyle(
                color: color, fontWeight: FontWeight.bold, fontSize: 13),
          ),
        ),
        const SizedBox(height: 24),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // [UPDATED] Total Invested Amount
            _statItem(
                "INVESTED", _formatAmount(investment.totalInvestedAmount)),
            Container(
                width: 1,
                height: 24,
                color: Colors.white10,
                margin: const EdgeInsets.symmetric(horizontal: 24)),
            _statItem("START DATE",
                "${investment.startDate.day}/${investment.startDate.month}/${investment.startDate.year}"),
            Container(
                width: 1,
                height: 24,
                color: Colors.white10,
                margin: const EdgeInsets.symmetric(horizontal: 24)),
            _statItem(
              "XIRR",
              investment.xirr != null
                  ? "${investment.xirr!.toStringAsFixed(2)}%"
                  : "N/A",
            ),
          ],
        )
      ],
    );
  }

  Widget _statItem(String label, String value) {
    return Column(
      children: [
        Text(label,
            style: const TextStyle(
                color: Colors.white38,
                fontSize: 10,
                fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        Text(value,
            style: const TextStyle(
                color: Colors.white70,
                fontSize: 14,
                fontWeight: FontWeight.w600)),
      ],
    );
  }
}
