import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/investment_model.dart';

class PortfolioAllocationChart extends StatefulWidget {
  final List<InvestmentRecord> records;

  const PortfolioAllocationChart({super.key, required this.records});

  @override
  State<PortfolioAllocationChart> createState() =>
      _PortfolioAllocationChartState();
}

class _PortfolioAllocationChartState extends State<PortfolioAllocationChart> {
  int _touchedIndex = -1;
  bool _showByBucket = false; // Toggle between Type (false) and Bucket (true)
  final _currencyFormat = NumberFormat.compactCurrency(
    locale: 'en_IN',
    symbol: '₹',
  );

  // Color Palette for charts
  final List<Color> _colors = [
    const Color(0xFF3A86FF), // Blue
    const Color(0xFF8338EC), // Purple
    const Color(0xFFFF006E), // Pink
    const Color(0xFFFFBE0B), // Yellow
    const Color(0xFFFB5607), // Orange
    const Color(0xFF2EC4B6), // Teal
    const Color(0xFF38B000), // Green
  ];

  @override
  Widget build(BuildContext context) {
    if (widget.records.isEmpty) return const SizedBox.shrink();

    // 1. Aggregate Data
    final totalValue = widget.records.fold(
      0.0,
      (sum, item) => sum + item.currentValue,
    );
    if (totalValue == 0) return const SizedBox.shrink();

    final dataMap = _aggregateData();
    final sortedKeys = dataMap.keys.toList()
      ..sort((a, b) => dataMap[b]!.compareTo(dataMap[a]!)); // Sort Descending

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1B263B).withOpacity(0.6),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Column(
        children: [
          // Header & Toggle
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Allocation",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              _buildToggle(),
            ],
          ),
          const SizedBox(height: 24),

          // Chart & Legend Row
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Pie Chart
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
                              .touchedSection!
                              .touchedSectionIndex;
                        });
                      },
                    ),
                    borderData: FlBorderData(show: false),
                    sectionsSpace: 2,
                    centerSpaceRadius: 30,
                    sections: _generateSections(
                      sortedKeys,
                      dataMap,
                      totalValue,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 24),

              // Legend
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: List.generate(sortedKeys.length, (index) {
                    // Show top 4 categories, collapse rest
                    if (index > 3) return const SizedBox.shrink();
                    final key = sortedKeys[index];
                    final value = dataMap[key]!;
                    final percent = (value / totalValue) * 100;
                    final color = _colors[index % _colors.length];

                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Row(
                        children: [
                          Container(
                            width: 10,
                            height: 10,
                            decoration: BoxDecoration(
                              color: color,
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
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Text(
                            "${percent.toStringAsFixed(0)}%",
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
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

  Widget _buildToggle() {
    return Container(
      height: 32,
      decoration: BoxDecoration(
        color: Colors.white10,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          _toggleBtn("Type", !_showByBucket),
          _toggleBtn("Bucket", _showByBucket),
        ],
      ),
    );
  }

  Widget _toggleBtn(String text, bool isActive) {
    return GestureDetector(
      onTap: () => setState(() => _showByBucket = text == "Bucket"),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isActive ? const Color(0xFF3A86FF) : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(
          text,
          style: TextStyle(
            color: isActive ? Colors.white : Colors.white54,
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  // Logic: Group by Bucket or Type
  Map<String, double> _aggregateData() {
    final Map<String, double> map = {};
    for (var r in widget.records) {
      final key = _showByBucket
          ? r.bucket
          : (r.type == InvestmentType.stock
                ? "Stocks"
                : r.type == InvestmentType.mutualFund
                ? "MF"
                : "Others");
      map[key] = (map[key] ?? 0) + r.currentValue;
    }
    return map;
  }

  List<PieChartSectionData> _generateSections(
    List<String> keys,
    Map<String, double> data,
    double total,
  ) {
    return List.generate(keys.length, (i) {
      final isTouched = i == _touchedIndex;
      final fontSize = isTouched
          ? 16.0
          : 0.0; // Hide value on chart unless touched
      final radius = isTouched ? 45.0 : 35.0;
      final key = keys[i];
      final value = data[key]!;
      final color = _colors[i % _colors.length];

      return PieChartSectionData(
        color: color,
        value: value,
        title: _currencyFormat.format(value), // Show compact currency on touch
        radius: radius,
        titleStyle: TextStyle(
          fontSize: fontSize,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
        titlePositionPercentageOffset: 0.55,
      );
    });
  }
}
