import 'package:budget/features/investments/utils/investment_analytics_engine.dart';
import 'package:flutter/material.dart';

class SmartInsightBox extends StatelessWidget {
  final SmartInsight insight;

  const SmartInsightBox({super.key, required this.insight});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: insight.color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: insight.color.withOpacity(0.2)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: insight.color.withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(insight.icon, color: insight.color, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  insight.title,
                  style: TextStyle(
                    color: insight.color,
                    fontSize: 10,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  insight.message,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 13,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
