import 'package:cloud_firestore/cloud_firestore.dart'; // Added for Timestamp
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../core/models/financial_record_model.dart';

class DashboardSummaryCard extends StatelessWidget {
  final FinancialRecord record;
  final NumberFormat currencyFormat;
  final VoidCallback onOptionsTap;

  const DashboardSummaryCard({
    super.key,
    required this.record,
    required this.currencyFormat,
    required this.onOptionsTap,
  });

  @override
  Widget build(BuildContext context) {
    // Theme colors
    final Color cardColor = const Color(0xFF1B263B).withOpacity(0.6);
    final Color greenColor = const Color(0xFF00E676);
    final Color redColor = const Color(0xFFFF5252);

    final totalIncome = record.salary + record.extraIncome;
    final totalDeductions = record.emi;
    final balance = record.effectiveIncome;

    // Use updatedAt to show the last modified time
    final String formattedDate = DateFormat(
      'dd MMM yyyy : HH:mm',
    ).format(record.updatedAt.toDate());

    return Stack(
      children: [
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [cardColor, cardColor.withOpacity(0.8)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(24),
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
              const Text(
                "NET EFFECTIVE INCOME",
                style: TextStyle(
                  color: Colors.white54,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.5,
                ),
              ),
              // --- NEW: As on Date Label ---
              const SizedBox(height: 4),
              Text(
                "As on $formattedDate",
                style: TextStyle(
                  color: Colors.white.withOpacity(0.3),
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                ),
              ),
              // -----------------------------
              const SizedBox(height: 8),
              Text(
                currencyFormat.format(balance),
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
                      "Gross Income",
                      totalIncome,
                      greenColor,
                      Icons.arrow_downward,
                    ),
                  ),
                  Container(width: 1, height: 40, color: Colors.white10),
                  Expanded(
                    child: _summaryItem(
                      "Deductions",
                      totalDeductions,
                      redColor,
                      Icons.arrow_upward,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        Positioned(
          top: 8,
          right: 8,
          child: IconButton(
            onPressed: onOptionsTap,
            icon: Icon(
              Icons.more_vert_rounded,
              color: Colors.white.withOpacity(0.4),
            ),
            tooltip: 'Record Options',
            splashRadius: 20,
          ),
        ),
      ],
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
