import 'package:budget/core/design/budgetr_colors.dart';
import 'package:budget/core/widgets/glass_card.dart';
import 'package:budget/features/investments/services/passive_income_service.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class PassiveIncomeCard extends StatelessWidget {
  final int investmentId;
  final double totalInvested; // Needed for Yield calculation
  final VoidCallback onTap;

  const PassiveIncomeCard({
    super.key,
    required this.investmentId,
    required this.totalInvested,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final service = PassiveIncomeService();
    final currency =
        NumberFormat.currency(symbol: '₹', decimalDigits: 0, locale: "en_IN");

    return StreamBuilder<PassiveIncomeMetrics>(
      stream: service.watchMetrics(investmentId, totalInvested),
      builder: (context, snapshot) {
        // If no income ever, show a collapsed "Add" hint or nothing?
        // Let's show the card but empty state if 0, to encourage adding it.
        final metrics = snapshot.data ??
            PassiveIncomeMetrics(
                totalEarned: 0, yieldPercentage: 0, transactionCount: 0);

        return GestureDetector(
          onTap: onTap,
          child: GlassCard(
            borderRadius: 16,
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Icon Box
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.amber.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.savings_rounded,
                      color: Colors.amber, size: 24),
                ),
                const SizedBox(width: 16),

                // Text Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "PASSIVE INCOME",
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.5),
                          fontSize: 10,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1.2,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            currency.format(metrics.totalEarned),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          if (metrics.totalEarned > 0) ...[
                            const SizedBox(width: 8),
                            Padding(
                              padding: const EdgeInsets.only(bottom: 2),
                              child: Text(
                                "(Yield: ${metrics.yieldPercentage.toStringAsFixed(1)}%)",
                                style: const TextStyle(
                                  color: BudgetrColors.success,
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ]
                        ],
                      ),
                    ],
                  ),
                ),

                // Arrow
                Icon(Icons.chevron_right_rounded,
                    color: Colors.white.withOpacity(0.3)),
              ],
            ),
          ),
        );
      },
    );
  }
}
