import 'package:budget/core/design/budgetr_colors.dart';
import 'package:budget/core/widgets/glass_card.dart';
import 'package:budget/features/investments/models/investment_dto.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class PortfolioAllocationChart extends StatefulWidget {
  final List<InvestmentDto> investments;

  const PortfolioAllocationChart({super.key, required this.investments});

  @override
  State<PortfolioAllocationChart> createState() =>
      _PortfolioAllocationChartState();
}

class _PortfolioAllocationChartState extends State<PortfolioAllocationChart> {
  int _touchedIndex = -1;

  @override
  Widget build(BuildContext context) {
    if (widget.investments.isEmpty) return const SizedBox.shrink();

    // 1. Group Data by Type
    final Map<String, double> dataMap = {};
    double totalValue = 0;

    for (var inv in widget.investments) {
      if (inv.currentMarketValue > 0) {
        final key = inv.displayType;
        dataMap[key] = (dataMap[key] ?? 0) + inv.currentMarketValue;
        totalValue += inv.currentMarketValue;
      }
    }

    if (totalValue == 0) return const SizedBox.shrink();

    // 2. Prepare Sections
    final List<String> sortedKeys = dataMap.keys.toList()
      ..sort((a, b) => dataMap[b]!.compareTo(dataMap[a]!)); // Sort desc

    // Color Palette
    final List<Color> colors = [
      const Color(0xFF4CC9F0), // Light Blue
      const Color(0xFF4361EE), // Blue
      const Color(0xFF3A0CA3), // Dark Blue
      const Color(0xFF7209B7), // Purple
      const Color(0xFFF72585), // Pink
      const Color(0xFFFF9F1C), // Orange
      const Color(0xFF2EC4B6), // Teal
    ];

    return GlassCard(
      borderRadius: 16,
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "ASSET ALLOCATION",
            style: TextStyle(
              color: Colors.white38,
              fontSize: 10,
              fontWeight: FontWeight.w900,
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: 24),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Chart
              SizedBox(
                height: 140,
                width: 140,
                child: PieChart(
                  PieChartData(
                    pieTouchData: PieTouchData(
                      touchCallback: (FlTouchEvent event, pieTouchResponse) {
                        setState(() {
                          if (!event.isInterestedForInteractions ||
                              pieTouchResponse == null ||
                              pieTouchResponse.touchedSection == null) {
                            _touchedIndex = -1;
                            return;
                          }
                          _touchedIndex = pieTouchResponse
                              .touchedSection!.touchedSectionIndex;
                        });
                      },
                    ),
                    borderData: FlBorderData(show: false),
                    sectionsSpace: 2,
                    centerSpaceRadius: 30,
                    sections: List.generate(sortedKeys.length, (i) {
                      final isTouched = i == _touchedIndex;
                      final fontSize =
                          isTouched ? 16.0 : 0.0; // Hide text unless touched
                      final radius = isTouched ? 50.0 : 40.0;
                      final key = sortedKeys[i];
                      final value = dataMap[key]!;
                      final percentage = (value / totalValue) * 100;

                      return PieChartSectionData(
                        color: colors[i % colors.length],
                        value: value,
                        title: '${percentage.toStringAsFixed(2)}%',
                        radius: radius,
                        titleStyle: TextStyle(
                          fontSize: fontSize,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      );
                    }),
                  ),
                ),
              ),
              const SizedBox(width: 24),
              // Legend
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(sortedKeys.length, (i) {
                    final key = sortedKeys[i];
                    final value = dataMap[key]!;
                    final percentage = (value / totalValue) * 100;

                    // Show only top 5 in legend to avoid overflow
                    if (i >= 5) return const SizedBox.shrink();

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: colors[i % colors.length],
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              key,
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Text(
                            "${percentage.toStringAsFixed(2)}%",
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
