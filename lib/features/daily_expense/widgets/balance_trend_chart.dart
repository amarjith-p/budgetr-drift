import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:intl/intl.dart';
import 'package:collection/collection.dart';
import '../../../core/widgets/modern_loader.dart';
import '../models/expense_models.dart';
import '../services/expense_service.dart';

class BalanceTrendChart extends StatefulWidget {
  const BalanceTrendChart({super.key});

  @override
  State<BalanceTrendChart> createState() => _BalanceTrendChartState();
}

class _BalanceTrendChartState extends State<BalanceTrendChart> {
  final ExpenseService _service = GetIt.I<ExpenseService>();

  late Stream<List<ExpenseAccountModel>> _accountsStream;
  late Stream<List<ExpenseTransactionModel>> _transactionsStream;

  String _selectedRange = '1M';
  String? _selectedAccountId;

  @override
  void initState() {
    super.initState();
    _accountsStream = _service.getAccounts();
    _transactionsStream = _service.getAllTransactions();
  }

  DateTime _getStartDate() {
    final now = DateTime.now();
    switch (_selectedRange) {
      case '1W':
        return now.subtract(const Duration(days: 7));
      case '1M':
        return DateTime(now.year, now.month - 1, now.day);
      case '3M':
        return DateTime(now.year, now.month - 3, now.day);
      case '6M':
        return DateTime(now.year, now.month - 6, now.day);
      case '1Y':
        return DateTime(now.year - 1, now.month, now.day);
      case 'ALL':
        return DateTime(2000);
      default:
        return now.subtract(const Duration(days: 30));
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<ExpenseAccountModel>>(
      stream: _accountsStream,
      builder: (context, accSnapshot) {
        final accounts = accSnapshot.data ?? [];

        double currentDisplayBalance = 0;
        if (_selectedAccountId == null) {
          currentDisplayBalance =
              accounts.fold(0.0, (sum, item) => sum + item.currentBalance);
        } else {
          final selectedAccount =
              accounts.firstWhereOrNull((a) => a.id == _selectedAccountId);
          currentDisplayBalance = selectedAccount?.currentBalance ?? 0.0;
        }

        if (_selectedAccountId != null &&
            !accounts.any((a) => a.id == _selectedAccountId)) {
          _selectedAccountId = null;
        }

        return StreamBuilder<List<ExpenseTransactionModel>>(
          stream: _transactionsStream,
          builder: (context, txnSnapshot) {
            if (!accSnapshot.hasData || !txnSnapshot.hasData) {
              return const SizedBox(
                  height: 200, child: Center(child: ModernLoader()));
            }

            final allTxns = txnSnapshot.data!;
            final filteredTxns = _selectedAccountId == null
                ? allTxns
                : allTxns
                    .where((t) => t.accountId == _selectedAccountId)
                    .toList();

            final List<FlSpot> spots = _generateBalanceHistory(
              currentDisplayBalance,
              filteredTxns,
              _getStartDate(),
            );

            double minY = 0, maxY = 0, range = 0, padding = 0;
            if (spots.isNotEmpty) {
              minY = spots.map((e) => e.y).min;
              maxY = spots.map((e) => e.y).max;
              range = maxY - minY;
              if (range == 0) range = maxY == 0 ? 100 : maxY * 0.2;
              padding = range * 0.1;
            }

            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFF151D29),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white.withOpacity(0.08)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 15,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // --- Header Row 1: Title & Account Filter ---
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.05),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(CupertinoIcons.waveform_path_ecg,
                            color: Colors.white70, size: 12),
                      ),
                      const Text(
                        "BALANCE TREND",
                        style: TextStyle(
                          color: Colors.white54,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.5,
                        ),
                      ),
                      Flexible(
                        child: _buildAccountFilter(accounts),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // --- Header Row 2: Amount & Range Selector ---
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment:
                        CrossAxisAlignment.center, // Align center for safety
                    children: [
                      // Amount (Expanded + FittedBox ensures it never overflows)
                      Expanded(
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          alignment: Alignment.centerLeft,
                          child: Text(
                            NumberFormat.currency(
                                    locale: 'en_IN',
                                    symbol: '₹',
                                    decimalDigits: 2)
                                .format(currentDisplayBalance),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      // Range Selector
                      _buildRangeSelector(),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // --- Chart ---
                  if (spots.isEmpty)
                    const SizedBox(
                      height: 180,
                      child: Center(
                        child: Text("No data for this period",
                            style: TextStyle(color: Colors.white24)),
                      ),
                    )
                  else
                    SizedBox(
                      height: 180,
                      child: LineChart(
                        LineChartData(
                          gridData: FlGridData(
                            show: true,
                            drawVerticalLine: false,
                            horizontalInterval: range / 4,
                            getDrawingHorizontalLine: (value) => FlLine(
                              color: Colors.white.withOpacity(0.05),
                              strokeWidth: 1,
                            ),
                          ),
                          titlesData: FlTitlesData(
                            show: true,
                            rightTitles: const AxisTitles(
                                sideTitles: SideTitles(showTitles: false)),
                            topTitles: const AxisTitles(
                                sideTitles: SideTitles(showTitles: false)),
                            leftTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                reservedSize: 40,
                                interval: range / 4,
                                getTitlesWidget: (value, meta) {
                                  if (value == minY - padding ||
                                      value == maxY + padding) {
                                    return const SizedBox.shrink();
                                  }
                                  return Text(
                                    NumberFormat.compactCurrency(
                                            locale: 'en_IN', symbol: '')
                                        .format(value),
                                    style: TextStyle(
                                      color: Colors.white.withOpacity(0.3),
                                      fontSize: 10,
                                    ),
                                  );
                                },
                              ),
                            ),
                            bottomTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                reservedSize: 22,
                                interval: (spots.last.x - spots.first.x) / 3,
                                getTitlesWidget: (value, meta) {
                                  final date =
                                      DateTime.fromMillisecondsSinceEpoch(
                                          value.toInt());
                                  return Padding(
                                    padding: const EdgeInsets.only(top: 8.0),
                                    child: Text(
                                      DateFormat('d MMM').format(date),
                                      style: TextStyle(
                                        color: Colors.white.withOpacity(0.3),
                                        fontSize: 10,
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                          borderData: FlBorderData(show: false),
                          minX: spots.first.x,
                          maxX: spots.last.x,
                          minY: minY - padding,
                          maxY: maxY + padding,
                          lineBarsData: [
                            LineChartBarData(
                              spots: spots,
                              isCurved: true,
                              curveSmoothness: 0.25,
                              color: const Color(0xFF00B4D8),
                              barWidth: 2,
                              isStrokeCapRound: true,
                              dotData: const FlDotData(show: false),
                              belowBarData: BarAreaData(
                                show: true,
                                gradient: LinearGradient(
                                  colors: [
                                    const Color(0xFF00B4D8).withOpacity(0.15),
                                    const Color(0xFF00B4D8).withOpacity(0.0),
                                  ],
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                ),
                              ),
                            ),
                          ],
                          lineTouchData: LineTouchData(
                            touchTooltipData: LineTouchTooltipData(
                              tooltipRoundedRadius: 8,
                              tooltipPadding: const EdgeInsets.all(12),
                              tooltipMargin: 8,
                              getTooltipItems: (touchedSpots) {
                                return touchedSpots
                                    .map((LineBarSpot touchedSpot) {
                                  final date =
                                      DateTime.fromMillisecondsSinceEpoch(
                                          touchedSpot.x.toInt());
                                  return LineTooltipItem(
                                    "${DateFormat('MMM d, yyyy').format(date)}\n",
                                    const TextStyle(
                                        color: Colors.white70, fontSize: 10),
                                    children: [
                                      TextSpan(
                                        text: NumberFormat.currency(
                                                locale: 'en_IN', symbol: '₹')
                                            .format(touchedSpot.y),
                                        style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ],
                                  );
                                }).toList();
                              },
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  List<FlSpot> _generateBalanceHistory(double currentBalance,
      List<ExpenseTransactionModel> transactions, DateTime startDate) {
    final sortedTxns = List<ExpenseTransactionModel>.from(transactions)
      ..sort((a, b) => b.date.compareTo(a.date));

    Map<int, double> dailyBalances = {};
    DateTime toMidnight(DateTime d) => DateTime(d.year, d.month, d.day);

    double runningBalance = currentBalance;
    final now = DateTime.now();

    dailyBalances[toMidnight(now).millisecondsSinceEpoch] = runningBalance;

    final cutoff = startDate.subtract(const Duration(days: 1));

    for (var txn in sortedTxns) {
      final txnDate = txn.date;
      if (txnDate.isBefore(cutoff)) break;

      if (txn.type == 'Income') {
        runningBalance -= txn.amount;
      } else if (txn.type == 'Expense') {
        runningBalance += txn.amount;
      } else if (txn.type == 'Transfer In') {
        runningBalance -= txn.amount;
      } else if (txn.type == 'Transfer Out') {
        runningBalance += txn.amount;
      }

      dailyBalances[toMidnight(txnDate.subtract(const Duration(days: 1)))
          .millisecondsSinceEpoch] = runningBalance;
    }

    final startMillis = startDate.millisecondsSinceEpoch;
    final List<FlSpot> spots = dailyBalances.entries
        .where((e) => e.key >= startMillis)
        .map((e) => FlSpot(e.key.toDouble(), e.value))
        .toList();

    spots.sort((a, b) => a.x.compareTo(b.x));

    if (spots.length == 1) {
      spots.insert(0, FlSpot(startMillis.toDouble(), spots.first.y));
    } else if (spots.isNotEmpty && spots.first.x > startMillis) {
      spots.insert(0, FlSpot(startMillis.toDouble(), spots.first.y));
    }

    return spots;
  }

  Widget _buildRangeSelector() {
    final ranges = ['1W', '1M', '3M', '6M', '1Y', 'ALL'];
    return Container(
      height: 28,
      constraints: const BoxConstraints(maxWidth: 200),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(4),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: ranges.map((range) {
            final isSelected = _selectedRange == range;
            return GestureDetector(
              onTap: () => setState(() => _selectedRange = range),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: isSelected
                      ? Colors.white.withOpacity(0.1)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  range,
                  style: TextStyle(
                    color:
                        isSelected ? const Color(0xFF00B4D8) : Colors.white38,
                    fontSize: 10,
                    fontWeight:
                        isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildAccountFilter(List<ExpenseAccountModel> accounts) {
    return Container(
      height: 28,
      constraints: const BoxConstraints(maxWidth: 150),
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String?>(
          value: _selectedAccountId,
          dropdownColor: const Color(0xFF1B263B),
          icon: const Icon(Icons.filter_list_rounded,
              color: Colors.white54, size: 14),
          style: const TextStyle(color: Colors.white, fontSize: 11),
          isDense: true,
          isExpanded: true,
          hint: const Text(
            "All Accounts",
            style: TextStyle(color: Colors.white70, fontSize: 11),
            overflow: TextOverflow.ellipsis,
          ),
          items: [
            const DropdownMenuItem<String?>(
              value: null,
              child: Text("All Accounts"),
            ),
            ...accounts.map((acc) => DropdownMenuItem(
                  value: acc.id,
                  child: Text(
                    "${acc.name} ( ${acc.bankName} )",
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                )),
          ],
          onChanged: (val) {
            setState(() => _selectedAccountId = val);
          },
        ),
      ),
    );
  }
}
