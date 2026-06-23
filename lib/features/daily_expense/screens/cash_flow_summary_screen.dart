import 'dart:ui';
import 'package:budget/core/widgets/modern_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:collection/collection.dart';

import '../../../core/models/financial_record_model.dart';
import '../../../core/widgets/futuristic_loader.dart';
import '../../dashboard/services/dashboard_service.dart';
import '../../credit_tracker/models/credit_models.dart';
import '../../credit_tracker/services/credit_service.dart';
import '../models/expense_models.dart';
import '../services/expense_service.dart';

class CashFlowSummaryScreen extends StatefulWidget {
  const CashFlowSummaryScreen({super.key});

  @override
  State<CashFlowSummaryScreen> createState() => _CashFlowSummaryScreenState();
}

class _CashFlowSummaryScreenState extends State<CashFlowSummaryScreen> {
  final ExpenseService _expenseService = GetIt.I<ExpenseService>();
  final CreditService _creditService = GetIt.I<CreditService>();
  final DashboardService _dashboardService = GetIt.I<DashboardService>();

  String _selectedRange = 'This Month';
  DateTimeRange? _customDateRange;

  bool _isExpenseTableExpanded = false;
  bool _isIncomeTableExpanded = false;

  // Theme Colors
  final Color _bgColor = const Color(0xFF0D1B2A);
  final Color _cardColor = const Color(0xFF151D29);
  final Color _incomeColor = const Color(0xFF00E676);
  final Color _expenseColor = const Color(0xFFFF4D6D);
  final Color _accentColor = const Color(0xFF00B4D8);
  final Color _warningColor = Colors.amberAccent;

  // Change decimalDigits from 0 to 2
  final NumberFormat _currencyFmt = NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: 2);
  final NumberFormat _percentFmt = NumberFormat.percentPattern('en_IN')
    ..minimumFractionDigits = 2
    ..maximumFractionDigits = 2;

@override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bgColor,
      body: SafeArea(
        child: StreamBuilder<List<ExpenseTransactionModel>>(
          stream: _expenseService.getAllTransactions(),
          builder: (context, expenseSnap) {
            return StreamBuilder<List<CreditTransactionModel>>(
              stream: _creditService.getAllTransactions(),
              builder: (context, creditSnap) {
                return StreamBuilder<List<FinancialRecord>>(
                  stream: _dashboardService.getFinancialRecords(),
                  builder: (context, recordsSnap) {
                    
                    // 1. Loading State
                    if (!expenseSnap.hasData || !creditSnap.hasData || !recordsSnap.hasData) {
                      return Column(
                        children: [
                          const ModernAppBar(
                            title: "Cash Flow Summary",
                            subtitle: "ANALYZING...",
                            trailingIcon: null, // Hide icon while loading
                          ),
                          Expanded(
                            child: Center(
                              child: FuturisticLoader(size: 60, label: "ANALYZING CASH FLOW..."),
                            ),
                          ),
                        ],
                      );
                    }

                    // 2. Data Preparation
                    final allExpenses = expenseSnap.data ?? [];
                    final allCredits = creditSnap.data ?? [];
                    final allRecords = recordsSnap.data ?? [];

                    final dateRange = _resolveDateRange(allExpenses, allCredits);
                    final filteredTxns = _getFilteredTransactions(allExpenses, allCredits, dateRange);

                    // 3. Compute Core Aggregations
                    final incomeTxns = filteredTxns.where((t) => t['isIncome'] == true).toList();
                    final expenseTxns = filteredTxns.where((t) => t['isIncome'] == false).toList();

                    final totalIncome = incomeTxns.fold(0.0, (sum, t) => sum + (t['amount'] as double));
                    final totalExpense = expenseTxns.fold(0.0, (sum, t) => sum + (t['amount'] as double));
                    final netSavings = totalIncome - totalExpense;
                    final savingsRate = totalIncome > 0 ? (netSavings / totalIncome) : 0.0;
                    final spendVsIncome = totalIncome > 0 ? (totalExpense / totalIncome) : 0.0;

                    final monthsSpanned = _calculateMonthsSpanned(dateRange);
                    final avgIncome = totalIncome / monthsSpanned;
                    final avgExpense = totalExpense / monthsSpanned;
                    final avgSavings = netSavings / monthsSpanned;

                    // 4. Format the Subtitle for ModernAppBar
                    final fmt = DateFormat('dd MMM yyyy');
                    String dateSubtitle = _selectedRange;
                    if (_selectedRange != 'All Time') {
                      dateSubtitle = "${fmt.format(dateRange.start)} - ${fmt.format(dateRange.end)}";
                    }

                    // 5. Main Screen Layout
                    return Column(
                      children: [
                        ModernAppBar(
                          title: "Cash Flow Summary",
                          subtitle: dateSubtitle,
                          trailingIcon: Icons.calendar_month_rounded,
                          onTrailingPressed: _showTimeSelectionSheet,
                        ),
                        Expanded(
                          child: filteredTxns.isEmpty
                              ? _buildEmptyState()
                              : RefreshIndicator(
                                  onRefresh: () async { setState(() {}); },
                                  color: _accentColor,
                                  backgroundColor: _cardColor,
                                  child: ListView(
                                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 40),
                                    physics: const BouncingScrollPhysics(),
                                    children: [
                                      _buildKPIGrid(
                                        totalIncome: totalIncome,
                                        totalExpense: totalExpense,
                                        netSavings: netSavings,
                                        savingsRate: savingsRate,
                                        avgIncome: avgIncome,
                                        avgExpense: avgExpense,
                                        avgSavings: avgSavings,
                                        spendVsIncome: spendVsIncome,
                                        monthsSpanned: monthsSpanned,
                                      ),
                                      const SizedBox(height: 24),
                                      _buildDonutChartsRow(incomeTxns, expenseTxns),
                                      const SizedBox(height: 24),
                                      _buildTrendCharts(filteredTxns, dateRange, monthsSpanned),
                                      const SizedBox(height: 24),
                                      _buildCategoryTable(
                                        "Top Spending Categories", 
                                        expenseTxns, 
                                        totalExpense, 
                                        referenceIncome: totalIncome,
                                        isExpense: true,
                                        isExpanded: _isExpenseTableExpanded,
                                        onToggle: () => setState(() => _isExpenseTableExpanded = !_isExpenseTableExpanded),
                                      ),
                                      const SizedBox(height: 24),
                                      _buildCategoryTable(
                                        "Top Income Sources", 
                                        incomeTxns, 
                                        totalIncome, 
                                        referenceIncome: totalIncome,
                                        isExpense: false,
                                        isExpanded: _isIncomeTableExpanded,
                                        onToggle: () => setState(() => _isIncomeTableExpanded = !_isIncomeTableExpanded),
                                      ),
                                      const SizedBox(height: 24),
                                      _buildBucketAnalysis(expenseTxns, allRecords, dateRange, totalExpense),
                                    ],
                                  ),
                                ),
                        ),
                      ],
                    );
                  },
                );
              },
            );
          },
        ),
      ),
    );
  }

