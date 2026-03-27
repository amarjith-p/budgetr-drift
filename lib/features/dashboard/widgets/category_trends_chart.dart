// lib/features/dashboard/widgets/category_trends_chart.dart
import 'package:budget/core/database/app_database.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../core/design/budgetr_colors.dart';
import '../../../core/design/budgetr_styles.dart';

class CategoryTrendsChart extends StatefulWidget {
  final CategoryBudget budget;
  final List<ExpenseTransaction> transactions;

  const CategoryTrendsChart({
    super.key,
    required this.budget,
    required this.transactions,
  });

  @override
  State<CategoryTrendsChart> createState() => _CategoryTrendsChartState();
}

class _CategoryTrendsChartState extends State<CategoryTrendsChart> {
  late List<FlSpot> _actualSpots;
  late List<FlSpot> _projectedSpots;

  double _maxY = 0;
  double _totalSpent = 0;
  double _projectedTotal = 0;
  double _avgDailySpend = 0;
  double _remainingBudget = 0;
  double _recommendedDaily = 0;

  int _daysInPeriod = 30;
  int? _overspendDate;

  @override
  void initState() {
    super.initState();
    _processData();
  }

  @override
  void didUpdateWidget(covariant CategoryTrendsChart oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.transactions != widget.transactions ||
        oldWidget.budget != widget.budget) {
      _processData();
    }
  }

  void _processData() {
    // Total days in this custom budget
    _daysInPeriod =
        widget.budget.endDate.difference(widget.budget.startDate).inDays + 1;

    final Map<int, double> dailyTotals = {};
    _totalSpent = 0;

    for (var txn in widget.transactions) {
      final dayIndex = txn.date.difference(widget.budget.startDate).inDays + 1;
      if (dayIndex > 0 && dayIndex <= _daysInPeriod) {
        dailyTotals[dayIndex] = (dailyTotals[dayIndex] ?? 0) + txn.amount;
        _totalSpent += txn.amount;
      }
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
    final bool isCurrentPeriod = now.isAfter(
            widget.budget.startDate.subtract(const Duration(days: 1))) &&
        now.isBefore(widget.budget.endDate.add(const Duration(days: 1)));

    int today = 0;
    if (isCurrentPeriod) {
      today = now.difference(widget.budget.startDate).inDays + 1;
    } else if (now.isAfter(widget.budget.endDate)) {
      today = _daysInPeriod;
    }

    if (widget.budget.amount > 0) {
      _remainingBudget = widget.budget.amount - _totalSpent;
      final int remainingDays = _daysInPeriod - today;
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
    if (isCurrentPeriod && today < _daysInPeriod && runningTotal > 0) {
      _avgDailySpend = runningTotal / today;
      _projectedTotal = _avgDailySpend * _daysInPeriod;

      double projectedRunning = runningTotal;
      _projectedSpots.add(FlSpot(today.toDouble(), projectedRunning));

      bool crossed = false;
      if (projectedRunning > widget.budget.amount) crossed = true;

      for (int i = today + 1; i <= _daysInPeriod; i++) {
        projectedRunning += _avgDailySpend;
        _projectedSpots.add(FlSpot(i.toDouble(), projectedRunning));
        if (projectedRunning > _maxY) _maxY = projectedRunning;

        if (!crossed &&
            widget.budget.amount > 0 &&
            projectedRunning >= widget.budget.amount) {
          _overspendDate = i;
          crossed = true;
        }
      }
    } else {
      _projectedTotal = _totalSpent;
      if (today > 0) _avgDailySpend = _totalSpent / today;
    }

    // 3. Adjust Y-Axis
    if (widget.budget.amount > 0) {
      if (widget.budget.amount > _maxY) _maxY = widget.budget.amount;
    }
    if (_maxY == 0) _maxY = 1000;
    _maxY = _maxY * 1.25;
  }

  @override
  Widget build(BuildContext context) {
    final fullCurrency =
        NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: 2);
    final currencyFormat =
        NumberFormat.compactSimpleCurrency(locale: 'en_IN', name: '₹');

    final bool isTotalOverLimit =
        widget.budget.amount > 0 && _totalSpent > widget.budget.amount;
    final bool isProjectedOverLimit =
        widget.budget.amount > 0 && _projectedTotal > widget.budget.amount;

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
    final Color remainingColor =
        _remainingBudget < 0 ? Colors.redAccent : BudgetrColors.success;
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
          // Row 1: Totals
          Row(
            children: [
              Expanded(
                  child: _buildInfoItem("CURRENT TOTAL",
                      fullCurrency.format(_totalSpent), totalTextColor)),
              Expanded(
                  child: _buildInfoItem("BUDGET LIMIT",
                      fullCurrency.format(widget.budget.amount), Colors.white70,
                      crossAlign: CrossAxisAlignment.end)),
            ],
          ),
          const SizedBox(height: 16),
          // Row 2: Planning
          if (widget.budget.amount > 0) ...[
            Row(
              children: [
                Expanded(
                    child: _buildInfoItem("REMAINING",
                        fullCurrency.format(_remainingBudget), remainingColor)),
                Expanded(
                    child: _buildInfoItem(
                        "REC. DAILY SPEND",
                        fullCurrency.format(_recommendedDaily),
                        recommendedColor,
                        crossAlign: CrossAxisAlignment.end)),
              ],
            ),
            const SizedBox(height: 16),
          ],
          // Row 3: Trends
          Row(
            children: [
              Expanded(
                  child: _buildInfoItem("DAILY AVERAGE",
                      fullCurrency.format(_avgDailySpend), avgTextColor)),
              Expanded(
                  child: _buildInfoItem("PROJECTED SPEND",
                      fullCurrency.format(_projectedTotal), projectedTextColor,
                      crossAlign: CrossAxisAlignment.end)),
            ],
          ),
          const SizedBox(height: 24),

          // OVERSPEND ALERT
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
                  const Icon(Icons.warning_amber_rounded,
                      color: Colors.redAccent, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: RichText(
                      text: TextSpan(
                        children: [
                          const TextSpan(
                              text: "Projected to cross budget on ",
                              style: TextStyle(
                                  color: Colors.redAccent, fontSize: 12)),
                          TextSpan(
                            text: DateFormat('MMM d').format(widget
                                .budget.startDate
                                .add(Duration(days: _overspendDate! - 1))),
                            style: const TextStyle(
                                color: Colors.redAccent,
                                fontWeight: FontWeight.bold,
                                fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],

          // CHART
          SizedBox(
            height: 220,
            child: LineChart(
              LineChartData(
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: _maxY / 5,
                  getDrawingHorizontalLine: (value) => FlLine(
                      color: Colors.white.withOpacity(0.05), strokeWidth: 1),
                ),
                titlesData: FlTitlesData(
                  show: true,
                  rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                  topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 30,
                      interval: (_daysInPeriod / 5).ceilToDouble(),
                      getTitlesWidget: (value, meta) {
                        if (value <= 0 || value > _daysInPeriod)
                          return const SizedBox.shrink();

                        // [NEW] Map the X-axis number back to the actual Calendar Date
                        final dateForTick = widget.budget.startDate
                            .add(Duration(days: value.toInt() - 1));
                        final dateStr = DateFormat('MMM d').format(dateForTick);

                        return Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Text(
                            dateStr,
                            style: TextStyle(
                                color: Colors.white.withOpacity(0.5),
                                fontSize: 10),
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
                        return Text(currencyFormat.format(value),
                            style: TextStyle(
                                color: Colors.white.withOpacity(0.5),
                                fontSize: 10));
                      },
                    ),
                  ),
                ),
                borderData: FlBorderData(show: false),
                minX: 1,
                maxX: _daysInPeriod.toDouble(),
                minY: 0,
                maxY: _maxY,
                extraLinesData: ExtraLinesData(
                  horizontalLines: [
                    if (widget.budget.amount > 0)
                      HorizontalLine(
                        y: widget.budget.amount,
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
                                fontWeight: FontWeight.bold),
                            labelResolver: (line) => "LIMIT"),
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
                                fontWeight: FontWeight.bold),
                            labelResolver: (line) => "CRITICAL"),
                      ),
                  ],
                ),
                lineBarsData: [
                  if (_projectedSpots.isNotEmpty)
                    LineChartBarData(
                      spots: _projectedSpots,
                      isCurved: true,
                      color: projectedColor,
                      barWidth: 2,
                      isStrokeCapRound: true,
                      dotData: FlDotData(
                        show: true,
                        checkToShowDot: (spot, barData) =>
                            _overspendDate != null && spot.x == _overspendDate,
                        getDotPainter: (spot, percent, barData, index) =>
                            FlDotCirclePainter(
                                radius: 4,
                                color: Colors.redAccent,
                                strokeWidth: 2,
                                strokeColor: Colors.white),
                      ),
                      dashArray: [4, 4],
                    ),
                  LineChartBarData(
                    spots: _actualSpots,
                    isCurved: true,
                    curveSmoothness: 0.2,
                    color: actualColor,
                    barWidth: 3,
                    isStrokeCapRound: true,
                    dotData: FlDotData(
                      show: true,
                      checkToShowDot: (spot, barData) =>
                          spot.x == _actualSpots.last.x,
                      getDotPainter: (spot, percent, barData, index) =>
                          FlDotCirclePainter(
                              radius: 4,
                              color: Colors.white,
                              strokeWidth: 2,
                              strokeColor: actualColor),
                    ),
                    belowBarData: BarAreaData(
                      show: true,
                      gradient: LinearGradient(
                        colors: [
                          actualColor.withOpacity(0.3),
                          actualColor.withOpacity(0.0)
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
                        final dateStr = DateFormat('MMM d').format(widget
                            .budget.startDate
                            .add(Duration(days: touchedSpot.x.toInt() - 1)));
                        final amount = touchedSpot.y;

                        return LineTooltipItem(
                          '$dateStr\n',
                          const TextStyle(
                              color: Colors.white70,
                              fontSize: 12,
                              fontWeight: FontWeight.w500),
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
  }

  Widget _buildInfoItem(String title, String value, Color valueColor,
      {CrossAxisAlignment crossAlign = CrossAxisAlignment.start}) {
    return Column(
      crossAxisAlignment: crossAlign,
      children: [
        Text(title, style: BudgetrStyles.caption.copyWith(fontSize: 10)),
        const SizedBox(height: 4),
        Text(value,
            style: TextStyle(
                color: valueColor, fontSize: 16, fontWeight: FontWeight.bold)),
      ],
    );
  }
}
