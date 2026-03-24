import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

class CreditFilterSheet extends StatefulWidget {
  final String initialType;
  final String initialSort;
  final DateTimeRange? initialDateRange;
  final Set<String> initialCategories;
  final Set<String> initialBuckets;
  final List<String> availableCategories;
  final List<String> availableBuckets;
  final Function(
    String type,
    String sort,
    DateTimeRange? dateRange,
    Set<String> categories,
    Set<String> buckets,
  ) onApply;

  const CreditFilterSheet({
    super.key,
    required this.initialType,
    required this.initialSort,
    required this.initialDateRange,
    required this.initialCategories,
    required this.initialBuckets,
    required this.availableCategories,
    required this.availableBuckets,
    required this.onApply,
  });

  @override
  State<CreditFilterSheet> createState() => _CreditFilterSheetState();
}

class _CreditFilterSheetState extends State<CreditFilterSheet> {
  late String _selectedType;
  late String _sortOption;
  DateTimeRange? _dateRange;

  // Using Lists internally for easier manipulation with the modern sub-sheets
  late List<String> _selectedCategories;
  late List<String> _selectedBuckets;

  final Color _accentColor = const Color(0xFF3A86FF);
  final Color _bgColor = const Color(0xFF0D1B2A);
  final Color _cardColor = Colors.white.withOpacity(0.03);

  @override
  void initState() {
    super.initState();
    _selectedType = widget.initialType;
    _sortOption = widget.initialSort;
    _dateRange = widget.initialDateRange;
    _selectedCategories = widget.initialCategories.toList();
    _selectedBuckets = widget.initialBuckets.toList();
  }

  void _updateFilters(VoidCallback update) {
    setState(() {
      update();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.9,
      decoration: BoxDecoration(
        color: _bgColor, // Deep premium background
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
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
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("FILTERS",
                        style: TextStyle(
                            color: _accentColor,
                            fontSize: 10,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 2)),
                    const SizedBox(height: 2),
                    const Text("Smart Selection",
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
                    // [UPDATED LOGIC] Pass empty/default values to the parent and pop immediately
                    widget
                        .onApply('All', 'Newest', null, <String>{}, <String>{});
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
                      _buildSortChip("Newest"),
                      _buildSortChip("Oldest"),
                      _buildSortChip("Amount High"),
                      _buildSortChip("Amount Low"),
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
                    ]),
                  ),
                  const SizedBox(height: 24),

                  // 4. BUCKETS
                  if (widget.availableBuckets.isNotEmpty) ...[
                    _buildDrillDownTile(
                      icon: Icons.pie_chart_outline_rounded,
                      label: "Buckets",
                      count: _selectedBuckets.length,
                      onTap: () => _openMultiSelectSheet(
                        title: "Select Buckets",
                        items: widget.availableBuckets,
                        selectedItems: _selectedBuckets,
                        onSelectionChanged: (updated) =>
                            _updateFilters(() => _selectedBuckets = updated),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],

                  // 5. CATEGORIES
                  if (widget.availableCategories.isNotEmpty) ...[
                    _buildDrillDownTile(
                      icon: Icons.category_outlined,
                      label: "Categories",
                      count: _selectedCategories.length,
                      onTap: () => _openMultiSelectSheet(
                        title: "Select Categories",
                        items: widget.availableCategories,
                        selectedItems: _selectedCategories,
                        onSelectionChanged: (updated) =>
                            _updateFilters(() => _selectedCategories = updated),
                      ),
                    ),
                    const SizedBox(height: 40),
                  ],
                ],
              ),
            ),
          ),