DateTimeRange _resolveDateRange(List<ExpenseTransactionModel> expenses, List<CreditTransactionModel> credits) {
    final now = DateTime.now();
    switch (_selectedRange) {
      case 'This Month':
        return DateTimeRange(start: DateTime(now.year, now.month, 1), end: DateTime(now.year, now.month + 1, 0));
      case 'Last Month':
        return DateTimeRange(start: DateTime(now.year, now.month - 1, 1), end: DateTime(now.year, now.month, 0));
      case 'This Year':
        return DateTimeRange(start: DateTime(now.year, 1, 1), end: DateTime(now.year, 12, 31));
      case 'Last Year':
        return DateTimeRange(start: DateTime(now.year - 1, 1, 1), end: DateTime(now.year - 1, 12, 31));
      case 'Custom Range':
        return _customDateRange ?? DateTimeRange(start: DateTime(now.year, now.month, 1), end: now);
      case 'All Time':
      default:
        DateTime? earliest;
        for (var e in expenses) { if (earliest == null || e.date.isBefore(earliest)) earliest = e.date; }
        for (var c in credits) { if (earliest == null || c.date.isBefore(earliest)) earliest = c.date; }
        return DateTimeRange(start: earliest ?? DateTime(now.year, now.month, 1), end: now);
    }
  }

  int _calculateMonthsSpanned(DateTimeRange range) {
    int months = (range.end.year - range.start.year) * 12 + range.end.month - range.start.month + 1;
    return months <= 0 ? 1 : months;
  }

  List<Map<String, dynamic>> _getFilteredTransactions(
    List<ExpenseTransactionModel> expenses,
    List<CreditTransactionModel> credits,
    DateTimeRange range,
  ) {
    final List<Map<String, dynamic>> combined = [];

    // Filter Expenses
    for (var e in expenses) {
      if (e.date.isBefore(range.start) || e.date.isAfter(range.end.add(const Duration(days: 1)))) continue;
      if (e.type.contains('Transfer')) continue; // Ignore internal transfers
      
      combined.add({
        'date': e.date,
        'amount': e.amount,
        'category': e.category,
        'bucket': e.bucket,
        'isIncome': e.type == 'Income',
        'raw': e,
      });
    }

    // Filter Credits
    for (var c in credits) {
      if (c.date.isBefore(range.start) || c.date.isAfter(range.end.add(const Duration(days: 1)))) continue;
      if (c.type == 'Income' && (c.category.toLowerCase() == 'payment' || c.category.toLowerCase() == 'repayment')) continue; // Ignore card payments
      
      combined.add({
        'date': c.date,
        'amount': c.amount,
        'category': c.category,
        'bucket': c.bucket,
        'isIncome': c.type == 'Income',
        'raw': c,
      });
    }

    return combined;
  }

  // --- 2. Widgets: Header & KPIs ---

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.receipt_long_rounded,
              size: 48,
              color: Colors.white.withOpacity(0.2),
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            "No Data Found", 
            style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)
          ),
          const SizedBox(height: 8),
          Text(
            "There are no transactions recorded\nfor the selected period.",
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 13, height: 1.4),
          ),
        ],
      ),
    );
  }

 Widget _buildFilterHeader(DateTimeRange resolvedRange) {
    final fmt = DateFormat('dd MMM yyyy');
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Period Overview", style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 12)),
            const SizedBox(height: 4),
            Text(
              _selectedRange == 'All Time' ? 'All Time' : "${fmt.format(resolvedRange.start)} - ${fmt.format(resolvedRange.end)}",
              style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        
        // --- EXACT CATEGORY BREAKDOWN BUTTON STYLE ---
        GestureDetector(
          onTap: _showTimeSelectionSheet,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(4), // 4px exact match
              border: Border.all(color: Colors.white.withOpacity(0.1)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _selectedRange == 'Custom Range' && _customDateRange != null
                      ? "${DateFormat('dd MMM').format(_customDateRange!.start)} - ${DateFormat('dd MMM').format(_customDateRange!.end)}"
                      : _selectedRange,
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w600), // Bold exact match
                ),
                const SizedBox(width: 4),
                const Icon(Icons.keyboard_arrow_down_rounded,
                    color: Colors.white70, size: 18),
              ],
            ),
          ),
        )
      ],
    );
  }

  // ===========================================================================
  // --- BOTTOM SHEET & TIME UTILITIES ---
  // ===========================================================================

  Widget _buildEnhancedListTile({
    required String title,
    required bool isSelected,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: isSelected
              ? _accentColor.withOpacity(0.15)
              : Colors.white.withOpacity(0.03),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected
                ? _accentColor.withOpacity(0.5)
                : Colors.white.withOpacity(0.05),
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: isSelected ? _accentColor : Colors.white38,
              size: 20,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  color: isSelected ? Colors.white : Colors.white70,
                  fontSize: 14,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                ),
              ),
            ),
            if (isSelected)
              Icon(Icons.check_circle_rounded, color: _accentColor, size: 20)
            else
              const Icon(Icons.circle_outlined, color: Colors.white12, size: 20),
          ],
        ),
      ),
    );
  }

  Future<void> _pickDateRange() async {
    final initialRange = _customDateRange ??
        DateTimeRange(
          start: DateTime.now().subtract(const Duration(days: 30)),
          end: DateTime.now(),
        );
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      initialDateRange: initialRange,
      builder: (context, child) => Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.dark(
                primary: _accentColor,
                onPrimary: Colors.white,
                surface: _cardColor,
                onSurface: Colors.white),
            dialogBackgroundColor: _cardColor,
          ),
          child: child!),
    );
    if (picked != null) {
      setState(() {
        _customDateRange = picked;
        _selectedRange = 'Custom Range';
      });
    }
  }

  void _showTimeSelectionSheet() {
    final periods = [
      'This Month',
      'Last Month',
      'This Year',
      'Last Year',
      'All Time',
      'Custom Range'
    ];

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: EdgeInsets.only(bottom: MediaQuery.of(context).padding.bottom),
          decoration: BoxDecoration(
            color: _cardColor.withOpacity(0.9),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
            border: Border(top: BorderSide(color: Colors.white.withOpacity(0.1))),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 12),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 20, 24, 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "Select Period",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.05),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.close, color: Colors.white54, size: 18),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: periods.map((p) {
                    return _buildEnhancedListTile(
                      title: p,
                      isSelected: _selectedRange == p,
                      icon: Icons.calendar_today_rounded,
                      onTap: () {
                        Navigator.pop(context);
                        if (p == 'Custom Range') {
                          WidgetsBinding.instance.addPostFrameCallback((_) => _pickDateRange());
                        } else {
                          setState(() => _selectedRange = p);
                        }
                      },
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

Widget _buildKPIGrid({
    required double totalIncome, required double totalExpense, required double netSavings, 
    required double savingsRate, required double avgIncome, required double avgExpense, 
    required double avgSavings, required double spendVsIncome, required int monthsSpanned
  }) {
    // Determine if the selected range spans only a single month
    final isSingleMonth = monthsSpanned == 1;
    
    return LayoutBuilder(
      builder: (context, constraints) {
        final crossAxisCount = constraints.maxWidth > 600 ? 4 : 2;
        final width = (constraints.maxWidth - ((crossAxisCount - 1) * 12)) / crossAxisCount;
        
        return Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            // --- Core Cards (Always Visible) ---
            _buildKpiCard(width, "Total Income", totalIncome, _incomeColor),
            _buildKpiCard(width, "Total Expense", totalExpense, _expenseColor),
            _buildKpiCard(width, "Net Savings", netSavings, netSavings >= 0 ? _incomeColor : _expenseColor),
            _buildKpiCard(width, "Savings Rate", savingsRate, Colors.white, isPercent: true, fallbackAmount: totalIncome),
            
            // --- Averages & Extras (Visible ONLY for Multi-Month Ranges) ---
            if (!isSingleMonth) ...[
              _buildKpiCard(width, "Avg Monthly Income", avgIncome, _incomeColor),
              _buildKpiCard(width, "Avg Monthly Expense", avgExpense, _expenseColor),
              _buildKpiCard(width, "Avg Monthly Savings", avgSavings, avgSavings >= 0 ? _incomeColor : _expenseColor),
              _buildKpiCard(width, "Spend vs Income", spendVsIncome, Colors.white, isPercent: true, fallbackAmount: totalIncome),
            ],
          ],
        );
      },
    );
  }

  Widget _buildKpiCard(double width, String title, double value, Color valueColor, {bool isPercent = false, double? fallbackAmount}) {
    String displayValue;
    if (isPercent) {
      if (fallbackAmount == 0) {
        displayValue = "—";
      } else {
        displayValue = _percentFmt.format(value);
      }
    } else {
      displayValue = _currencyFmt.format(value);
    }

    return Container(
      width: width,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: _cardColor, borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.white.withOpacity(0.05))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 11, fontWeight: FontWeight.w500), overflow: TextOverflow.ellipsis),
          const SizedBox(height: 8),
          FittedBox(fit: BoxFit.scaleDown, child: Text(displayValue, style: TextStyle(color: valueColor, fontSize: 16, fontWeight: FontWeight.bold))),
        ],
      ),
    );
  }

  // --- 3. Widgets: Donut Charts ---

  // --- 3. Widgets: Donut Charts ---

  Widget _buildDonutChartsRow(List<Map<String, dynamic>> incomes, List<Map<String, dynamic>> expenses) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth > 600;

        final expenseDonut = ModernDonutChartCard(title: "Top 5 Expenses", txns: expenses);
        final incomeDonut = ModernDonutChartCard(title: "Top 5 Income", txns: incomes);

        if (isWide) {
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: expenseDonut),
              const SizedBox(width: 24),
              Expanded(child: incomeDonut),
            ],
          );
        } else {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              expenseDonut,
              const SizedBox(height: 24),
              incomeDonut,
            ],
          );
        }
      },
    );
  }

  Widget _buildSingleDonut(String title, List<Map<String, dynamic>> txns, Color baseColor) {
    if (txns.isEmpty) {
      return _buildDonutContainer(title, Center(child: Text("No Data", style: TextStyle(color: Colors.white.withOpacity(0.4)))));
    }

    final grouped = groupBy(txns, (t) => t['category'] as String);
    List<MapEntry<String, double>> sums = grouped.entries.map((e) {
      return MapEntry(e.key, e.value.fold(0.0, (sum, t) => sum + (t['amount'] as double)));
    }).toList();
    
    sums.sort((a, b) => b.value.compareTo(a.value));
    
    List<MapEntry<String, double>> top5 = sums.take(5).toList();
    if (sums.length > 5) {
      final othersSum = sums.skip(5).fold(0.0, (sum, e) => sum + e.value);
      top5.add(MapEntry("Others", othersSum));
    }

    final total = top5.fold(0.0, (sum, e) => sum + e.value);
    
    return _buildDonutContainer(
      title,
      Stack(
        alignment: Alignment.center,
        children: [
          PieChart(
            PieChartData(
              sectionsSpace: 2,
              centerSpaceRadius: 40,
              sections: top5.asMap().entries.map((entry) {
                final idx = entry.key;
                final data = entry.value;
                final opacity = 1.0 - (idx * 0.15);
                return PieChartSectionData(
                  color: baseColor.withOpacity(opacity.clamp(0.2, 1.0)),
                  value: data.value,
                  title: "${((data.value / total) * 100).toStringAsFixed(0)}%",
                  radius: 20,
                  titleStyle: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white),
                  showTitle: (data.value / total) > 0.05,
                );
              }).toList(),
            ),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text("Total", style: TextStyle(fontSize: 10, color: Colors.white.withOpacity(0.5))),
              Text(NumberFormat.compactCurrency(locale: 'en_IN', symbol: '₹').format(total), style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white)),
            ],
          )
        ],
      ),
      legend: top5.map((e) => _buildLegendItem(e.key, e.value, total, baseColor)).toList(),
    );
  }

  Widget _buildDonutContainer(String title, Widget chart, {List<Widget>? legend}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: _cardColor, borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.white.withOpacity(0.05))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
          const SizedBox(height: 24),
          SizedBox(height: 160, child: chart),
          if (legend != null) ...[
            const SizedBox(height: 24),
            ...legend,
          ]
        ],
      ),
    );
  }

  Widget _buildLegendItem(String title, double amount, double total, Color color) {
    final pct = total > 0 ? (amount / total) * 100 : 0.0;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        children: [
          Container(width: 10, height: 10, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
          const SizedBox(width: 8),
          Expanded(child: Text(title, style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 12), overflow: TextOverflow.ellipsis)),
          Text("${pct.toStringAsFixed(1)}%", style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 12)),
        ],
      ),
    );
  }

  // --- 4. Widgets: Bar & Line Charts ---

