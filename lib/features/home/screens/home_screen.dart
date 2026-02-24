import 'package:budget/features/settings/screens/settings_screen.dart';
import 'package:budget/features/settlement/screens/settlement_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:ui';
import 'package:google_fonts/google_fonts.dart';
import 'package:rxdart/rxdart.dart';
import '../../../core/design/budgetr_colors.dart';
import '../../../core/services/service_locator.dart';

// Services
import '../../daily_expense/services/expense_service.dart';
import '../../dashboard/services/dashboard_service.dart';
import '../../backup_restore/services/backup_service.dart';

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

  bool _isBalanceVisible = false;
  final BackupService _backupService = BackupService();
  bool _needsBackup = false;
  bool _isBudgetMode = false;
  DateTime? _lastBackPressTime;

  @override
  void initState() {
    super.initState();
    _checkBackupStatus();
  }

  Future<void> _checkBackupStatus() async {
    final overdue = await _backupService.isBackupOverdue();
    if (mounted && overdue != _needsBackup) {
      setState(() => _needsBackup = overdue);
    }
  }

  void _handlePopInvoked(bool didPop) {
    if (didPop) return;

    final now = DateTime.now();
    final backButtonHasNotBeenPressedOrSnackBarHasClosed =
        _lastBackPressTime == null ||
            now.difference(_lastBackPressTime!) > const Duration(seconds: 2);

    if (backButtonHasNotBeenPressedOrSnackBarHasClosed) {
      _lastBackPressTime = now;
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.white,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          duration: const Duration(seconds: 2),
          content: Row(
            children: [
              const Icon(Icons.warning_amber_rounded,
                  color: Color(0xFFFF9F1C), size: 24),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  "Press back again to exit",
                  style: GoogleFonts.robotoSlab(
                    color: const Color(0xFF1B263B),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    } else {
      SystemNavigator.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
        canPop: false,
        onPopInvoked: _handlePopInvoked,
        child: Scaffold(
          backgroundColor: const Color(0xFF0A0E12),
          extendBodyBehindAppBar: true,
          appBar: const HomeAppBar(),
          body: Stack(
            children: [
              _buildAmbientGlow(
                  Alignment.topRight, BudgetrColors.accent.withOpacity(0.15)),
              _buildAmbientGlow(Alignment.bottomLeft,
                  const Color(0xFF4361EE).withOpacity(0.1)),
              SafeArea(
                // [DESIGN FIX] Using Column with Expanded sections for perfect fit
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 10),

                      // 1. BANNER (Optional)
                      if (_needsBackup)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 15),
                          child: InkWell(
                            onTap: () async {
                              await _backupService.shareBackup();
                              _checkBackupStatus();
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
                                      "Tap to Backup data Now!",
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

                      // 2. FINANCIAL OVERVIEW (Fixed Height)
                      _buildFinancialOverview(),

                      const SizedBox(height: 20),

                      // 3. FINANCE TODAY (EXPANDED ENGINE)
                      // This section will grow to fill all available space in the middle
                      _buildSectionHeader("Finance Today"),
                      const SizedBox(height: 12),
                      Expanded(
                        child: _buildFlexibleFeatureGrid(context),
                      ),

                      const SizedBox(height: 20),

                      // 4. MORE TOOLS (COMPACT 3-COL GRID)
                      // Fixed at the bottom, accessible without scrolling
                      _buildSectionHeader("More Tools"),
                      const SizedBox(height: 12),
                      _buildCompactQuickActionGrid(context),

                      const SizedBox(height: 12), // Bottom padding
                    ],
                  ),
                ),
              ),
            ],
          ),
        ));
  }

  // --- 100% RESPONSIVE MIDDLE SECTION ---
  Widget _buildFlexibleFeatureGrid(BuildContext context) {
    return Column(
      children: [
        // Top Row
        Expanded(
          child: Row(
            children: [
              Expanded(
                child: _buildCompactCard(
                    context,
                    "Budget Dashboard",
                    Icons.donut_large_rounded,
                    const Color(0xFF4361EE),
                    const DashboardScreen()),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildCompactCard(
                    context,
                    "Daily Expense",
                    Icons.account_balance_wallet_rounded,
                    const Color(0xFF06D6A0),
                    const DailyExpenseScreen()),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        // Bottom Row
        Expanded(
          child: Row(
            children: [
              Expanded(
                child: _buildCompactCard(
                    context,
                    "Credit Tracker",
                    Icons.credit_card_rounded,
                    const Color(0xFFEF476F),
                    const CreditTrackerScreen()),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildCompactCard(
                    context,
                    "Custom Entry",
                    Icons.post_add_rounded,
                    const Color(0xFFFFD166),
                    const CustomEntryDashboard()),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // --- COMPACT 3-COLUMN BOTTOM GRID ---
  Widget _buildCompactQuickActionGrid(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min, // Takes minimal space needed
      children: [
        // Row 1
        Row(
          children: [
            Expanded(
                child: _buildVerticalActionChip(
                    context,
                    "Goals & Loans",
                    Icons.rocket_launch_rounded,
                    const Color(0xFF7209B7),
                    const GoalsLoansDashboard())),
            const SizedBox(width: 12),
            Expanded(
                child: _buildVerticalActionChip(
                    context,
                    "Investments",
                    Icons.insights_rounded,
                    const Color(0xFF3F37C9),
                    const InvestmentScreen())),
            const SizedBox(width: 12),
            Expanded(
                child: _buildVerticalActionChip(
                    context,
                    "Net Worth",
                    Icons.diamond_rounded,
                    const Color(0xFF4CC9F0),
                    const NetWorthScreen())),
          ],
        ),
        const SizedBox(height: 12),
        // Row 2
        Row(
          children: [
            Expanded(
                child: _buildVerticalActionChip(
                    context,
                    "Budget Buckets",
                    Icons.widgets_rounded,
                    const Color(0xFFF72585),
                    const SettingsScreen())),
            const SizedBox(width: 12),
            Expanded(
                child: _buildVerticalActionChip(
                    context,
                    "Settlements",
                    Icons.fact_check_rounded,
                    const Color(0xFFFF9F1C),
                    const SettlementScreen())),
            const SizedBox(width: 12),
            Expanded(
                child: _buildVerticalActionChip(
                    context,
                    "Settings",
                    Icons.tune_rounded,
                    const Color(0xFFADB5BD),
                    const ConfigurationMenuScreen())),
          ],
        ),
      ],
    );
  }

  // [UPDATED] Using _BouncyButton for Tactile Feedback
  Widget _buildVerticalActionChip(BuildContext context, String label,
      IconData icon, Color iconColor, Widget page) {
    return _BouncyButton(
      onTap: () => Navigator.push(
          context, MaterialPageRoute(builder: (context) => page)),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.white10),
          color: Colors.white.withOpacity(0.03),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: iconColor, size: 22),
            const SizedBox(height: 6),
            Text(
              label,
              textAlign: TextAlign.center,
              style: GoogleFonts.robotoSlab(
                  color: Colors.white70,
                  fontSize: 11, // Slightly smaller font to fit 3 cols
                  height: 1.1),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  // [UPDATED] Using _BouncyButton for Tactile Feedback
  Widget _buildCompactCard(BuildContext context, String title, IconData icon,
      Color color, Widget page) {
    return _BouncyButton(
      onTap: () => Navigator.push(
          context, MaterialPageRoute(builder: (context) => page)),
      child: Container(
        // Removed hardcoded constraints, relies on parent Expanded
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(8), // Smoother corners
          border: Border.all(color: Colors.white.withOpacity(0.2)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 36), // Slightly larger icon
            const SizedBox(height: 10),
            Text(title,
                textAlign: TextAlign.center,
                style: GoogleFonts.robotoSlab(
                    color: Colors.white, fontWeight: FontWeight.w500)),
          ],
        ),
      ),
    );
  }

  // ... [UNCHANGED HELPERS BELOW] ...

  Widget _buildSectionHeader(String title) {
    return Text(title,
        style: GoogleFonts.robotoSlab(
            color: Colors.white,
            fontSize: 16,
            fontWeight:
                FontWeight.bold)); // Slightly smaller header to save space
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

          currentRecord.allocations.forEach((key, value) {
            if (key != 'Income') monthlyBudget += value;
          });

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
          padding: const EdgeInsets.all(20), // Reduced padding slightly
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8), // Match rounded look
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.white.withOpacity(0.08),
                Colors.white.withOpacity(0.03),
              ],
            ),
            border: Border.all(color: Colors.white.withOpacity(0.2)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
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
                                color: Colors.white70, fontSize: 13)),
                        const SizedBox(width: 8),
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
                                  fontSize: 11,
                                  fontWeight: FontWeight.w500)),
                          const SizedBox(height: 2),
                          Text(timeStr,
                              style: GoogleFonts.robotoSlab(
                                  color: Colors.white,
                                  fontSize: 13,
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
              Text(
                  _isBalanceVisible
                      ? "₹ ${currentBalance.toStringAsFixed(2)}"
                      : "₹ ${"*" * currentBalance.toStringAsFixed(2).length}",
                  style: GoogleFonts.openSans(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1)),
              const SizedBox(height: 16), // Reduced gap
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildMiniStat(
                      "Monthly Budget",
                      "    ₹ ${monthlyBudget.toStringAsFixed(2)}",
                      Colors.blueAccent),
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
                                  color: Colors.white54, fontSize: 11)),
                          const SizedBox(width: 6),
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
                              fontSize: 15,
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
                    color: Colors.white54, fontSize: 11)),
          ],
        ),
        const SizedBox(height: 4),
        Text(value,
            style: GoogleFonts.openSans(
                color: Colors.white,
                fontSize: 15,
                fontWeight: FontWeight.w600)),
      ],
    );
  }
}

// ==============================================================================
//  [NEW] PRIVATE HELPER FOR TACTILE BOUNCE EFFECT
// ==============================================================================
class _BouncyButton extends StatefulWidget {
  final Widget child;
  final VoidCallback onTap;

  const _BouncyButton({required this.child, required this.onTap});

  @override
  State<_BouncyButton> createState() => _BouncyButtonState();
}

class _BouncyButtonState extends State<_BouncyButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _controller.forward(),
      onTapUp: (_) {
        _controller.reverse();
        widget.onTap();
      },
      onTapCancel: () => _controller.reverse(),
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: widget.child,
      ),
    );
  }
}
