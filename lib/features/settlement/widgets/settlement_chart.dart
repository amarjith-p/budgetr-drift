import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../core/models/percentage_config_model.dart';
import '../../../core/models/settlement_model.dart';

// --- DESIGN SYSTEM IMPORTS ---
import '../../../core/design/budgetr_colors.dart';
import '../../../core/design/budgetr_styles.dart';

class SettlementChart extends StatelessWidget {
  final Settlement settlement;
  final PercentageConfig? percentageConfig;

  const SettlementChart({
    super.key,
    required this.settlement,
    this.percentageConfig,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(
        16,
        24,
        16,
        16,
      ), // Added top padding for labels
      width: double.infinity,
      decoration: BoxDecoration(
        color: BudgetrColors.cardSurface.withOpacity(0.6),
        borderRadius: BudgetrStyles.radiusM,
        border: BudgetrStyles.glassBorder,
      ),
      child: Column(
        children: [
          SizedBox(height: 300, child: _buildChart(settlement)),
          const SizedBox(height: 16),
          _buildLegend(),
        ],
      ),
    );
  }

  Widget _buildChart(Settlement data) {
    final keys = data.allocations.keys.toList();

    // --- SORTING LOGIC (Preserved) ---
    if (data.bucketOrder.isNotEmpty) {
      keys.sort((a, b) {
        int idxA = data.bucketOrder.indexOf(a);
        int idxB = data.bucketOrder.indexOf(b);
        if (idxA == -1) idxA = 999;
        if (idxB == -1) idxB = 999;
        return idxA.compareTo(idxB);
      });
    } else if (percentageConfig != null) {
      keys.sort((a, b) {
        int idxA = percentageConfig!.categories.indexWhere((c) => c.name == a);
        int idxB = percentageConfig!.categories.indexWhere((c) => c.name == b);
        if (idxA == -1) idxA = 999;
        if (idxB == -1) idxB = 999;
        return idxA.compareTo(idxB);
      });
    } else {
      keys.sort((a, b) {
        final valA = data.allocations[a] ?? 0;
        final valB = data.allocations[b] ?? 0;
        return valB.compareTo(valA);
      });
    }

    // Determine max value for Y-axis scaling
    double maxY = 0;
    for (var key in keys) {
      final allocated = data.allocations[key] ?? 0;
      final spent = data.expenses[key] ?? 0;
      if (allocated > maxY) maxY = allocated;
      if (spent > maxY) maxY = spent;
    }
    maxY = maxY * 1.2; // Buffer
    if (maxY == 0) maxY = 1000;

    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: maxY,
        barTouchData: BarTouchData(
          touchTooltipData: BarTouchTooltipData(
            getTooltipColor: (_) => BudgetrColors.cardSurface.withOpacity(0.9),
            getTooltipItem: (group, groupIndex, rod, rodIndex) {
              final key = keys[groupIndex];
              final isAllocated = rodIndex == 0;
              final value = rod.toY;
              return BarTooltipItem(
                '$key\n',
                const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
                children: [
                  TextSpan(
                    text: isAllocated ? 'Allocated: ' : 'Spent: ',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.7),
                      fontSize: 12,
                    ),
                  ),
                  TextSpan(
                    text: NumberFormat.currency(
                      locale: 'en_IN',
                      symbol: '₹',
                      decimalDigits: 0,
                    ).format(value),
                    style: TextStyle(
                      color: isAllocated
                          ? BudgetrColors.accent
                          : const Color(0xFFFF006E),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              );
            },
          ),
        ),
        titlesData: FlTitlesData(
          show: true,
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          // --- UPDATED: Show Left Y-Axis Titles ---
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 40, // Reserve space for the labels
              getTitlesWidget: (value, meta) {
                if (value == 0) return const SizedBox.shrink();
                return SideTitleWidget(
                  axisSide: meta.axisSide,
                  child: Text(
                    NumberFormat.compactCurrency(
                      locale: 'en_IN',
                      symbol: '',
                      decimalDigits: 0,
                    ).format(value),
                    style: BudgetrStyles.caption.copyWith(
                      fontSize: 10,
                      color: Colors.white.withOpacity(0.5),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                );
              },
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 40, // Reduced height since text is shorter
              getTitlesWidget: (value, meta) {
                final index = value.toInt();
                if (index >= 0 && index < keys.length) {
                  String text = keys[index];

                  // [UPDATED] Strict truncation to first 4 characters
                  if (text.length > 4) {
                    text = text.substring(0, 4);
                  }

                  return SideTitleWidget(
                    axisSide: meta.axisSide,
                    space: 8,
                    child: Text(
                      text.toUpperCase(),
                      style: BudgetrStyles.caption.copyWith(
                        fontSize: 10,
                        color: Colors.white.withOpacity(0.5),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ),
        ),
        borderData: FlBorderData(
          show: true,
          border: Border(
            bottom: BorderSide(color: Colors.white.withOpacity(0.1)),
            left: BorderSide(color: Colors.white.withOpacity(0.1)),
          ),
        ),
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: maxY / 5, // Show ~5 grid lines
          getDrawingHorizontalLine: (value) {
            return FlLine(
              color: Colors.white.withOpacity(0.05),
              strokeWidth: 1,
            );
          },
        ),
        barGroups: List.generate(keys.length, (index) {
          final key = keys[index];
          final allocated = data.allocations[key] ?? 0;
          final spent = data.expenses[key] ?? 0;

          return BarChartGroupData(
            x: index,
            barRods: [
              // Allocated Rod
              BarChartRodData(
                toY: allocated,
                color: BudgetrColors.accent,
                width: 8,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(2),
                  topRight: Radius.circular(2),
                ),
              ),
              // Spent Rod
              BarChartRodData(
                toY: spent,
                color: const Color(0xFFFF006E),
                width: 8,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(2),
                  topRight: Radius.circular(2),
                ),
              ),
            ],
            barsSpace: 4,
          );
        }),
      ),
    );
  }

  Widget _buildLegend() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _legendItem(BudgetrColors.accent, 'Allocated'),
        const SizedBox(width: 24),
        _legendItem(const Color(0xFFFF006E), 'Spent'),
      ],
    );
  }

  Widget _legendItem(Color color, String text) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 8),
        Text(
          text,
          style: BudgetrStyles.caption.copyWith(
            color: Colors.white.withOpacity(0.7),
          ),
        ),
      ],
    );
  }
}
