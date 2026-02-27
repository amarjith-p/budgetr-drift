import 'package:budget/core/design/budgetr_colors.dart';
import 'package:budget/core/widgets/futuristic_loader.dart';
import 'package:budget/core/widgets/glass_card.dart';
import 'package:budget/core/widgets/modern_app_bar.dart';
import 'package:budget/core/widgets/status_bottom_sheet.dart';
import 'package:budget/features/investments/models/investment_dto.dart';
import 'package:budget/features/investments/models/investment_log_dto.dart';
import 'package:budget/features/investments/screens/add_investment_screen.dart';
import 'package:budget/features/investments/services/portfolio_service.dart';
import 'package:budget/features/investments/widgets/investment_growth_chart.dart';
import 'package:budget/features/investments/widgets/investment_history_list.dart';
import 'package:budget/features/investments/widgets/log_transaction_sheet.dart';
import 'package:budget/features/investments/widgets/income/passive_income_card.dart';
import 'package:budget/features/investments/widgets/income/passive_income_history_sheet.dart';

import 'package:budget/features/investments/utils/investment_analytics_engine.dart';
import 'package:budget/features/investments/widgets/analytics/core_financial_stats.dart';
import 'package:budget/features/investments/widgets/analytics/smart_insight_box.dart';
import 'package:budget/features/investments/widgets/analytics/target_progress_bar.dart';

import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:intl/intl.dart';

class InvestmentDetailScreen extends StatelessWidget {
  final int investmentId;
  final String investmentName;

