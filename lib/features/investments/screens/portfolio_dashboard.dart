import 'package:budget/core/design/budgetr_colors.dart';
import 'package:budget/core/widgets/futuristic_loader.dart';
import 'package:budget/core/widgets/modern_app_bar.dart';
import 'package:budget/features/investments/models/investment_dto.dart';
import 'package:budget/features/investments/screens/add_investment_screen.dart';
import 'package:budget/features/investments/screens/investment_detail_screen.dart';
import 'package:budget/features/investments/services/portfolio_service.dart';
import 'package:budget/features/investments/widgets/portfolio_item_card.dart';
import 'package:budget/features/investments/widgets/portfolio_summary_card.dart';
import 'package:budget/features/investments/widgets/portfolio_glass_folder.dart';

import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

enum SortOption {
  valueHighToLow,
  valueLowToHigh,
  returnHighToLow,
  nameAsc,
  dateNewest,
  dateOldest
}

enum GroupOption { none, type, specialId }

class PortfolioDashboard extends StatefulWidget {
  const PortfolioDashboard({super.key});

  @override
  State<PortfolioDashboard> createState() => _PortfolioDashboardState();
}

class _PortfolioDashboardState extends State<PortfolioDashboard> {
  InvestmentType? _filterType;
  String? _filterSpecialId;

  SortOption _sortOption = SortOption.dateNewest;
  GroupOption _groupOption = GroupOption.none;

