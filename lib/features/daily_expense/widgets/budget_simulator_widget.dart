import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import '../../../core/widgets/modern_loader.dart';
import '../../../core/models/financial_record_model.dart';
import '../models/expense_models.dart';
import '../services/expense_service.dart';
import '../../credit_tracker/models/credit_models.dart';
import '../../credit_tracker/services/credit_service.dart';
import '../../dashboard/services/dashboard_service.dart';

class BudgetSimulatorWidget extends StatefulWidget {
  const BudgetSimulatorWidget({super.key});

  @override
  State<BudgetSimulatorWidget> createState() => _BudgetSimulatorWidgetState();
}

class _BudgetSimulatorWidgetState extends State<BudgetSimulatorWidget> {
  final ExpenseService _expenseService = ExpenseService();
  final CreditService _creditService = CreditService();
  final DashboardService _dashboardService = DashboardService();

  // --- STATE ---
  List<String> _allBuckets = [];
  final Set<String> _selectedBuckets = {};
  bool _isLoading = true;

  List<dynamic> _combinedTransactions = [];
  FinancialRecord? _currentBudgetRecord;
  String _selectedPeriod = 'This Month';

  @override
  void initState() {
    super.initState();
    _loadAllData();
  }

  Future<void> _loadAllData() async {
    setState(() => _isLoading = true);
    try {
      final range = _getDateRange();
      final expensesStream = _expenseService.getAllTransactions();
      final creditStream = _creditService.getAllTransactions();

      final expenses = await expensesStream.first;
      final credits = await creditStream.first;
      final budgetRecord = await _dashboardService.getRecordForMonth(
          range.start.year, range.start.month);

      if (mounted) {
        final List<dynamic> all = [...expenses, ...credits];
        final Set<String> buckets = {};

        // A. From Transactions
        for (var t in all) {
          final date = _getDate(t);
          if (date.isAfter(range.start.subtract(const Duration(seconds: 1))) &&
              date.isBefore(range.end.add(const Duration(seconds: 1)))) {
            String bucket = _getBucket(t);
            if (_getType(t) == 'Expense' && bucket.isNotEmpty)
              buckets.add(bucket);
          }
        }

        // B. From Budget
        if (budgetRecord != null) {
          buckets.addAll(budgetRecord.allocations.keys);
        }

        setState(() {
          _combinedTransactions = all;
          _allBuckets = buckets.toList()..sort();
          _currentBudgetRecord = budgetRecord;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _onPeriodChanged(String? newValue) {
    if (newValue != null) {
      setState(() {
        _selectedPeriod = newValue;
        _selectedBuckets.clear();
      });
      _loadAllData();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading)
      return const SizedBox(height: 250, child: Center(child: ModernLoader()));

    final currencyFmt =
        NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: 2);

    // --- CALCULATIONS ---
    final filteredTxns = _getSimulatedTransactions();
    final double simulatedSpend =
        filteredTxns.fold(0.0, (sum, t) => sum + _getAmount(t));

    double simulatedAllocation = 0.0;
    if (_currentBudgetRecord != null) {
      for (var bucket in _selectedBuckets) {
        simulatedAllocation += _currentBudgetRecord!.allocations[bucket] ?? 0.0;
      }
    }

    final range = _getDateRange();
    final now = DateTime.now();
    final totalDaysInMonth =
        DateTime(range.start.year, range.start.month + 1, 0).day;

    int daysPassed =
        (_selectedPeriod == 'This Month') ? now.day : totalDaysInMonth;
    if (daysPassed < 1) daysPassed = 1;
    int daysRemaining = totalDaysInMonth - daysPassed;
    if (daysRemaining < 0) daysRemaining = 0;

    final double dailyAvg = simulatedSpend / daysPassed;
    final double dailyLimit =
        simulatedAllocation > 0 ? simulatedAllocation / totalDaysInMonth : 0;

    double projectedSpend = simulatedSpend;
    if (_selectedPeriod == 'This Month') {
      projectedSpend = (simulatedSpend / daysPassed) * totalDaysInMonth;
    }

    // --- STATUS FLAGS ---
    final bool isTotalOver =
        simulatedAllocation > 0 && simulatedSpend > simulatedAllocation;
    final bool isProjectedOver =
        simulatedAllocation > 0 && projectedSpend > simulatedAllocation;
    final bool isDailyOver = dailyLimit > 0 && dailyAvg > dailyLimit;

    // --- REC. DAILY CALCULATION ---
    double recDaily = 0.0;
    if (daysRemaining > 0 && !isTotalOver && simulatedAllocation > 0) {
      recDaily = (simulatedAllocation - simulatedSpend) / daysRemaining;
    }

    // --- PREDICTIVE DATE CALCULATION (UPDATED) ---
    String crossDateText = "";
    bool isDangerDate = false;

    if (simulatedAllocation > 0 && _selectedPeriod == 'This Month') {
      if (isTotalOver) {
        crossDateText = "Budget exceeded on ${DateFormat('d MMM').format(now)}";
        isDangerDate = true;
      } else if (dailyAvg > 0) {
        final double remainingBudget = simulatedAllocation - simulatedSpend;
        // [FIX]: Changed to ceil() to be inclusive of the partial day, matching Dashboard
        final int daysToBurn = (remainingBudget / dailyAvg).ceil();

        final DateTime estimatedDate = now.add(Duration(days: daysToBurn));
        final DateTime monthEnd = range.end;

        if (estimatedDate.isBefore(monthEnd)) {
          crossDateText =
              "Projected to cross budget on ${DateFormat('d MMM').format(estimatedDate)}";
          isDangerDate = true;
        } else {
          crossDateText = "Spending is sustainable until month end";
          isDangerDate = false;
        }
      }
    }

    // Colors
    final Color goodColor = const Color(0xFF00E676);
    final Color badColor = const Color(0xFFFF5252);
    final Color neutralColor = Colors.white;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF151D29),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withOpacity(0.08)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.4),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // --- HEADER ---
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF00B4D8).withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(CupertinoIcons.speedometer,
                        color: Color.fromARGB(255, 255, 255, 255), size: 18),
                  ),
                  const SizedBox(width: 12),
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("BUDGET SIMULATOR",
                          style: TextStyle(
                              color: Colors.white70,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.2)),
                      Text("Combined Impact",
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold)),
                    ],
                  ),
                ],
              ),
              _buildPeriodDropdown(),
            ],
          ),
          const SizedBox(height: 24),

          // --- HORIZONTAL BUCKET LIST ---
          if (_allBuckets.isEmpty)
            const Padding(
                padding: EdgeInsets.symmetric(vertical: 20),
                child: Text("No buckets found.",
                    style: TextStyle(color: Colors.white38)))
          else
            SizedBox(
              height: 36,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                itemCount: _allBuckets.length + 1,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (context, index) {
                  if (index == 0) {
                    final bool hasSelection = _selectedBuckets.isNotEmpty;
                    return GestureDetector(
                      onTap: hasSelection
                          ? () {
                              HapticFeedback.mediumImpact();
                              setState(() => _selectedBuckets.clear());
                            }
                          : null,
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: hasSelection
                              ? badColor.withOpacity(0.1)
                              : Colors.white.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(
                              color: hasSelection
                                  ? badColor.withOpacity(0.3)
                                  : Colors.transparent),
                        ),
                        child: Icon(Icons.restart_alt_rounded,
                            color: hasSelection ? badColor : Colors.white24,
                            size: 16),
                      ),
                    );
                  }
                  final bucket = _allBuckets[index - 1];
                  final isSelected = _selectedBuckets.contains(bucket);
                  final isWarning = bucket == 'Out of Bucket';
                  return GestureDetector(
                    onTap: () {
                      HapticFeedback.selectionClick();
                      setState(() {
                        if (isSelected)
                          _selectedBuckets.remove(bucket);
                        else
                          _selectedBuckets.add(bucket);
                      });
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: isSelected
                            ? (isWarning
                                ? Colors.orangeAccent
                                : const Color(0xFF00B4D8))
                            : Colors.white.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(
                            color: isSelected
                                ? Colors.transparent
                                : Colors.white.withOpacity(0.1)),
                        boxShadow: isSelected
                            ? [
                                BoxShadow(
                                    color: (isWarning
                                            ? Colors.orangeAccent
                                            : const Color(0xFF00B4D8))
                                        .withOpacity(0.4),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2))
                              ]
                            : [],
                      ),
                      child: Text(bucket,
                          style: TextStyle(
                              color:
                                  isSelected ? Colors.black87 : Colors.white70,
                              fontSize: 12,
                              fontWeight: isSelected
                                  ? FontWeight.w700
                                  : FontWeight.w500)),
                    ),
                  );
                },
              ),
            ),

          const SizedBox(height: 32),

          // --- RESULTS ---
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: _selectedBuckets.isNotEmpty
                ? Column(
                    key: const ValueKey('results'),
                    children: [
                      if (simulatedAllocation > 0) ...[
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text("Utilization",
                                style: TextStyle(
                                    color: Colors.white.withOpacity(0.5),
                                    fontSize: 11)),
                            Text(
                                "${((simulatedSpend / simulatedAllocation) * 100).toStringAsFixed(1)}%",
                                style: TextStyle(
                                    color: isTotalOver ? badColor : goodColor,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12)),
                          ],
                        ),
                        const SizedBox(height: 8),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: (simulatedSpend / simulatedAllocation)
                                .clamp(0.0, 1.0),
                            backgroundColor: Colors.white.withOpacity(0.1),
                            color: isTotalOver ? badColor : goodColor,
                            minHeight: 6,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(currencyFmt.format(simulatedSpend),
                                style: TextStyle(
                                    color:
                                        isTotalOver ? badColor : neutralColor,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12)),
                            Text(
                                "of ${currencyFmt.format(simulatedAllocation)}",
                                style: TextStyle(
                                    color: Colors.white.withOpacity(0.5),
                                    fontSize: 11)),
                          ],
                        ),
                        const SizedBox(height: 24),
                      ] else
                        Container(
                          margin: const EdgeInsets.only(bottom: 24),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                              color: Colors.orangeAccent.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                  color: Colors.orangeAccent.withOpacity(0.3))),
                          child: const Row(children: [
                            Icon(Icons.warning_amber_rounded,
                                color: Colors.orangeAccent, size: 16),
                            SizedBox(width: 8),
                            Expanded(
                                child: Text(
                                    "No budget limits set for these buckets.",
                                    style: TextStyle(
                                        color: Colors.orangeAccent,
                                        fontSize: 11)))
                          ]),
                        ),

                      // Metrics Grid
                      Row(
                        children: [
                          Expanded(
                              child: _buildMetricCard("Daily Avg.",
                                  currencyFmt.format(dailyAvg), Icons.today,
                                  color: isDailyOver ? badColor : goodColor)),
                          const SizedBox(width: 12),
                          Expanded(
                              child: _buildMetricCard(
                                  "Rec. Daily Avg.",
                                  daysRemaining > 0
                                      ? currencyFmt.format(recDaily)
                                      : "-",
                                  Icons.event_available,
                                  color: isTotalOver
                                      ? Colors.white30
                                      : goodColor)),
                        ],
                      ),
                      const SizedBox(height: 12),

                      // Projected Month End Card
                      _buildProjectedCard(
                          projectedSpend,
                          simulatedAllocation,
                          currencyFmt,
                          _selectedPeriod == 'Last Month',
                          isProjectedOver),

                      // Date Projection Footer
                      if (crossDateText.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 12),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                  isDangerDate
                                      ? Icons.warning_amber_rounded
                                      : Icons.check_circle_outline,
                                  color: isDangerDate
                                      ? badColor
                                      : goodColor.withOpacity(0.7),
                                  size: 14),
                              const SizedBox(width: 6),
                              Text(
                                crossDateText,
                                style: TextStyle(
                                  color: isDangerDate
                                      ? badColor
                                      : goodColor.withOpacity(0.7),
                                  fontSize: 11,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  )
                : SizedBox(
                    key: const ValueKey('empty'),
                    height: 120,
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.touch_app_outlined,
                              color: Colors.white.withOpacity(0.2), size: 32),
                          const SizedBox(height: 12),
                          const Text("Tap buckets above to combine them",
                              style: TextStyle(
                                  color: Colors.white30, fontSize: 12)),
                        ],
                      ),
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricCard(String label, String value, IconData icon,
      {Color? color}) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: Colors.white38, size: 14),
              const SizedBox(width: 6),
              Text(label,
                  style: const TextStyle(
                      color: Colors.white54,
                      fontSize: 10,
                      fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 8),
          Text(value,
              style: TextStyle(
                  color: color ?? Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildProjectedCard(double projected, double limit, NumberFormat fmt,
      bool isPast, bool isOver) {
    final Color goodColor = const Color(0xFF00E676);
    final Color badColor = const Color(0xFFFF5252);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF00B4D8).withOpacity(0.2),
            const Color(0xFF0077B6).withOpacity(0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF00B4D8).withOpacity(0.3)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(isPast ? "Total Month Spend" : "Projected Spend",
                  style: const TextStyle(color: Colors.white70, fontSize: 11)),
              const SizedBox(height: 4),
              Text(fmt.format(projected),
                  style: TextStyle(
                      color: isOver ? badColor : Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold)),
            ],
          ),
          if (limit > 0)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: isOver
                    ? badColor.withOpacity(0.2)
                    : goodColor.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(isOver ? Icons.trending_up : Icons.check_circle_outline,
                      color: isOver ? badColor : goodColor, size: 16),
                  const SizedBox(width: 4),
                  Text(
                    isOver
                        ? "Over Budget"
                        : (isPast ? "Within Budget" : "On Track"),
                    style: TextStyle(
                        color: isOver ? badColor : goodColor,
                        fontSize: 10,
                        fontWeight: FontWeight.bold),
                  )
                ],
              ),
            )
        ],
      ),
    );
  }

  // --- HELPERS ---

  Widget _buildPeriodDropdown() {
    return Container(
      height: 28,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _selectedPeriod,
          dropdownColor: const Color(0xFF1B263B),
          icon: const Icon(Icons.keyboard_arrow_down_rounded,
              color: Colors.white54, size: 14),
          style: const TextStyle(
              color: Colors.white, fontSize: 11, fontWeight: FontWeight.w500),
          isDense: true,
          items: ['This Month', 'Last Month']
              .map((e) => DropdownMenuItem(value: e, child: Text(e)))
              .toList(),
          onChanged: _onPeriodChanged,
        ),
      ),
    );
  }

  // Data helpers
  double _getAmount(dynamic t) => (t is ExpenseTransactionModel)
      ? t.amount
      : (t is CreditTransactionModel ? t.amount : 0.0);
  DateTime _getDate(dynamic t) => (t is ExpenseTransactionModel)
      ? t.date.toDate()
      : (t is CreditTransactionModel ? t.date.toDate() : DateTime.now());
  String _getType(dynamic t) => (t is ExpenseTransactionModel)
      ? t.type
      : (t is CreditTransactionModel ? t.type : 'Expense');
  String _getBucket(dynamic t) => (t is ExpenseTransactionModel)
      ? t.bucket
      : (t is CreditTransactionModel ? t.bucket : 'Unallocated');

  ({DateTime start, DateTime end}) _getDateRange() {
    final now = DateTime.now();
    if (_selectedPeriod == 'Last Month') {
      return (
        start: DateTime(now.year, now.month - 1, 1),
        end: DateTime(now.year, now.month, 0, 23, 59, 59)
      );
    }
    return (
      start: DateTime(now.year, now.month, 1),
      end: DateTime(now.year, now.month + 1, 0, 23, 59, 59)
    );
  }

  bool _matchesPeriod(DateTime date, DateTime start, DateTime end) {
    return date.isAfter(start.subtract(const Duration(seconds: 1))) &&
        date.isBefore(end.add(const Duration(seconds: 1)));
  }

  List<dynamic> _getSimulatedTransactions() {
    final range = _getDateRange();
    return _combinedTransactions.where((t) {
      if (_getType(t) != 'Expense') return false;
      if (!_selectedBuckets.contains(_getBucket(t))) return false;
      if (!_matchesPeriod(_getDate(t), range.start, range.end)) return false;
      return true;
    }).toList();
  }
}
