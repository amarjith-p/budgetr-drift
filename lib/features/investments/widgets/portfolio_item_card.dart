import 'package:budget/core/design/budgetr_colors.dart';
import 'package:budget/core/widgets/glass_card.dart';
import 'package:budget/features/investments/models/investment_dto.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class PortfolioItemCard extends StatelessWidget {
  final InvestmentDto investment;
  final VoidCallback onTap;

  const PortfolioItemCard({
    super.key,
    required this.investment,
    required this.onTap,
  });

  String _formatAmount(double amount) {
    final format =
        NumberFormat.currency(locale: 'en_IN', symbol: '₹ ', decimalDigits: 2);
    return format.format(amount.abs());
  }

  @override
  Widget build(BuildContext context) {
    final isPositive = investment.totalGainLoss >= 0;
    final gainColor = isPositive ? BudgetrColors.success : BudgetrColors.error;

    final hasUrl = investment.providerWebsite != null &&
        investment.providerWebsite!.isNotEmpty;
    final logoUrl = hasUrl
        ? "https://www.google.com/s2/favicons?domain=${investment.providerWebsite}&sz=64"
        : "";

    // [NEW] Status check for Opacity dimming
    final isClosed = investment.status == 'closed';

    return GestureDetector(
      onTap: onTap,
      child: Opacity(
        opacity:
            isClosed ? 0.6 : 1.0, // Dim closed assets heavily to recede them
        child: GlassCard(
          borderRadius: 12,
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.white.withOpacity(0.05)),
                ),
                padding: const EdgeInsets.all(8),
                child: hasUrl
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          logoUrl,
                          fit: BoxFit.contain,
                          errorBuilder: (context, error, stackTrace) => Icon(
                              Icons.pie_chart_rounded,
                              color: Colors.white.withOpacity(0.5)),
                        ),
                      )
                    : Icon(Icons.trending_up,
                        color: Colors.white.withOpacity(0.5)),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      investment.name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            investment.displayType.toUpperCase(),
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        // =======================================================
                        // [NEW] CLOSED CHIP BADGE
                        // =======================================================
                        if (isClosed) ...[
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: BudgetrColors.success.withOpacity(0.2),
                              border: Border.all(
                                  color:
                                      BudgetrColors.success.withOpacity(0.5)),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Text(
                              "CLOSED",
                              style: TextStyle(
                                color: BudgetrColors.success,
                                fontSize: 9,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            investment.providerName,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.4),
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 4),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    _formatAmount(investment.currentMarketValue),
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        isPositive
                            ? Icons.arrow_drop_up
                            : Icons.arrow_drop_down,
                        color: gainColor,
                        size: 16,
                      ),
                      Text(
                        _formatAmount(investment.totalGainLoss),
                        style: TextStyle(
                          color: gainColor,
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
