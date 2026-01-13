import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../core/design/budgetr_colors.dart';
import '../../../core/design/budgetr_styles.dart';
import '../models/dashboard_transaction.dart';

class BucketTrendsChart extends StatefulWidget {
  final List<DashboardTransaction> transactions;
  final int year;
  final int month;
  final double budgetLimit;

  const BucketTrendsChart({
    super.key,
    required this.transactions,
    required this.year,
    required this.month,
    required this.budgetLimit,
  });

  @override
  State<BucketTrendsChart> createState() => _BucketTrendsChartState();
}

class _BucketTrendsChartState extends State<BucketTrendsChart> {
  late List<FlSpot> _actualSpots;
  late List<FlSpot> _projectedSpots;

  double _maxY = 0;
  double _totalSpent = 0;
  double _projectedTotal = 0;
  double _avgDailySpend = 0;

  // --- NEW VARIABLES ---
  double _remainingBudget = 0;
  double _recommendedDaily = 0;

  int _daysInMonth = 30;
  int? _overspendDate;

  @override
  void initState() {
    super.initState();
    _processData();
  }

  @override
  void didUpdateWidget(covariant BucketTrendsChart oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.transactions != widget.transactions ||
        oldWidget.budgetLimit != widget.budgetLimit) {
      _processData();
    }
  }

  void _processData() {
    _daysInMonth = DateTime(widget.year, widget.month + 1, 0).day;

    final Map<int, double> dailyTotals = {};
    _totalSpent = 0;

    for (var txn in widget.transactions) {
      final day = txn.date.day;
      final amount = txn.amount;
      dailyTotals[day] = (dailyTotals[day] ?? 0) + amount;
      _totalSpent += amount;
    }

    _actualSpots = [];
    _projectedSpots = [];
    _maxY = 0;
    _overspendDate = null;
    _avgDailySpend = 0;
    _projectedTotal = 0;
    _remainingBudget = 0;
    _recommendedDaily = 0;

    final now = DateTime.now();
    final isCurrentMonth = now.year == widget.year && now.month == widget.month;
    final int today = isCurrentMonth ? now.day : _daysInMonth;

    // --- NEW: Calculate Remaining & Recommended ---
    if (widget.budgetLimit > 0) {
      _remainingBudget = widget.budgetLimit - _totalSpent;

      // Calculate remaining days in the month
      final int remainingDays = _daysInMonth - today;

      if (_remainingBudget > 0 && remainingDays > 0) {
        _recommendedDaily = _remainingBudget / remainingDays;
      }
    }

    // 1. Build Actual Spending Line (Cumulative)
    double runningTotal = 0;
    for (int i = 1; i <= today; i++) {
      final dailyAmount = dailyTotals[i] ?? 0.0;
      runningTotal += dailyAmount;
      _actualSpots.add(FlSpot(i.toDouble(), runningTotal));
      if (runningTotal > _maxY) _maxY = runningTotal;
    }

    // 2. Build Projection
    if (isCurrentMonth && today < _daysInMonth && runningTotal > 0) {
      // Calculate Average Daily Spend
      _avgDailySpend = runningTotal / today;
      _projectedTotal = _avgDailySpend * _daysInMonth;

      double projectedRunning = runningTotal;
      _projectedSpots.add(FlSpot(today.toDouble(), projectedRunning));

      bool crossed = false;
      if (projectedRunning > widget.budgetLimit) crossed = true;

      for (int i = today + 1; i <= _daysInMonth; i++) {
        projectedRunning += _avgDailySpend;
        _projectedSpots.add(FlSpot(i.toDouble(), projectedRunning));

        if (projectedRunning > _maxY) _maxY = projectedRunning;

        if (!crossed &&
            widget.budgetLimit > 0 &&
            projectedRunning >= widget.budgetLimit) {
          _overspendDate = i;
          crossed = true;
        }
      }
    } else {
      // Past month or no spending yet
      _projectedTotal = _totalSpent;
      if (today > 0) {
        _avgDailySpend = _totalSpent / today;
      }
    }

    // 3. Adjust Y-Axis
    if (widget.budgetLimit > 0) {
      if (widget.budgetLimit > _maxY) _maxY = widget.budgetLimit;
    }

    if (_maxY == 0) _maxY = 1000;
    _maxY = _maxY * 1.25;
  }

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.compactSimpleCurrency(
      locale: 'en_IN',
      name: '₹',
    );
    final fullCurrency = NumberFormat.currency(
      locale: 'en_IN',
      symbol: '₹',
      decimalDigits: 2,
    );

    // --- Color Logic ---
    final bool isTotalOverLimit =
        widget.budgetLimit > 0 && _totalSpent > widget.budgetLimit;

    final bool isProjectedOverLimit =
        widget.budgetLimit > 0 && _projectedTotal > widget.budgetLimit;

    // Colors
    final Color actualColor =
        isTotalOverLimit ? Colors.redAccent : BudgetrColors.accent;
    final Color projectedColor = isProjectedOverLimit
        ? Colors.redAccent.withOpacity(0.5)
        : Colors.white.withOpacity(0.3);

    final Color totalTextColor =
        isTotalOverLimit ? Colors.redAccent : Colors.white;
    final Color projectedTextColor = isProjectedOverLimit
        ? Colors.redAccent
        : BudgetrColors.accent.withOpacity(0.7);
    final Color avgTextColor =
        isProjectedOverLimit ? Colors.redAccent : BudgetrColors.accent;

    // --- NEW Color Logic ---
    final Color remainingColor = _remainingBudget < 0
        ? Colors.redAccent
        : BudgetrColors.success; // Green if positive, Red if negative

    final Color recommendedColor = Colors.white70;

    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: BudgetrColors.cardSurface.withOpacity(0.5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // --- HEADER GRID (Now 3x2) ---

          // Row 1: Totals
          Row(
            children: [
              Expanded(
                child: _buildInfoItem(
                  "CURRENT TOTAL",
                  fullCurrency.format(_totalSpent),
                  totalTextColor,
                ),
              ),
              Expanded(
                child: _buildInfoItem(
                  "BUDGET LIMIT",
                  fullCurrency.format(widget.budgetLimit),
                  Colors.white70,
                  crossAlign: CrossAxisAlignment.end,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Row 2: Planning (NEW)
          if (widget.budgetLimit > 0) ...[
            Row(
              children: [
                Expanded(
                  child: _buildInfoItem(
                    "REMAINING",
                    fullCurrency.format(_remainingBudget),
                    remainingColor,
                  ),
                ),
                Expanded(
                  child: _buildInfoItem(
                    "REC. DAILY SPEND",
                    fullCurrency.format(_recommendedDaily),
                    recommendedColor,
                    crossAlign: CrossAxisAlignment.end,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
          ],

          // Row 3: Trends
          Row(
            children: [
              Expanded(
                child: _buildInfoItem(
                  "DAILY AVERAGE",
                  fullCurrency.format(_avgDailySpend),
                  avgTextColor,
                ),
              ),
              Expanded(
                child: _buildInfoItem(
                  "PROJECTED SPEND",
                  fullCurrency.format(_projectedTotal),
                  projectedTextColor,
                  crossAlign: CrossAxisAlignment.end,
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // --- OVERSPEND ALERT ---
          if (_overspendDate != null) ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              margin: const EdgeInsets.only(bottom: 24),
              decoration: BoxDecoration(
                color: Colors.redAccent.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.redAccent.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.warning_amber_rounded,
                    color: Colors.redAccent,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: RichText(
                      text: TextSpan(
                        children: [
                          const TextSpan(
                            text: "Projected to cross budget on ",
                            style: TextStyle(
                              color: Colors.redAccent,
                              fontSize: 12,
                            ),
                          ),
                          TextSpan(
                            text:
                                "${DateFormat('MMM').format(DateTime(widget.year, widget.month))} $_overspendDate",
                            style: const TextStyle(
                              color: Colors.redAccent,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],

          // --- CHART ---
          SizedBox(
            height: 220,
            child: LineChart(
              LineChartData(
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: _maxY / 5,
                  getDrawingHorizontalLine: (value) {
                    return FlLine(
                      color: Colors.white.withOpacity(0.05),
                      strokeWidth: 1,
                    );
                  },
                ),
                titlesData: FlTitlesData(
                  show: true,
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 30,
                      interval: 5,
                      getTitlesWidget: (value, meta) {
                        if (value <= 0 || value > _daysInMonth)
                          return const SizedBox.shrink();
                        return Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Text(
                            "${value.toInt()}",
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.5),
                              fontSize: 12,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 40,
                      interval: _maxY / 5,
                      getTitlesWidget: (value, meta) {
                        if (value == 0) return const SizedBox.shrink();
                        return Text(
                          currencyFormat.format(value),
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.5),
                            fontSize: 10,
                          ),
                        );
                      },
                    ),
                  ),
                ),
                borderData: FlBorderData(show: false),
                minX: 1,
                maxX: _daysInMonth.toDouble(),
                minY: 0,
                maxY: _maxY,
                extraLinesData: ExtraLinesData(
                  horizontalLines: [
                    if (widget.budgetLimit > 0)
                      HorizontalLine(
                        y: widget.budgetLimit,
                        color: Colors.white.withOpacity(0.3),
                        strokeWidth: 1,
                        dashArray: [5, 5],
                        label: HorizontalLineLabel(
                          show: true,
                          alignment: Alignment.topRight,
                          padding: const EdgeInsets.only(right: 5, bottom: 2),
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.5),
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                          labelResolver: (line) => "LIMIT",
                        ),
                      ),
                  ],
                  verticalLines: [
                    if (_overspendDate != null)
                      VerticalLine(
                        x: _overspendDate!.toDouble(),
                        color: Colors.redAccent.withOpacity(0.8),
                        strokeWidth: 1,
                        dashArray: [2, 2],
                        label: VerticalLineLabel(
                          show: true,
                          alignment: Alignment.topCenter,
                          padding: const EdgeInsets.only(top: 2),
                          style: const TextStyle(
                            color: Colors.redAccent,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                          labelResolver: (line) => "CRITICAL",
                        ),
                      ),
                  ],
                ),
                lineBarsData: [
                  // Projection
                  if (_projectedSpots.isNotEmpty)
                    LineChartBarData(
                      spots: _projectedSpots,
                      isCurved: true,
                      color: projectedColor, // Conditional Color
                      barWidth: 2,
                      isStrokeCapRound: true,
                      dotData: FlDotData(
                        show: true,
                        checkToShowDot: (spot, barData) {
                          return _overspendDate != null &&
                              spot.x == _overspendDate;
                        },
                        getDotPainter: (spot, percent, barData, index) {
                          return FlDotCirclePainter(
                            radius: 4,
                            color: Colors.redAccent,
                            strokeWidth: 2,
                            strokeColor: Colors.white,
                          );
                        },
                      ),
                      dashArray: [4, 4],
                    ),

                  // Actual
                  LineChartBarData(
                    spots: _actualSpots,
                    isCurved: true,
                    curveSmoothness: 0.2,
                    color: actualColor, // Conditional Color
                    barWidth: 3,
                    isStrokeCapRound: true,
                    dotData: FlDotData(
                      show: true,
                      checkToShowDot: (spot, barData) {
                        return spot.x == _actualSpots.last.x;
                      },
                      getDotPainter: (spot, percent, barData, index) {
                        return FlDotCirclePainter(
                          radius: 4,
                          color: Colors.white,
                          strokeWidth: 2,
                          strokeColor: actualColor, // Match line color
                        );
                      },
                    ),
                    belowBarData: BarAreaData(
                      show: true,
                      gradient: LinearGradient(
                        colors: [
                          actualColor.withOpacity(0.3),
                          actualColor.withOpacity(0.0),
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
                    tooltipMargin: 16,
                    getTooltipItems: (touchedSpots) {
                      return touchedSpots.map((LineBarSpot touchedSpot) {
                        final isProjection = touchedSpot.barIndex == 0 &&
                            _projectedSpots.isNotEmpty;
                        final date = touchedSpot.x.toInt();
                        final amount = touchedSpot.y;

                        return LineTooltipItem(
                          '${DateFormat('MMM').format(DateTime(widget.year, widget.month))} $date\n',
                          const TextStyle(
                            color: Colors.white70,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                          children: [
                            TextSpan(
                              text: isProjection
                                  ? "Projected: ${fullCurrency.format(amount)}"
                                  : "Total: ${fullCurrency.format(amount)}",
                              style: TextStyle(
                                color: isProjection
                                    ? Colors.white70
                                    : Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
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
  }

  Widget _buildInfoItem(
    String title,
    String value,
    Color valueColor, {
    CrossAxisAlignment crossAlign = CrossAxisAlignment.start,
  }) {
    return Column(
      crossAxisAlignment: crossAlign,
      children: [
        Text(title, style: BudgetrStyles.caption.copyWith(fontSize: 10)),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            color: valueColor,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
