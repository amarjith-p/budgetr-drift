import 'package:flutter/material.dart';

import '../../custom_entry/screens/custom_entry_dashboard.dart';
import '../../dashboard/screens/dashboard_screen.dart';
import '../../net_worth/screens/net_worth_screen.dart';
// import '../../settlement/screens/settlement_screen.dart'; // Keep commented if unused
import '../../credit_tracker/screens/credit_tracker_screen.dart';
import '../../investment/screens/investment_screen.dart';
// ADD THIS IMPORT
import '../../daily_expense/screens/daily_expense_screen.dart';

import '../widgets/home_app_bar.dart';
import '../widgets/home_bottom_bar.dart';
import '../widgets/home_feature_card.dart';

import '../../../core/design/budgetr_colors.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: BudgetrColors.background,
      extendBodyBehindAppBar: true,
      appBar: const HomeAppBar(),
      body: Stack(
        children: [
          // --- Ambient Background Glows ---
          Positioned(
            top: -100,
            right: -100,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    BudgetrColors.accent.withOpacity(0.2),
                    Colors.transparent,
                  ],
                  center: Alignment.center,
                  radius: 0.6,
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 0,
            left: -50,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    const Color(0xFF00A6FB).withOpacity(0.15),
                    Colors.transparent,
                  ],
                  center: Alignment.center,
                  radius: 0.6,
                ),
              ),
            ),
          ),

          // --- Main Content ---
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 10),
                  const SizedBox(height: 20),

                  // --- Dashboard Grid ---
                  Expanded(
                    child: GridView.count(
                      crossAxisCount: 2,
                      mainAxisSpacing: 16,
                      crossAxisSpacing: 16,
                      childAspectRatio: 0.85,
                      children: [
                        // 1. Planning (Budgets)
                        HomeFeatureCard(
                          title: "Budgets",
                          subtitle: "Manage Monthly Budgets",
                          icon: Icons.pie_chart_outline,
                          color: const Color(0xFF4361EE),
                          destination: const DashboardScreen(),
                        ),

                        // 2. Tracking (Daily Expenses) - NEW
                        HomeFeatureCard(
                          title: "Daily Expenses",
                          subtitle: "Track Cash & Bank Spends",
                          icon: Icons.account_balance_wallet_outlined,
                          color: const Color(
                              0xFF00B4D8), // Matching the Cyan theme
                          destination: const DailyExpenseScreen(),
                        ),

                        // 3. Debt (Credit Cards)
                        HomeFeatureCard(
                          title: "Credit Tracker",
                          subtitle: "Cards & Repayments",
                          icon: Icons.credit_card_outlined,
                          color: const Color(0xFFE63946),
                          destination: const CreditTrackerScreen(),
                        ),

                        // 4. Growth (Investments)
                        HomeFeatureCard(
                          title: "Investments",
                          subtitle: "Stocks & Mutual Funds",
                          icon: Icons.show_chart_rounded,
                          color: const Color(0xFFFF9F1C),
                          destination: const InvestmentScreen(),
                        ),

                        // 5. Status (Net Worth)
                        HomeFeatureCard(
                          title: "Net Worth",
                          subtitle: "Track Your Networth",
                          icon: Icons.currency_rupee,
                          color: const Color(0xFF2EC4B6),
                          destination: const NetWorthScreen(),
                        ),

                        // 6. Tools (Custom Data)
                        HomeFeatureCard(
                          title: "Custom Data Entry",
                          subtitle: "Personal Data Trackers",
                          icon: Icons.dashboard_customize_outlined,
                          color: const Color(0xFFF72585),
                          destination: const CustomEntryDashboard(),
                        ),
                      ],
                    ),
                  ),

                  // --- Bottom Settings Bar ---
                  const HomeBottomBar(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