// ===========================================================================
  // --- 4. Widgets: Bar & Line Charts (MODERN & SMART SCALING) ---
  // ===========================================================================

  Widget _buildTrendCharts(List<Map<String, dynamic>> txns, DateTimeRange range, int monthsSpanned) {
    if (txns.isEmpty) return const SizedBox();

    final isDaily = monthsSpanned <= 1;
    final Map<String, Map<String, double>> grouped = {};

    // 1. Generate a continuous timeline of keys
    DateTime current = range.start;
    while (current.isBefore(range.end) || current.isAtSameMomentAs(range.end)) {
      final key = isDaily ? DateFormat('dd MMM').format(current) : DateFormat('MMM yy').format(current);
      if (!grouped.containsKey(key)) grouped[key] = {'in': 0.0, 'out': 0.0};
      current = isDaily ? current.add(const Duration(days: 1)) : DateTime(current.year, current.month + 1, 1);
    }

    // 2. Populate data
    for (var t in txns) {
      final d = t['date'] as DateTime;
      final key = isDaily ? DateFormat('dd MMM').format(d) : DateFormat('MMM yy').format(d);
      if (grouped.containsKey(key)) {
        if (t['isIncome']) {
          grouped[key]!['in'] = grouped[key]!['in']! + t['amount'];
        } else {
          grouped[key]!['out'] = grouped[key]!['out']! + t['amount'];
        }
      }
    }

    final keys = grouped.keys.toList();
    
    // 3. Calculate dynamic Max Y based on layout
    double maxY = 0;
    for (var v in grouped.values) {
      if (isDaily) {
        // Stacked bar max is the sum of both
        if (v['in']! + v['out']! > maxY) maxY = v['in']! + v['out']!;
      } else {
        // Grouped bar max is the highest individual bar
        if (v['in']! > maxY) maxY = v['in']!;
        if (v['out']! > maxY) maxY = v['out']!;
      }
    }
    if (maxY == 0) maxY = 1000;

    // --- SMART AXIS LOGIC ---
    // If we have 30 days, prevent label overlap by stepping dynamically
    final int labelStep = (keys.length / 6).ceil();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      decoration: BoxDecoration(
        color: _cardColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.white.withOpacity(0.03)),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 15, offset: const Offset(0, 8))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(color: _accentColor.withOpacity(0.1), shape: BoxShape.circle),
                child: Icon(Icons.bar_chart_rounded, color: _accentColor, size: 16),
              ),
              const SizedBox(width: 12),
              Text(
                isDaily ? "Daily Flow" : "Monthly Flow", 
                style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold, letterSpacing: 0.5)
              ),
            ],
          ),
          const SizedBox(height: 32),
          
          // --- BAR CHART (Income vs Expense) ---
          SizedBox(
            height: 220,
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: maxY * 1.2,
                barTouchData: BarTouchData(
                  touchTooltipData: BarTouchTooltipData(
                    getTooltipColor: (_) => const Color(0xFF1E293B).withOpacity(0.95), // Premium Dark Tooltip
                    tooltipRoundedRadius: 8,
                    tooltipPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    tooltipMargin: 8,
                    getTooltipItem: (group, groupIndex, rod, rodIndex) {
                      final String dateLabel = keys[group.x.toInt()];
                      
                      if (isDaily) {
                        // Stacked Daily Tooltip (Shows X-Axis Date, Income, and Expense combined)
                        final double inVal = grouped[dateLabel]!['in']!;
                        final double outVal = grouped[dateLabel]!['out']!;
                        
                        return BarTooltipItem(
                          "$dateLabel\n",
                          const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 0.5),
                          children: [
                            const TextSpan(text: "\n"),
                            TextSpan(
                              text: "Income:\n ${_currencyFmt.format(inVal)}\n",
                              style: TextStyle(color: _incomeColor, fontSize: 12, fontWeight: FontWeight.w600),
                            ),
                            TextSpan(
                              text: "Expense:\n${_currencyFmt.format(outVal)}",
                              style: TextStyle(color: _expenseColor, fontSize: 12, fontWeight: FontWeight.w600),
                            ),
                          ],
                        );
                      } else {
                        // Grouped Monthly Tooltip (Shows X-Axis Date + Single Bar Identity)
                        final isIncome = rodIndex == 0;
                        return BarTooltipItem(
                          "$dateLabel\n",
                          const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 0.5),
                          children: [
                            const TextSpan(text: "\n"),
                            TextSpan(
                              text: "${isIncome ? 'Income' : 'Expense'}:  ",
                              style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 11, fontWeight: FontWeight.w600),
                            ),
                            TextSpan(
                              text: _currencyFmt.format(rod.toY),
                              style: TextStyle(color: rod.color, fontSize: 13, fontWeight: FontWeight.bold),
                            ),
                          ],
                        );
                      }
                    },
                  ),
                ),
                titlesData: FlTitlesData(
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (double value, TitleMeta meta) {
                        final idx = value.toInt();
                        if (idx < 0 || idx >= keys.length) return const SizedBox();
                        
                        // Intelligent Axis Label Rendering
                        // Always show first, last, and perfectly stepped labels in between
                        if (keys.length > 8 && idx % labelStep != 0 && idx != 0 && idx != keys.length - 1) {
                          return const SizedBox();
                        }
                        
                        return Padding(
                          padding: const EdgeInsets.only(top: 10.0),
                          child: Text(
                            keys[idx], 
                            style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 10, fontWeight: FontWeight.w600)
                          ),
                        );
                      },
                    ),
                  ),
                  leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                ),
                gridData: const FlGridData(show: false), // Hidden grid for cleaner look
                borderData: FlBorderData(show: false),
                barGroups: keys.asMap().entries.map((e) {
                  final data = grouped[e.value]!;
                  
                  if (isDaily) {
                     // DAILY: Sub-divided (Stacked) Bar Graph
                     final double inVal = data['in']!;
                     final double outVal = data['out']!;
                     return BarChartGroupData(
                       x: e.key,
                       barRods: [
                         BarChartRodData(
                           toY: inVal + outVal,
                           width: keys.length > 15 ? 6 : 12,
                           borderRadius: BorderRadius.circular(4),
                           color: Colors.transparent, // Invisible background for the stack
                           rodStackItems: [
                             // Stack Income on bottom, Expense on top
                             BarChartRodStackItem(0, inVal, _incomeColor),
                             BarChartRodStackItem(inVal, inVal + outVal, _expenseColor),
                           ],
                         )
                       ]
                     );
                  } else {
                     // MONTHLY: Multiple (Grouped) Bar Graph
                     return BarChartGroupData(
                       x: e.key,
                       barRods: [
                         BarChartRodData(
                           toY: data['in']!, 
                           color: _incomeColor, 
                           width: 8, 
                           borderRadius: BorderRadius.circular(4)
                         ),
                         BarChartRodData(
                           toY: data['out']!, 
                           color: _expenseColor, 
                           width: 8,
                           borderRadius: BorderRadius.circular(4)
                         ),
                       ],
                     );
                  }
                }).toList(),
              ),
            ),
          ),
          
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 24),
            child: Divider(color: Colors.white10, height: 1),
          ),
          
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(color: _accentColor.withOpacity(0.1), shape: BoxShape.circle),
                child: Icon(Icons.show_chart_rounded, color: _accentColor, size: 16),
              ),
              const SizedBox(width: 12),
              const Text("Net Savings Trend", style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold, letterSpacing: 0.5)),
            ],
          ),
          const SizedBox(height: 32),

          // --- LINE CHART (Net Savings) ---
          SizedBox(
            height: 120,
            child: LineChart(
              LineChartData(
                lineTouchData: LineTouchData(
                  handleBuiltInTouches: true,
                  touchTooltipData: LineTouchTooltipData(
                    getTooltipColor: (_) => const Color(0xFF1E293B).withOpacity(0.95),
                    tooltipRoundedRadius: 8,
                    tooltipPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    getTooltipItems: (List<LineBarSpot> touchedSpots) {
                      return touchedSpots.map((spot) {
                        final String dateLabel = keys[spot.x.toInt()];
                        final double val = spot.y;
                        final Color color = val >= 0 ? _incomeColor : _expenseColor;
                        
                        return LineTooltipItem(
                          "$dateLabel\n",
                          const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 0.5),
                          children: [
                            const TextSpan(text: "\n"),
                            TextSpan(
                              text: "Net Savings :\n",
                              style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 11, fontWeight: FontWeight.w600),
                            ),
                            TextSpan(
                              text: _currencyFmt.format(val),
                              style: TextStyle(color: color, fontSize: 13, fontWeight: FontWeight.bold),
                            ),
                          ],
                        );
                      }).toList();
                    },
                  ),
                ),
                gridData: const FlGridData(show: false),
                titlesData: const FlTitlesData(show: false), // Hide axes entirely for a clean mini-sparkline look
                borderData: FlBorderData(show: false),
                lineBarsData: [
                  LineChartBarData(
                    spots: keys.asMap().entries.map((e) {
                      final data = grouped[e.value]!;
                      return FlSpot(e.key.toDouble(), data['in']! - data['out']!);
                    }).toList(),
                    isCurved: true,
                    curveSmoothness: 0.35,
                    color: _accentColor,
                    barWidth: 3,
                    isStrokeCapRound: true,
                    dotData: const FlDotData(show: false), // Hide dots by default, they appear on touch
                    belowBarData: BarAreaData(
                      show: true,
                      gradient: LinearGradient(
                        colors: [
                          _accentColor.withOpacity(0.4),
                          _accentColor.withOpacity(0.0),
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

// ===========================================================================
  // --- 5. Widgets: Category Tables (TOP 5 + MODERN TINTED TOGGLE) ---
  // ===========================================================================

  Widget _buildCategoryTable(
    String title, 
    List<Map<String, dynamic>> txns, 
    double grandTotal, {
    required double referenceIncome,
    required bool isExpense,
    required bool isExpanded,
    required VoidCallback onToggle,
  }) {
    // Dynamically grab the table's theme color (Red for Expenses, Green for Income)
    final Color themeColor = isExpense ? _expenseColor : _incomeColor;
    
    final grouped = groupBy(txns, (t) => t['category'] as String);
    List<Map<String, dynamic>> rows = grouped.entries.map((e) {
      final sum = e.value.fold(0.0, (s, t) => s + (t['amount'] as double));
      return {
        'category': e.key,
        'sum': sum,
        'count': e.value.length,
        'avgAgainstIncome': referenceIncome > 0 ? sum / referenceIncome : 0.0,
        'avgPerTxn': sum / e.value.length,
        'pct': grandTotal > 0 ? sum / grandTotal : 0.0,
      };
    }).toList();

    rows.sort((a, b) => (b['sum'] as double).compareTo(a['sum'] as double));

    // Show only the Top 5 categories by default to match Donut charts
    final displayRows = isExpanded ? rows : rows.take(5).toList();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _cardColor, 
        borderRadius: BorderRadius.circular(8), 
        border: Border.all(color: Colors.white.withOpacity(0.03)),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 4))
        ]
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold, letterSpacing: 0.5)),
          const SizedBox(height: 16),
          
          if (rows.isEmpty)
             Padding(
               padding: const EdgeInsets.all(16.0),
               child: Center(child: Text("No records available.", style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 13))),
             )
          else ...[
            ...displayRows.map((r) => _buildDataListRow(
              title: r['category'],
              mainAmount: _currencyFmt.format(r['sum']),
              meta1: "${r['count']} txns",
              meta2: isExpense 
                  ? "Avg vs Income: ${_percentFmt.format(r['avgAgainstIncome'])}"
                  : "Avg/Txn: ${_currencyFmt.format(r['avgPerTxn'])}",
              pct: r['pct'],
              color: themeColor,
            )),
            
            // --- Premium Modern Expand Toggle ---
            if (rows.length > 5)
              GestureDetector(
                onTap: onToggle,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  curve: Curves.easeInOut,
                  width: double.infinity,
                  margin: const EdgeInsets.only(top: 4, bottom: 8),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  decoration: BoxDecoration(
                    color: themeColor.withOpacity(0.05), // Subtle background tint
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: themeColor.withOpacity(0.15)), // Crisp translucent border
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        isExpanded ? "Collapse List" : "View All ${rows.length} Categories",
                        style: TextStyle(
                          color: themeColor, 
                          fontSize: 12, 
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5
                        ),
                      ),
                      const SizedBox(width: 8),
                      Icon(
                        isExpanded ? Icons.keyboard_arrow_up_rounded : Icons.keyboard_arrow_down_rounded,
                        color: themeColor,
                        size: 16,
                      ),
                    ],
                  ),
                ),
              ),
              
            const SizedBox(height: 4),
            _buildDataListRow(
              title: "TOTAL",
              mainAmount: _currencyFmt.format(grandTotal),
              meta1: "${txns.length} txns",
              meta2: isExpense 
                  ? "Avg vs Income: ${_percentFmt.format(referenceIncome > 0 ? grandTotal / referenceIncome : 0.0)}" 
                  : "",
              pct: 1.0,
              color: themeColor,
              isBold: true,
            ),
          ]
        ],
      ),
    );
  }

  Widget _buildTableHeaderRow(List<String> columns) {
    final style = TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 10, fontWeight: FontWeight.w700, letterSpacing: 1.0);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Row(
        children: [
          Expanded(flex: 3, child: Text(columns[0].toUpperCase(), style: style)),
          Expanded(flex: 2, child: Text(columns[1].toUpperCase(), textAlign: TextAlign.right, style: style)),
          Expanded(flex: 1, child: Text(columns[2].toUpperCase(), textAlign: TextAlign.right, style: style)),
          Expanded(flex: 2, child: Text(columns[3].toUpperCase(), textAlign: TextAlign.right, style: style)),
          Expanded(flex: 2, child: Text(columns[4].toUpperCase(), textAlign: TextAlign.right, style: style)),
        ],
      ),
    );
  }

  Widget _buildTableRow(String col1, String col2, String col3, String col4, double pct, Color color, {bool isBold = false}) {
    final textStyle = TextStyle(color: isBold ? Colors.white : Colors.white.withOpacity(0.85), fontSize: 12, fontWeight: isBold ? FontWeight.bold : FontWeight.w500);
    
    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: isBold ? color.withOpacity(0.1) : Colors.white.withOpacity(0.02),
        borderRadius: BorderRadius.circular(8),
        border: isBold ? Border.all(color: color.withOpacity(0.3)) : Border.all(color: Colors.transparent),
      ),
      child: Row(
        children: [
          Expanded(flex: 3, child: Text(col1, style: textStyle, overflow: TextOverflow.ellipsis)),
          Expanded(flex: 2, child: Text(col2, textAlign: TextAlign.right, style: textStyle)),
          Expanded(flex: 1, child: Text(col3, textAlign: TextAlign.right, style: textStyle)),
          Expanded(flex: 2, child: Text(col4, textAlign: TextAlign.right, style: textStyle)),
          Expanded(
            flex: 2, 
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (!isBold) Expanded(
                  child: Container(
                    margin: const EdgeInsets.only(right: 8, left: 8),
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(2)
                    ),
                    alignment: Alignment.centerLeft,
                    child: FractionallySizedBox(
                      widthFactor: pct.clamp(0.0, 1.0),
                      child: Container(
                        decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(2)),
                      ),
                    ),
                  ),
                ),
                Text(_percentFmt.format(pct), style: textStyle.copyWith(color: isBold ? color : Colors.white70, fontWeight: FontWeight.w600)),
              ],
            )
          ),
        ],
      ),
    );
  }

  // --- 6. Widgets: Bucket Analysis ---

