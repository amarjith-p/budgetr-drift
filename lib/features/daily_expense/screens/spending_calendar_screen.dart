import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get_it/get_it.dart';
import 'package:intl/intl.dart';
import 'package:rxdart/rxdart.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:table_calendar/table_calendar.dart';

// --- CORE IMPORTS ---
import '../../../core/design/budgetr_colors.dart';
import '../../../core/widgets/glass_card.dart';
import '../../../core/widgets/modern_loader.dart';
import '../../../core/services/category_service.dart';
import '../../../core/models/transaction_category_model.dart';
import '../../../core/constants/icon_constants.dart'; // [ADDED] For dynamic icons

// --- SERVICE & MODEL IMPORTS ---
import '../../credit_tracker/models/credit_models.dart';
import '../../credit_tracker/services/credit_service.dart';
import '../models/expense_models.dart';
import '../services/expense_service.dart';
import '../widgets/modern_expense_sheet.dart';

class SpendingCalendarScreen extends StatefulWidget {
  const SpendingCalendarScreen({super.key});

  @override
  State<SpendingCalendarScreen> createState() => _SpendingCalendarScreenState();
}

class _SpendingCalendarScreenState extends State<SpendingCalendarScreen> {
  final ExpenseService _expenseService = GetIt.I<ExpenseService>();
  final CreditService _creditService = GetIt.I<CreditService>();
  final CategoryService _categoryService = GetIt.I<CategoryService>();

  // --- STATE ---
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  bool _isLoading = true;

  // --- DATA ---
  List<dynamic> _rawTransactions = []; // Unfiltered
  List<dynamic> _filteredTransactions = []; // Filtered
  Map<DateTime, double> _dailySpending = {}; // For Heatmap
  List<TransactionCategoryModel> _categories = []; // For Filter

  // --- FILTERS ---
  String _filterSource = 'All'; // Options: 'All', 'Bank', 'Credit'
  String? _filterCategory; // null = All Categories

  // --- STATS ---
  double _monthTotal = 0.0;
  double _monthDailyAvg = 0.0;
  int _noSpendDays = 0;

