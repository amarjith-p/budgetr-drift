// lib/features/dashboard/widgets/custom_budget_summary_card.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class CustomBudgetSummaryCard extends StatelessWidget {
  final double totalBudget;
  final double totalSpent;
  final NumberFormat currencyFormat;

  const CustomBudgetSummaryCard({
    super.key,
    required this.totalBudget,
    required this.totalSpent,
    required this.currencyFormat,
  });

  @override
  Widget build(BuildContext context) {
    // Theme colors identical to DashboardSummaryCard
    final Color cardColor = const Color(0xFF1B263B).withOpacity(0.6);
    final Color greenColor = const Color(0xFF00E676);
    final Color redColor = const Color(0xFFFF5252);

    final double remaining = totalBudget - totalSpent;
    final String formattedDate =
        DateFormat('dd MMM yyyy : HH:mm').format(DateTime.now());

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [cardColor, cardColor.withOpacity(0.8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
        boxShadow: const [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                "TOTAL BUDGET ALLOCATED",
                style: TextStyle(
                  color: Colors.white54,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.5,
                ),
              ),
              const SizedBox(width: 6),
              Icon(
                Icons.info_outline,
                color: Colors.white.withOpacity(0.2),
                size: 14,
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            "As on $formattedDate",
            style: TextStyle(
              color: Colors.white.withOpacity(0.3),
              fontSize: 10,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            currencyFormat.format(totalBudget),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 32,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: _summaryItem(
                  "Total Spent",
                  totalSpent,
                  redColor,
                  Icons.arrow_upward,
                ),
              ),
              Container(width: 1, height: 40, color: Colors.white10),
              Expanded(
                child: _summaryItem(
                  "Remaining",
                  remaining,
                  greenColor,
                  Icons.arrow_downward,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _summaryItem(String label, double amount, Color color, IconData icon) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 14),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                color: color.withOpacity(0.8),
                fontSize: 11,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          currencyFormat.format(amount),
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 15,
          ),
        ),
      ],
    );
  }
}
