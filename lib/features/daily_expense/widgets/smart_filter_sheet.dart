import 'package:flutter/material.dart';
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
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: const BoxDecoration(
        color: BudgetrColors.cardSurface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(14)),
      ),
      child: Column(
        children: [
          // HEADER
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Filter & Sort",
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold)),
                TextButton(
                  onPressed: () {
                    // [UPDATED] Reset Logic: Apply defaults and close sheet
                    widget.onApply(FilterCriteria());
                    Navigator.pop(context);
                  },
                  child: const Text("Reset",
                      style: TextStyle(color: BudgetrColors.accent)),
                )
              ],
            ),
          ),
          const Divider(height: 1, color: Colors.white10),

          // SCROLLABLE FILTERS
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 1. SORT
                  _buildSectionLabel("Sort By"),
                  _buildHorizontalRibbon([
                    _buildSortChip("Newest", SortOption.newest),
                    _buildSortChip("Oldest", SortOption.oldest),
                    _buildSortChip("Highest", SortOption.highestAmount),
                    _buildSortChip("Lowest", SortOption.lowestAmount),
                  ]),

                  const SizedBox(height: 24),

                  // 2. DATE
                  _buildSectionLabel("Time Period"),
                  _buildHorizontalRibbon([
                    _buildDateChip("All Time", null),
                    _buildDateChip(
                        "This Month", _getDateRangeForMonth(DateTime.now())),
                    _buildDateChip(
                        "Last Month",
                        _getDateRangeForMonth(
                            DateTime.now().subtract(const Duration(days: 30)))),
                    _buildCustomDateButton(),
                  ]),

                  const SizedBox(height: 24),

                  // 3. TYPE
                  _buildSectionLabel("Transaction Type"),
                  _buildHorizontalRibbon([
                    _buildTypeChip("All"),
                    _buildTypeChip("Expense"),
                    _buildTypeChip("Income"),
                    _buildTypeChip("Transfer Out"),
                  ]),

                  const SizedBox(height: 24),

                  // 4. BUCKETS
                  _buildSectionLabel("Buckets"),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: _buildDrillDownTile(
                      label: "Selected Buckets",
                      count: _filters.selectedBuckets.length,
                      onTap: () => _openBucketSelector(),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // 5. CATEGORIES
                  _buildSectionLabel("Categories"),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: _buildDrillDownTile(
                      label: "Selected Categories",
                      count: _filters.selectedCategories.length,
                      onTap: () => _openCategorySelector(),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // 6. AMOUNT
                  _buildSectionLabel("Amount Range"),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text("₹${_currentRange.start.toInt()}",
                                style: const TextStyle(color: Colors.white54)),
                            Text("₹${_currentRange.end.toInt()}+",
                                style: const TextStyle(color: Colors.white54)),
                          ],
                        ),
                        RangeSlider(
                          values: _currentRange,
                          min: _minAmount,
                          max: _maxAmount,
                          divisions: 1000,
                          activeColor: BudgetrColors.accent,
                          inactiveColor: Colors.white10,
                          onChanged: (values) =>
                              setState(() => _currentRange = values),
                          onChangeEnd: (values) => _updateFilters(
                              () => _filters.amountRange = values),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // LIVE COUNT BUTTON
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
                color: BudgetrColors.cardSurface,
                border: Border(
                    top: BorderSide(color: Colors.white.withOpacity(0.05)))),
            child: SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: () {
                  widget.onApply(_filters);
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: BudgetrColors.accent,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                  elevation: 0,
                ),
                child: Text(
                  "Show $_matchCount Transactions",
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

  Widget _buildSectionLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(left: 20, bottom: 12),
      child: Text(label,
          style: const TextStyle(
              color: Colors.white70,
              fontSize: 14,
              fontWeight: FontWeight.w600)),
    );
  }

  Widget _buildHorizontalRibbon(List<Widget> children) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: children
            .map((c) =>
                Padding(padding: const EdgeInsets.only(right: 8), child: c))
            .toList(),
      ),
    );
  }

  Widget _buildDrillDownTile(
      {required String label,
      required int count,
      required VoidCallback onTap}) {
    final hasSelection = count > 0;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
              color: hasSelection
                  ? BudgetrColors.accent.withOpacity(0.5)
                  : Colors.white10),
        ),
        child: Row(
          children: [
            Icon(
                label.contains("Buckets")
                    ? Icons.pie_chart_outline
                    : Icons.category_outlined,
                color: hasSelection ? BudgetrColors.accent : Colors.white70),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label,
                      style:
                          const TextStyle(color: Colors.white70, fontSize: 12)),
                  const SizedBox(height: 4),
                  Text(
                    hasSelection ? "$count Selected" : "All",
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios_rounded,
                size: 16, color: Colors.white38),
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
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) => _updateFilters(() => _filters.sortOption = option),
      selectedColor: BudgetrColors.accent,
      backgroundColor: Colors.white.withOpacity(0.05),
      labelStyle: TextStyle(color: isSelected ? Colors.white : Colors.white70),
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10), side: BorderSide.none),
      showCheckmark: false,
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

    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) => _updateFilters(() => _filters.dateRange = range),
      selectedColor: BudgetrColors.accent,
      backgroundColor: Colors.white.withOpacity(0.05),
      labelStyle: TextStyle(color: isSelected ? Colors.white : Colors.white70),
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10), side: BorderSide.none),
      showCheckmark: false,
    );
  }

  Widget _buildCustomDateButton() {
    bool isCustom =
        _filters.dateRange != null && !_isStandardRange(_filters.dateRange!);
    return ActionChip(
      label: Text(isCustom
          ? "${DateFormat('dd/MM').format(_filters.dateRange!.start)} - ${DateFormat('dd/MM').format(_filters.dateRange!.end)}"
          : "Custom"),
      avatar: Icon(Icons.calendar_today,
          size: 14, color: isCustom ? Colors.white : Colors.white70),
      backgroundColor:
          isCustom ? BudgetrColors.accent : Colors.white.withOpacity(0.05),
      labelStyle: TextStyle(color: isCustom ? Colors.white : Colors.white70),
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10), side: BorderSide.none),
      onPressed: () async {
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
    );
  }

  Widget _buildTypeChip(String label) {
    bool isSelected = (label == "All")
        ? _filters.transactionTypes.isEmpty
        : _filters.transactionTypes.contains(label);

    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (bool selected) {
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
      selectedColor: Colors.blueAccent,
      backgroundColor: Colors.white.withOpacity(0.05),
      labelStyle: TextStyle(color: isSelected ? Colors.white : Colors.white70),
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10), side: BorderSide.none),
      showCheckmark: false,
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
        color: Color(0xFF151C24),
        borderRadius: BorderRadius.vertical(top: Radius.circular(14)),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("Cancel",
                      style: TextStyle(color: Colors.white54)),
                ),
                const Text("Select Categories",
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold)),
                TextButton(
                  onPressed: () {
                    widget.onSelectionChanged(_tempSelected);
                    Navigator.pop(context);
                  },
                  child: const Text("Done",
                      style: TextStyle(
                          color: BudgetrColors.accent,
                          fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ),
          TabBar(
            controller: _tabController,
            indicatorColor: BudgetrColors.accent,
            labelColor: BudgetrColors.accent,
            unselectedLabelColor: Colors.white54,
            tabs: const [Tab(text: "Expense"), Tab(text: "Income")],
          ),
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
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: categories.length + 1,
      separatorBuilder: (_, __) =>
          const Divider(height: 1, color: Colors.white10),
      itemBuilder: (context, index) {
        if (index == 0) {
          return ListTile(
            title: const Text("Clear Selection",
                style: TextStyle(
                    color: Colors.white54, fontStyle: FontStyle.italic)),
            onTap: () => setState(() => _tempSelected
                .removeWhere((name) => categories.any((c) => c.name == name))),
          );
        }
        final cat = categories[index - 1];
        final isSelected = _tempSelected.contains(cat.name);
        return ListTile(
          title: Text(cat.name,
              style: TextStyle(
                  color: isSelected ? Colors.white : Colors.white70,
                  fontWeight:
                      isSelected ? FontWeight.bold : FontWeight.normal)),
          trailing: isSelected
              ? const Icon(Icons.check_circle, color: BudgetrColors.accent)
              : const Icon(Icons.circle_outlined, color: Colors.white24),
          onTap: () => setState(() {
            if (isSelected)
              _tempSelected.remove(cat.name);
            else
              _tempSelected.add(cat.name);
          }),
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
      height: MediaQuery.of(context).size.height * 0.7,
      decoration: const BoxDecoration(
        color: Color(0xFF151C24),
        borderRadius: BorderRadius.vertical(top: Radius.circular(14)),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("Cancel",
                      style: TextStyle(color: Colors.white54)),
                ),
                Text(widget.title,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold)),
                TextButton(
                  onPressed: () {
                    widget.onSelectionChanged(_tempSelected);
                    Navigator.pop(context);
                  },
                  child: const Text("Done",
                      style: TextStyle(
                          color: BudgetrColors.accent,
                          fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: widget.items.length + 1,
              separatorBuilder: (_, __) =>
                  const Divider(height: 1, color: Colors.white10),
              itemBuilder: (context, index) {
                if (index == 0) {
                  return ListTile(
                    title: const Text("Clear Selection",
                        style: TextStyle(
                            color: Colors.white54,
                            fontStyle: FontStyle.italic)),
                    onTap: () => setState(() => _tempSelected.clear()),
                  );
                }
                final item = widget.items[index - 1];
                final isSelected = _tempSelected.contains(item);
                return ListTile(
                  title: Text(item,
                      style: TextStyle(
                          color: isSelected ? Colors.white : Colors.white70,
                          fontWeight: isSelected
                              ? FontWeight.bold
                              : FontWeight.normal)),
                  trailing: isSelected
                      ? const Icon(Icons.check_circle,
                          color: BudgetrColors.accent)
                      : const Icon(Icons.circle_outlined,
                          color: Colors.white24),
                  onTap: () => setState(() {
                    if (isSelected)
                      _tempSelected.remove(item);
                    else
                      _tempSelected.add(item);
                  }),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
