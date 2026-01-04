import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class CreditStatusHeader extends StatelessWidget {
  final String label;
  final double amount;
  final Color color;
  final NumberFormat currency;

  const CreditStatusHeader({
    super.key,
    required this.label,
    required this.amount,
    required this.color,
    required this.currency,
  });

  @override
  Widget build(BuildContext context) {
    String displayString = label == "STATUS"
        ? "All Settled"
        : (amount > 0
            ? "+ ${currency.format(amount)}"
            : currency.format(amount));

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            label,
            style: TextStyle(
              color: Colors.white.withOpacity(0.6),
              fontSize: 12,
              fontWeight: FontWeight.bold,
              letterSpacing: 2.0,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            displayString,
            style: TextStyle(
              color: color,
              fontSize: 32,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.5,
            ),
          ),
        ],
      ),
    );
  }
}
