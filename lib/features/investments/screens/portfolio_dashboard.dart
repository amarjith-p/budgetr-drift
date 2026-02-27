import 'package:budget/core/design/budgetr_colors.dart';
import 'package:budget/core/widgets/futuristic_loader.dart';
import 'package:budget/core/widgets/modern_app_bar.dart';
import 'package:budget/features/investments/models/investment_dto.dart';
import 'package:budget/features/investments/screens/add_investment_screen.dart';
import 'package:budget/features/investments/screens/investment_detail_screen.dart';
import 'package:budget/features/investments/services/portfolio_service.dart';
import 'package:budget/features/investments/widgets/portfolio_item_card.dart';
import 'package:budget/features/investments/widgets/portfolio_summary_card.dart';

// [NEW IMPORT]
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

// [NEW] Grouping Option
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
  GroupOption _groupOption = GroupOption.none; // [NEW STATE]

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

            // Search Bar
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
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 10),
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
                        child: FuturisticLoader(label: "LOADING ASSETS..."));
                  }

                  if (snapshot.hasError) {
                    return Center(
                        child: Text("Error: ${snapshot.error}",
                            style: const TextStyle(color: Colors.red)));
                  }

                  final allInvestments = snapshot.data ?? [];

                  // Apply Filters & Search
                  var investments = allInvestments.where((inv) {
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

                    return matchType && matchId && matchSearch;
                  }).toList();

                  // Sorting Logic
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
                      // 1. Optimized Summary Card
                      PortfolioSummaryCard(
                        totalInvested: globalInvested,
                        currentValue: globalCurrent,
                        totalGainLoss: globalGain,
                        returnPercentage: globalReturnPct,
                        investments: investments,
                      ),

                      const SizedBox(height: 8),

                      // [NEW] 2. The Command Bar (Group & Sort)
                      Row(
                        children: [
                          Expanded(
                            child: _buildCommandButton(
                              icon: Icons.grid_view_rounded,
                              label: "Group: ${_getGroupLabel(_groupOption)}",
                              onTap: _showGroupSheet,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildCommandButton(
                              icon: Icons.sort_rounded,
                              label: "Sort: ${_getSortLabel(_sortOption)}",
                              onTap: _showSortSheet,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 12),

                      // 3. Investment List or Folders
                      if (investments.isEmpty)
                        _buildEmptyState()
                      else
                        _buildAssetList(investments),

                      const SizedBox(height: 60),
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

  // --- NEW: Command Button UI ---
  Widget _buildCommandButton(
      {required IconData icon,
      required String label,
      required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white.withOpacity(0.05)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white70, size: 14),
            const SizedBox(width: 6),
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

  // --- NEW: List/Folder Rendering Logic ---
  Widget _buildAssetList(List<InvestmentDto> investments) {
    if (_groupOption == GroupOption.none) {
      // Flat List (Legacy Mode)
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

    // Grouping Mode
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

    // Sort the keys alphabetically for consistent UI
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
        return "Newest";
      case SortOption.dateOldest:
        return "Oldest";
    }
  }

  String _getGroupLabel(GroupOption option, {bool full = false}) {
    switch (option) {
      case GroupOption.none:
        return full ? "None (Flat List)" : "None";
      case GroupOption.type:
        return full ? "Asset Type (Mutual Fund, Stock, etc)" : "Type";
      case GroupOption.specialId:
        return full ? "Special ID (Custom Tags)" : "Special ID";
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