  // Viewport State
  bool _showActiveAssets = true;

  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = "";

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
                  setState(() {
                    _filterType = null;
                    _filterSpecialId = null;
                  });
                } else {
                  _showFilterSheet();
                }
              },
            ),

            // =================================================================
            // FULL WIDTH SEARCH BAR (Space Reclaimed)
            // =================================================================
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

            if (isFiltered)
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 4, 20, 0),
                child: Row(
                  children: [
                    const Text("Filtered by: ",
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
                        child: FuturisticLoader(
                            label: "COMPILING WEALTH LEDGER..."));
                  }

                  if (snapshot.hasError) {
                    return Center(
                        child: Text("Error: ${snapshot.error}",
                            style: const TextStyle(color: Colors.red)));
                  }

                  final allInvestments = snapshot.data ?? [];

                  var investments = allInvestments.where((inv) {
                    bool matchStatus = _showActiveAssets
                        ? inv.status == 'active'
                        : inv.status == 'closed';

                    bool matchType =
                        _filterType == null || inv.type == _filterType;
                    bool matchId = _filterSpecialId == null ||
                        _filterSpecialId!.isEmpty ||
                        (inv.specialId != null &&
                            inv.specialId!
                                .toLowerCase()
                                .contains(_filterSpecialId!.toLowerCase()));
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

                    return matchStatus && matchType && matchId && matchSearch;
                  }).toList();

                  investments.sort((a, b) {
                    switch (_sortOption) {
                      case SortOption.valueHighToLow:
                        int valComp = b.currentMarketValue.compareTo(a.currentMarketValue);
                        // Tie-breaker: If values are equal, show newest added first
                        if (valComp == 0) return (b.id ?? 0).compareTo(a.id ?? 0);
                        return valComp;
                        
                      case SortOption.valueLowToHigh:
                        int valComp = a.currentMarketValue.compareTo(b.currentMarketValue);
                        if (valComp == 0) return (a.id ?? 0).compareTo(b.id ?? 0);
                        return valComp;
                        
                      case SortOption.returnHighToLow:
                        int retComp = b.returnPercentage.compareTo(a.returnPercentage);
                        if (retComp == 0) return (b.id ?? 0).compareTo(a.id ?? 0);
                        return retComp;
                        
                      case SortOption.nameAsc:
                        // Ignore case when sorting by name
                        int nameComp = a.name.toLowerCase().compareTo(b.name.toLowerCase());
                        if (nameComp == 0) return (b.id ?? 0).compareTo(a.id ?? 0);
                        return nameComp;
                        
                      case SortOption.dateNewest:
                        int dateComp = b.startDate.compareTo(a.startDate);
                        // Tie-breaker: If dates are the same, sort by highest ID (newest saved)
                        if (dateComp == 0) return (b.id ?? 0).compareTo(a.id ?? 0);
                        return dateComp;
                        
                      case SortOption.dateOldest:
                        int dateComp = a.startDate.compareTo(b.startDate);
                        // Tie-breaker: If dates are the same, sort by lowest ID (oldest saved)
                        if (dateComp == 0) return (a.id ?? 0).compareTo(b.id ?? 0);
                        return dateComp;
                    }
                  });

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

                  return AnimatedSwitcher(
                    duration: const Duration(milliseconds: 400),
                    switchInCurve: Curves.easeOutCubic,
                    switchOutCurve: Curves.easeInCubic,
                    child: ListView(
                      key: ValueKey<bool>(_showActiveAssets),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 10),
                      children: [
                        PortfolioSummaryCard(
                          totalInvested: globalInvested,
                          currentValue: globalCurrent,
                          totalGainLoss: globalGain,
                          returnPercentage: globalReturnPct,
                          investments: investments,
                        ),

                        const SizedBox(height: 8),

                        // =====================================================
                        // [MODERNIZED] ZERO-SPACE ACTION BAR (3 Buttons)
                        // =====================================================
                        Row(
                          children: [
                            Expanded(
                              child: _buildCommandButton(
                                icon: _showActiveAssets
                                    ? Icons.layers_rounded
                                    : Icons.inventory_2_rounded,
                                label: _showActiveAssets ? "Active" : "Closed",
                                onTap: _showViewSheet,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: _buildCommandButton(
                                icon: Icons.grid_view_rounded,
                                label: _getGroupLabel(_groupOption),
                                onTap: _showGroupSheet,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: _buildCommandButton(
                                icon: Icons.sort_rounded,
                                label: _getSortLabel(_sortOption),
                                onTap: _showSortSheet,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 12),

                        if (investments.isEmpty)
                          _buildEmptyState()
                        else
                          _buildAssetList(investments),

                        const SizedBox(height: 80),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        transitionBuilder: (child, animation) =>
            ScaleTransition(scale: animation, child: child),
        child: _showActiveAssets
            ? FloatingActionButton.extended(
                key: const ValueKey('add_fab'),
                backgroundColor: BudgetrColors.accent,
                icon: const Icon(Icons.add, color: Colors.white),
                label: const Text("Add Asset",
                    style: TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold)),
                onPressed: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const AddInvestmentScreen()));
                },
              )
            : const SizedBox.shrink(key: ValueKey('empty_fab')),
      ),
    );
  }

  Widget _buildCommandButton(
      {required IconData icon,
      required String label,
      required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white.withOpacity(0.05)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white70, size: 14),
            const SizedBox(width: 4),
            Flexible(
              child: Text(
                label,
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.bold),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 2),
            const Icon(Icons.arrow_drop_down, color: Colors.white38, size: 14),
          ],
        ),
      ),
    );
  }

  Widget _buildAssetList(List<InvestmentDto> investments) {
    if (_groupOption == GroupOption.none) {
      return Column(
        children: investments
            .map((inv) => PortfolioItemCard(
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
                ))
            .toList(),
      );
    }

    Map<String, List<InvestmentDto>> grouped = {};

    for (var inv in investments) {
      String key = "Uncategorized";
      if (_groupOption == GroupOption.type) {
        key = inv.displayType;
      } else if (_groupOption == GroupOption.specialId) {
        if (inv.specialId != null && inv.specialId!.isNotEmpty) {
          key = inv.specialId!;
        }
      }
      grouped.putIfAbsent(key, () => []).add(inv);
    }

    final sortedKeys = grouped.keys.toList()..sort();

    return Column(
      children: sortedKeys.map((key) {
        return PortfolioGlassFolder(
          groupName: key,
          investments: grouped[key]!,
        );
      }).toList(),
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
              style: TextStyle(color: Colors.white.withOpacity(0.5))),
        ],
      ),
    );
  }

  // ===========================================================================
  // [NEW] VIEWPORT SELECTOR SHEET
  // ===========================================================================
  void _showViewSheet() {
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
                child: Text("VIEWPORT",
                    style: TextStyle(
                        color: Colors.white38,
                        fontSize: 12,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.5)),
              ),
              ListTile(
                leading: Icon(
                  _showActiveAssets
                      ? Icons.radio_button_checked
                      : Icons.radio_button_unchecked,
                  color:
                      _showActiveAssets ? BudgetrColors.accent : Colors.white24,
                ),
                title: const Text("Active Assets",
                    style: TextStyle(color: Colors.white)),
                subtitle: const Text("Currently tracked investments",
                    style: TextStyle(color: Colors.white54, fontSize: 11)),
                onTap: () {
                  setState(() => _showActiveAssets = true);
                  Navigator.pop(ctx);
                },
              ),
              ListTile(
                leading: Icon(
                  !_showActiveAssets
                      ? Icons.radio_button_checked
                      : Icons.radio_button_unchecked,
                  color: !_showActiveAssets
                      ? BudgetrColors.accent
                      : Colors.white24,
                ),
                title: const Text("Closed History",
                    style: TextStyle(color: Colors.white)),
                subtitle: const Text("Realized and completed assets",
                    style: TextStyle(color: Colors.white54, fontSize: 11)),
                onTap: () {
                  setState(() => _showActiveAssets = false);
                  Navigator.pop(ctx);
                },
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
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
                    // Uses full text in the sheet, short text in the button!
                    title: Text(_getSortLabel(option, full: true),
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

  void _showGroupSheet() {
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
                child: Text("GROUP ASSETS BY",
                    style: TextStyle(
                        color: Colors.white38,
                        fontSize: 12,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.5)),
              ),
              ...GroupOption.values.map((option) => ListTile(
                    leading: Icon(
                      _groupOption == option
                          ? Icons.radio_button_checked
                          : Icons.radio_button_unchecked,
                      color: _groupOption == option
                          ? BudgetrColors.accent
                          : Colors.white24,
                    ),
                    title: Text(_getGroupLabel(option, full: true),
                        style: const TextStyle(color: Colors.white)),
                    onTap: () {
                      setState(() => _groupOption = option);
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

  // Adjusted for short tags in the button row
  String _getSortLabel(SortOption option, {bool full = false}) {
    switch (option) {
      case SortOption.valueHighToLow:
        return full ? "Highest Value" : "Highest";
      case SortOption.valueLowToHigh:
        return full ? "Lowest Value" : "Lowest";
      case SortOption.returnHighToLow:
        return full ? "Highest Return %" : "High %";
      case SortOption.nameAsc:
        return full ? "Name (A-Z)" : "A-Z";
      case SortOption.dateNewest:
        return "Newest";
      case SortOption.dateOldest:
        return "Oldest";
    }
  }

  String _getGroupLabel(GroupOption option, {bool full = false}) {
    switch (option) {
      case GroupOption.none:
        return full ? "None (Flat List)" : "No Group";
      case GroupOption.type:
        return full ? "Asset Type" : "Type";
      case GroupOption.specialId:
        return full ? "Special ID" : "ID";
    }
  }

  // ===========================================================================
  // [FIXED] Proper String formatting with Switch Statement
  // ===========================================================================
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
                  border: Border.all(color: Colors.white10)),
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