Widget _buildBucketAnalysis(List<Map<String, dynamic>> expenseTxns, List<FinancialRecord> records, DateTimeRange range, double totalExpense) {
    final Set<String> targetMonthIds = {};
    DateTime current = range.start;
    while (current.isBefore(range.end) || current.isAtSameMomentAs(range.end)) {
      targetMonthIds.add("${current.year}${current.month.toString().padLeft(2, '0')}");
      current = DateTime(current.year, current.month + 1, 1);
    }

    final Map<String, double> aggregatedBudget = {};
    int missingMonthsCount = 0;

    for (var mId in targetMonthIds) {
      final record = records.firstWhereOrNull((r) => r.id == mId);
      if (record != null) {
        record.allocations.forEach((k, v) {
          aggregatedBudget[k] = (aggregatedBudget[k] ?? 0.0) + v;
        });
      } else {
        missingMonthsCount++;
      }
    }

    final grouped = groupBy(expenseTxns, (t) {
      final b = t['bucket'] as String;
      return b.isEmpty ? 'Unallocated' : b;
    });

    final Set<String> allBuckets = {...aggregatedBudget.keys, ...grouped.keys};
    
    List<Map<String, dynamic>> rows = allBuckets.map((b) {
      final actual = grouped[b]?.fold(0.0, (s, t) => s + (t['amount'] as double)) ?? 0.0;
      final allocated = aggregatedBudget[b];
      return {
        'bucket': b,
        'actual': actual,
        'allocated': allocated,
        'variance': allocated != null ? allocated - actual : null,
        'pct': totalExpense > 0 ? actual / totalExpense : 0.0,
      };
    }).toList();

    rows.sort((a, b) => (b['actual'] as double).compareTo(a['actual'] as double));

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _cardColor, 
        borderRadius: BorderRadius.circular(8), 
        border: Border.all(color: Colors.white.withOpacity(0.03)),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 4))
        ]
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(color: _accentColor.withOpacity(0.1), shape: BoxShape.circle),
                child: Icon(Icons.all_inbox_rounded, color: _accentColor, size: 16)
              ),
              const SizedBox(width: 12),
              const Text("Bucket Analysis", style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold, letterSpacing: 0.5)),
            ],
          ),
          if (missingMonthsCount > 0)
            Container(
              margin: const EdgeInsets.only(top: 12.0),
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(color: _warningColor.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
              child: Row(
                children: [
                  Icon(Icons.info_outline_rounded, color: _warningColor, size: 14),
                  const SizedBox(width: 8),
                  Expanded(child: Text("Budget data unavailable for $missingMonthsCount month(s) in this range.", style: TextStyle(color: _warningColor.withOpacity(0.9), fontSize: 11))),
                ],
              ),
            ),
          const SizedBox(height: 16),
          
          ...rows.map((r) {
            final String b = r['bucket'];
            final bool isUnbudgeted = b == 'Out of Bucket' || b == 'Unallocated' || r['allocated'] == null;
            
            final actualStr = _currencyFmt.format(r['actual']);
            final allocStr = isUnbudgeted ? "Unbudgeted" : "Budget: ${_currencyFmt.format(r['allocated'])}";
            
            String varStr = "";
            Color? varColor;
            
            if (!isUnbudgeted) {
              final v = r['variance'] as double;
              if (v >= 0) {
                 varStr = "Var: +${_currencyFmt.format(v.abs())}";
                 varColor = _incomeColor;
              } else {
                 varStr = "Var: -${_currencyFmt.format(v.abs())}";
                 varColor = _expenseColor;
              }
            }

            return _buildDataListRow(
              title: b,
              mainAmount: actualStr,
              meta1: allocStr,
              meta2: varStr,
              pct: r['pct'],
              color: isUnbudgeted ? _warningColor : _accentColor,
              meta2Color: varColor,
              isWarning: isUnbudgeted,
            );
          }),
        ],
      ),
    );
  }
