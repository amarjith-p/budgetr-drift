import 'package:flutter/material.dart';
import '../widgets/balance_trend_chart.dart';
import '../widgets/category_spending_chart.dart'; // NEW Import

class ExpenseAnalyticsScreen extends StatelessWidget {
  const ExpenseAnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.only(top: 20, bottom: 120),
      physics: const BouncingScrollPhysics(),
      children: [
        // --- 1. Net Worth / Balance Trend ---
        const BalanceTrendChart(),

        // --- 2. Category Spending Donut Chart ---
        const CategorySpendingChart(),

        // Add more widgets here later (e.g. Monthly comparison bar chart)
      ],
    );
  }
}
