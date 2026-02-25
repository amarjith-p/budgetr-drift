import 'package:budget/core/design/budgetr_colors.dart';
import 'package:budget/core/widgets/glass_card.dart';
import 'package:budget/features/investments/models/investment_log_dto.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class InvestmentGrowthChart extends StatelessWidget {
  final List<InvestmentLogDto> logs;
  final bool embedded; // [NEW] Control background

  const InvestmentGrowthChart({
    super.key,
    required this.logs,
    this.embedded = false,
  });

  @override
  Widget build(BuildContext context) {
    if (logs.isEmpty) return const SizedBox.shrink();

    final sortedLogs = List<InvestmentLogDto>.from(logs)
      ..sort((a, b) => a.date.compareTo(b.date));

    if (sortedLogs.length < 2) {
      return const SizedBox.shrink();
    }

    final spots = sortedLogs.map((log) {
      return FlSpot(
          log.date.millisecondsSinceEpoch.toDouble(), log.currentValue);
    }).toList();

    final double minX = spots.first.x;
    final double maxX = spots.last.x;
    final double minY =
        sortedLogs.map((e) => e.currentValue).reduce((a, b) => a < b ? a : b);
    final double maxY =
        sortedLogs.map((e) => e.currentValue).reduce((a, b) => a > b ? a : b);

    final double yBuffer = (maxY - minY) * 0.1;

    // Chart Content
    final chartContent = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (!embedded) // Only show title if standalone
          const Padding(
            padding: EdgeInsets.only(left: 8, bottom: 20),
            child: Text(
              "GROWTH TREND",
              style: TextStyle(
                color: Colors.white38,
                fontSize: 10,
                fontWeight: FontWeight.w900,
                letterSpacing: 1.5,
              ),
            ),
          ),
        SizedBox(
          height: 200,
          child: LineChart(
            LineChartData(
              gridData: FlGridData(
                show: true,
                drawVerticalLine: false,
                horizontalInterval:
                    (maxY - minY) / 4 == 0 ? 1 : (maxY - minY) / 4,
                getDrawingHorizontalLine: (value) => FlLine(
                  color: Colors.white.withOpacity(0.05),
                  strokeWidth: 1,
                ),
              ),
              titlesData: FlTitlesData(
                show: true,
                rightTitles:
                    const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                topTitles:
                    const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 40,
                    interval: (maxY - minY) / 4 == 0 ? 1 : (maxY - minY) / 4,
                    getTitlesWidget: (value, meta) {
                      return Text(
                        _formatCurrencyCompact(value),
                        style: const TextStyle(
                          color: Colors.white38,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      );
                    },
                  ),
                ),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 30,
                    interval: (maxX - minX) / 3,
                    getTitlesWidget: (value, meta) {
                      if (value == minX || value == maxX)
                        return const SizedBox.shrink();
                      final date =
                          DateTime.fromMillisecondsSinceEpoch(value.toInt());
                      return Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Text(
                          DateFormat('MMM dd').format(date),
                          style: const TextStyle(
                            color: Colors.white38,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
              borderData: FlBorderData(show: false),
              minX: minX,
              maxX: maxX,
              minY: minY - yBuffer,
              maxY: maxY + yBuffer,
              lineBarsData: [
                LineChartBarData(
                  spots: spots,
                  isCurved: true,
                  color: BudgetrColors.accent,
                  barWidth: 3,
                  isStrokeCapRound: true,
                  dotData: const FlDotData(show: false),
                  belowBarData: BarAreaData(
                    show: true,
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        BudgetrColors.accent.withOpacity(0.2),
                        BudgetrColors.accent.withOpacity(0.0),
                      ],
                    ),
                  ),
                ),
              ],
              lineTouchData: LineTouchData(
                touchTooltipData: LineTouchTooltipData(
                  getTooltipColor: (_) => const Color(0xFF1B263B),
                  getTooltipItems: (touchedSpots) {
                    return touchedSpots.map((spot) {
                      final date =
                          DateTime.fromMillisecondsSinceEpoch(spot.x.toInt());
                      return LineTooltipItem(
                        "${DateFormat('dd MMM').format(date)}\n",
                        const TextStyle(
                            color: Colors.white70,
                            fontSize: 10,
                            fontWeight: FontWeight.bold),
                        children: [
                          TextSpan(
                            text: "₹${spot.y.toStringAsFixed(2)}",
                            style: const TextStyle(
                                color: Colors.white,
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
    );

    // [NEW] Return logic
    if (embedded) {
      return chartContent;
    }

    return GlassCard(
      borderRadius: 16,
      padding: const EdgeInsets.fromLTRB(16, 24, 24, 16),
      child: chartContent,
    );
  }

  String _formatCurrencyCompact(double value) {
    if (value >= 10000000) return '${(value / 10000000).toStringAsFixed(1)}Cr';
    if (value >= 100000) return '${(value / 100000).toStringAsFixed(1)}L';
    if (value >= 1000) return '${(value / 1000).toStringAsFixed(1)}k';
    return value.toInt().toString();
  }
}