  const InvestmentDetailScreen({
    super.key,
    required this.investmentId,
    required this.investmentName,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: BudgetrColors.background,
      body: SafeArea(
        child: Column(
          children: [
            ModernAppBar(
              title: investmentName,
              subtitle: "ASSET DETAILS",
              trailingIcon: Icons.more_vert_rounded,
              onTrailingPressed: () => _showOptions(context),
            ),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    // 1. Smart Header & Feature Cards
                    StreamBuilder<List<InvestmentDto>>(
                      stream: GetIt.I<PortfolioService>().watchAllInvestments(),
                      builder: (context, snapshot) {
                        if (!snapshot.hasData) return const SizedBox.shrink();
                        final matches = snapshot.data!
                            .where((i) => i.id == investmentId)
                            .toList();
                        if (matches.isEmpty) return const SizedBox.shrink();

                        final investment = matches.first;

                        return Column(
                          children: [
                            // Main Stats & Chart
                            InvestmentHeaderCard(investment: investment),

                            const SizedBox(height: 16),

                            // Passive Income Card
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 16),
                              child: PassiveIncomeCard(
                                investmentId: investmentId,
                                totalInvested: investment.totalInvestedAmount,
                                onTap: () => _showPassiveIncomeHistory(context),
                              ),
                            ),
                          ],
                        );
                      },
                    ),

                    const SizedBox(height: 24),

                    // 2. History Section Title
                    const Padding(
                      padding:
                          EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                      child: Row(
                        children: [
                          Icon(Icons.history_rounded,
                              color: Colors.white54, size: 16),
                          SizedBox(width: 8),
                          Text(
                            "TRANSACTION HISTORY",
                            style: TextStyle(
                              color: Colors.white38,
                              fontSize: 11,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 1.5,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // 3. History List
                    StreamBuilder<List<InvestmentLogDto>>(
                      stream: GetIt.I<PortfolioService>()
                          .watchInvestmentDetails(investmentId),
                      builder: (context, snapshot) {
                        if (!snapshot.hasData) {
                          return const Center(
                              child: FuturisticLoader(
                            size: 80,
                            label: "LOADING...",
                          ));
                        }
                        return InvestmentHistoryList(logs: snapshot.data!);
                      },
                    ),

                    const SizedBox(height: 100),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomSheet: _buildBottomActions(context),
    );
  }

  void _showPassiveIncomeHistory(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => PassiveIncomeHistorySheet(investmentId: investmentId),
    );
  }

  void _showOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        decoration: const BoxDecoration(
          color: Color(0xFF1B263B),
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                margin: const EdgeInsets.only(top: 8, bottom: 8),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                    color: Colors.white24,
                    borderRadius: BorderRadius.circular(2)),
              ),
              ListTile(
                leading: const Icon(Icons.edit_rounded, color: Colors.white),
                title: const Text("Edit Investment",
                    style: TextStyle(color: Colors.white)),
                onTap: () async {
                  Navigator.pop(ctx);
                  _handleEdit(context);
                },
              ),
              ListTile(
                leading:
                    const Icon(Icons.delete_rounded, color: Colors.redAccent),
                title: const Text("Delete Asset",
                    style: TextStyle(color: Colors.redAccent)),
                onTap: () async {
                  Navigator.pop(ctx);
                  _handleDelete(context);
                },
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _handleEdit(BuildContext context) async {
    final service = GetIt.I<PortfolioService>();
    final all = await service.watchAllInvestments().first;
    final item = all.firstWhere((e) => e.id == investmentId);

    if (context.mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(
            builder: (_) => AddInvestmentScreen(investmentToEdit: item)),
      );
    }
  }

  Future<void> _handleDelete(BuildContext context) async {
    showStatusSheet(
      context: context,
      title: "Delete Asset ?",
      message:
          "This will permanently delete this investment and all its transaction history.",
      icon: Icons.delete_sweep_sharp,
      color: Colors.redAccent,
      cancelButtonText: "Cancel",
      onCancel: () {},
      buttonText: "Delete",
      onDismiss: () async {
        await GetIt.I<PortfolioService>().deleteInvestment(investmentId);
        if (context.mounted) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Investment deleted")));
        }
      },
    );
  }

  Widget _buildBottomActions(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: Color(0xFF0D1B2A),
        border: Border(top: BorderSide(color: Colors.white10)),
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: _ActionButton(
                label: "LOG INVESTMENT",
                icon: Icons.add_circle_outline,
                color: BudgetrColors.accent,
                onTap: () => _showLogSheet(context, LogType.invested),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _ActionButton(
                label: "UPDATE VALUE",
                icon: Icons.trending_up,
                color: const Color(0xFFF72585),
                onTap: () => _showLogSheet(context, LogType.valueUpdate),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showLogSheet(BuildContext context, LogType type) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => LogTransactionSheet(
        investmentId: investmentId,
        initialType: type,
      ),
    );
  }
}

// --- HEADER WIDGET (UPDATED TO FETCH LOGS) ---

class InvestmentHeaderCard extends StatefulWidget {
  final InvestmentDto investment;

  const InvestmentHeaderCard({super.key, required this.investment});

  @override
  State<InvestmentHeaderCard> createState() => _InvestmentHeaderCardState();
}

class _InvestmentHeaderCardState extends State<InvestmentHeaderCard> {
  bool _showChart = false;

  @override
  Widget build(BuildContext context) {
    final investment = widget.investment;

    // [NEW] Wrap the entire card in a StreamBuilder so the Cockpit gets access to history logs
    return StreamBuilder<List<InvestmentLogDto>>(
      stream:
          GetIt.I<PortfolioService>().watchInvestmentDetails(investment.id!),
      builder: (context, snapshot) {
        final logs = snapshot.data ?? [];

        return GlassCard(
          borderRadius: 16,
          margin: const EdgeInsets.symmetric(horizontal: 16),
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _showChart ? "GROWTH TREND" : "CURRENT VALUE",
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.4),
                      fontSize: 10,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.5,
                    ),
                  ),
                  Row(
                    children: [
                      GestureDetector(
                        onTap: () => setState(() => _showChart = !_showChart),
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            _showChart
                                ? Icons.home_outlined
                                : Icons.show_chart_rounded,
                            color: Colors.white70,
                            size: 16,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      GestureDetector(
                        onTap: () => _showInfoSheet(context, investment),
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.info_outline_rounded,
                            color: Colors.white54,
                            size: 16,
                          ),
                        ),
                      ),
                    ],
                  )
                ],
              ),
              const SizedBox(height: 16),
              AnimatedCrossFade(
                // Pass logs down into the Cockpit and Chart
                firstChild: _buildCockpitView(investment, logs),
                secondChild: _buildChartView(logs),
                crossFadeState: _showChart
                    ? CrossFadeState.showSecond
                    : CrossFadeState.showFirst,
                duration: const Duration(milliseconds: 300),
              ),
            ],
          ),
        );
      },
    );
  }

  // --- NEW: COCKPIT VIEW COMPOSITION ---
  Widget _buildCockpitView(
      InvestmentDto investment, List<InvestmentLogDto> logs) {
    // 1. Generate Intelligence (Now using Transaction Logs)
    final insight = InvestmentAnalyticsEngine.analyze(investment, logs);

    return Column(
      children: [
        // Zone 1: Core Stats (Preserved Logic)
        CoreFinancialStats(investment: investment),

        // Zone 2 & 3 only show if Target is configured
        if (investment.targetAmount != null &&
            investment.targetAmount! > 0) ...[
          const SizedBox(height: 32),

          // Zone 2: Target Visualizer
          TargetProgressBar(
            current: investment.currentMarketValue,
            target: investment.targetAmount!,
            projected: insight.projectedValue,
          ),

          const SizedBox(height: 16),

          // Zone 3: Advisor Card
          SmartInsightBox(insight: insight),
        ]
      ],
    );
  }

  Widget _buildChartView(List<InvestmentLogDto> logs) {
    if (logs.isEmpty) {
      return const SizedBox(
          height: 150,
          child: Center(
              child: Text("No Data", style: TextStyle(color: Colors.white38))));
    }
    if (logs.length < 2) {
      return const SizedBox(
          height: 150,
          child: Center(
              child: Text("Need more data for chart",
                  style: TextStyle(color: Colors.white38))));
    }
    return InvestmentGrowthChart(logs: logs, embedded: true);
  }

  void _showInfoSheet(BuildContext context, InvestmentDto item) {
    // ... [UNCHANGED FROM PREVIOUS VERSION] ...
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => Container(
        height: MediaQuery.of(context).size.height * 0.75, // Slightly taller
        decoration: const BoxDecoration(
          color: Color(0xFF1B263B),
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                    color: Colors.white24,
                    borderRadius: BorderRadius.circular(2)),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              item.name.toUpperCase(),
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold),
            ),
            Text(
              "ASSET INFORMATION",
              style: TextStyle(
                  color: Colors.white.withOpacity(0.5),
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.5),
            ),
            const SizedBox(height: 24),
            Expanded(
              child: ListView(
                children: [
                  _buildInfoRow("Provider", item.providerName),
                  _buildInfoRow("Type", item.displayType),

                  // Display Target Amount and Special ID
                  if (item.targetAmount != null && item.targetAmount! > 0)
                    _buildInfoRow(
                        "Target Amount",
                        NumberFormat.currency(
                                symbol: '₹', decimalDigits: 2, locale: 'en_IN')
                            .format(item.targetAmount!)),
                  if (item.specialId != null && item.specialId!.isNotEmpty)
                    _buildInfoRow("Special ID", item.specialId!),

                  _buildInfoRow("Start Date",
                      DateFormat('dd MMM yyyy').format(item.startDate)),
                  if (item.endDate != null)
                    _buildInfoRow("End Date",
                        DateFormat('dd MMM yyyy').format(item.endDate!)),
                  if (item.expectedReturn != null)
                    _buildInfoRow(
                        "Exp. Return", "${item.expectedReturn.toString()}%"),
                  _buildInfoRow("Folio Number", item.folioNumber),
                  _buildInfoRow("Units / Quantity", item.units),
                  _buildInfoRow("Broker", item.brokerName),
                  _buildInfoRow("Linked Bank", item.linkedBankName),
                  _buildInfoRow("Linked Account", item.linkedBankAccount),
                  _buildInfoRow("Purpose", item.purpose),
                  const Divider(color: Colors.white10, height: 32),
                  if (item.notes != null && item.notes!.isNotEmpty) ...[
                    const Text("NOTES",
                        style: TextStyle(
                            color: Colors.white54,
                            fontSize: 12,
                            fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Text(item.notes!,
                        style: const TextStyle(
                            color: Colors.white70, height: 1.5)),
                  ]
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String? value) {
    if (value == null || value.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style:
                  TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 13),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _ActionButton(
      {required this.label,
      required this.icon,
      required this.color,
      required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: color.withOpacity(0.15),
        foregroundColor: color,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: color.withOpacity(0.3))),
        elevation: 0,
      ),
      onPressed: onTap,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 18),
          const SizedBox(width: 8),
          Text(label,
              style:
                  const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
