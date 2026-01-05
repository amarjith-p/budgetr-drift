import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
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
  final ExpenseService _service = ExpenseService();

  // Streams initialized once to prevent rebuilding loop
  late Stream<List<ExpenseAccountModel>> _accountsStream;
  late Stream<List<ExpenseTransactionModel>> _transactionsStream;

  String _selectedRange = '1M';

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
        // We calculate balance but don't block UI if loading,
        // to allow inner stream to listen effectively.
        final double currentTotalBalance = (accSnapshot.data ?? [])
            .fold(0.0, (sum, item) => sum + item.currentBalance);

        return StreamBuilder<List<ExpenseTransactionModel>>(
          stream: _transactionsStream,
          builder: (context, txnSnapshot) {
            // Wait for both to have data to avoid jumping
            if (!accSnapshot.hasData || !txnSnapshot.hasData) {
              return const SizedBox(
                  height: 200, child: Center(child: ModernLoader()));
            }

            final List<FlSpot> spots = _generateBalanceHistory(
              currentTotalBalance,
              txnSnapshot.data!,
              _getStartDate(),
            );

            if (spots.isEmpty) return const SizedBox.shrink();

            // Dynamic Y-Axis Scaling
            final double minY = spots.map((e) => e.y).min;
            final double maxY = spots.map((e) => e.y).max;
            double range = maxY - minY;
            if (range == 0) range = maxY == 0 ? 100 : maxY * 0.2;

            final double padding = range * 0.1;

            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFF151D29),
                borderRadius: BorderRadius.circular(24),
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
                  // --- Header ---
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "BALANCE TREND",
                            style: TextStyle(
                              color: Colors.white54,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.5,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            NumberFormat.currency(
                                    locale: 'en_IN',
                                    symbol: '₹',
                                    decimalDigits: 2)
                                .format(currentTotalBalance),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      _buildRangeSelector(),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // --- Chart ---
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
                          // Y-Axis
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
                          // X-Axis
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

  // --- OPTIMIZED GENERATOR ---
  List<FlSpot> _generateBalanceHistory(double currentBalance,
      List<ExpenseTransactionModel> transactions, DateTime startDate) {
    // Sort Newest -> Oldest
    final sortedTxns = List<ExpenseTransactionModel>.from(transactions)
      ..sort((a, b) => b.date.compareTo(a.date));

    Map<int, double> dailyBalances = {};
    DateTime toMidnight(DateTime d) => DateTime(d.year, d.month, d.day);

    double runningBalance = currentBalance;
    final now = DateTime.now();

    // Point 1: Today (Current Balance)
    dailyBalances[toMidnight(now).millisecondsSinceEpoch] = runningBalance;

    // Cutoff date for optimization (include buffer)
    final cutoff = startDate.subtract(const Duration(days: 1));

    for (var txn in sortedTxns) {
      final txnDate = txn.date.toDate();

      // Optimization: If txn is older than start date, stop processing
      // We already have the balance curve for [startDate -> Now]
      if (txnDate.isBefore(cutoff)) break;

      // Reverse Math: To go back in time, undo the transaction
      if (txn.type == 'Income') {
        runningBalance -= txn.amount;
      } else if (txn.type == 'Expense') {
        runningBalance += txn.amount;
      } else if (txn.type == 'Transfer In') {
        runningBalance -= txn.amount;
      } else if (txn.type == 'Transfer Out') {
        runningBalance += txn.amount;
      }

      // Store the balance at the end of the *previous* day relative to this txn
      dailyBalances[toMidnight(txnDate.subtract(const Duration(days: 1)))
          .millisecondsSinceEpoch] = runningBalance;
    }

    // Convert to Spots and ensure order
    final startMillis = startDate.millisecondsSinceEpoch;
    final List<FlSpot> spots = dailyBalances.entries
        .where((e) => e.key >= startMillis)
        .map((e) => FlSpot(e.key.toDouble(), e.value))
        .toList();

    spots.sort((a, b) => a.x.compareTo(b.x));

    // Fix: If only 1 spot (Today) exists (e.g. no recent transactions),
    // add a start point with the same balance to draw a flat line.
    if (spots.length == 1) {
      spots.insert(0, FlSpot(startMillis.toDouble(), spots.first.y));
    } else if (spots.isNotEmpty && spots.first.x > startMillis) {
      // Extend line to start date if first transaction is mid-period
      spots.insert(0, FlSpot(startMillis.toDouble(), spots.first.y));
    }

    return spots;
  }

  Widget _buildRangeSelector() {
    final ranges = ['1W', '1M', '3M', '6M', '1Y', 'ALL'];
    return Container(
      height: 28,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: ranges.map((range) {
          final isSelected = _selectedRange == range;
          return GestureDetector(
            onTap: () => setState(() => _selectedRange = range),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: isSelected
                    ? Colors.white.withOpacity(0.1)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                range,
                style: TextStyle(
                  color: isSelected ? const Color(0xFF00B4D8) : Colors.white38,
                  fontSize: 10,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
