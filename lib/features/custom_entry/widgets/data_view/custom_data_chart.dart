import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../core/models/custom_data_models.dart';

class CustomDataChart extends StatelessWidget {
  final List<CustomRecord> records;
  final String xKey;
  final String yKey;

  final Color positiveColor = const Color(0xFF00E676);
  final Color negativeColor = const Color(0xFFFF5252);

  const CustomDataChart({
    super.key,
    required this.records,
    required this.xKey,
    required this.yKey,
  });

  @override
  Widget build(BuildContext context) {
    var sorted = List<CustomRecord>.from(records)
      ..sort((a, b) => a.createdAt.compareTo(b.createdAt));
    List<FlSpot> spots = [];
    double minY = double.infinity;
    double maxY = double.negativeInfinity;

    double sumX = 0, sumY = 0, sumXY = 0, sumXX = 0;
    int n = sorted.length;

    for (int i = 0; i < n; i++) {
      double val = 0.0;
      var raw = sorted[i].data[yKey];
      if (raw is num) {
        val = raw.toDouble();
      } else if (raw is String) {
        val = double.tryParse(raw) ?? 0.0;
      }

      spots.add(FlSpot(i.toDouble(), val));
      if (val < minY) minY = val;
      if (val > maxY) maxY = val;

      double x = i.toDouble();
      sumX += x;
      sumY += val;
      sumXY += (x * val);
      sumXX += (x * x);
    }

    if (spots.isEmpty) return const SizedBox.shrink();

    // Trend Line (Least Squares)
    List<FlSpot> trendSpots = [];
    if (n > 1) {
      double slope = (n * sumXY - sumX * sumY) / (n * sumXX - sumX * sumX);
      double intercept = (sumY - slope * sumX) / n;
      trendSpots.add(FlSpot(0, intercept));
      trendSpots.add(FlSpot((n - 1).toDouble(), slope * (n - 1) + intercept));
    } else {
      trendSpots.add(FlSpot(0, spots[0].y));
    }

    List<Color> gradientColors = [positiveColor, positiveColor];
    List<double> stops = [0.0, 1.0];

    if (minY < 0 && maxY > 0) {
      double zeroPos = (0 - minY) / (maxY - minY);
      gradientColors = [
        negativeColor,
        negativeColor,
        positiveColor,
        positiveColor,
      ];
      stops = [0.0, zeroPos, zeroPos, 1.0];
    } else if (maxY <= 0) {
      gradientColors = [negativeColor, negativeColor];
    }

    double interval = 1.0;
    if (sorted.length > 4) interval = (sorted.length / 4).ceilToDouble();

    return LineChart(
      LineChartData(
        lineTouchData: LineTouchData(
          touchTooltipData: LineTouchTooltipData(
            getTooltipColor: (spot) =>
                const Color(0xFF0D1B2A).withOpacity(0.95),
            tooltipRoundedRadius: 8,
            getTooltipItems: (List<LineBarSpot> touchedBarSpots) {
              return touchedBarSpots.map((barSpot) {
                if (barSpot.barIndex == 0) return null; // Ignore Trend Line

                final index = barSpot.x.toInt();
                if (index >= 0 && index < sorted.length) {
                  final d = sorted[index].data[xKey];
                  String xLabel = (d is DateTime)
                      ? DateFormat('dd MMM yyyy').format(d)
                      : d.toString();
                  Color valColor =
                      barSpot.y > 0 ? positiveColor : negativeColor;

                  return LineTooltipItem(
                    '$xLabel\n',
                    const TextStyle(color: Colors.white70, fontSize: 10),
                    children: [
                      TextSpan(
                        text: NumberFormat.compact().format(barSpot.y),
                        style: TextStyle(
                          color: valColor,
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
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 32,
              getTitlesWidget: (val, _) => Text(
                NumberFormat.compact().format(val),
                style: const TextStyle(fontSize: 10, color: Colors.white30),
              ),
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 42,
              interval: interval,
              getTitlesWidget: (val, meta) {
                int index = val.toInt();
                if (index >= 0 &&
                    index < sorted.length &&
                    val == index.toDouble()) {
                  final d = sorted[index].data[xKey];
                  String label = (d is DateTime)
                      ? DateFormat('dd/MM').format(d)
                      : d.toString();
                  return SideTitleWidget(
                    axisSide: meta.axisSide,
                    child: Text(
                      label,
                      style: const TextStyle(
                        fontSize: 10,
                        color: Colors.white30,
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
            barWidth: 1,
            color: Colors.white.withOpacity(0.3),
            dashArray: [5, 5],
            dotData: const FlDotData(show: false),
          ),
          // Main Data
          LineChartBarData(
            spots: spots,
            isCurved: true,
            barWidth: 3,
            gradient: LinearGradient(
              colors: gradientColors,
              stops: stops,
              begin: Alignment.bottomCenter,
              end: Alignment.topCenter,
            ),
            dotData: FlDotData(
              show: true,
              getDotPainter: (spot, percent, barData, index) {
                Color dotColor = spot.y > 0 ? positiveColor : negativeColor;
                return FlDotCirclePainter(
                  radius: 4,
                  color: dotColor,
                  strokeWidth: 2,
                  strokeColor: Colors.white.withOpacity(0.8),
                );
              },
            ),
            belowBarData: BarAreaData(
              show: true,
              gradient: LinearGradient(
                colors: gradientColors.map((c) => c.withOpacity(0.1)).toList(),
                stops: stops,
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
