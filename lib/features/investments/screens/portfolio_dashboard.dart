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

class PortfolioDashboard extends StatefulWidget {
  const PortfolioDashboard({super.key});

  @override
  State<PortfolioDashboard> createState() => _PortfolioDashboardState();
}

class _PortfolioDashboardState extends State<PortfolioDashboard> {
  // [NEW] Filter State
  InvestmentType? _filterType;
  String? _filterSpecialId;

  @override
  Widget build(BuildContext context) {
    // Check if any filter is active
    final isFiltered = _filterType != null ||
        (_filterSpecialId != null && _filterSpecialId!.isNotEmpty);

    return Scaffold(
      backgroundColor: BudgetrColors.background,
      body: SafeArea(
        child: Column(
          children: [
            ModernAppBar(
              title: "Portfolio Tracker",
              subtitle: "WEALTH OVERVIEW",
              // [NEW] Filter Action
              trailingIcon: isFiltered
                  ? Icons.filter_alt_off_rounded
                  : Icons.filter_alt_rounded,
              onTrailingPressed: () {
                if (isFiltered) {
                  // Clear filters
                  setState(() {
                    _filterType = null;
                    _filterSpecialId = null;
                  });
                } else {
                  _showFilterSheet();
                }
              },
            ),

            // Filter Status Indicator
            if (isFiltered)
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 10),
                child: Row(
                  children: [
                    Text("Filtered by: ",
                        style: TextStyle(color: Colors.white38, fontSize: 12)),
                    if (_filterType != null)
                      _buildFilterChip(_formatType(_filterType!)),
                    if (_filterSpecialId != null &&
                        _filterSpecialId!.isNotEmpty)
                      _buildFilterChip("ID: $_filterSpecialId"),
                  ],
                ),
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

                  // [NEW] Apply Filtering Logic
                  final allInvestments = snapshot.data ?? [];
                  final investments = allInvestments.where((inv) {
                    bool matchType =
                        _filterType == null || inv.type == _filterType;
                    bool matchId = _filterSpecialId == null ||
                        _filterSpecialId!.isEmpty ||
                        (inv.specialId != null &&
                            inv.specialId!
                                .toLowerCase()
                                .contains(_filterSpecialId!.toLowerCase()));
                    return matchType && matchId;
                  }).toList();

                  // Calculate Global Totals (Based on filtered view)
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
                      // 1. Global Summary
                      PortfolioSummaryCard(
                        totalInvested: globalInvested,
                        currentValue: globalCurrent,
                        totalGainLoss: globalGain,
                        returnPercentage: globalReturnPct,
                        investments: investments,
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

  Widget _buildFilterChip(String label) {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: BudgetrColors.accent.withOpacity(0.2),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: BudgetrColors.accent.withOpacity(0.3)),
      ),
      child: Text(label,
          style: const TextStyle(
              color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.all(40),
      alignment: Alignment.center,
      child: Column(
        children: [
          Icon(Icons.filter_list_off,
              size: 60, color: Colors.white.withOpacity(0.1)),
          const SizedBox(height: 16),
          Text(
            "No investments found",
            style: TextStyle(color: Colors.white.withOpacity(0.5)),
          ),
          const SizedBox(height: 8),
          Text(
            "Try clearing filters or adding new assets",
            style:
                TextStyle(color: Colors.white.withOpacity(0.3), fontSize: 12),
          ),
        ],
      ),
    );
  }

  void _showFilterSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => _FilterSheet(
        initialType: _filterType,
        initialId: _filterSpecialId,
        onApply: (type, id) {
          setState(() {
            _filterType = type;
            _filterSpecialId = id;
          });
        },
      ),
    );
  }

  String _formatType(InvestmentType type) {
    String label = type.toString().split('.').last;
    return label[0].toUpperCase() + label.substring(1);
  }
}

class _FilterSheet extends StatefulWidget {
  final InvestmentType? initialType;
  final String? initialId;
  final Function(InvestmentType?, String?) onApply;

  const _FilterSheet(
      {required this.initialType,
      required this.initialId,
      required this.onApply});

  @override
  State<_FilterSheet> createState() => _FilterSheetState();
}

class _FilterSheetState extends State<_FilterSheet> {
  InvestmentType? _selectedType;
  late TextEditingController _idController;

  @override
  void initState() {
    super.initState();
    _selectedType = widget.initialType;
    _idController = TextEditingController(text: widget.initialId ?? '');
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom + 20,
          top: 20,
          left: 20,
          right: 20),
      decoration: const BoxDecoration(
        color: Color(0xFF1B263B),
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("FILTER INVESTMENTS",
              style: TextStyle(
                  color: Colors.white38,
                  fontSize: 12,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.5)),
          const SizedBox(height: 20),

          // Type Selector
          const Text("Investment Type",
              style: TextStyle(color: Colors.white70, fontSize: 14)),
          const SizedBox(height: 8),
          DropdownButtonFormField<InvestmentType>(
            value: _selectedType,
            dropdownColor: const Color(0xFF0D1B2A),
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.black12,
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
            items: [
              const DropdownMenuItem(value: null, child: Text("All Types")),
              ...InvestmentType.values.map((type) => DropdownMenuItem(
                    value: type,
                    child: Text(type.toString().split('.').last.toUpperCase()),
                  ))
            ],
            onChanged: (val) => setState(() => _selectedType = val),
          ),

          const SizedBox(height: 20),

          // Special ID Input
          const Text("Special ID",
              style: TextStyle(color: Colors.white70, fontSize: 14)),
          const SizedBox(height: 8),
          TextField(
            controller: _idController,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              hintText: "Enter ID to match",
              hintStyle: TextStyle(color: Colors.white.withOpacity(0.3)),
              filled: true,
              fillColor: Colors.black12,
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none),
              prefixIcon: const Icon(Icons.tag, color: Colors.white38),
            ),
          ),

          const SizedBox(height: 30),

          // Apply Button
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: BudgetrColors.accent,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: () {
                widget.onApply(
                    _selectedType,
                    _idController.text.trim().isEmpty
                        ? null
                        : _idController.text.trim());
                Navigator.pop(context);
              },
              child: const Text("APPLY FILTERS",
                  style: TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }
}
