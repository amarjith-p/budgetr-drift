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
import 'package:budget/features/investments/widgets/compact_calculator_keyboard.dart';

import 'package:budget/features/investments/utils/investment_analytics_engine.dart';
import 'package:budget/features/investments/widgets/analytics/core_financial_stats.dart';
import 'package:budget/features/investments/widgets/analytics/smart_insight_box.dart';
import 'package:budget/features/investments/widgets/analytics/target_progress_bar.dart';

import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:intl/intl.dart';
import 'package:math_expressions/math_expressions.dart';

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
        child: StreamBuilder<List<InvestmentDto>>(
            stream: GetIt.I<PortfolioService>().watchAllInvestments(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) return const SizedBox.shrink();
              final matches =
                  snapshot.data!.where((i) => i.id == investmentId).toList();
              if (matches.isEmpty) return const SizedBox.shrink();

              final investment = matches.first;
              final isClosed = investment.status == 'closed';

              return Column(
                children: [
                  ModernAppBar(
                    title: investmentName,
                    subtitle: isClosed ? "CLOSED ASSET" : "ASSET DETAILS",
                    trailingIcon: Icons.more_vert_rounded,
                    onTrailingPressed: () => _showOptions(context, investment),
                  ),
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          InvestmentHeaderCard(investment: investment),
                          const SizedBox(height: 16),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: PassiveIncomeCard(
                              investmentId: investmentId,
                              totalInvested: investment.totalInvestedAmount,
                              // [UPDATED] Passing the isClosed flag here
                              onTap: () =>
                                  _showPassiveIncomeHistory(context, isClosed),
                            ),
                          ),
                          const SizedBox(height: 24),
                          const Padding(
                            padding: EdgeInsets.symmetric(
                                horizontal: 20, vertical: 8),
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
                          StreamBuilder<List<InvestmentLogDto>>(
                            stream: GetIt.I<PortfolioService>()
                                .watchInvestmentDetails(investmentId),
                            builder: (context, snapshot) {
                              if (!snapshot.hasData) {
                                return const Center(
                                    child: FuturisticLoader(
                                        size: 80,
                                        label: "ANALYZING ASSET TELEMETRY..."));
                              }
                              return InvestmentHistoryList(
                                  logs: snapshot.data!, isClosed: isClosed);
                            },
                          ),
                          const SizedBox(height: 100),
                        ],
                      ),
                    ),
                  ),
                  if (!isClosed) _buildBottomActions(context),
                ],
              );
            }),
      ),
    );
  }

  // ===========================================================================
  // [UPDATED] Now accepts the isClosed flag to pass to the sheet
  // ===========================================================================
  void _showPassiveIncomeHistory(BuildContext context, bool isClosed) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => PassiveIncomeHistorySheet(
        investmentId: investmentId,
        isClosed: isClosed, // [NEW] Pass the lock flag
      ),
    );
  }

  void _showOptions(BuildContext context, InvestmentDto investment) {
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
              if (investment.status != 'closed')
                ListTile(
                  leading: const Icon(Icons.edit_rounded, color: Colors.white),
                  title: const Text("Edit Asset",
                      style: TextStyle(color: Colors.white)),
                  onTap: () async {
                    Navigator.pop(ctx);
                    _handleEdit(context);
                  },
                ),
              if (investment.status != 'closed')
                ListTile(
                  leading: const Icon(Icons.check_circle_outline,
                      color: BudgetrColors.success),
                  title: const Text("Close Asset",
                      style: TextStyle(color: BudgetrColors.success)),
                  onTap: () async {
                    Navigator.pop(ctx);
                    _showCloseAssetSheet(context, investment);
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

  void _showCloseAssetSheet(BuildContext context, InvestmentDto investment) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => CloseInvestmentSheet(investment: investment),
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

class CloseInvestmentSheet extends StatefulWidget {
  final InvestmentDto investment;

  const CloseInvestmentSheet({super.key, required this.investment});

  @override
  State<CloseInvestmentSheet> createState() => _CloseInvestmentSheetState();
}

class _CloseInvestmentSheetState extends State<CloseInvestmentSheet> {
  final _amountController = TextEditingController();
  final _reasonController = TextEditingController();
  DateTime _selectedDate = DateTime.now();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _amountController.text = widget.investment.currentMarketValue.toString();
  }

  double? _evaluateFinalAmount() {
    try {
      String expression =
          _amountController.text.replaceAll('×', '*').replaceAll('÷', '/');
      if (expression.isEmpty) return null;
      Parser p = Parser();
      Expression exp = p.parse(expression);
      ContextModel cm = ContextModel();
      return exp.evaluate(EvaluationType.REAL, cm);
    } catch (e) {
      return null;
    }
  }

  Future<void> _processClosure() async {
    final amount = _evaluateFinalAmount();
    if (amount == null || amount < 0) return;

    setState(() => _isLoading = true);
    try {
      await GetIt.I<PortfolioService>().closeInvestment(
        widget.investment.id!,
        amount,
        _selectedDate,
        _reasonController.text.trim().isEmpty
            ? "Closed"
            : _reasonController.text.trim(),
      );
      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text("Error: $e")));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: true,
      bottom: false,
      child: Container(
        padding: EdgeInsets.only(
          top: 40,
          left: 20,
          right: 20,
          bottom: MediaQuery.of(context).viewInsets.bottom + 24,
        ),
        decoration: const BoxDecoration(
          color: Color(0xFF1B263B),
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.lock_outline,
                      color: BudgetrColors.success, size: 20),
                  const SizedBox(width: 8),
                  const Text("CLOSE INVESTMENT",
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1.5)),
                ],
              ),
              const SizedBox(height: 8),
              const Text(
                  "Record the final realized amount and mark this asset as completed.",
                  style: TextStyle(color: Colors.white54, fontSize: 12)),
              const SizedBox(height: 24),
              const Text("Final Realized Amount",
                  style: TextStyle(color: Colors.white70, fontSize: 14)),
              TextField(
                controller: _amountController,
                readOnly: true,
                style: const TextStyle(
                    color: BudgetrColors.success,
                    fontSize: 32,
                    fontWeight: FontWeight.bold),
                decoration: InputDecoration(
                  prefixText: "₹ ",
                  prefixStyle: TextStyle(
                      color: BudgetrColors.success.withOpacity(0.5),
                      fontSize: 32),
                  border: InputBorder.none,
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _reasonController,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: "Reason (e.g., Profit Booking, Stop Loss)",
                  hintStyle: TextStyle(color: Colors.white.withOpacity(0.3)),
                  filled: true,
                  fillColor: Colors.black12,
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none),
                ),
              ),
              const SizedBox(height: 16),
              CompactCalculatorKeyboard(controller: _amountController),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: BudgetrColors.success,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16)),
                  ),
                  onPressed: _isLoading ? null : _processClosure,
                  child: _isLoading
                      ? const FuturisticLoader(size: 20)
                      : const Text("FINALIZE & CLOSE ASSET",
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.5)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

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
    final isClosed = investment.status == 'closed';

    return StreamBuilder<List<InvestmentLogDto>>(
      stream:
          GetIt.I<PortfolioService>().watchInvestmentDetails(investment.id!),
      builder: (context, snapshot) {
        final logs = snapshot.data ?? [];

        return Opacity(
          opacity: isClosed ? 0.8 : 1.0,
          child: GlassCard(
            borderRadius: 16,
            margin: const EdgeInsets.symmetric(horizontal: 16),
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _showChart
                          ? "GROWTH TREND"
                          : (isClosed ? "REALIZED VALUE" : "CURRENT VALUE"),
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
                  firstChild: _buildCockpitView(investment, logs),
                  secondChild: _buildChartView(logs),
                  crossFadeState: _showChart
                      ? CrossFadeState.showSecond
                      : CrossFadeState.showFirst,
                  duration: const Duration(milliseconds: 300),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildCockpitView(
      InvestmentDto investment, List<InvestmentLogDto> logs) {
    final insight = InvestmentAnalyticsEngine.analyze(investment, logs);

    return Column(
      children: [
        CoreFinancialStats(investment: investment),
        if (investment.targetAmount != null &&
            investment.targetAmount! > 0 &&
            investment.status != 'closed') ...[
          const SizedBox(height: 32),
          TargetProgressBar(
            current: investment.currentMarketValue,
            target: investment.targetAmount!,
            projected: insight.projectedValue,
          ),
          const SizedBox(height: 16),
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
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => Container(
        height: MediaQuery.of(context).size.height * 0.75,
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
            Text(item.name.toUpperCase(),
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold)),
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
                  _buildInfoRow("Status", item.status.toUpperCase()),
                  if (item.status == 'closed')
                    _buildInfoRow("Closure Reason", item.closureReason),
                  if (item.status == 'closed' && item.closureDate != null)
                    _buildInfoRow("Closure Date",
                        DateFormat('dd MMM yyyy').format(item.closureDate!)),
                  _buildInfoRow("Provider", item.providerName),
                  _buildInfoRow("Type", item.displayType),
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
            child: Text(label,
                style: TextStyle(
                    color: Colors.white.withOpacity(0.4), fontSize: 13)),
          ),
          Expanded(
            child: Text(value,
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w600)),
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
