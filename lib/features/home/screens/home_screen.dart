import 'package:budget/features/settings/screens/settings_screen.dart';
import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:google_fonts/google_fonts.dart'; // Added package
import '../../../core/design/budgetr_colors.dart';
import '../../../core/services/service_locator.dart';

// Services
import '../../daily_expense/services/expense_service.dart';
import '../../dashboard/services/dashboard_service.dart';

// Screens
import '../../dashboard/screens/dashboard_screen.dart';
import '../../daily_expense/screens/daily_expense_screen.dart';
import '../../credit_tracker/screens/credit_tracker_screen.dart';
import '../../custom_entry/screens/custom_entry_dashboard.dart';
import '../../goals_loans/screens/goals_loans_dashboard.dart';
import '../../investment/screens/investment_screen.dart';
import '../../net_worth/screens/net_worth_screen.dart';
import '../../settings/screens/configuration_menu_screen.dart';

import '../widgets/home_app_bar.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final expenseService = locator<ExpenseService>();
  final dashboardService = locator<DashboardService>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0E12),
      extendBodyBehindAppBar: true,
      appBar: const HomeAppBar(),
      body: Stack(
        children: [
          // Background ambient gradients
          _buildAmbientGlow(
              Alignment.topRight, BudgetrColors.accent.withOpacity(0.15)),
          _buildAmbientGlow(
              Alignment.bottomLeft, const Color(0xFF4361EE).withOpacity(0.1)),

          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 10),
                  // 1. Summary Card (Fixed Height)
                  _buildFinancialOverview(),

                  const SizedBox(height: 25),

                  // 2. Financial Engines (Fills available space)
                  _buildSectionHeader("Finance Today"),
                  const SizedBox(height: 15),
                  Expanded(
                    child: _buildFeatureGrid(context),
                  ),

                  const SizedBox(height: 25),

                  // 3. Quick Actions (Fixed Height at bottom)
                  _buildSectionHeader("More Tools"),
                  const SizedBox(height: 15),
                  _buildQuickActionList(context),

                  const SizedBox(height: 20), // Bottom Padding
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFinancialOverview() {
    return FutureBuilder(
      future: Future.wait([
        expenseService.getTotalBalance(),
        dashboardService.getMonthlySummary(DateTime.now()),
      ]),
      builder: (context, AsyncSnapshot<List<dynamic>> snapshot) {
        double currentBalance = 0.0;
        double monthlyBudget = 0.0;
        double totalSpent = 0.0;

        if (snapshot.hasData) {
          currentBalance = snapshot.data![0] as double;
          final summary = snapshot.data![1] as MonthlySummary;
          monthlyBudget = summary.totalBudget;
          totalSpent = summary.totalSpent;
        }

        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.white.withOpacity(0.08),
                Colors.white.withOpacity(0.03),
              ],
            ),
            border: Border.all(color: Colors.white.withOpacity(0.1)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // --- Header with Day, Date & 12H Live Clock ---
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text("Total Account Balance",
                        style: GoogleFonts.robotoSlab(
                            color: Colors.white70, fontSize: 14)),
                  ),
                  StreamBuilder(
                    stream: Stream.periodic(
                        const Duration(seconds: 1), (_) => DateTime.now()),
                    builder: (context, snapshot) {
                      final now = DateTime.now();

                      // Date Formatting with Day Name
                      final months = [
                        "Jan",
                        "Feb",
                        "Mar",
                        "Apr",
                        "May",
                        "Jun",
                        "Jul",
                        "Aug",
                        "Sep",
                        "Oct",
                        "Nov",
                        "Dec"
                      ];
                      final weekdays = [
                        "Mon",
                        "Tue",
                        "Wed",
                        "Thu",
                        "Fri",
                        "Sat",
                        "Sun"
                      ];

                      final dayName = weekdays[now.weekday - 1];
                      final monthName = months[now.month - 1];
                      final dayNum = now.day.toString().padLeft(2, '0');

                      // Result: "Mon, 02 Feb 2026"
                      final dateStr =
                          "$dayName, $dayNum $monthName ${now.year}";

                      // 12-Hour Time Formatting
                      int hour = now.hour;
                      final String period = hour >= 12 ? 'PM' : 'AM';
                      hour = hour % 12;
                      if (hour == 0) hour = 12;

                      final timeStr =
                          "${hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}:${now.second.toString().padLeft(2, '0')} $period";

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(dateStr,
                              style: GoogleFonts.robotoSlab(
                                  color: Colors.white.withOpacity(0.6),
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500)),
                          const SizedBox(height: 2),
                          // tabularFigures ensures the width doesn't jump as numbers change
                          Text(timeStr,
                              style: GoogleFonts.robotoSlab(
                                  color: Colors.white,
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  fontFeatures: [
                                    const FontFeature.tabularFigures()
                                  ])),
                        ],
                      );
                    },
                  ),
                ],
              ),
              Text("₹ ${currentBalance.toStringAsFixed(2)}",
                  style: GoogleFonts.robotoSlab(
                      color: Colors.white,
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1)),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildMiniStat(
                      "Monthly Budget",
                      "    ₹ ${monthlyBudget.toStringAsFixed(2)}",
                      Colors.blueAccent),
                  _buildMiniStat(
                      "Spent so far",
                      "    ₹ ${totalSpent.toStringAsFixed(2)}",
                      Colors.orangeAccent),
                ],
              )
            ],
          ),
        );
      },
    );
  }

  Widget _buildMiniStat(String label, String value, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            CircleAvatar(radius: 4, backgroundColor: color),
            const SizedBox(width: 8),
            Text(label,
                style: GoogleFonts.robotoSlab(
                    color: Colors.white54, fontSize: 12)),
          ],
        ),
        const SizedBox(height: 4),
        Text(value,
            style: GoogleFonts.robotoSlab(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w600)),
      ],
    );
  }

  Widget _buildFeatureGrid(BuildContext context) {
    // LayoutBuilder allows us to calculate the perfect aspect ratio to fit the grid in the Expanded space
    return LayoutBuilder(
      builder: (context, constraints) {
        // We want 2 rows and 2 columns
        // Item Width = (Total Width - CrossAxisSpacing) / 2
        // Item Height = (Total Height - MainAxisSpacing) / 2
        double itemWidth = (constraints.maxWidth - 16) / 2;
        double itemHeight = (constraints.maxHeight - 16) / 2;
        double childAspectRatio = itemWidth / itemHeight;

        return GridView.count(
          physics: const NeverScrollableScrollPhysics(), // No scrolling
          crossAxisCount: 2,
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
          childAspectRatio: childAspectRatio,
          children: [
            _buildCompactCard(
                context,
                "Budget Dashboard",
                Icons.donut_large_rounded,
                const Color(0xFF4361EE),
                const DashboardScreen()),
            _buildCompactCard(
                context,
                "Daily Expense",
                Icons.account_balance_wallet_rounded,
                const Color(0xFF00B4D8),
                const DailyExpenseScreen()),
            _buildCompactCard(
                context,
                "Credit Tracker",
                Icons.credit_card_rounded,
                const Color(0xFFE63946),
                const CreditTrackerScreen()),
            _buildCompactCard(
                context,
                "Custom Entry",
                Icons.dashboard_customize_rounded,
                const Color(0xFFFF9F1C),
                const CustomEntryDashboard()),
          ],
        );
      },
    );
  }

  Widget _buildCompactCard(BuildContext context, String title, IconData icon,
      Color color, Widget page) {
    return GestureDetector(
      onTap: () => Navigator.push(
          context, MaterialPageRoute(builder: (context) => page)),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.white.withOpacity(0.05)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 12),
            Text(title,
                textAlign: TextAlign.center,
                style: GoogleFonts.robotoSlab(
                    color: Colors.white, fontWeight: FontWeight.w500)),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(title,
        style: GoogleFonts.robotoSlab(
            color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold));
  }

  Widget _buildAmbientGlow(Alignment alignment, Color color) {
    return Positioned.fill(
      child: Align(
        alignment: alignment,
        child: Container(
          width: 300,
          height: 300,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(color: color, blurRadius: 100, spreadRadius: 50)
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuickActionList(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          // Added specific colors for each action icon
          _buildActionChip(
              context,
              "Goals & Loans",
              Icons.flag_rounded,
              const Color.fromARGB(255, 38, 219, 2),
              const GoalsLoansDashboard()),
          _buildActionChip(
              context,
              "Investment Tracker",
              Icons.show_chart_rounded,
              const Color.fromARGB(255, 161, 1, 241),
              const InvestmentScreen()),
          _buildActionChip(
              context,
              "Net Worth Analysis",
              Icons.currency_rupee_rounded,
              const Color.fromARGB(255, 92, 123, 21),
              const NetWorthScreen()),
          _buildActionChip(context, "Budget Buckets", Icons.pie_chart_outline,
              const Color.fromARGB(255, 255, 90, 175), const SettingsScreen()),
          _buildActionChip(context, "Settings", Icons.settings_rounded,
              Colors.white70, const ConfigurationMenuScreen()),
        ],
      ),
    );
  }

  Widget _buildActionChip(BuildContext context, String label, IconData icon,
      Color iconColor, Widget page) {
    return GestureDetector(
      onTap: () => Navigator.push(
          context, MaterialPageRoute(builder: (context) => page)),
      child: Container(
        margin: const EdgeInsets.only(right: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: Colors.white10),
          color: Colors.white.withOpacity(0.02),
        ),
        child: Row(
          children: [
            Icon(icon,
                color: iconColor, size: 18), // Icon now uses the passed color
            const SizedBox(width: 8),
            Text(label, style: GoogleFonts.robotoSlab(color: Colors.white70)),
          ],
        ),
      ),
    );
  }
}
