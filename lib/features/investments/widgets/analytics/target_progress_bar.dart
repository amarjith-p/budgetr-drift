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

    final fmt = NumberFormat.compactCurrency(symbol: '₹', decimalDigits: 1);

    final currentPct = (current / target).clamp(0.0, 1.0);
    double projPct = 0.0;
    if (projected != null) {
      projPct = (projected! / target).clamp(0.0, 1.0);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Labels
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

        // Progress Bar Stack
        SizedBox(
          height: 8,
          child: Stack(
            children: [
              // 1. Background
              Container(
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              // 2. Projected (Dotted/Lighter)
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
              // 3. Current (Solid)
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

        // Footer Labels
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
