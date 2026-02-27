import 'package:budget/core/design/budgetr_colors.dart';
import 'package:budget/core/widgets/glass_card.dart';
import 'package:budget/features/investments/models/investment_dto.dart';
import 'package:budget/features/investments/screens/investment_detail_screen.dart';
import 'package:budget/features/investments/widgets/portfolio_item_card.dart';
import 'package:flutter/material.dart';

class PortfolioGlassFolder extends StatelessWidget {
  final String groupName;
  final List<InvestmentDto> investments;

  const PortfolioGlassFolder({
    super.key,
    required this.groupName,
    required this.investments,
  });

  @override
  Widget build(BuildContext context) {
    if (investments.isEmpty) return const SizedBox.shrink();

    // Calculate Sub-Totals for this specific folder
    double folderTotalValue = 0;
    double folderTotalInvested = 0;
    for (var inv in investments) {
      folderTotalValue += inv.currentMarketValue;
      folderTotalInvested += inv.totalInvestedAmount;
    }

    final gain = folderTotalValue - folderTotalInvested;
    final isPositive = gain >= 0;
    final gainColor = isPositive ? BudgetrColors.success : BudgetrColors.error;

    return Container(
      margin: const EdgeInsets.only(bottom: 1),
      child: GlassCard(
        borderRadius: 16,
        padding: EdgeInsets.zero, // Padding handled by ExpansionTile
        child: Theme(
          data: Theme.of(context).copyWith(
            dividerColor:
                Colors.transparent, // Removes the ugly default borders
            splashColor: Colors.transparent,
            highlightColor: Colors.white.withOpacity(0.05),
          ),
          child: ExpansionTile(
            initiallyExpanded: false, // Default to collapsed for clean view
            tilePadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            iconColor: Colors.white70,
            collapsedIconColor: Colors.white54,

            // --- FOLDER HEADER ---
            title: Row(
              children: [
                // Folder Icon
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: BudgetrColors.accent.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.folder_open_rounded,
                      color: BudgetrColors.accent, size: 20),
                ),
                const SizedBox(width: 16),

                // Group Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        groupName.toUpperCase(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                          letterSpacing: 1,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "${investments.length} Asset${investments.length > 1 ? 's' : ''}",
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.5),
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),

                // Sub-Total Value
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      "₹${folderTotalValue.toStringAsFixed(2)}",
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
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
                          "₹${gain.abs().toStringAsFixed(2)}",
                          style: TextStyle(
                            color: gainColor,
                            fontWeight: FontWeight.w600,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),

            // --- FOLDER BODY (The Assets) ---
            children: investments.map((inv) {
              return Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: PortfolioItemCard(
                  investment: inv,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => InvestmentDetailScreen(
                          investmentId: inv.id!,
                          investmentName: inv.name,
                        ),
                      ),
                    );
                  },
                ),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}
