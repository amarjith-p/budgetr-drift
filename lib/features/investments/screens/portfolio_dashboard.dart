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

enum SortOption {
  valueHighToLow,
  valueLowToHigh,
  returnHighToLow,
  nameAsc,
  dateNewest,
  dateOldest,
}

class PortfolioDashboard extends StatefulWidget {
  const PortfolioDashboard({super.key});

  @override
  State<PortfolioDashboard> createState() => _PortfolioDashboardState();
}

class _PortfolioDashboardState extends State<PortfolioDashboard> {
  // Filter State
  InvestmentType? _filterType;
  String? _filterSpecialId;

  // Sort State
  SortOption _sortOption = SortOption.dateNewest;

  // [NEW] Search State
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = "";

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

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

            // [NEW] Search Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.white.withOpacity(0.05)),
                ),
                child: TextField(
                  controller: _searchController,
                  style: const TextStyle(color: Colors.white),
                  onChanged: (val) => setState(() => _searchQuery = val),
                  decoration: InputDecoration(
                    hintText: "Search by Name, Provider...",
                    hintStyle: TextStyle(color: Colors.white.withOpacity(0.3)),
                    prefixIcon: const Icon(Icons.search, color: Colors.white38),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? GestureDetector(
                            onTap: () {
                              _searchController.clear();
                              setState(() => _searchQuery = "");
                            },
                            child: const Icon(Icons.close,
                                color: Colors.white38, size: 18),
                          )
                        : null,
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 14),
                  ),
                ),
              ),
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

                  final allInvestments = snapshot.data ?? [];

                  // 1. Apply Filters & Search
                  var investments = allInvestments.where((inv) {
                    // Filter Logic
                    bool matchType =
                        _filterType == null || inv.type == _filterType;
                    bool matchId = _filterSpecialId == null ||
                        _filterSpecialId!.isEmpty ||
                        (inv.specialId != null &&
                            inv.specialId!
                                .toLowerCase()
                                .contains(_filterSpecialId!.toLowerCase()));

                    // [NEW] Search Logic
                    bool matchSearch = _searchQuery.isEmpty ||
                        inv.name
                            .toLowerCase()
                            .contains(_searchQuery.toLowerCase()) ||
                        inv.providerName
                            .toLowerCase()
                            .contains(_searchQuery.toLowerCase()) ||
                        (inv.specialId != null &&
                            inv.specialId!
                                .toLowerCase()
                                .contains(_searchQuery.toLowerCase()));

                    return matchType && matchId && matchSearch;
                  }).toList();

                  // 2. Sorting Logic
                  investments.sort((a, b) {
                    switch (_sortOption) {
                      case SortOption.valueHighToLow:
                        return b.currentMarketValue
                            .compareTo(a.currentMarketValue);
                      case SortOption.valueLowToHigh:
                        return a.currentMarketValue
                            .compareTo(b.currentMarketValue);
                      case SortOption.returnHighToLow:
                        return b.returnPercentage.compareTo(a.returnPercentage);
                      case SortOption.nameAsc:
                        return a.name.compareTo(b.name);
                      case SortOption.dateNewest:
                        return b.startDate.compareTo(a.startDate);
                      case SortOption.dateOldest:
                        return a.startDate.compareTo(b.startDate);
                    }
                  });

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

                      // 2. List Header with Sort Button
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Padding(
                            padding: EdgeInsets.only(left: 4),
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
                          GestureDetector(
                            onTap: _showSortSheet,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.05),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                children: [
                                  Icon(Icons.sort_rounded,
                                      color: Colors.white70, size: 16),
                                  const SizedBox(width: 4),
                                  Text(
                                    _getSortLabel(_sortOption),
                                    style: const TextStyle(
                                        color: Colors.white70,
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

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
          Icon(
              _searchQuery.isNotEmpty
                  ? Icons.search_off_rounded
                  : Icons.filter_list_off,
              size: 60,
              color: Colors.white.withOpacity(0.1)),
          const SizedBox(height: 16),
          Text(
            _searchQuery.isNotEmpty
                ? "No results found"
                : "No investments found",
            style: TextStyle(color: Colors.white.withOpacity(0.5)),
          ),
          const SizedBox(height: 8),
          Text(
            _searchQuery.isNotEmpty
                ? "Try adjusting your search"
                : "Try clearing filters or adding new assets",
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

  void _showSortSheet() {
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
              const Padding(
                padding: EdgeInsets.all(16),
                child: Text("SORT BY",
                    style: TextStyle(
                        color: Colors.white38,
                        fontSize: 12,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.5)),
              ),
              ...SortOption.values.map((option) => ListTile(
                    leading: Icon(
                      _sortOption == option
                          ? Icons.radio_button_checked
                          : Icons.radio_button_unchecked,
                      color: _sortOption == option
                          ? BudgetrColors.accent
                          : Colors.white24,
                    ),
                    title: Text(_getSortLabel(option),
                        style: const TextStyle(color: Colors.white)),
                    onTap: () {
                      setState(() => _sortOption = option);
                      Navigator.pop(ctx);
                    },
                  )),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  String _getSortLabel(SortOption option) {
    switch (option) {
      case SortOption.valueHighToLow:
        return "Highest Value";
      case SortOption.valueLowToHigh:
        return "Lowest Value";
      case SortOption.returnHighToLow:
        return "Highest Return %";
      case SortOption.nameAsc:
        return "Name (A-Z)";
      case SortOption.dateNewest:
        return "Date Added (Newest)";
      case SortOption.dateOldest:
        return "Date Added (Oldest)";
    }
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
          const Text("Investment Type",
              style: TextStyle(color: Colors.white70, fontSize: 14)),
          const SizedBox(height: 8),
          GestureDetector(
            onTap: _showTypePicker,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: Colors.black12,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white10),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      _selectedType == null
                          ? "All Types"
                          : _formatType(_selectedType!),
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                  const Icon(Icons.arrow_drop_down, color: Colors.white54),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
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

  void _showTypePicker() {
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
              const Padding(
                padding: EdgeInsets.all(16),
                child: Text("Select Type",
                    style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16)),
              ),
              Flexible(
                child: ListView(
                  shrinkWrap: true,
                  children: [
                    ListTile(
                      leading: Icon(Icons.circle,
                          size: 10,
                          color: _selectedType == null
                              ? BudgetrColors.accent
                              : Colors.white24),
                      title: const Text("All Types",
                          style: TextStyle(color: Colors.white)),
                      onTap: () {
                        setState(() => _selectedType = null);
                        Navigator.pop(ctx);
                      },
                    ),
                    ...InvestmentType.values.map((type) {
                      return ListTile(
                        leading: Icon(Icons.circle,
                            size: 10,
                            color: _selectedType == type
                                ? BudgetrColors.accent
                                : Colors.white24),
                        title: Text(_formatType(type),
                            style: const TextStyle(color: Colors.white)),
                        onTap: () {
                          setState(() => _selectedType = type);
                          Navigator.pop(ctx);
                        },
                      );
                    }).toList(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // [UPDATED] Proper formatting for Filter Sheet with word spacing
  String _formatType(InvestmentType type) {
    switch (type) {
      case InvestmentType.mutualFund:
        return "Mutual Fund";
      case InvestmentType.stocks:
        return "Stocks";
      case InvestmentType.bonds:
        return "Bonds";
      case InvestmentType.fixedDeposit:
        return "Fixed Deposit";
      case InvestmentType.recurringDeposit:
        return "Recurring Deposit";
      case InvestmentType.p2pLending:
        return "P2P Lending";
      case InvestmentType.savingsAccount:
        return "Savings Account";
      case InvestmentType.others:
        return "Others";
    }
  }
}
