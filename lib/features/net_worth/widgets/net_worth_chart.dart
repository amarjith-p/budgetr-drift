import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../core/models/net_worth_model.dart';

class NetWorthChart extends StatelessWidget {
  final List<NetWorthRecord> sortedRecords;
  final NumberFormat currencyFormat;
  final Color accentColor;

  const NetWorthChart({
    super.key,
    required this.sortedRecords,
    required this.currencyFormat,
    required this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    // Theme constant for the card background inside the tooltip
    final tooltipBgColor = const Color(0xFF0D1B2A).withOpacity(0.95);

    List<FlSpot> spots = [];
    double sumX = 0, sumY = 0, sumXY = 0, sumXX = 0;
    int n = sortedRecords.length;

    for (int i = 0; i < n; i++) {
      double val = sortedRecords[i].amount;
      spots.add(FlSpot(i.toDouble(), val));
      sumX += i;
      sumY += val;
      sumXY += (i * val);
      sumXX += (i * i);
    }

    // Linear Regression for Trend Line
    List<FlSpot> trendSpots = [];
    if (n > 1) {
      double slope = (n * sumXY - sumX * sumY) / (n * sumXX - sumX * sumX);
      double intercept = (sumY - slope * sumX) / n;
      trendSpots.add(FlSpot(0, intercept));
      trendSpots.add(FlSpot((n - 1).toDouble(), slope * (n - 1) + intercept));
    } else if (n == 1) {
      trendSpots.add(FlSpot(0, spots[0].y));
    }

    // Calculate X-Axis Interval
    double interval = 1.0;
    if (n > 5) interval = (n / 5).ceilToDouble();

    return Container(
      height: 320,
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 0),
      decoration: BoxDecoration(
        color: const Color(0xFF1B263B).withOpacity(0.6),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 8.0, bottom: 20),
            child: Text(
              "Growth Trajectory",
              style: TextStyle(
                color: Colors.white.withOpacity(0.7),
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Expanded(
            child: LineChart(
              LineChartData(
                lineTouchData: LineTouchData(
                  touchTooltipData: LineTouchTooltipData(
                    getTooltipColor: (spot) => tooltipBgColor,
                    tooltipRoundedRadius: 8,
                    getTooltipItems: (List<LineBarSpot> touchedBarSpots) {
                      return touchedBarSpots.map((barSpot) {
                        // Ignore trend line tooltips (index 0)
                        if (barSpot.barIndex == 0) return null;

                        final index = barSpot.x.toInt();
                        if (index >= 0 && index < sortedRecords.length) {
                          final record = sortedRecords[index];
                          final dateStr = DateFormat(
                            'dd MMM yyyy',
                          ).format(record.date);
                          return LineTooltipItem(
                            '$dateStr\n',
                            const TextStyle(
                              color: Colors.white70,
                              fontSize: 10,
                              fontWeight: FontWeight.w500,
                            ),
                            children: [
                              TextSpan(
                                text: currencyFormat.format(barSpot.y),
                                style: TextStyle(
                                  color: accentColor,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          );
                        }
                        return null;
                      }).toList();
                    },
                  ),
                ),
                gridData: const FlGridData(show: false),
                titlesData: FlTitlesData(
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  leftTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      interval: interval,
                      getTitlesWidget: (value, meta) {
                        int index = value.toInt();
                        if (index >= 0 && index < sortedRecords.length) {
                          return Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Text(
                              DateFormat(
                                'MMM yy',
                              ).format(sortedRecords[index].date),
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.3),
                                fontSize: 10,
                              ),
                            ),
                          );
                        }
                        return const Text('');
                      },
                    ),
                  ),
                ),
                borderData: FlBorderData(show: false),
                lineBarsData: [
                  // Trend Line
                  LineChartBarData(
                    spots: trendSpots,
                    isCurved: false,
                    color: Colors.white.withOpacity(0.3),
                    barWidth: 1,
                    dashArray: [5, 5],
                    dotData: const FlDotData(show: false),
                  ),
                  // Actual Data Line
                  LineChartBarData(
                    spots: spots,
                    isCurved: true,
                    color: accentColor,
                    barWidth: 3,
                    dotData: FlDotData(
                      show: true,
                      getDotPainter: (spot, percent, barData, index) =>
                          FlDotCirclePainter(
                            radius: 4,
                            color: accentColor,
                            strokeWidth: 2,
                            strokeColor: Colors.white,
                          ),
                    ),
                    belowBarData: BarAreaData(
                      show: true,
                      gradient: LinearGradient(
                        colors: [
                          accentColor.withOpacity(0.3),
                          accentColor.withOpacity(0.0),
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
