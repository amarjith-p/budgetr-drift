import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/investment_model.dart';
import 'portfolio_allocation_chart.dart';

class InvestmentSummaryCard extends StatelessWidget {
  final double invested;
  final double current;
  final double dayGain;
  final NumberFormat currencyFormat;
  final List<InvestmentRecord> records;

  const InvestmentSummaryCard({
    super.key,
    required this.invested,
    required this.current,
    required this.dayGain,
    required this.currencyFormat,
    required this.records,
  });

  @override
  Widget build(BuildContext context) {
    final totalReturn = current - invested;
    final returnPercent = invested == 0 ? 0.0 : (totalReturn / invested) * 100;
    final isProfit = totalReturn >= 0;
    final isDayProfit = dayGain >= 0;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20), // Reduced Padding
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF4361EE).withOpacity(0.8),
            const Color(0xFF4CC9F0).withOpacity(0.6),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF4361EE).withOpacity(0.2),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Header Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Total Value",
                style: TextStyle(
                  color: Colors.white.withOpacity(0.8),
                  fontSize: 13,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.black26,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Row(
                  children: [
                    Icon(
                      isProfit ? Icons.arrow_upward : Icons.arrow_downward,
                      color: isProfit ? Colors.greenAccent : Colors.redAccent,
                      size: 10,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      "${returnPercent.toStringAsFixed(2)}%",
                      style: TextStyle(
                        color: isProfit ? Colors.greenAccent : Colors.redAccent,
                        fontWeight: FontWeight.bold,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          // 2. Main Amount
          const SizedBox(height: 4),
          Text(
            currencyFormat.format(current),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 28, // Slightly Smaller
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),

          // 3. Metrics Row (Invested | Day | Total)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildSubMetric("Invested", invested, currencyFormat),
              _buildSubMetric(
                "Day Gain",
                dayGain,
                currencyFormat,
                isColor: true,
                isProfit: isDayProfit,
                withSign: true,
              ),
              _buildSubMetric(
                "Returns",
                totalReturn,
                currencyFormat,
                isColor: true,
                isProfit: isProfit,
              ),
            ],
          ),

          // 4. Compact Chart
          if (records.isNotEmpty) ...[
            const SizedBox(height: 16),
            Divider(color: Colors.white.withOpacity(0.15), height: 1),
            const SizedBox(height: 12),
            PortfolioAllocationChart(records: records, isEmbedded: true),
          ],
        ],
      ),
    );
  }

  Widget _buildSubMetric(
    String label,
    double val,
    NumberFormat fmt, {
    bool isColor = false,
    bool isProfit = true,
    bool withSign = false,
  }) {
    Color valColor = Colors.white;
    if (isColor) valColor = isProfit ? Colors.greenAccent : Colors.redAccent;
    String text = fmt.format(val);
    if (withSign && val > 0) text = "+$text";

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 11),
        ),
        const SizedBox(height: 2),
        Text(
          text,
          style: TextStyle(
            color: valColor,
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
        ),
      ],
    );
  }
}
