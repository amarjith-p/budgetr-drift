import 'package:budget/core/design/budgetr_colors.dart';
import 'package:budget/core/widgets/futuristic_loader.dart';
import 'package:budget/core/widgets/modern_app_bar.dart';
import 'package:budget/features/investments/models/investment_dto.dart';
import 'package:budget/features/investments/screens/add_investment_screen.dart';
import 'package:budget/features/investments/screens/investment_detail_screen.dart';
import 'package:budget/features/investments/services/portfolio_service.dart';
import 'package:budget/features/investments/widgets/portfolio_item_card.dart';
import 'package:budget/features/investments/widgets/portfolio_summary_card.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

class PortfolioDashboard extends StatelessWidget {
  const PortfolioDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: BudgetrColors.background,
      body: SafeArea(
        child: Column(
          children: [
            const ModernAppBar(
              title: "Portfolio Tracker",
              subtitle: "WEALTH OVERVIEW",
            ),
            Expanded(
              child: StreamBuilder<List<InvestmentDto>>(
                stream: GetIt.I<PortfolioService>().watchAllInvestments(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: FuturisticLoader(label: "LOADING ASSETS..."),
                    );
                  }

                  if (snapshot.hasError) {
                    return Center(
                        child: Text("Error: ${snapshot.error}",
                            style: const TextStyle(color: Colors.red)));
                  }

                  final investments = snapshot.data ?? [];

                  // Calculate Global Totals
                  double globalInvested = 0;
                  double globalCurrent = 0;
                  double globalGain = 0;

                  for (var inv in investments) {
                    globalInvested += inv.totalInvestedAmount;
                    globalCurrent += inv.currentMarketValue;
                    globalGain += inv.totalGainLoss;
                  }

                  double globalReturnPct = 0;
                  if (globalInvested > 0) {
                    globalReturnPct = (globalGain / globalInvested) * 100;
                  }

                  return ListView(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 10),
                    children: [
                      // 1. Global Summary (Now with Chart Toggle)
                      PortfolioSummaryCard(
                        totalInvested: globalInvested,
                        currentValue: globalCurrent,
                        totalGainLoss: globalGain,
                        returnPercentage: globalReturnPct,
                        investments: investments, // [NEW] Pass data for chart
                      ),

                      const SizedBox(height: 24),

                      // 2. List Header
                      const Padding(
                        padding: EdgeInsets.only(left: 4, bottom: 12),
                        child: Text(
                          "YOUR INVESTMENTS",
                          style: TextStyle(
                            color: Colors.white38,
                            fontSize: 11,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 1.5,
                          ),
                        ),
                      ),

                      // 3. Investment List
                      if (investments.isEmpty)
                        _buildEmptyState()
                      else
                        ...investments.map((inv) => PortfolioItemCard(
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
                            )),

                      const SizedBox(height: 80),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: BudgetrColors.accent,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text("Add Asset",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddInvestmentScreen()),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.all(40),
      alignment: Alignment.center,
      child: Column(
        children: [
          Icon(Icons.trending_up,
              size: 60, color: Colors.white.withOpacity(0.1)),
          const SizedBox(height: 16),
          Text(
            "No investments yet",
            style: TextStyle(color: Colors.white.withOpacity(0.5)),
          ),
          const SizedBox(height: 8),
          Text(
            "Tap '+ Add Asset' to start tracking",
            style:
                TextStyle(color: Colors.white.withOpacity(0.3), fontSize: 12),
          ),
        ],
      ),
    );
  }
}
