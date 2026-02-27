import 'package:budget/core/design/budgetr_colors.dart';
import 'package:budget/core/widgets/glass_card.dart';
import 'package:budget/features/investments/models/investment_dto.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class PortfolioSummaryCard extends StatefulWidget {
  final double totalInvested;
  final double currentValue;
  final double totalGainLoss;
  final double returnPercentage;
  final List<InvestmentDto> investments;

  const PortfolioSummaryCard({
    super.key,
    required this.totalInvested,
    required this.currentValue,
    required this.totalGainLoss,
    required this.returnPercentage,
    required this.investments,
  });

  @override
  State<PortfolioSummaryCard> createState() => _PortfolioSummaryCardState();
}

class _PortfolioSummaryCardState extends State<PortfolioSummaryCard> {
  bool _showChart = false;
  int _touchedIndex = -1;

  @override
  Widget build(BuildContext context) {
    final isPositive = widget.totalGainLoss >= 0;
    final statusColor =
        isPositive ? BudgetrColors.success : BudgetrColors.error;
    final statusIcon =
        isPositive ? Icons.trending_up_rounded : Icons.trending_down_rounded;

    return GlassCard(
      borderRadius: 16,
      // [OPTIMIZED] Reduced padding from 20 to 16
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // --- HEADER ROW ---
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _showChart ? "ASSET ALLOCATION" : "PORTFOLIO VALUE",
                  style: const TextStyle(
                    color: Colors.white38,
                    fontSize: 10,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.5,
                  ),
                ),
                Row(
                  children: [
                    GestureDetector(
                      onTap: () => setState(() => _showChart = !_showChart),
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          _showChart
                              ? Icons.home_outlined
                              : Icons.pie_chart_rounded,
                          color: Colors.white70,
                          size: 16,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    if (!_showChart)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4), // [OPTIMIZED] Tighter pill
                        decoration: BoxDecoration(
                          color: statusColor.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(20),
                          border:
                              Border.all(color: statusColor.withOpacity(0.3)),
                        ),
                        child: Row(
                          children: [
                            Icon(statusIcon, color: statusColor, size: 12),
                            const SizedBox(width: 4),
                            Text(
                              "${isPositive ? '+' : ''}${widget.returnPercentage.toStringAsFixed(2)}%",
                              style: TextStyle(
                                color: statusColor,
                                fontWeight: FontWeight.bold,
                                fontSize: 11, // [OPTIMIZED]
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                )
              ],
            ),
            const SizedBox(height: 12),

            // --- ANIMATED CONTENT SWITCHER ---
            AnimatedCrossFade(
              firstChild: _buildStatsView(statusColor, isPositive),
              secondChild: _buildChartView(),
              crossFadeState: _showChart
                  ? CrossFadeState.showSecond
                  : CrossFadeState.showFirst,
              duration: const Duration(milliseconds: 300),
            ),
          ],
        ),
      ),
    );
  }

  // --- VIEW 1: Compact Stats View ---
  Widget _buildStatsView(Color statusColor, bool isPositive) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Main Value
        Text(
          "₹${widget.currentValue.toStringAsFixed(2)}",
          style: const TextStyle(
            color: Colors.white,
            fontSize: 28, // [OPTIMIZED] Reduced from 32
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16), // [OPTIMIZED] Reduced from 24

        Container(height: 1, color: Colors.white10),

        const SizedBox(height: 12), // [OPTIMIZED] Reduced from 16

        // Bottom Row
        Row(
          children: [
            Expanded(
              child: _buildMiniStat(
                "INVESTED", // [OPTIMIZED] Shorter text
                "₹${widget.totalInvested.toStringAsFixed(2)}",
                Colors.white70,
              ),
            ),
            Container(
                width: 1,
                height: 30,
                color: Colors.white10), // [OPTIMIZED] Height 40 -> 30
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(left: 20),
                child: _buildMiniStat(
                  "GAIN/LOSS", // [OPTIMIZED] Shorter text
                  "${isPositive ? '+' : ''}₹${widget.totalGainLoss.toStringAsFixed(2)}",
                  statusColor,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  // --- VIEW 2: Compact Chart View ---
  Widget _buildChartView() {
    if (widget.investments.isEmpty) {
      return const SizedBox(
          height: 120,
          child: Center(
              child: Text("No Data", style: TextStyle(color: Colors.white38))));
    }

    final Map<String, double> dataMap = {};
    double totalValue = 0;
    for (var inv in widget.investments) {
      if (inv.currentMarketValue > 0) {
        final key = inv.displayType;
        dataMap[key] = (dataMap[key] ?? 0) + inv.currentMarketValue;
        totalValue += inv.currentMarketValue;
      }
    }

    if (totalValue == 0) {
      return const SizedBox(
          height: 120,
          child: Center(
              child:
                  Text("Zero Value", style: TextStyle(color: Colors.white38))));
    }

    final sortedKeys = dataMap.keys.toList()
      ..sort((a, b) => dataMap[b]!.compareTo(dataMap[a]!));

    final List<Color> colors = [
      const Color(0xFF4CC9F0),
      const Color(0xFF4361EE),
      const Color(0xFF3A0CA3),
      const Color(0xFF7209B7),
      const Color(0xFFF72585),
      const Color(0xFFFF9F1C),
    ];

    return Container(
      height: 130, // [OPTIMIZED] Reduced height from 180 -> 130
      padding: const EdgeInsets.only(top: 8),
      child: Row(
        children: [
          AspectRatio(
            aspectRatio: 1,
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
                sectionsSpace: 2,
                centerSpaceRadius: 20, // [OPTIMIZED] Smaller center
                sections: List.generate(sortedKeys.length, (i) {
                  final isTouched = i == _touchedIndex;
                  final radius =
                      isTouched ? 35.0 : 25.0; // [OPTIMIZED] Smaller radii
                  final key = sortedKeys[i];
                  final value = dataMap[key]!;
                  final percentage = (value / totalValue) * 100;

                  return PieChartSectionData(
                    color: colors[i % colors.length],
                    value: value,
                    title: percentage > 5
                        ? '${percentage.toStringAsFixed(0)}%'
                        : '',
                    radius: radius,
                    titleStyle: const TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                        color: Colors.white),
                  );
                }),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: List.generate(sortedKeys.length, (i) {
                  final key = sortedKeys[i];
                  return Padding(
                    padding: const EdgeInsets.only(
                        bottom: 4), // [OPTIMIZED] Tighter spacing
                    child: Row(
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                              color: colors[i % colors.length],
                              shape: BoxShape.circle),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            key,
                            style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 10), // [OPTIMIZED]
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  );
                }),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMiniStat(String label, String value, Color valueColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Colors.white30,
            fontSize: 9, // [OPTIMIZED]
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: TextStyle(
            color: valueColor,
            fontSize: 15, // [OPTIMIZED]
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
