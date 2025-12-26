import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/investment_model.dart';

class PortfolioAllocationChart extends StatefulWidget {
  final List<InvestmentRecord> records;
  final bool isEmbedded;

  const PortfolioAllocationChart({
    super.key,
    required this.records,
    this.isEmbedded = false,
  });

  @override
  State<PortfolioAllocationChart> createState() =>
      _PortfolioAllocationChartState();
}

class _PortfolioAllocationChartState extends State<PortfolioAllocationChart> {
  int _touchedIndex = -1;
  bool _showByBucket = false;
  final _currencyFormat = NumberFormat.compactCurrency(
    locale: 'en_IN',
    symbol: '₹',
  );

  final List<Color> _colors = [
    const Color(0xFF3A86FF), // Blue
    const Color(0xFF8338EC), // Purple
    const Color(0xFFFF006E), // Pink
    const Color(0xFFFFBE0B), // Yellow
    const Color(0xFFFB5607), // Orange
    const Color(0xFF2EC4B6), // Teal
    const Color(0xFF38B000), // Green
    const Color(0xFF9D4EDD), // Deep Purple
    const Color(0xFFFF9F1C), // Orange Peel
  ];

  @override
  Widget build(BuildContext context) {
    if (widget.records.isEmpty) return const SizedBox.shrink();

    final totalValue = widget.records.fold(
      0.0,
      (sum, item) => sum + item.currentValue,
    );
    if (totalValue == 0) return const SizedBox.shrink();

    final dataMap = _aggregateData();
    final sortedKeys = dataMap.keys.toList()
      ..sort((a, b) => dataMap[b]!.compareTo(dataMap[a]!));

    // --- EMBEDDED (COMPACT) VIEW ---
    if (widget.isEmbedded) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // 1. Tiny Pie Chart
          SizedBox(
            height: 80, // Very compact
            width: 80,
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
                      _touchedIndex =
                          pieTouchResponse.touchedSection!.touchedSectionIndex;
                    });
                  },
                ),
                borderData: FlBorderData(show: false),
                sectionsSpace: 0,
                centerSpaceRadius: 15, // Small hole
                sections: _generateSections(
                  sortedKeys,
                  dataMap,
                  totalValue,
                  true,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),

          // 2. Scrollable/Compact Legend
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Toggle Buttons (Inline)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Allocation",
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.5),
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    _buildToggle(compact: true),
                  ],
                ),
                const SizedBox(height: 8),
                // Legend Items
                Wrap(
                  spacing: 12,
                  runSpacing: 4,
                  children: List.generate(sortedKeys.length, (index) {
                    if (index >= 4)
                      return const SizedBox.shrink(); // Max 4 items
                    final key = sortedKeys[index];
                    final value = dataMap[key]!;
                    final percent = (value / totalValue) * 100;
                    final color = _colors[index % _colors.length];

                    return Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 6,
                          height: 6,
                          decoration: BoxDecoration(
                            color: color,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          key,
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.8),
                            fontSize: 10,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          "${percent.toStringAsFixed(0)}%",
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    );
                  }),
                ),
              ],
            ),
          ),
        ],
      );
    }

    // --- FULL VIEW (Not used in Card currently) ---
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
              _buildToggle(compact: false),
            ],
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 140,
            width: 140,
            child: PieChart(
              PieChartData(
                sectionsSpace: 0,
                centerSpaceRadius: 30,
                sections: _generateSections(
                  sortedKeys,
                  dataMap,
                  totalValue,
                  false,
                ),
              ),
            ),
          ),
          // ... (Legend code for full view omitted for brevity as it's not the focus)
        ],
      ),
    );
  }

  Widget _buildToggle({required bool compact}) {
    return Container(
      height: 24,
      decoration: BoxDecoration(
        color: Colors.black26,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          _toggleBtn("Type", !_showByBucket, compact),
          _toggleBtn("Bucket", _showByBucket, compact),
        ],
      ),
    );
  }

  Widget _toggleBtn(String text, bool isActive, bool compact) {
    return GestureDetector(
      onTap: () => setState(() => _showByBucket = text == "Bucket"),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isActive ? Colors.white.withOpacity(0.2) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          text,
          style: TextStyle(
            color: isActive ? Colors.white : Colors.white54,
            fontSize: compact ? 9 : 11,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Map<String, double> _aggregateData() {
    final Map<String, double> map = {};
    for (var r in widget.records) {
      String key;
      if (_showByBucket) {
        key = r.bucket.isNotEmpty ? r.bucket : "Uncategorized";
      } else {
        switch (r.type) {
          case InvestmentType.stock:
            key = "Stocks";
            break;
          case InvestmentType.mutualFund:
            key = "MF";
            break;
          case InvestmentType.other:
            key = "Other";
            break;
        }
      }
      map[key] = (map[key] ?? 0) + r.currentValue;
    }
    return map;
  }

  List<PieChartSectionData> _generateSections(
    List<String> keys,
    Map<String, double> data,
    double total,
    bool compact,
  ) {
    return List.generate(keys.length, (i) {
      final isTouched = i == _touchedIndex;
      final double radius = isTouched
          ? (compact ? 22 : 45.0)
          : (compact ? 18 : 35.0);
      final key = keys[i];
      final value = data[key]!;
      final color = _colors[i % _colors.length];

      return PieChartSectionData(
        color: color,
        value: value,
        showTitle: false,
        radius: radius,
      );
    });
  }
}
