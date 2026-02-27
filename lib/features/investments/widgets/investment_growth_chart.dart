import 'dart:math';
import 'package:budget/core/design/budgetr_colors.dart';
import 'package:budget/core/widgets/glass_card.dart';
import 'package:budget/features/investments/models/investment_log_dto.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class InvestmentGrowthChart extends StatelessWidget {
  final List<InvestmentLogDto> logs;
  final bool embedded;

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

    final double minY = spots.map((e) => e.y).reduce(min);
    final double maxY = spots.map((e) => e.y).reduce(max);

    final double yRange = maxY - minY;
    final double effectiveRange = yRange == 0 ? maxY * 0.1 : yRange;

    // Buffers to ensure the line doesn't hit the absolute top or bottom
    final double yTopBuffer = effectiveRange * 0.25;
    final double yBottomBuffer = effectiveRange * 0.10;

    final chartContent = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (!embedded)
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
          height: 220,
          child: LineChart(
            LineChartData(
              gridData: FlGridData(
                show: true,
                drawVerticalLine: true,
                getDrawingHorizontalLine: (value) => FlLine(
                  color: Colors.white.withOpacity(0.05),
                  strokeWidth: 1,
                  dashArray: [5, 5],
                ),
                getDrawingVerticalLine: (value) => FlLine(
                  color: Colors.white.withOpacity(0.02),
                  strokeWidth: 1,
                  dashArray: [5, 5],
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
                    // Reduced reserved space since we are using compact forms (K/L/Cr)
                    reservedSize: 45,
                    getTitlesWidget: (value, meta) {
                      if (value == meta.max || value == meta.min)
                        return const SizedBox.shrink();

                      return Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: Text(
                          _formatAxisCurrency(
                              value), // [NEW] Compact format for axis
                          style: const TextStyle(
                            color: Colors.white38,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 1,
                          textAlign: TextAlign.right,
                        ),
                      );
                    },
                  ),
                ),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 30,
                    getTitlesWidget: (value, meta) {
                      if (value == meta.min || value == meta.max)
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
              minY: minY - yBottomBuffer,
              maxY: maxY + yTopBuffer,
              lineBarsData: [
                LineChartBarData(
                  spots: spots,
                  isCurved: true,
                  curveSmoothness: 0.35,
                  // [NEW] Professional Gradient Line
                  gradient: LinearGradient(
                    colors: [
                      BudgetrColors.accent.withOpacity(0.5),
                      BudgetrColors.accent,
                    ],
                  ),
                  barWidth: 3,
                  isStrokeCapRound: true,
                  dotData: const FlDotData(show: false),
                  // [NEW] Glowing neon shadow effect
                  shadow: Shadow(
                    color: BudgetrColors.accent.withOpacity(0.4),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                  belowBarData: BarAreaData(
                    show: true,
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        BudgetrColors.accent.withOpacity(0.3),
                        BudgetrColors.accent.withOpacity(0.0),
                      ],
                    ),
                  ),
                ),
              ],
              lineTouchData: LineTouchData(
                handleBuiltInTouches: true,
                touchTooltipData: LineTouchTooltipData(
                  // [NEW] Prevents tooltips from clipping out of the screen
                  fitInsideHorizontally: true,
                  fitInsideVertically: true,
                  // [NEW] Premium Glass Tooltip Design
                  getTooltipColor: (_) =>
                      const Color(0xFF1B263B).withOpacity(0.9),
                  tooltipRoundedRadius: 12,
                  tooltipPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  tooltipBorder: BorderSide(
                      color: Colors.white.withOpacity(0.1), width: 1),
                  getTooltipItems: (touchedSpots) {
                    return touchedSpots.map((spot) {
                      final date =
                          DateTime.fromMillisecondsSinceEpoch(spot.x.toInt());
                      return LineTooltipItem(
                        "${DateFormat('dd MMM yyyy').format(date)}\n",
                        const TextStyle(
                          color: Colors.white54,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                        children: [
                          TextSpan(
                            text: _formatExactCurrency(
                                spot.y), // [NEW] Exact 2 decimal value on touch
                            style: const TextStyle(
                              color: BudgetrColors.accent,
                              fontSize: 15,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      );
                    }).toList();
                  },
                ),
                // [NEW] Professional crosshair dot indicator
                getTouchedSpotIndicator:
                    (LineChartBarData barData, List<int> spotIndexes) {
                  return spotIndexes.map((spotIndex) {
                    return TouchedSpotIndicatorData(
                      FlLine(
                          color: Colors.white38,
                          strokeWidth: 1.5,
                          dashArray: [4, 4]),
                      FlDotData(
                        getDotPainter: (spot, percent, barData, index) {
                          return FlDotCirclePainter(
                            radius: 5,
                            color: const Color(0xFF1B263B), // Hollow center
                            strokeWidth: 2,
                            strokeColor: BudgetrColors.accent, // Colored rim
                          );
                        },
                      ),
                    );
                  }).toList();
                },
              ),
            ),
          ),
        ),
      ],
    );

    if (embedded) {
      return chartContent;
    }

    return GlassCard(
      borderRadius: 16,
      padding: const EdgeInsets.fromLTRB(16, 24, 24, 16),
      child: chartContent,
    );
  }

  // --- FORMATTERS ---

  // Exact 2-decimal format for the Tooltip
  String _formatExactCurrency(double value) {
    return NumberFormat.currency(symbol: '₹', decimalDigits: 2, locale: 'en_IN')
        .format(value);
  }

  // Smart compact format for the Y-Axis (e.g. 1.5L, 50k)
  String _formatAxisCurrency(double value) {
    if (value >= 10000000) {
      return '₹${(value / 10000000).toStringAsFixed(1).replaceAll(RegExp(r'\.0$'), '')}Cr';
    }
    if (value >= 100000) {
      return '₹${(value / 100000).toStringAsFixed(1).replaceAll(RegExp(r'\.0$'), '')}L';
    }
    if (value >= 1000) {
      return '₹${(value / 1000).toStringAsFixed(1).replaceAll(RegExp(r'\.0$'), '')}k';
    }
    return '₹${value.toInt()}';
  }
}