// ===========================================================================
  // --- CORE UTILITY: Modern Rich List Row ---
  // ===========================================================================

  Widget _buildDataListRow({
    required String title,
    required String mainAmount,
    required String meta1,
    required String meta2,
    required double pct,
    required Color color,
    Color? meta2Color,
    bool isBold = false,
    bool isWarning = false,
  }) {
    final titleStyle = TextStyle(
      color: isWarning ? _warningColor : (isBold ? Colors.white : Colors.white.withOpacity(0.9)),
      fontSize: 13,
      fontWeight: isBold || isWarning ? FontWeight.bold : FontWeight.w600,
    );
    final amountStyle = TextStyle(
      color: isBold ? Colors.white : Colors.white.withOpacity(0.9),
      fontSize: 14,
      fontWeight: FontWeight.bold,
      letterSpacing: 0.5,
    );
    final metaStyle = TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 11);

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: isWarning ? _warningColor.withOpacity(0.05) : (isBold ? color.withOpacity(0.1) : Colors.white.withOpacity(0.02)),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: isWarning ? _warningColor.withOpacity(0.2) : (isBold ? color.withOpacity(0.3) : Colors.transparent)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Left Column (Titles & Metadata)
          Expanded(
            flex: 12,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    if (isWarning) ...[
                      Icon(Icons.warning_amber_rounded, size: 14, color: _warningColor),
                      const SizedBox(width: 6),
                    ],
                    Expanded(child: Text(title, style: titleStyle, overflow: TextOverflow.ellipsis)),
                  ],
                ),
                if (meta1.isNotEmpty || meta2.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Wrap(
                    spacing: 6,
                    runSpacing: 4,
                    children: [
                      if (meta1.isNotEmpty) Text(meta1, style: metaStyle),
                      if (meta1.isNotEmpty && meta2.isNotEmpty) Text("•", style: metaStyle),
                      if (meta2.isNotEmpty) 
                        Text(
                          meta2, 
                          style: metaStyle.copyWith(
                            color: meta2Color ?? metaStyle.color, 
                            fontWeight: meta2Color != null ? FontWeight.bold : FontWeight.normal
                          )
                        ),
                    ],
                  ),
                ]
              ],
            ),
          ),
          const SizedBox(width: 8),
          
          // Right Column (Amounts & Progress)
          Expanded(
            flex: 10,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                // Automatically scales down if amount is too large (e.g. ₹ 1,50,000.00)
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerRight,
                  child: Text(mainAmount, style: amountStyle),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(2)
                      ),
                      alignment: Alignment.centerLeft,
                      child: FractionallySizedBox(
                        widthFactor: pct.clamp(0.0, 1.0),
                        child: Container(
                          decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(2)),
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Flexible(
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.centerRight,
                        child: Text(_percentFmt.format(pct), style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
  // --- Utility: Date Picker Bottom Sheet ---

  // void _showTimeSelectionSheet() {
  //   final periods = ['Current Month', 'Previous Month', 'Current Year', 'Previous Year', 'All Time', 'Custom Range'];

  //   showModalBottomSheet(
  //     context: context,
  //     backgroundColor: Colors.transparent,
  //     isScrollControlled: true,
  //     builder: (context) => BackdropFilter(
  //       filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
  //       child: Container(
  //         padding: EdgeInsets.only(bottom: MediaQuery.of(context).padding.bottom),
  //         decoration: BoxDecoration(
  //           color: _cardColor.withOpacity(0.95),
  //           borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
  //           border: Border(top: BorderSide(color: Colors.white.withOpacity(0.1))),
  //         ),
  //         child: Column(
  //           mainAxisSize: MainAxisSize.min,
  //           children: [
  //             const SizedBox(height: 12),
  //             Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(2))),
  //             Padding(
  //               padding: const EdgeInsets.all(24),
  //               child: Row(
  //                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //                 children: [
  //                   const Text("Select Period", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
  //                   GestureDetector(
  //                     onTap: () => Navigator.pop(context),
  //                     child: Container(
  //                       padding: const EdgeInsets.all(6),
  //                       decoration: BoxDecoration(color: Colors.white.withOpacity(0.05), shape: BoxShape.circle),
  //                       child: const Icon(Icons.close, color: Colors.white54, size: 18),
  //                     ),
  //                   ),
  //                 ],
  //               ),
  //             ),
  //             ...periods.map((p) => ListTile(
  //               title: Text(p, style: TextStyle(color: _selectedRange == p ? _accentColor : Colors.white70, fontWeight: _selectedRange == p ? FontWeight.bold : FontWeight.normal)),
  //               trailing: _selectedRange == p ? Icon(Icons.check_circle, color: _accentColor) : null,
  //               onTap: () async {
  //                 Navigator.pop(context);
  //                 if (p == 'Custom Range') {
  //                   final picked = await showDateRangePicker(
  //                     context: context,
  //                     firstDate: DateTime(2020),
  //                     lastDate: DateTime.now().add(const Duration(days: 365)),
  //                     initialDateRange: _customDateRange ?? DateTimeRange(start: DateTime.now().subtract(const Duration(days: 30)), end: DateTime.now()),
  //                     builder: (context, child) => Theme(
  //                       data: Theme.of(context).copyWith(
  //                         colorScheme: ColorScheme.dark(primary: _accentColor, onPrimary: Colors.white, surface: _cardColor, onSurface: Colors.white),
  //                       ),
  //                       child: child!,
  //                     ),
  //                   );
  //                   if (picked != null) {
  //                     setState(() {
  //                       _customDateRange = picked;
  //                       _selectedRange = p;
  //                     });
  //                   }
  //                 } else {
  //                   setState(() => _selectedRange = p);
  //                 }
  //               },
  //             )),
  //             const SizedBox(height: 24),
  //           ],
  //         ),
  //       ),
  //     ),
  //   );
  // }
}
// ===========================================================================
// --- PREMIUM EXPANDABLE DONUT CHART WIDGET ---
// ===========================================================================

class ModernDonutChartCard extends StatefulWidget {
  final String title;
  final List<Map<String, dynamic>> txns;

  const ModernDonutChartCard({
    super.key,
    required this.title,
    required this.txns,
  });

  @override
  State<ModernDonutChartCard> createState() => _ModernDonutChartCardState();
}

class _ModernDonutChartCardState extends State<ModernDonutChartCard> {
  int _touchedIndex = -1;
  bool _isExpanded = false;
  
  // Fintech-inspired modern vibrant palette
  final List<Color> _palette = [
    const Color(0xFF00B4D8), // Cyan
    const Color(0xFF7209B7), // Deep Purple
    const Color(0xFFF72585), // Neon Pink
    const Color(0xFF4CC9F0), // Light Blue
    const Color(0xFFF8961E), // Vibrant Orange
    const Color(0xFF43AA8B), // Soft Teal
  ];

  @override
  Widget build(BuildContext context) {
    final Color cardColor = const Color(0xFF151D29);
    final Color accentColor = const Color(0xFF00B4D8);
    
    // Strict 2-decimal currency formatting
    final NumberFormat currencyFmt = NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: 2);

    // Empty State Handling
    if (widget.txns.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.white.withOpacity(0.03)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.title, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w700, letterSpacing: 0.5)),
            const SizedBox(height: 40),
            Center(child: Text("No Data", style: TextStyle(color: Colors.white.withOpacity(0.4)))),
            const SizedBox(height: 40),
          ],
        ),
      );
    }

    // Data Processing
    final grouped = groupBy(widget.txns, (t) => t['category'] as String);
    List<MapEntry<String, double>> sums = grouped.entries.map((e) {
      return MapEntry(e.key, e.value.fold(0.0, (sum, t) => sum + (t['amount'] as double)));
    }).toList();

    sums.sort((a, b) => b.value.compareTo(a.value));

    List<MapEntry<String, double>> top5 = sums.take(5).toList();
    if (sums.length > 5) {
      final othersSum = sums.skip(5).fold(0.0, (sum, e) => sum + e.value);
      top5.add(MapEntry("Others", othersSum));
    }

    final total = top5.fold(0.0, (sum, e) => sum + e.value);

    // Premium Expandable Layout
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.white.withOpacity(0.03)),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.15), blurRadius: 20, offset: const Offset(0, 8))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with Expand Toggle
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(child: Text(widget.title, style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w700, letterSpacing: 0.5))),
              GestureDetector(
                onTap: () => setState(() => _isExpanded = !_isExpanded),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: accentColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Text(
                        _isExpanded ? "Hide" : "Legend", 
                        style: TextStyle(color: accentColor, fontSize: 11, fontWeight: FontWeight.bold)
                      ),
                      const SizedBox(width: 4),
                      Icon(
                        _isExpanded ? Icons.keyboard_arrow_up_rounded : Icons.keyboard_arrow_down_rounded, 
                        color: accentColor, 
                        size: 14
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          
          // Smooth Animated State Transition
          AnimatedSize(
            duration: const Duration(milliseconds: 350),
            curve: Curves.easeInOut,
            child: AnimatedCrossFade(
              duration: const Duration(milliseconds: 300),
              crossFadeState: _isExpanded ? CrossFadeState.showSecond : CrossFadeState.showFirst,
              
              // STATE 1: COLLAPSED (Chart Only, Centered)
              firstChild: SizedBox(
                height: 220,
                width: double.infinity,
                child: _buildChartArea(top5, total, currencyFmt, false),
              ),
              
              // STATE 2: EXPANDED (Chart on Left, Legend on Right)
              secondChild: SizedBox(
                width: double.infinity,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      flex: 5,
                      child: SizedBox(
                        height: 180, // Keep height strict so it doesn't squash
                        child: _buildChartArea(top5, total, currencyFmt, true),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 6,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: top5.asMap().entries.map((entry) {
                          return _buildLegendItem(entry.key, entry.value.key, entry.value.value, total, currencyFmt);
                        }).toList(),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- Reusable Chart Area that automatically scales ---
// --- Reusable Chart Area that automatically scales ---
  Widget _buildChartArea(List<MapEntry<String, double>> top5, double total, NumberFormat currencyFmt, bool isCompact) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Dynamically shrink text and radius if squeezed into half the screen
        final double radiusScale = constraints.maxWidth < 220 ? 0.65 : 1.0;
        final double centerRadius = 70.0 * radiusScale;
        
        // [NEW] Calculate a strict safe width for the center text (approx 80% of the inner diameter)
        final double innerTextWidth = centerRadius * 1.6; 
        
        final double normalStroke = 16.0 * radiusScale;
        final double touchedStroke = 24.0 * radiusScale;
        final double titleFontSize = 22.0 * radiusScale;
        final double subFontSize = 11.0 * radiusScale;

        return Stack(
          children: [
            PieChart(
              PieChartData(
                pieTouchData: PieTouchData(
                  touchCallback: (FlTouchEvent event, pieTouchResponse) {
                    setState(() {
                      if (!event.isInterestedForInteractions || pieTouchResponse == null || pieTouchResponse.touchedSection == null) {
                        _touchedIndex = -1;
                        return;
                      }
                      _touchedIndex = pieTouchResponse.touchedSection!.touchedSectionIndex;
                    });
                  },
                ),
                borderData: FlBorderData(show: false),
                sectionsSpace: 2,
                centerSpaceRadius: centerRadius,
                sections: top5.asMap().entries.map((entry) {
                  final idx = entry.key;
                  final data = entry.value;
                  final isTouched = idx == _touchedIndex;
                  final color = _palette[idx % _palette.length];

                  return PieChartSectionData(
                    color: color,
                    value: data.value,
                    title: '',
                    radius: isTouched ? touchedStroke : normalStroke,
                  );
                }).toList(),
              ),
            ),
            
            // --- Interactive Dynamic Center Text (Fitted Strictly to Inner Hole) ---
            Positioned.fill(
              child: Center(
                child: SizedBox(
                  width: innerTextWidth, // Strictly constrains the FittedBox
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      if (_touchedIndex == -1) ...[
                        Text("TOTAL", style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: subFontSize, fontWeight: FontWeight.w700, letterSpacing: 1.0)),
                        const SizedBox(height: 4),
                        FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(currencyFmt.format(total), style: TextStyle(color: Colors.white, fontSize: titleFontSize, fontWeight: FontWeight.bold)),
                        ),
                      ] else ...[
                        Text(
                          top5[_touchedIndex].key,
                          textAlign: TextAlign.center,
                          style: TextStyle(color: _palette[_touchedIndex % _palette.length], fontSize: subFontSize + 1, fontWeight: FontWeight.bold),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(currencyFmt.format(top5[_touchedIndex].value), style: TextStyle(color: Colors.white, fontSize: titleFontSize * 0.85, fontWeight: FontWeight.bold)),
                        ),
                        Text(
                          "${((top5[_touchedIndex].value / total) * 100).toStringAsFixed(1)}%",
                          style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: subFontSize, fontWeight: FontWeight.w600),
                        ),
                      ]
                    ],
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  // --- Right-Side Interactive Legend Item (Fitted) ---
  Widget _buildLegendItem(int idx, String title, double amount, double total, NumberFormat fmt) {
    final color = _palette[idx % _palette.length];
    final isTouched = idx == _touchedIndex;
    final pct = total > 0 ? (amount / total) * 100 : 0.0;

    return GestureDetector(
      onTapDown: (_) => setState(() => _touchedIndex = idx),
      onTapUp: (_) => setState(() => _touchedIndex = -1),
      onTapCancel: () => setState(() => _touchedIndex = -1),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 6),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        decoration: BoxDecoration(
          color: isTouched ? color.withOpacity(0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: isTouched ? color.withOpacity(0.3) : Colors.transparent),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(width: 8, height: 8, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title, 
                    style: TextStyle(
                      color: isTouched ? Colors.white : Colors.white.withOpacity(0.85), 
                      fontSize: 11, 
                      fontWeight: isTouched ? FontWeight.bold : FontWeight.w600
                    ), 
                    maxLines: 1, 
                    overflow: TextOverflow.ellipsis
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Text("${pct.toStringAsFixed(1)}%", style: TextStyle(color: color.withOpacity(0.9), fontSize: 10, fontWeight: FontWeight.bold)),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(left: 4.0),
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            alignment: Alignment.centerLeft,
                            child: Text("• ${fmt.format(amount)}", style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 10)),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}