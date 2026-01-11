import 'package:budget/features/daily_expense/widgets/budget_simulator_widget.dart';
import 'package:budget/features/daily_expense/widgets/unified_spending_chart.dart';
import 'package:flutter/material.dart'; // NEW Import

class ExpenseAnalyticsScreen extends StatelessWidget {
  const ExpenseAnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.only(top: 20, bottom: 120),
      physics: const BouncingScrollPhysics(),
      children: [
        const UnifiedSpendingChart(),
        const BudgetSimulatorWidget(),
      ],
    );
  }
}
