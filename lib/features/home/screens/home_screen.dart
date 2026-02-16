import 'package:budget/features/settings/screens/settings_screen.dart';
import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:google_fonts/google_fonts.dart';
import 'package:rxdart/rxdart.dart';
import '../../../core/design/budgetr_colors.dart';
import '../../../core/services/service_locator.dart';

// Services
import '../../daily_expense/services/expense_service.dart';
import '../../dashboard/services/dashboard_service.dart';
import '../../backup_restore/services/backup_service.dart'; // [ADDED] Import

// Models
import '../../dashboard/models/dashboard_transaction.dart';
import '../../../core/models/financial_record_model.dart';

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

  // State for balance visibility
  bool _isBalanceVisible = false;

  // [ADDED] Backup Logic
  final BackupService _backupService = BackupService();
  bool _needsBackup = false;

  // Budget Mode State
  bool _isBudgetMode = false;

  @override
  void initState() {
    super.initState();
    // [ADDED] Check status
    _checkBackupStatus();
  }

  // [ADDED] Logic
  Future<void> _checkBackupStatus() async {
    final overdue = await _backupService.isBackupOverdue();
    if (mounted && overdue != _needsBackup) {
      setState(() => _needsBackup = overdue);
    }
  }

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

                  // [ADDED] Warning Banner - Inserted here
                  if (_needsBackup)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 15),
                      child: InkWell(
                        onTap: () async {
                          await _backupService.shareBackup();
                          _checkBackupStatus(); // Refresh after backup
                        },
                        borderRadius: BorderRadius.circular(8),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              vertical: 10, horizontal: 16),
                          decoration: BoxDecoration(
                            color: Colors.redAccent.withOpacity(0.15),
                            border: Border.all(
                                color: Colors.redAccent.withOpacity(0.3)),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.warning_amber_rounded,
                                  color: Colors.redAccent, size: 20),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  "Quick check: Time to Backup your data!. Tap to Backup Now.",
                                  style: GoogleFonts.robotoSlab(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                              const Icon(Icons.arrow_forward_ios,
                                  color: Colors.white30, size: 12),
                            ],
                          ),
                        ),
                      ),
                    ),
                  // [END ADDED BANNER]

                  // 1. Summary Card
                  _buildFinancialOverview(),

                  const SizedBox(height: 25),

                  // 2. Financial Engines
                  _buildSectionHeader("Finance Today"),
                  const SizedBox(height: 15),
                  Expanded(
                    child: _buildFeatureGrid(context),
                  ),

                  const SizedBox(height: 25),

                  // 3. Quick Actions
                  _buildSectionHeader("More Tools"),
                  const SizedBox(height: 15),
                  _buildQuickActionList(context),

                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ... [Keep ALL your other methods (_buildFinancialOverview, _buildMiniStat, etc.) exactly identical] ...

  Widget _buildFinancialOverview() {
    final now = DateTime.now();

    return StreamBuilder(
      stream: Rx.combineLatest3(
        expenseService.watchTotalBalance(),
        dashboardService.getMonthlyTransactions(now.year, now.month),
        dashboardService.getFinancialRecords(),
        (double balance, List<DashboardTransaction> txns,
                List<FinancialRecord> records) =>
            [balance, txns, records],
      ),
      builder: (context, snapshot) {
        double currentBalance = 0.0;
        double monthlyBudget = 0.0;
        double totalSpent = 0.0;

        if (snapshot.hasData) {
          currentBalance = snapshot.data![0] as double;
          final txns = snapshot.data![1] as List<DashboardTransaction>;
          final records = snapshot.data![2] as List<FinancialRecord>;

          // 1. Find Current Month Budget
          final recordId = "${now.year}${now.month.toString().padLeft(2, '0')}";
          final currentRecord = records.firstWhere(
            (r) => r.id == recordId,
            orElse: () => FinancialRecord(
                id: '',
                year: now.year,
                month: now.month,
                salary: 0,
                extraIncome: 0,
                emi: 0,
                effectiveIncome: 0,
                allocations: {},
                allocationPercentages: {},
                bucketOrder: [],
                createdAt: DateTime.now(),
                updatedAt: DateTime.now()),
          );

          // Sum Allocations (excluding Income)
          currentRecord.allocations.forEach((key, value) {
            if (key != 'Income') monthlyBudget += value;
          });

          // 2. Calculate Total Spent with Filtering
          for (var txn in txns) {
            bool exclude = false;

            if (_isBudgetMode) {
              if (txn.bucket == 'Out of Bucket') exclude = true;
              if (txn.category == 'Non-Calculated Expense') exclude = true;
            }

            if (!exclude) {
              if (txn.type == 'Expense' ||
                  (txn.type == 'Transfer Out' &&
                      txn.sourceType == TransactionSourceType.creditCard)) {
                totalSpent += txn.amount;
              }
            }
          }
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
              // --- Header Row ---
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Row(
                      children: [
                        Text("Total Account Balance",
                            style: GoogleFonts.robotoSlab(
                                color: Colors.white70, fontSize: 14)),
                        const SizedBox(width: 8),
                        // [UPDATED] Visibility Toggle Icon
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              _isBalanceVisible = !_isBalanceVisible;
                            });
                          },
                          child: Icon(
                            _isBalanceVisible
                                ? Icons.visibility_outlined
                                : Icons.visibility_off_outlined,
                            color: Colors.white54,
                            size: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                  StreamBuilder(
                    stream: Stream.periodic(
                        const Duration(seconds: 1), (_) => DateTime.now()),
                    builder: (context, snapshot) {
                      final now = DateTime.now();
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
                      final dateStr =
                          "$dayName, $dayNum $monthName ${now.year}";

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

              // [UPDATED] Masked Total Balance Logic
              Text(
                  _isBalanceVisible
                      ? "₹ ${currentBalance.toStringAsFixed(2)}"
                      : "₹ ${"*" * currentBalance.toStringAsFixed(2).length}",
                  style: GoogleFonts.openSans(
                      color: Colors.white,
                      fontSize: 20,
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

                  // Custom Column for Spent so far + Toggle
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                              radius: 4,
                              backgroundColor: _isBudgetMode
                                  ? Colors.greenAccent
                                  : Colors.orangeAccent),
                          const SizedBox(width: 8),
                          Text(_isBudgetMode ? "Budget Spent" : "Spent so far",
                              style: GoogleFonts.robotoSlab(
                                  color: Colors.white54, fontSize: 12)),
                          const SizedBox(width: 6),
                          // Toggle Icon
                          SizedBox(
                            height: 20,
                            width: 20,
                            child: IconButton(
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                              iconSize: 16,
                              tooltip: "Budget Mode",
                              onPressed: () {
                                setState(() {
                                  _isBudgetMode = !_isBudgetMode;
                                });
                              },
                              icon: Icon(
                                _isBudgetMode
                                    ? Icons.savings_rounded
                                    : Icons.savings_outlined,
                                color: _isBudgetMode
                                    ? const Color(0xFF00B4D8)
                                    : Colors.white24,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text("    ₹ ${totalSpent.toStringAsFixed(2)}",
                          style: GoogleFonts.openSans(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w600)),
                    ],
                  ),
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
            style: GoogleFonts.openSans(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w600)),
      ],
    );
  }

  Widget _buildFeatureGrid(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        double itemWidth = (constraints.maxWidth - 16) / 2;
        double itemHeight = (constraints.maxHeight - 16) / 2;
        double childAspectRatio = itemWidth / itemHeight;

        return GridView.count(
          physics: const NeverScrollableScrollPhysics(),
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
            Icon(icon, color: iconColor, size: 18),
            const SizedBox(width: 8),
            Text(label, style: GoogleFonts.robotoSlab(color: Colors.white70)),
          ],
        ),
      ),
    );
  }
}
