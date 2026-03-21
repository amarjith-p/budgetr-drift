import 'package:budget/features/backup_restore/screens/backup_screen.dart';
import 'package:budget/features/investments/screens/portfolio_dashboard.dart';
import 'package:budget/features/recurring/screens/recurring_dashboard.dart';
import 'package:budget/features/settings/screens/category_manager_screen.dart';
import 'package:budget/features/settings/screens/settings_screen.dart';
import 'package:budget/features/settlement/screens/settlement_screen.dart';
import 'package:budget/features/trip_mode/screens/trip_dashboard_screen.dart';
import 'package:budget/features/vault/screens/vault_auth_screen.dart';
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
import '../../credit_tracker/services/credit_service.dart'; // [NEW IMPORT]
import '../../settings/services/settings_service.dart'; // [NEW IMPORT]

// Models
import '../../dashboard/models/dashboard_transaction.dart';
import '../../../core/models/financial_record_model.dart';
import '../../credit_tracker/models/credit_models.dart'; // [NEW IMPORT]
import '../../daily_expense/models/expense_models.dart'; // [NEW IMPORT]

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
  final creditService = locator<CreditService>();
  final settingsService = locator<SettingsService>();

  bool _isBalanceVisible = false;
  final BackupService _backupService = BackupService();
  bool _needsBackup = false;
  bool _isBudgetMode = false;
  DateTime? _lastBackPressTime;
  final PageController _toolsPageController = PageController();
  int _currentToolPage = 0;

  bool _showTopBanner = false;

  // [NEW] Reactive Stream to calculate Credit Shortfall Live
  late Stream<bool> _creditShortfallStream;

  @override
  void initState() {
    super.initState();
    _checkBackupStatus();

    // [NEW] Combine the Live Cards Data with the Live Linked Bank Accounts Data
    _creditShortfallStream = Rx.combineLatest2(
        creditService.getCreditCards(),
        settingsService.watchCreditPayableAccountIds().switchMap((ids) {
          return expenseService.watchAccountsByIds(ids);
        }), (List<CreditCardModel> cards,
            List<ExpenseAccountModel> linkedAccounts) {
      double totalDebt = cards
          .where((c) => c.currentBalance > 0)
          .fold(0.0, (sum, c) => sum + c.currentBalance);
      double allocatedFunds =
          linkedAccounts.fold(0.0, (sum, acc) => sum + acc.currentBalance);

      // Return true if there's a shortfall and there's actually a debt
      return (allocatedFunds - totalDebt < 0) && (totalDebt > 0.01);
    });
  }

  Future<void> _checkBackupStatus() async {
    final overdue = await _backupService.isBackupOverdue();
    if (mounted && overdue != _needsBackup) {
      setState(() {
        _needsBackup = overdue;
        _showTopBanner = overdue;
      });

      if (_needsBackup) {
        Future.delayed(const Duration(seconds: 8), () {
          if (mounted) {
            setState(() => _showTopBanner = false);
          }
        });
      }
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
          appBar: HomeAppBar(
            needsBackup: _needsBackup,
            onBackupTap: () async {
              setState(() => _showTopBanner = false);
              await _backupService.shareBackup();
              _checkBackupStatus();
            },
          ),
          body: Stack(
            children: [
              _buildAmbientGlow(
                  Alignment.topRight, BudgetrColors.accent.withOpacity(0.15)),
              _buildAmbientGlow(Alignment.bottomLeft,
                  const Color(0xFF4361EE).withOpacity(0.1)),
              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 10),

                      // 2. FINANCIAL OVERVIEW
                      _buildFinancialOverview(),

                      const SizedBox(height: 20),

                      // 3. FINANCE TODAY
                      _buildSectionHeader("Finance Today"),
                      const SizedBox(height: 12),
                      Expanded(
                        child: _buildFlexibleFeatureGrid(context),
                      ),

                      const SizedBox(height: 20),

                      // 4. MORE TOOLS
                      _buildSectionHeader("More Tools"),
                      const SizedBox(height: 12),
                      _buildCompactQuickActionGrid(context),

                      const SizedBox(height: 12),
                    ],
                  ),
                ),
              ),
              AnimatedPositioned(
                duration: const Duration(milliseconds: 600),
                curve: Curves.elasticOut,
                top: _showTopBanner
                    ? MediaQuery.of(context).padding.top + 55
                    : -120,
                left: 20,
                right: 20,
                child: Material(
                  color: Colors.transparent,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: Colors.redAccent.withOpacity(0.95),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.redAccent.withOpacity(0.3),
                          blurRadius: 15,
                          offset: const Offset(0, 8),
                        )
                      ],
                    ),
                    child: Row(
                      children: [
                        // const Icon(Icons.arrow_upward_rounded,
                        //     color: Colors.white, size: 24),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            "Data Backup Overdue! Click the ⚠️ icon above to backup now.",
                            style: GoogleFonts.robotoSlab(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ),
                        GestureDetector(
                          onTap: () => setState(() => _showTopBanner = false),
                          child: const Icon(Icons.close_rounded,
                              color: Colors.white70, size: 24),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ));
  }

  Widget _buildFlexibleFeatureGrid(BuildContext context) {
    return Column(
      children: [
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
        Expanded(
          child: Row(
            children: [
              Expanded(
                // [UPDATED] Passed the Shortfall Stream specifically to the Credit Card Tile
                child: _buildCompactCard(
                    context,
                    "Credit Tracker",
                    Icons.credit_card_rounded,
                    const Color(0xFFEF476F),
                    const CreditTrackerScreen(),
                    warningStream: _creditShortfallStream),
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

  Widget _buildCompactQuickActionGrid(BuildContext context) {
    final List<Widget> page1 = [
      _buildVerticalActionChip(
          context,
          "Goals & Loans",
          Icons.rocket_launch_rounded,
          const Color(0xFFE63946),
          const GoalsLoansDashboard()),
      _buildVerticalActionChip(context, "Investments", Icons.insights_rounded,
          const Color(0xFFFF7F11), const PortfolioDashboard()),
      _buildVerticalActionChip(context, "Net Worth", Icons.diamond_rounded,
          const Color(0xFFFFB703), const NetWorthScreen()),
      _buildVerticalActionChip(context, "Budget Buckets", Icons.widgets_rounded,
          const Color(0xFFFFE066), const SettingsScreen()),
      _buildVerticalActionChip(context, "Settlements", Icons.fact_check_rounded,
          const Color(0xFF2DC653), const SettlementScreen()),
      _buildVerticalActionChip(
          context,
          "Recurring Txns",
          Icons.autorenew_rounded,
          const Color(0xFF2EC4B6),
          const RecurringDashboard()),
    ];

    final List<Widget> page2 = [
      _buildVerticalActionChip(
          context,
          "Trip Mode",
          Icons.flight_takeoff_rounded,
          const Color(0xFF00B4D8),
          const TripDashboardScreen()),
      _buildVerticalActionChip(
          context,
          "Live Portfolio",
          Icons.bar_chart_rounded,
          const Color(0xFF4361EE),
          const InvestmentScreen()),
      _buildVerticalActionChip(context, "Secure Vault", Icons.security_rounded,
          const Color(0xFFF72585), const VaultAuthScreen()),
      _buildVerticalActionChip(context, "Categories", Icons.category_outlined,
          const Color(0xFF9D4EDD), const CategoryManagerScreen()),
      _buildVerticalActionChip(
          context,
          "Backup & Restore",
          Icons.settings_backup_restore_rounded,
          const Color(0xFF9C6644),
          const BackupScreen()),
      _buildVerticalActionChip(
          context,
          "Settings",
          Icons.tune_rounded,
          const Color.fromARGB(255, 252, 252, 252),
          const ConfigurationMenuScreen()),
      // const SizedBox.shrink(),
      // const SizedBox.shrink(),
      // const SizedBox.shrink(),
    ];

    final pages = [page1, page2];

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          height: 160,
          child: PageView.builder(
            controller: _toolsPageController,
            onPageChanged: (index) {
              setState(() {
                _currentToolPage = index;
              });
            },
            itemCount: pages.length,
            itemBuilder: (context, pageIndex) {
              final items = pages[pageIndex];
              return Column(
                children: [
                  Row(
                    children: [
                      Expanded(child: items[0]),
                      const SizedBox(width: 12),
                      Expanded(child: items[1]),
                      const SizedBox(width: 12),
                      Expanded(child: items[2]),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(child: items[3]),
                      const SizedBox(width: 12),
                      Expanded(child: items[4]),
                      const SizedBox(width: 12),
                      Expanded(child: items[5]),
                    ],
                  ),
                ],
              );
            },
          ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            pages.length,
            (index) => AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              margin: const EdgeInsets.symmetric(horizontal: 4),
              height: 6,
              width: _currentToolPage == index ? 16 : 6,
              decoration: BoxDecoration(
                color: _currentToolPage == index
                    ? const Color(0xFF4361EE)
                    : Colors.white24,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
        ),
      ],
    );
  }

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
                  color: Colors.white70, fontSize: 11, height: 1.1),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  // [UPDATED] Re-engineered to support an optional warning badge overlay
  Widget _buildCompactCard(BuildContext context, String title, IconData icon,
      Color color, Widget page,
      {Stream<bool>? warningStream}) {
    return _BouncyButton(
      onTap: () => Navigator.push(
          context, MaterialPageRoute(builder: (context) => page)),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.white.withOpacity(0.2)),
        ),
        child: Stack(
          children: [
            Positioned.fill(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(icon, color: color, size: 36),
                  const SizedBox(height: 10),
                  Text(title,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.robotoSlab(
                          color: Colors.white, fontWeight: FontWeight.w500)),
                ],
              ),
            ),

            // The Dynamic Warning Badge
            if (warningStream != null)
              Positioned(
                top: 8,
                right: 8,
                child: StreamBuilder<bool>(
                  stream: warningStream,
                  builder: (context, snapshot) {
                    if (snapshot.hasData && snapshot.data == true) {
                      return Container(
                        padding: const EdgeInsets.all(6),
                        // decoration: BoxDecoration(
                        //   color: const Color.fromARGB(255, 252, 213, 217)
                        //       .withOpacity(0.1), // Light Red glow
                        //   shape: BoxShape.circle,
                        // ),
                        child: const Icon(Icons.warning_rounded,
                            color: Color(0xFFE71D36), size: 14),
                      );
                    }
                    return const SizedBox.shrink();
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(title,
        style: GoogleFonts.robotoSlab(
            color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold));
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
          padding: const EdgeInsets.all(20),
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
              const SizedBox(height: 16),
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
