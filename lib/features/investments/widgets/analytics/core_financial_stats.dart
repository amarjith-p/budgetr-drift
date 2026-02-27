import 'package:budget/core/design/budgetr_colors.dart';
import 'package:budget/features/investments/models/investment_dto.dart';
import 'package:flutter/material.dart';

class CoreFinancialStats extends StatelessWidget {
  final InvestmentDto investment;

  const CoreFinancialStats({super.key, required this.investment});

  @override
  Widget build(BuildContext context) {
    final isPositive = investment.totalGainLoss >= 0;
    final color = isPositive ? BudgetrColors.success : BudgetrColors.error;

    return Column(
      children: [
        Text(
          "₹${investment.currentMarketValue.toStringAsFixed(2)}",
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
            "${isPositive ? '+' : ''}₹${investment.totalGainLoss.toStringAsFixed(2)} (${investment.returnPercentage.toStringAsFixed(2)}%)",
            style: TextStyle(
                color: color, fontWeight: FontWeight.bold, fontSize: 13),
          ),
        ),
        const SizedBox(height: 24),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _statItem("INVESTED",
                "₹${investment.totalInvestedAmount.toStringAsFixed(2)}"),
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
