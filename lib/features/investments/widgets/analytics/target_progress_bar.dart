import 'package:budget/core/design/budgetr_colors.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class TargetProgressBar extends StatelessWidget {
  final double current;
  final double target;
  final double? projected;

  const TargetProgressBar({
    super.key,
    required this.current,
    required this.target,
    this.projected,
  });

  @override
  Widget build(BuildContext context) {
    if (target <= 0) return const SizedBox.shrink();

    // [UPDATED] Strict 2-decimal format
    final fmt =
        NumberFormat.currency(symbol: '₹', decimalDigits: 2, locale: "en_IN");

    final currentPct = (current / target).clamp(0.0, 1.0);
    double projPct = 0.0;
    if (projected != null) {
      projPct = (projected! / target).clamp(0.0, 1.0);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text("GOAL PROGRESS",
                style: TextStyle(
                    color: Colors.white.withOpacity(0.4),
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1)),
            Text("${(currentPct * 100).toStringAsFixed(1)}%",
                style: const TextStyle(
                    color: BudgetrColors.accent,
                    fontSize: 12,
                    fontWeight: FontWeight.bold)),
          ],
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 8,
          child: Stack(
            children: [
              Container(
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              if (projected != null && projPct > currentPct)
                FractionallySizedBox(
                  widthFactor: projPct,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.amber.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
              FractionallySizedBox(
                widthFactor: currentPct,
                child: Container(
                  decoration: BoxDecoration(
                    color: BudgetrColors.accent,
                    borderRadius: BorderRadius.circular(4),
                    boxShadow: [
                      BoxShadow(
                        color: BudgetrColors.accent.withOpacity(0.5),
                        blurRadius: 6,
                      )
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(fmt.format(current),
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.bold)),
            Text(fmt.format(target),
                style: const TextStyle(color: Colors.white70, fontSize: 11)),
          ],
        ),
      ],
    );
  }
}