  // --- CONFIG ---
  double _greenLimit = 500.0;
  double _yellowLimit = 2000.0;

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
    _loadPreferences();
    _fetchCategories();
    _fetchTransactions();
  }

  Future<void> _loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    if (mounted) {
      setState(() {
        _greenLimit = prefs.getDouble('calendar_limit_green') ?? 500.0;
        _yellowLimit = prefs.getDouble('calendar_limit_yellow') ?? 2000.0;
      });
    }
  }

  Future<void> _savePreferences(double green, double yellow) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('calendar_limit_green', green);
    await prefs.setDouble('calendar_limit_yellow', yellow);
    setState(() {
      _greenLimit = green;
      _yellowLimit = yellow;
    });
  }

  void _fetchCategories() {
    _categoryService.getCategories().listen((cats) {
      if (mounted) {
        setState(() {
          // [FIX] Filter to only show EXPENSE categories
          _categories = cats.where((c) => c.type == 'Expense').toList();
        });
      }
    });
  }

  void _fetchTransactions() {
    Rx.combineLatest2(
      _expenseService.getAllTransactions(),
      _creditService.getAllTransactions(),
      (List<ExpenseTransactionModel> expenses,
          List<CreditTransactionModel> credits) {
        // Merge raw data first
        List<dynamic> combined = [];
        combined.addAll(expenses.where((t) => t.type == 'Expense'));
        combined.addAll(credits.where((t) => t.type == 'Expense'));

        // Sort by Date DESC
        combined.sort((a, b) {
          DateTime dateA = a is ExpenseTransactionModel
              ? a.date
              : (a as CreditTransactionModel).date;
          DateTime dateB = b is ExpenseTransactionModel
              ? b.date
              : (b as CreditTransactionModel).date;
          return dateB.compareTo(dateA);
        });

        return combined;
      },
    ).listen((data) {
      if (mounted) {
        setState(() {
          _rawTransactions = data;
          _applyFilters(); // Apply current filters to new data
          _isLoading = false;
        });
      }
    });
  }

  void _applyFilters() {
    List<dynamic> temp = List.from(_rawTransactions);

    // 1. Filter Source
    if (_filterSource == 'Bank') {
      temp = temp.where((t) => t is ExpenseTransactionModel).toList();
    } else if (_filterSource == 'Credit') {
      temp = temp.where((t) => t is CreditTransactionModel).toList();
    }

    // 2. Filter Category
    if (_filterCategory != null) {
      temp = temp.where((t) {
        String cat = t is ExpenseTransactionModel
            ? t.category
            : (t as CreditTransactionModel).category;
        return cat == _filterCategory;
      }).toList();
    }

    // 3. Rebuild Heatmap Data
    final Map<DateTime, double> totals = {};
    for (var txn in temp) {
      double amt = txn is ExpenseTransactionModel
          ? txn.amount
          : (txn as CreditTransactionModel).amount;
      DateTime date = txn is ExpenseTransactionModel
          ? txn.date
          : (txn as CreditTransactionModel).date;
      final dateKey = DateTime(date.year, date.month, date.day);
      totals[dateKey] = (totals[dateKey] ?? 0) + amt;
    }

    setState(() {
      _filteredTransactions = temp;
      _dailySpending = totals;
      _calculateMonthStats(_focusedDay);
    });
  }

  void _calculateMonthStats(DateTime focusedMonth) {
    double total = 0.0;
    int spendDays = 0;

    final firstDay = DateTime(focusedMonth.year, focusedMonth.month, 1);
    final lastDay = DateTime(focusedMonth.year, focusedMonth.month + 1, 0);
    final daysInMonth = lastDay.day;

    _dailySpending.forEach((date, amount) {
      if (date.year == focusedMonth.year &&
          date.month == focusedMonth.month &&
          amount > 0) {
        total += amount;
        spendDays++;
      }
    });

    int effectiveDays = daysInMonth;
    if (focusedMonth.year == DateTime.now().year &&
        focusedMonth.month == DateTime.now().month) {
      effectiveDays = DateTime.now().day;
    }

    setState(() {
      _monthTotal = total;
      _monthDailyAvg = effectiveDays > 0 ? total / effectiveDays : 0.0;
      _noSpendDays = effectiveDays - spendDays;
      if (_noSpendDays < 0) _noSpendDays = 0;
    });
  }

  Color _getColorForSpend(double amount) {
    if (amount == 0) return Colors.transparent;
    if (amount <= _greenLimit) return const Color(0xFF2EC4B6).withOpacity(0.8);
    if (amount <= _yellowLimit) return const Color(0xFFFF9F1C).withOpacity(0.8);
    return const Color(0xFFE71D36).withOpacity(0.8);
  }

  // --- UI BUILDING ---

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xff0D1B2A),
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        flexibleSpace: ClipRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(color: const Color(0xff0D1B2A).withOpacity(0.8)),
          ),
        ),
        title: const Text("Expense Heatmap",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded,
              color: Colors.white, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.tune_rounded, color: Colors.white70),
            tooltip: "Color Limits",
            onPressed: _showLimitSettingsSheet,
          )
        ],
      ),
      body: _isLoading
          ? const Center(child: ModernLoader())
          : Column(
              children: [
                SizedBox(
                    height:
                        MediaQuery.of(context).padding.top + kToolbarHeight),
                _buildFilterBar(),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildMonthStatsCard(),
                        const SizedBox(height: 12),
                        _buildCalendarCard(),
                        const SizedBox(height: 6),
                        _buildSelectedDayDetails(),
                      ],
                    ),
                  ),
                ),
              ],
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            backgroundColor: Colors.transparent,
            builder: (ctx) => ModernExpenseSheet(initialDate: _selectedDay),
          );
        },
        backgroundColor: const Color(0xFF00B4D8),
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text("Add Entry",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _buildFilterBar() {
    return Container(
      height: 50,
      width: double.infinity,
      color: const Color(0xff0D1B2A).withOpacity(0.8),
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        children: [
          // 1. Source Filter
          _filterChip(
              label: "All",
              isSelected: _filterSource == 'All',
              onTap: () => setState(() {
                    _filterSource = 'All';
                    _applyFilters();
                  })),
          const SizedBox(width: 8),
          _filterChip(
              label: "Bank",
              isSelected: _filterSource == 'Bank',
              onTap: () => setState(() {
                    _filterSource = 'Bank';
                    _applyFilters();
                  })),
          const SizedBox(width: 8),
          _filterChip(
              label: "Credit",
              isSelected: _filterSource == 'Credit',
              onTap: () => setState(() {
                    _filterSource = 'Credit';
                    _applyFilters();
                  })),

          _verticalDividerSmall(),

          // 2. View Mode
          _filterChip(
              label: _calendarFormat == CalendarFormat.month
                  ? "Month View"
                  : "2 Weeks",
              isSelected: true,
              color: Colors.blueGrey,
              icon: Icons.calendar_view_week,
              onTap: () => setState(() {
                    _calendarFormat = _calendarFormat == CalendarFormat.month
                        ? CalendarFormat.twoWeeks
                        : CalendarFormat.month;
                  })),

          _verticalDividerSmall(),

          // 3. Category Filter
          ActionChip(
            label: Text(_filterCategory ?? "Category: All"),
            avatar:
                const Icon(Icons.filter_list, size: 16, color: Colors.white70),
            backgroundColor: _filterCategory != null
                ? const Color(0xFF00B4D8).withOpacity(0.2)
                : Colors.white.withOpacity(0.05),
            labelStyle: TextStyle(
                color: _filterCategory != null
                    ? const Color(0xFF00B4D8)
                    : Colors.white70,
                fontSize: 12,
                fontWeight: FontWeight.w600),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: BorderSide(
                    color: _filterCategory != null
                        ? const Color(0xFF00B4D8).withOpacity(0.5)
                        : Colors.transparent)),
            onPressed: _showCategoryFilterSheet,
          ),
        ],
      ),
    );
  }

  Widget _verticalDividerSmall() {
    return Container(
      width: 1,
      height: 20,
      margin: const EdgeInsets.symmetric(horizontal: 12),
      color: Colors.white24,
    );
  }

  Widget _filterChip(
      {required String label,
      required bool isSelected,
      required VoidCallback onTap,
      Color? color,
      IconData? icon}) {
    final activeColor = color ?? const Color(0xFF00B4D8);
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected
              ? activeColor.withOpacity(0.2)
              : Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
              color: isSelected
                  ? activeColor.withOpacity(0.5)
                  : Colors.transparent),
        ),
        alignment: Alignment.center,
        child: Row(
          children: [
            if (icon != null) ...[
              Icon(icon,
                  size: 14, color: isSelected ? activeColor : Colors.white54),
              const SizedBox(width: 6)
            ],
            Text(
              label,
              style: TextStyle(
                color: isSelected ? activeColor : Colors.white54,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMonthStatsCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF1B263B).withOpacity(0.9),
            const Color(0xFF101825).withOpacity(0.9),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 10,
              offset: const Offset(0, 4)),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
              child:
                  _statItem("Filtered Total", _monthTotal, isCurrency: true)),
          _verticalDivider(),
          Expanded(
              child: _statItem("Daily Avg", _monthDailyAvg, isCurrency: true)),
          _verticalDivider(),
          Expanded(
              child: _statItem(
                  "Active Days",
                  (_monthTotal > 0 ? (DateTime.now().day - _noSpendDays) : 0)
                      .toDouble(),
                  isCurrency: false,
                  suffix: "")),
        ],
      ),
    );
  }

  Widget _statItem(String label, double value,
      {bool isCurrency = false, String suffix = ""}) {
    final valueStr = isCurrency
        ? NumberFormat.currency(symbol: '₹', decimalDigits: 2, locale: 'en_IN')
            .format(value)
        : "${value.toInt()}$suffix";

    return Column(
      children: [
        Text(
          label.toUpperCase(),
          style: const TextStyle(
              color: Colors.white54,
              fontSize: 10,
              letterSpacing: 1.0,
              fontWeight: FontWeight.w600),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 4),
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            valueStr,
            style: const TextStyle(
                color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }

  Widget _verticalDivider() {
    return Container(
        height: 30, width: 1, color: Colors.white.withOpacity(0.1));
  }

  Widget _buildCalendarCard() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1B263B),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      padding: const EdgeInsets.only(bottom: 6),
      child: Column(
        children: [
          TableCalendar(
            firstDay: DateTime.utc(2020, 1, 1),
            lastDay: DateTime.utc(2030, 12, 31),
            focusedDay: _focusedDay,
            currentDay: DateTime.now(),
            calendarFormat: _calendarFormat,
            startingDayOfWeek: StartingDayOfWeek.monday,
            availableGestures: AvailableGestures.horizontalSwipe,
            sixWeekMonthsEnforced: false,
            headerStyle: const HeaderStyle(
              formatButtonVisible: false,
              titleCentered: true,
              titleTextStyle: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold),
              leftChevronIcon:
                  Icon(Icons.chevron_left, color: Color(0xFF00B4D8)),
              rightChevronIcon:
                  Icon(Icons.chevron_right, color: Color(0xFF00B4D8)),
            ),
            daysOfWeekStyle: const DaysOfWeekStyle(
              weekdayStyle: TextStyle(color: Colors.white38, fontSize: 12),
              weekendStyle: TextStyle(color: Colors.white38, fontSize: 12),
            ),
            selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
            onDaySelected: (selectedDay, focusedDay) {
              if (!isSameDay(_selectedDay, selectedDay)) {
                setState(() {
                  _selectedDay = selectedDay;
                  _focusedDay = focusedDay;
                });
                HapticFeedback.lightImpact();
              }
            },
            onPageChanged: (focusedDay) {
              setState(() {
                _focusedDay = focusedDay;
                _calculateMonthStats(focusedDay);
              });
            },
            calendarBuilders: CalendarBuilders(
              defaultBuilder: (context, day, focusedDay) => _buildDayCell(day),
              todayBuilder: (context, day, focusedDay) =>
                  _buildDayCell(day, isToday: true),
              selectedBuilder: (context, day, focusedDay) =>
                  _buildDayCell(day, isSelected: true),
              outsideBuilder: (context, day, focusedDay) =>
                  const SizedBox.shrink(),
            ),
          ),
          const SizedBox(height: 4),
          _buildLegend(),
        ],
      ),
    );
  }

  Widget _buildDayCell(DateTime day,
      {bool isToday = false, bool isSelected = false}) {
    final dateKey = DateTime(day.year, day.month, day.day);
    final spend = _dailySpending[dateKey] ?? 0.0;
    final color = _getColorForSpend(spend);
    final bool hasSpend = spend > 0;

    return Center(
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: isSelected
              ? Colors.white
              : (hasSpend ? color : Colors.transparent),
          shape: BoxShape.circle,
          border: isToday && !isSelected
              ? Border.all(color: const Color(0xFF00B4D8), width: 1.5)
              : null,
        ),
        alignment: Alignment.center,
        child: Text(
          '${day.day}',
          style: TextStyle(
            color: isSelected
                ? const Color(0xFF0D1B2A)
                : (hasSpend ? Colors.white : Colors.white38),
            fontWeight: (isToday || isSelected || hasSpend)
                ? FontWeight.bold
                : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  Widget _buildLegend() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _legendDot(const Color(0xFF2EC4B6), "< ₹${_greenLimit.toInt()}"),
          _legendDot(const Color(0xFFFF9F1C), "< ₹${_yellowLimit.toInt()}"),
          _legendDot(const Color(0xFFE71D36), "> ₹${_yellowLimit.toInt()}"),
        ],
      ),
    );
  }

  Widget _legendDot(Color color, String label) {
    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text(label,
            style: const TextStyle(color: Colors.white54, fontSize: 10)),
      ],
    );
  }

  Widget _buildSelectedDayDetails() {
    if (_selectedDay == null) return const SizedBox.shrink();

    // Use Filtered List
    final dayTxns = _filteredTransactions.where((t) {
      final date = t is ExpenseTransactionModel
          ? t.date
          : (t as CreditTransactionModel).date;
      return isSameDay(date, _selectedDay);
    }).toList();

    final dateStr = DateFormat('EEEE, MMM d').format(_selectedDay!);
    final total = _dailySpending[DateTime(
            _selectedDay!.year, _selectedDay!.month, _selectedDay!.day)] ??
        0.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              dateStr,
              style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 16,
                  fontWeight: FontWeight.bold),
            ),
            Text(
              NumberFormat.currency(
                      locale: 'en_IN', symbol: '₹', decimalDigits: 2)
                  .format(total),
              style: const TextStyle(
                  color: Color(0xFF00B4D8),
                  fontSize: 18,
                  fontWeight: FontWeight.bold),
            ),
          ],
        ),
        const SizedBox(height: 8),
        if (dayTxns.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFF1B263B).withOpacity(0.5),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white.withOpacity(0.05)),
            ),
            child: const Center(
              child: Text(
                "No transactions match your filters.",
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white38, fontSize: 14),
              ),
            ),
          )
        else
          ListView.separated(
            shrinkWrap: true,
            padding: EdgeInsets.zero,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: dayTxns.length,
            separatorBuilder: (_, __) => const SizedBox(height: 6),
            itemBuilder: (context, index) {
              final txn = dayTxns[index];
              final isCredit = txn is CreditTransactionModel;

              // Helper getters
              final category = isCredit
                  ? (txn as CreditTransactionModel).category
                  : (txn as ExpenseTransactionModel).category;
              final amount = isCredit
                  ? (txn as CreditTransactionModel).amount
                  : (txn as ExpenseTransactionModel).amount;
              final notes = isCredit
                  ? (txn as CreditTransactionModel).notes
                  : (txn as ExpenseTransactionModel).notes;

              // [FIX] Get the correct icon dynamically for list items too
              final catModel = _categories.firstWhere((c) => c.name == category,
                  orElse: () => TransactionCategoryModel(
                      id: '',
                      name: '',
                      type: '',
                      subCategories: [],
                      iconCode: null));

              return Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: const Color(0xFF1B263B),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.white.withOpacity(0.05)),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: isCredit
                            ? Colors.purpleAccent.withOpacity(0.1)
                            : Colors.white.withOpacity(0.05),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        catModel.iconCode != null
                            ? IconConstants.getIconByCode(catModel.iconCode!)
                            : Icons.category, // Dynamic Icon
                        color: isCredit ? Colors.purpleAccent : Colors.white70,
                        size: 18,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                category,
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w500),
                              ),
                              if (isCredit) ...[
                                const SizedBox(width: 6),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 4, vertical: 1),
                                  decoration: BoxDecoration(
                                      color:
                                          Colors.purpleAccent.withOpacity(0.2),
                                      borderRadius: BorderRadius.circular(4)),
                                  child: const Text("CREDIT",
                                      style: TextStyle(
                                          color: Colors.purpleAccent,
                                          fontSize: 8,
                                          fontWeight: FontWeight.bold)),
                                )
                              ]
                            ],
                          ),
                          if (notes.isNotEmpty)
                            Text(
                              notes,
                              style: const TextStyle(
                                  color: Colors.white38, fontSize: 12),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                        ],
                      ),
                    ),
                    Text(
                      "₹${NumberFormat.currency(locale: 'en_IN', symbol: '', decimalDigits: 2).format(amount)}",
                      style: const TextStyle(
                          color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              );
            },
          ),
        const SizedBox(height: 80),
      ],
    );
  }

  void _showCategoryFilterSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1B263B),
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.6,
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const Text("Filter by Category",
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            Expanded(
              child: ListView.separated(
                itemCount: _categories.length + 1,
                separatorBuilder: (_, __) => const SizedBox(height: 8),
                itemBuilder: (context, index) {
                  if (index == 0) {
                    return ListTile(
                      title: const Text("All Categories",
                          style: TextStyle(color: Colors.white)),
                      leading: const Icon(Icons.apps, color: Colors.white70),
                      tileColor: _filterCategory == null
                          ? Colors.white.withOpacity(0.1)
                          : Colors.transparent,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      onTap: () {
                        setState(() {
                          _filterCategory = null;
                          _applyFilters();
                        });
                        Navigator.pop(context);
                      },
                    );
                  }
                  final cat = _categories[index - 1];
                  return ListTile(
                    title: Text(cat.name,
                        style: const TextStyle(color: Colors.white)),
                    // [FIX] Use Dynamic Icon from IconConstants
                    leading: Icon(
                        cat.iconCode != null
                            ? IconConstants.getIconByCode(cat.iconCode!)
                            : Icons.category,
                        color: Colors.white70),
                    tileColor: _filterCategory == cat.name
                        ? Colors.white.withOpacity(0.1)
                        : Colors.transparent,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    onTap: () {
                      setState(() {
                        _filterCategory = cat.name;
                        _applyFilters();
                      });
                      Navigator.pop(context);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Removed _getCategoryIcon as it is no longer needed
  void _showLimitSettingsSheet() {
    final greenCtrl =
        TextEditingController(text: _greenLimit.toInt().toString());
    final yellowCtrl =
        TextEditingController(text: _yellowLimit.toInt().toString());

    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1B263B),
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom + 20,
          left: 20,
          right: 20,
          top: 20,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.palette_rounded, color: Color(0xFF00B4D8)),
                const SizedBox(width: 8),
                const Text(
                  "Heatmap Sensitivity",
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 8),
            const Text(
              "Adjust the spending thresholds to customize your calendar colors.",
              style: TextStyle(color: Colors.white54, fontSize: 12),
            ),
            const SizedBox(height: 24),
            _buildLimitInput(
                "Safe Limit (Green)", greenCtrl, const Color(0xFF2EC4B6)),
            const SizedBox(height: 16),
            _buildLimitInput(
                "Caution Limit (Orange)", yellowCtrl, const Color(0xFFFF9F1C)),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF00B4D8),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  elevation: 0,
                ),
                onPressed: () {
                  final g = double.tryParse(greenCtrl.text) ?? 500;
                  final y = double.tryParse(yellowCtrl.text) ?? 2000;
                  _savePreferences(g, y);
                  Navigator.pop(context);
                },
                child: const Text("Save Configuration",
                    style: TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLimitInput(
      String label, TextEditingController ctrl, Color color) {
    return TextField(
      controller: ctrl,
      keyboardType: TextInputType.number,
      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: color.withOpacity(0.8)),
        prefixIcon: Icon(Icons.currency_rupee, color: color, size: 18),
        filled: true,
        fillColor: Colors.black26,
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none),
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: color)),
      ),
    );
  }
}
