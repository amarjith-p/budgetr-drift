import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get_it/get_it.dart';
import 'package:intl/intl.dart';
import '../../../core/design/budgetr_colors.dart';
import '../../../core/models/transaction_category_model.dart';
import '../../../core/services/category_service.dart';
import '../../settings/services/settings_service.dart';
import '../models/filter_criteria.dart';
import '../models/expense_models.dart';

class SmartFilterSheet extends StatefulWidget {
  final FilterCriteria initialFilters;
  final List<ExpenseTransactionModel> allTransactions;
  final Function(FilterCriteria) onApply;

  const SmartFilterSheet({
    super.key,
    required this.initialFilters,
    required this.allTransactions,
    required this.onApply,
  });

  @override
  State<SmartFilterSheet> createState() => _SmartFilterSheetState();
}

class _SmartFilterSheetState extends State<SmartFilterSheet> {
  late FilterCriteria _filters;
  List<TransactionCategoryModel> _allCategories = [];
  List<String> _allBuckets = [];
  int _matchCount = 0;

  // Amount Config
  final double _minAmount = 0;
  final double _maxAmount = 100000;
  RangeValues _currentRange = const RangeValues(0, 100000);

  @override
  void initState() {
    super.initState();
    _filters = widget.initialFilters.copyWith();

    if (_filters.amountRange != null) {
      _currentRange = _filters.amountRange!;
    }

    _loadData();
    _calculateMatchCount();
  }

  void _calculateMatchCount() {
    final count =
        widget.allTransactions.where((t) => _filters.matches(t)).length;
    setState(() {
      _matchCount = count;
    });
  }

  Future<void> _loadData() async {
    final catsFuture = GetIt.I<CategoryService>().getCategories().first;
    final configFuture = GetIt.I<SettingsService>().getPercentageConfig();

    final results = await Future.wait([catsFuture, configFuture]);

    if (mounted) {
      setState(() {
        _allCategories = results[0] as List<TransactionCategoryModel>;

        final config = results[1] as dynamic;
        _allBuckets =
            (config.categories as List).map((e) => e.name as String).toList();
        if (!_allBuckets.contains("Out of Bucket")) {
          _allBuckets.add("Out of Bucket");
        }
      });
    }
  }