          // --- APPLY BUTTON ---
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
                  widget.onApply(
                    _selectedType,
                    _sortOption,
                    _dateRange,
                    _selectedCategories.toSet(),
                    _selectedBuckets.toSet(),
                  );
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: _accentColor,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  elevation: 0,
                ),
                child: const Text(
                  "Apply Filters",
                  style: TextStyle(
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
            color: _cardColor,
            borderRadius: BorderRadius.circular(12),
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
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          color: hasSelection ? _accentColor.withOpacity(0.08) : _cardColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
              color: hasSelection
                  ? _accentColor.withOpacity(0.3)
                  : Colors.white.withOpacity(0.05)),
        ),
        child: Row(
          children: [
            Icon(icon,
                color: hasSelection ? _accentColor : Colors.white38, size: 22),
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
                color:
                    hasSelection ? _accentColor : Colors.white.withOpacity(0.1),
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

  // --- CHIP BUILDERS ---

  Widget _buildSortChip(String label) {
    bool isSelected = _sortOption == label;
    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        _updateFilters(() => _sortOption = label);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? _accentColor : Colors.white.withOpacity(0.05),
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
      isSelected = _dateRange == null;
    } else if (_dateRange != null) {
      isSelected = _dateRange!.start.day == range.start.day &&
          _dateRange!.start.month == range.start.month &&
          _dateRange!.end.month == range.end.month;
    }

    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        _updateFilters(() => _dateRange = range);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? _accentColor : Colors.white.withOpacity(0.05),
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
    bool isCustom = _dateRange != null && !_isStandardRange(_dateRange!);
    return GestureDetector(
      onTap: () async {
        HapticFeedback.lightImpact();
        final picked = await showDateRangePicker(
          context: context,
          firstDate: DateTime(2020),
          lastDate: DateTime.now(),
          initialDateRange: _dateRange,
          builder: (context, child) => Theme(
            data: ThemeData.dark().copyWith(
              colorScheme: ColorScheme.dark(
                  primary: _accentColor,
                  onPrimary: Colors.white,
                  surface: const Color(0xFF1E293B),
                  onSurface: Colors.white),
            ),
            child: child!,
          ),
        );
        if (picked != null) {
          _updateFilters(() => _dateRange = picked);
        }
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isCustom ? _accentColor : Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Icon(Icons.calendar_today_rounded,
                size: 14, color: isCustom ? Colors.white : Colors.white38),
            const SizedBox(width: 6),
            Text(
                isCustom
                    ? "${DateFormat('dd/MM').format(_dateRange!.start)} - ${DateFormat('dd/MM').format(_dateRange!.end)}"
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
    bool isSelected = _selectedType == label;
    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        _updateFilters(() => _selectedType = label);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? _accentColor : Colors.white.withOpacity(0.05),
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
    final end = DateTime(date.year, date.month + 1, 0, 23, 59, 59, 999);
    return DateTimeRange(start: start, end: end);
  }

  bool _isStandardRange(DateTimeRange range) {
    final thisMonth = _getDateRangeForMonth(DateTime.now());
    final lastMonth = _getDateRangeForMonth(
        DateTime.now().subtract(const Duration(days: 30)));

    if (range.start.year == thisMonth.start.year &&
        range.start.month == thisMonth.start.month) return true;
    if (range.start.year == lastMonth.start.year &&
        range.start.month == lastMonth.start.month) return true;

    return false;
  }

  // --- SUB-SHEET OPENER ---

  void _openMultiSelectSheet({
    required String title,
    required List<String> items,
    required List<String> selectedItems,
    required Function(List<String>) onSelectionChanged,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _SimpleMultiSelectSheet(
        title: title,
        items: items,
        selectedItems: List.from(selectedItems),
        onSelectionChanged: onSelectionChanged,
        accentColor: _accentColor,
      ),
    );
  }
}

// =============================================================================
// SUB-SHEET: MULTI-SELECT (Used for both Categories & Buckets)
// =============================================================================
class _SimpleMultiSelectSheet extends StatefulWidget {
  final String title;
  final List<String> items;
  final List<String> selectedItems;
  final Function(List<String>) onSelectionChanged;
  final Color accentColor;

  const _SimpleMultiSelectSheet({
    required this.title,
    required this.items,
    required this.selectedItems,
    required this.onSelectionChanged,
    required this.accentColor,
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
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
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
                    backgroundColor: widget.accentColor,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
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
                          borderRadius: BorderRadius.circular(12)),
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
                final isSelected = _tempSelected
                    .any((e) => e.toLowerCase() == item.toLowerCase());

                return GestureDetector(
                  onTap: () {
                    HapticFeedback.selectionClick();
                    setState(() {
                      if (isSelected) {
                        _tempSelected.removeWhere(
                            (e) => e.toLowerCase() == item.toLowerCase());
                      } else {
                        _tempSelected.add(item);
                      }
                    });
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    curve: Curves.easeOutCubic,
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 16),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? widget.accentColor.withOpacity(0.08)
                          : Colors.white.withOpacity(0.03),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                          color: isSelected
                              ? widget.accentColor.withOpacity(0.4)
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
                                  ? widget.accentColor
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
