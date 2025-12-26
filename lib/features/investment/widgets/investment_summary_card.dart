import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class InvestmentSummaryCard extends StatelessWidget {
  final double invested;
  final double current;
  final double dayGain; // NEW
  final NumberFormat currencyFormat;

  const InvestmentSummaryCard({
    super.key,
    required this.invested,
    required this.current,
    required this.dayGain, // NEW
    required this.currencyFormat,
  });

  @override
  Widget build(BuildContext context) {
    final totalReturn = current - invested;
    final returnPercent = invested == 0 ? 0.0 : (totalReturn / invested) * 100;
    final isProfit = totalReturn >= 0;
    final isDayProfit = dayGain >= 0;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF4361EE).withOpacity(0.8),
            const Color(0xFF4CC9F0).withOpacity(0.6),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF4361EE).withOpacity(0.2),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Total Portfolio Value",
                style: TextStyle(
                  color: Colors.white.withOpacity(0.8),
                  fontSize: 14,
                ),
              ),

              // Total Return Pill
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.black26,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(
                      isProfit ? Icons.arrow_upward : Icons.arrow_downward,
                      color: isProfit ? Colors.greenAccent : Colors.redAccent,
                      size: 12,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      "${returnPercent.toStringAsFixed(2)}%",
                      style: TextStyle(
                        color: isProfit ? Colors.greenAccent : Colors.redAccent,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            currencyFormat.format(current),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 32,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildSubMetric("Invested", invested, currencyFormat),

              // NEW: Day's Gain
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    "Day's Gain",
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.6),
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "${isDayProfit ? '+' : ''}${currencyFormat.format(dayGain)}",
                    style: TextStyle(
                      color: isDayProfit
                          ? Colors.greenAccent
                          : Colors.redAccent,
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),

              _buildSubMetric(
                "Total Return",
                totalReturn,
                currencyFormat,
                isColor: true,
                isProfit: isProfit,
              ),
            ],
          ),
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
  }) {
    Color valColor = Colors.white;
    if (isColor) valColor = isProfit ? Colors.greenAccent : Colors.redAccent;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 12),
        ),
        const SizedBox(height: 4),
        Text(
          fmt.format(val),
          style: TextStyle(
            color: valColor,
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
      ],
    );
  }
}