  void _updateFilters(VoidCallback update) {
    setState(() {
      update();
    });
    _calculateMatchCount();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.9,
      decoration: const BoxDecoration(
        color: BudgetrColors.cardSurface, // Deep premium background
        borderRadius: BorderRadius.vertical(top: Radius.circular(8)),
      ),
      child: Column(
        children: [
          // --- Drag Handle ---
          Center(
            child: Container(
              margin: const EdgeInsets.only(top: 12, bottom: 8),
              width: 48,
              height: 5,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),

          // --- HEADER ---
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("FILTERS",
                        style: TextStyle(
                            color: BudgetrColors.accent,
                            fontSize: 10,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 2)),
                    SizedBox(height: 2),
                    Text("Smart Selection",
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            letterSpacing: -0.5)),
                  ],
                ),
                TextButton(
                  onPressed: () {
                    HapticFeedback.lightImpact();
                    widget.onApply(FilterCriteria());
                    Navigator.pop(context);
                  },
                  style: TextButton.styleFrom(
                    backgroundColor: Colors.white.withOpacity(0.05),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                  ),
                  child: const Text("Reset All",
                      style: TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                          fontWeight: FontWeight.bold)),
                )
              ],
            ),
          ),

          // --- SCROLLABLE FILTERS ---
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              physics: const BouncingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 1. SORT
                  _buildCardSection(
                    label: "Sort Strategy",
                    child: _buildHorizontalRibbon([
                      _buildSortChip("Newest", SortOption.newest),
                      _buildSortChip("Oldest", SortOption.oldest),
                      _buildSortChip("Highest", SortOption.highestAmount),
                      _buildSortChip("Lowest", SortOption.lowestAmount),
                    ]),
                  ),
                  const SizedBox(height: 20),

                  // 2. DATE
                  _buildCardSection(
                    label: "Timeframe",
                    child: _buildHorizontalRibbon([
                      _buildDateChip("All Time", null),
                      _buildDateChip(
                          "This Month", _getDateRangeForMonth(DateTime.now())),
                      _buildDateChip(
                          "Last Month",
                          _getDateRangeForMonth(DateTime.now()
                              .subtract(const Duration(days: 30)))),
                      _buildCustomDateButton(),
                    ]),
                  ),
                  const SizedBox(height: 20),

                  // 3. TYPE
                  _buildCardSection(
                    label: "Transaction Type",
                    child: _buildHorizontalRibbon([
                      _buildTypeChip("All"),
                      _buildTypeChip("Expense"),
                      _buildTypeChip("Income"),
                      _buildTypeChip("Transfer Out"),
                      _buildTypeChip("Transfer In"),
                    ]),
                  ),
                  const SizedBox(height: 24),

                  // 4. BUCKETS
                  _buildDrillDownTile(
                    icon: Icons.pie_chart_outline_rounded,
                    label: "Buckets",
                    count: _filters.selectedBuckets.length,
                    onTap: () => _openBucketSelector(),
                  ),
                  const SizedBox(height: 16),

                  // 5. CATEGORIES
                  _buildDrillDownTile(
                    icon: Icons.category_outlined,
                    label: "Categories",
                    count: _filters.selectedCategories.length,
                    onTap: () => _openCategorySelector(),
                  ),
                  const SizedBox(height: 24),

                  // 6. AMOUNT
                  _buildCardSection(
                    label: "Amount Threshold",
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text("₹${_currentRange.start.toInt()}",
                                style: const TextStyle(
                                    color: Colors.white54,
                                    fontWeight: FontWeight.bold)),
                            Text("₹${_currentRange.end.toInt()}+",
                                style: const TextStyle(
                                    color: Colors.white54,
                                    fontWeight: FontWeight.bold)),
                          ],
                        ),
                        RangeSlider(
                          values: _currentRange,
                          min: _minAmount,
                          max: _maxAmount,
                          divisions: 1000,
                          activeColor: BudgetrColors.accent,
                          inactiveColor: Colors.white.withOpacity(0.1),
                          onChanged: (values) =>
                              setState(() => _currentRange = values),
                          onChangeEnd: (values) => _updateFilters(
                              () => _filters.amountRange = values),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),

          // --- LIVE COUNT BUTTON ---
          Container(
            padding: EdgeInsets.fromLTRB(
                24, 16, 24, MediaQuery.of(context).padding.bottom + 16),
            decoration: BoxDecoration(
              color: const Color(0xFF151C24),
              border: Border(
                  top: BorderSide(color: Colors.white.withOpacity(0.05))),
            ),
            child: SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: () {
                  HapticFeedback.mediumImpact();
                  widget.onApply(_filters);
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: BudgetrColors.accent,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                  elevation: 0,
                ),
                child: Text(
                  "Show $_matchCount Results",
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- WIDGET HELPERS ---

  Widget _buildCardSection({required String label, required Widget child}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(label.toUpperCase(),
              style: TextStyle(
                  color: Colors.white.withOpacity(0.4),
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2)),
        ),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.03),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.white.withOpacity(0.05)),
          ),
          child: child,
        ),
      ],
    );
  }

  Widget _buildHorizontalRibbon(List<Widget> children) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Row(
        children: children
            .map((c) =>
                Padding(padding: const EdgeInsets.only(right: 8), child: c))
            .toList(),
      ),
    );
  }

  Widget _buildDrillDownTile(
      {required IconData icon,
      required String label,
      required int count,
      required VoidCallback onTap}) {
    final hasSelection = count > 0;
    return InkWell(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          color: hasSelection
              ? BudgetrColors.accent.withOpacity(0.08)
              : Colors.white.withOpacity(0.03),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
              color: hasSelection
                  ? BudgetrColors.accent.withOpacity(0.3)
                  : Colors.white.withOpacity(0.05)),
        ),
        child: Row(
          children: [
            Icon(icon,
                color: hasSelection ? BudgetrColors.accent : Colors.white38,
                size: 22),
            const SizedBox(width: 16),
            Expanded(
              child: Text(label,
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w600)),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: hasSelection
                    ? BudgetrColors.accent
                    : Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                hasSelection ? "$count Selected" : "All",
                style: TextStyle(
                    color: hasSelection ? Colors.white : Colors.white54,
                    fontSize: 11,
                    fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(width: 8),
            Icon(Icons.chevron_right_rounded,
                size: 20, color: Colors.white.withOpacity(0.2)),
          ],
        ),
      ),
    );
  }

  // --- SHEETS OPENERS ---

  void _openCategorySelector() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _CategorySelectionSheet(
        allCategories: _allCategories,
        selectedCategories: List.from(_filters.selectedCategories),
        onSelectionChanged: (updatedList) {
          _updateFilters(() {
            _filters.selectedCategories = updatedList;
          });
        },
      ),
    );
  }

  void _openBucketSelector() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _SimpleMultiSelectSheet(
        title: "Select Buckets",
        items: _allBuckets,
        selectedItems: List.from(_filters.selectedBuckets),
        onSelectionChanged: (updatedList) {
          _updateFilters(() {
            _filters.selectedBuckets = updatedList;
          });
        },
      ),
    );
  }

  // --- CHIP BUILDERS ---

  Widget _buildSortChip(String label, SortOption option) {
    bool isSelected = _filters.sortOption == option;
    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        _updateFilters(() => _filters.sortOption = option);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected
              ? BudgetrColors.accent
              : Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(label,
            style: TextStyle(
                color: isSelected ? Colors.white : Colors.white54,
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500)),
      ),
    );
  }

  Widget _buildDateChip(String label, DateTimeRange? range) {
    bool isSelected = false;
    if (range == null) {
      isSelected = _filters.dateRange == null;
    } else if (_filters.dateRange != null) {
      isSelected = _filters.dateRange!.start.day == range.start.day &&
          _filters.dateRange!.start.month == range.start.month &&
          _filters.dateRange!.end.month == range.end.month;
    }

    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        _updateFilters(() => _filters.dateRange = range);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected
              ? BudgetrColors.accent
              : Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(label,
            style: TextStyle(
                color: isSelected ? Colors.white : Colors.white54,
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500)),
      ),
    );
  }

  Widget _buildCustomDateButton() {
    bool isCustom =
        _filters.dateRange != null && !_isStandardRange(_filters.dateRange!);
    return GestureDetector(
      onTap: () async {
        HapticFeedback.lightImpact();
        final picked = await showDateRangePicker(
          context: context,
          firstDate: DateTime(2020),
          lastDate: DateTime(2030),
          initialDateRange: _filters.dateRange,
          builder: (context, child) => Theme(
            data: ThemeData.dark().copyWith(
              colorScheme: const ColorScheme.dark(
                  primary: BudgetrColors.accent,
                  onPrimary: Colors.white,
                  surface: Color(0xFF1E293B),
                  onSurface: Colors.white),
            ),
            child: child!,
          ),
        );
        if (picked != null) {
          _updateFilters(() => _filters.dateRange = picked);
        }
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color:
              isCustom ? BudgetrColors.accent : Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Icon(Icons.calendar_today_rounded,
                size: 14, color: isCustom ? Colors.white : Colors.white38),
            const SizedBox(width: 6),
            Text(
                isCustom
                    ? "${DateFormat('dd/MM').format(_filters.dateRange!.start)} - ${DateFormat('dd/MM').format(_filters.dateRange!.end)}"
                    : "Custom",
                style: TextStyle(
                    color: isCustom ? Colors.white : Colors.white54,
                    fontSize: 13,
                    fontWeight: isCustom ? FontWeight.bold : FontWeight.w500)),
          ],
        ),
      ),
    );
  }

  Widget _buildTypeChip(String label) {
    bool isSelected = (label == "All")
        ? _filters.transactionTypes.isEmpty
        : _filters.transactionTypes.contains(label);

    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        _updateFilters(() {
          if (label == 'All') {
            _filters.transactionTypes.clear();
          } else {
            if (_filters.transactionTypes.contains(label)) {
              _filters.transactionTypes.remove(label);
            } else {
              _filters.transactionTypes.add(label);
            }
          }
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color:
              isSelected ? Colors.blueAccent : Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(label,
            style: TextStyle(
                color: isSelected ? Colors.white : Colors.white54,
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500)),
      ),
    );
  }

  // --- LOGIC HELPERS ---
  DateTimeRange _getDateRangeForMonth(DateTime date) {
    final start = DateTime(date.year, date.month, 1);
    final end = DateTime(date.year, date.month + 1, 0);
    return DateTimeRange(start: start, end: end);
  }

  bool _isStandardRange(DateTimeRange range) {
    return false;
  }
}

// =============================================================================
// SUB-SHEET 1: CATEGORIES
// =============================================================================
class _CategorySelectionSheet extends StatefulWidget {
  final List<TransactionCategoryModel> allCategories;
  final List<String> selectedCategories;
  final Function(List<String>) onSelectionChanged;

  const _CategorySelectionSheet({
    required this.allCategories,
    required this.selectedCategories,
    required this.onSelectionChanged,
  });

  @override
  State<_CategorySelectionSheet> createState() =>
      _CategorySelectionSheetState();
}

class _CategorySelectionSheetState extends State<_CategorySelectionSheet>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late List<String> _tempSelected;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tempSelected = List.from(widget.selectedCategories);
  }

  @override
  Widget build(BuildContext context) {
    final expenseCats =
        widget.allCategories.where((c) => c.type == 'Expense').toList();
    final incomeCats =
        widget.allCategories.where((c) => c.type == 'Income').toList();

    return Container(
      height: MediaQuery.of(context).size.height * 0.9,
      decoration: const BoxDecoration(
        color: Color(0xFF0D1217),
        borderRadius: BorderRadius.vertical(top: Radius.circular(8)),
      ),
      child: Column(
        children: [
          // Drag Handle
          Center(
            child: Container(
              margin: const EdgeInsets.only(top: 12, bottom: 8),
              width: 48,
              height: 5,
              decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8)),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Categories",
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        letterSpacing: -0.5)),
                ElevatedButton(
                  onPressed: () {
                    HapticFeedback.mediumImpact();
                    widget.onSelectionChanged(_tempSelected);
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: BudgetrColors.accent,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                  ),
                  child: const Text("Done",
                      style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ),

          // Modern Segmented TabBar
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 24),
            decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.04),
                borderRadius: BorderRadius.circular(8)),
            child: TabBar(
              controller: _tabController,
              dividerColor: Colors.transparent,
              indicatorSize: TabBarIndicatorSize.tab,
              indicator: BoxDecoration(
                color: BudgetrColors.accent.withOpacity(0.15),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                    color: BudgetrColors.accent.withOpacity(0.5), width: 1),
              ),
              labelColor: BudgetrColors.accent,
              unselectedLabelColor: Colors.white54,
              labelStyle:
                  const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
              unselectedLabelStyle:
                  const TextStyle(fontWeight: FontWeight.w500, fontSize: 13),
              tabs: const [Tab(text: "Expense"), Tab(text: "Income")],
            ),
          ),
          const SizedBox(height: 8),

          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildList(expenseCats),
                _buildList(incomeCats),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildList(List<TransactionCategoryModel> categories) {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 40),
      physics: const BouncingScrollPhysics(),
      itemCount: categories.length + 1,
      itemBuilder: (context, index) {
        if (index == 0) {
          return GestureDetector(
            onTap: () {
              HapticFeedback.lightImpact();
              setState(() => _tempSelected.removeWhere(
                  (name) => categories.any((c) => c.name == name)));
            },
            child: Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              decoration: BoxDecoration(
                  color: Colors.redAccent.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8)),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.clear_all, color: Colors.redAccent, size: 18),
                  SizedBox(width: 8),
                  Text("Clear Selection",
                      style: TextStyle(
                          color: Colors.redAccent,
                          fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          );
        }

        final cat = categories[index - 1];
        final isSelected = _tempSelected.contains(cat.name);

        return GestureDetector(
          onTap: () {
            HapticFeedback.selectionClick();
            setState(() => isSelected
                ? _tempSelected.remove(cat.name)
                : _tempSelected.add(cat.name));
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeOutCubic,
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            decoration: BoxDecoration(
              color: isSelected
                  ? BudgetrColors.accent.withOpacity(0.08)
                  : Colors.white.withOpacity(0.03),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                  color: isSelected
                      ? BudgetrColors.accent.withOpacity(0.4)
                      : Colors.white.withOpacity(0.05),
                  width: 1.5),
            ),
            child: Row(
              children: [
                Text(cat.name,
                    style: TextStyle(
                        color: isSelected
                            ? Colors.white
                            : Colors.white.withOpacity(0.8),
                        fontSize: 15,
                        fontWeight:
                            isSelected ? FontWeight.w600 : FontWeight.w500)),
                const Spacer(),
                AnimatedScale(
                  scale: isSelected ? 1.0 : 0.8,
                  duration: const Duration(milliseconds: 200),
                  child: Icon(
                      isSelected
                          ? Icons.check_circle_rounded
                          : Icons.circle_outlined,
                      color: isSelected ? BudgetrColors.accent : Colors.white24,
                      size: 22),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

// =============================================================================
// SUB-SHEET 2: BUCKETS
// =============================================================================
class _SimpleMultiSelectSheet extends StatefulWidget {
  final String title;
  final List<String> items;
  final List<String> selectedItems;
  final Function(List<String>) onSelectionChanged;

  const _SimpleMultiSelectSheet({
    required this.title,
    required this.items,
    required this.selectedItems,
    required this.onSelectionChanged,
  });

  @override
  State<_SimpleMultiSelectSheet> createState() =>
      _SimpleMultiSelectSheetState();
}

class _SimpleMultiSelectSheetState extends State<_SimpleMultiSelectSheet> {
  late List<String> _tempSelected;

  @override
  void initState() {
    super.initState();
    _tempSelected = List.from(widget.selectedItems);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.75,
      decoration: const BoxDecoration(
        color: Color(0xFF0D1217),
        borderRadius: BorderRadius.vertical(top: Radius.circular(8)),
      ),
      child: Column(
        children: [
          // Drag Handle
          Center(
            child: Container(
              margin: const EdgeInsets.only(top: 12, bottom: 8),
              width: 48,
              height: 5,
              decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8)),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(widget.title,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        letterSpacing: -0.5)),
                ElevatedButton(
                  onPressed: () {
                    HapticFeedback.mediumImpact();
                    widget.onSelectionChanged(_tempSelected);
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: BudgetrColors.accent,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                  ),
                  child: const Text("Done",
                      style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 40),
              physics: const BouncingScrollPhysics(),
              itemCount: widget.items.length + 1,
              itemBuilder: (context, index) {
                if (index == 0) {
                  return GestureDetector(
                    onTap: () {
                      HapticFeedback.lightImpact();
                      setState(() => _tempSelected.clear());
                    },
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 16),
                      decoration: BoxDecoration(
                          color: Colors.redAccent.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8)),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.clear_all,
                              color: Colors.redAccent, size: 18),
                          SizedBox(width: 8),
                          Text("Clear Selection",
                              style: TextStyle(
                                  color: Colors.redAccent,
                                  fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                  );
                }

                final item = widget.items[index - 1];
                final isSelected = _tempSelected.contains(item);

                return GestureDetector(
                  onTap: () {
                    HapticFeedback.selectionClick();
                    setState(() => isSelected
                        ? _tempSelected.remove(item)
                        : _tempSelected.add(item));
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    curve: Curves.easeOutCubic,
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 16),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? BudgetrColors.accent.withOpacity(0.08)
                          : Colors.white.withOpacity(0.03),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                          color: isSelected
                              ? BudgetrColors.accent.withOpacity(0.4)
                              : Colors.white.withOpacity(0.05),
                          width: 1.5),
                    ),
                    child: Row(
                      children: [
                        Text(item,
                            style: TextStyle(
                                color: isSelected
                                    ? Colors.white
                                    : Colors.white.withOpacity(0.8),
                                fontSize: 15,
                                fontWeight: isSelected
                                    ? FontWeight.w600
                                    : FontWeight.w500)),
                        const Spacer(),
                        AnimatedScale(
                          scale: isSelected ? 1.0 : 0.8,
                          duration: const Duration(milliseconds: 200),
                          child: Icon(
                              isSelected
                                  ? Icons.check_circle_rounded
                                  : Icons.circle_outlined,
                              color: isSelected
                                  ? BudgetrColors.accent
                                  : Colors.white24,
                              size: 22),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
