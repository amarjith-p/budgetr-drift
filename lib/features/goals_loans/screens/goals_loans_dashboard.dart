import 'package:budget/core/widgets/modern_loader.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:intl/intl.dart';
import '../../../core/design/budgetr_colors.dart';
import '../../../core/design/budgetr_styles.dart';
import '../services/goal_loan_service.dart';
import '../models/goal_loan_models.dart';
import 'goal_detail_screen.dart';
import 'loan_detail_screen.dart';
import '../widgets/add_goal_sheet.dart';
import '../widgets/add_loan_sheet.dart';

class GoalsLoansDashboard extends StatefulWidget {
  const GoalsLoansDashboard({super.key});

  @override
  State<GoalsLoansDashboard> createState() => _GoalsLoansDashboardState();
}

class _GoalsLoansDashboardState extends State<GoalsLoansDashboard>
    with TickerProviderStateMixin {
  // State
  int _selectedIndex = 0; // 0 = Goals, 1 = Loans

  // Animation
  bool _isFabExpanded = false;
  late AnimationController _fabAnimController;
  late Animation<double> _fabAnimation;

  @override
  void initState() {
    super.initState();
    _fabAnimController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 200));
    _fabAnimation =
        CurvedAnimation(parent: _fabAnimController, curve: Curves.easeOut);
  }

  @override
  void dispose() {
    _fabAnimController.dispose();
    super.dispose();
  }

  void _toggleFab() {
    setState(() {
      _isFabExpanded = !_isFabExpanded;
      if (_isFabExpanded) {
        _fabAnimController.forward();
      } else {
        _fabAnimController.reverse();
      }
    });
  }

  void _showAddSheet(int typeIndex) {
    if (_isFabExpanded) _toggleFab();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) {
        if (typeIndex == 0) {
          return const AddGoalSheet();
        } else {
          return const AddLoanSheet();
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A), // Deep Slate Background
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                // 1. Header
                _buildHeader(),

                // 2. Segmented Switcher
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  child: _buildSegmentedToggle(),
                ),

                // 3. Content Area
                Expanded(
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    child: _selectedIndex == 0
                        ? _buildGoalsView()
                        : _buildLoansView(),
                  ),
                ),
              ],
            ),

            // Dimmer Overlay
            if (_isFabExpanded)
              GestureDetector(
                onTap: _toggleFab,
                child: Container(
                  color: Colors.black.withOpacity(0.6),
                  width: double.infinity,
                  height: double.infinity,
                ),
              ),

            // FAB Menu
            Positioned(
              bottom: 24,
              right: 24,
              child: _buildFabMenu(),
            ),
          ],
        ),
      ),
    );
  }

  // --- 1. HEADER ---
  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("",
                  style: TextStyle(
                      color: Colors.white38,
                      fontSize: 11,
                      letterSpacing: 1.5,
                      fontWeight: FontWeight.bold)),
              SizedBox(height: 4),
              Text("Financial Goals & Loans",
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold)),
            ],
          ),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.flag_circle_rounded, color: Colors.white70),
          )
        ],
      ),
    );
  }

  // --- 2. SEGMENTED TOGGLE ---
  Widget _buildSegmentedToggle() {
    return Container(
      height: 40,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final width = constraints.maxWidth / 2;
          return Stack(
            children: [
              AnimatedAlign(
                alignment: _selectedIndex == 0
                    ? Alignment.centerLeft
                    : Alignment.centerRight,
                duration: const Duration(milliseconds: 250),
                curve: Curves.easeInOut,
                child: Container(
                  width: width,
                  decoration: BoxDecoration(
                      color: _selectedIndex == 0
                          ? BudgetrColors.accent
                          : BudgetrColors.error,
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: [
                        BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 2,
                            offset: const Offset(0, 1))
                      ]),
                ),
              ),
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _selectedIndex = 0),
                      behavior: HitTestBehavior.opaque,
                      child: Center(
                        child: Text("GOALS",
                            style: TextStyle(
                                color: _selectedIndex == 0
                                    ? Colors.white
                                    : Colors.white54,
                                fontWeight: FontWeight.bold,
                                fontSize: 11)),
                      ),
                    ),
                  ),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _selectedIndex = 1),
                      behavior: HitTestBehavior.opaque,
                      child: Center(
                        child: Text("LOANS",
                            style: TextStyle(
                                color: _selectedIndex == 1
                                    ? Colors.white
                                    : Colors.white54,
                                fontWeight: FontWeight.bold,
                                fontSize: 11)),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }

  // --- 3. VIEWS (UPDATED FOR PROGRESS BAR FIX) ---

  Widget _buildGoalsView() {
    return StreamBuilder<List<GoalModel>>(
      stream: GetIt.I<GoalLoanService>().getActiveGoals(),
      builder: (context, snapshot) {
        // [FIX] Handle Loading State Explicitly
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: ModernLoader());
        }

        // [FIX] Handle Error State (Stops infinite spinner on DB error)
        if (snapshot.hasError) {
          return const Center(
              child: Text("Unable to load goals",
                  style: TextStyle(color: Colors.white24)));
        }

        final goals = snapshot.data ?? [];

        if (goals.isEmpty) {
          return _buildEmptyState("No active goals", Icons.flag_outlined);
        }

        return ListView.separated(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
          itemCount: goals.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final goal = goals[index];
            return _GoalCard(
                goal: goal,
                onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => GoalDetailScreen(goal: goal))));
          },
        );
      },
    );
  }

  Widget _buildLoansView() {
    return StreamBuilder<List<LoanModel>>(
      stream: GetIt.I<GoalLoanService>().getActiveLoans(),
      builder: (context, snapshot) {
        // [FIX] Handle Loading State Explicitly
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: ModernLoader());
        }

        // [FIX] Handle Error State (Stops infinite spinner on DB error)
        if (snapshot.hasError) {
          return const Center(
              child: Text("Unable to load loans",
                  style: TextStyle(color: Colors.white24)));
        }

        final loans = snapshot.data ?? [];

        if (loans.isEmpty) {
          return _buildEmptyState("Debt free", Icons.check_circle_outline);
        }

        final totalBorrowed =
            loans.fold(0.0, (sum, item) => sum + item.principalAmount);
        final totalOutstanding =
            loans.fold(0.0, (sum, item) => sum + item.remaining);

        return Column(
          children: [
            // Loan Summary Card
            _buildSummaryHeader(
                item1Label: "Total Loan Amount",
                item1Value: totalBorrowed,
                item2Label: "Total Due Payable",
                item2Value: totalOutstanding,
                item2Color: BudgetrColors.error),

            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
                itemCount: loans.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final loan = loans[index];
                  return _LoanCard(
                      loan: loan,
                      onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => LoanDetailScreen(loan: loan))));
                },
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildSummaryHeader({
    required String item1Label,
    required double item1Value,
    required String item2Label,
    required double item2Value,
    Color? item2Color,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
          color: const Color(0xFF1E293B),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white.withOpacity(0.05)),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 4,
                offset: const Offset(0, 2))
          ]),
      child: Row(
        children: [
          Expanded(child: _buildDashboardStat(item1Label, item1Value)),
          Container(width: 1, height: 24, color: Colors.white10),
          Expanded(
              child: _buildDashboardStat(item2Label, item2Value,
                  valueColor: item2Color)),
        ],
      ),
    );
  }

  Widget _buildDashboardStat(String label, double value, {Color? valueColor}) {
    // 2 Decimal Formatting for Summary
    final fmt = NumberFormat('#,##0.00');
    final displayValue = value > 9999999
        ? NumberFormat.compact().format(value)
        : fmt.format(value);

    return Column(
      children: [
        Text(label,
            style: const TextStyle(
                color: Colors.white38,
                fontSize: 10,
                fontWeight: FontWeight.bold)),
        const SizedBox(height: 2),
        Text("₹$displayValue",
            style: TextStyle(
                color: valueColor ?? Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16)),
      ],
    );
  }

  Widget _buildEmptyState(String text, IconData icon) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 48, color: Colors.white.withOpacity(0.1)),
          const SizedBox(height: 16),
          Text(text,
              style: const TextStyle(color: Colors.white24, fontSize: 14)),
        ],
      ),
    );
  }

  Widget _buildFabMenu() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildFabOption("New Loan", Icons.credit_score, BudgetrColors.error,
            () => _showAddSheet(1)),
        const SizedBox(height: 16),
        _buildFabOption("New Goal", Icons.flag_outlined, BudgetrColors.success,
            () => _showAddSheet(0)),
        const SizedBox(height: 16),
        FloatingActionButton(
          onPressed: _toggleFab,
          backgroundColor: Colors.white,
          mini: true,
          child: AnimatedIcon(
            icon: AnimatedIcons.menu_close,
            progress: _fabAnimController,
            color: Colors.black,
          ),
        ),
      ],
    );
  }

  Widget _buildFabOption(
      String label, IconData icon, Color color, VoidCallback onTap) {
    return ScaleTransition(
      scale: _fabAnimation,
      alignment: Alignment.bottomRight,
      child: GestureDetector(
        onTap: onTap,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(6),
                  boxShadow: const [
                    BoxShadow(
                        color: Colors.black26,
                        blurRadius: 4,
                        offset: Offset(0, 2))
                  ]),
              child: Text(label,
                  style: const TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                      fontSize: 11)),
            ),
            const SizedBox(width: 8),
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                  boxShadow: const [
                    BoxShadow(
                        color: Colors.black26,
                        blurRadius: 4,
                        offset: Offset(0, 2))
                  ]),
              child: Icon(icon, color: Colors.white, size: 18),
            ),
          ],
        ),
      ),
    );
  }
}

// --- MODERN CARDS ---

class _GoalCard extends StatelessWidget {
  final GoalModel goal;
  final VoidCallback onTap;
  const _GoalCard({required this.goal, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final color = Color(goal.color);
    final remaining = goal.targetAmount - goal.currentAmount;
    final currencyFmt = NumberFormat('#,##0.00');

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF1E293B),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withOpacity(0.05)),
        ),
        child: Row(
          children: [
            // Left: Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Icon + Name
                  Row(
                    children: [
                      Icon(Icons.flag_circle_sharp, color: color, size: 16),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          goal.name,
                          style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 15),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Key Metrics
                  _buildMetricRow(
                      "Current", currencyFmt.format(goal.currentAmount), color),
                  const SizedBox(height: 4),
                  _buildMetricRow("Target",
                      currencyFmt.format(goal.targetAmount), Colors.white54),
                  const SizedBox(height: 4),
                  _buildMetricRow("Remaining", currencyFmt.format(remaining),
                      Colors.white38),
                ],
              ),
            ),

            const SizedBox(width: 16),

            // Right: Donut Chart
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: 60,
                  height: 60,
                  child: Stack(
                    children: [
                      Center(
                        child: SizedBox(
                          width: 60,
                          height: 60,
                          child: CircularProgressIndicator(
                            value: goal.progress,
                            backgroundColor: Colors.white10,
                            color: color,
                            strokeWidth: 6,
                            strokeCap: StrokeCap.round,
                          ),
                        ),
                      ),
                      Center(
                        child: Text("${(goal.progress * 100).toInt()}%",
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.bold)),
                      )
                    ],
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget _buildMetricRow(String label, String value, Color valueColor) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
            width: 60,
            child: Text(label,
                style: const TextStyle(color: Colors.white38, fontSize: 10))),
        Text("₹ $value",
            style: TextStyle(
                color: valueColor, fontWeight: FontWeight.bold, fontSize: 12)),
      ],
    );
  }
}

class _LoanCard extends StatelessWidget {
  final LoanModel loan;
  final VoidCallback onTap;
  const _LoanCard({required this.loan, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final progress =
        (loan.totalAmount == 0) ? 0.0 : (loan.paidAmount / loan.totalAmount);
    final currencyFmt = NumberFormat('#,##0.00');

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF1E293B),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withOpacity(0.05)),
        ),
        child: Row(
          children: [
            // Left: Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Icon + Name
                  Row(
                    children: [
                      const Icon(Icons.credit_score_sharp,
                          color: BudgetrColors.error, size: 16),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          loan.title,
                          style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 15),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Key Metrics
                  _buildMetricRow("Remaining",
                      currencyFmt.format(loan.remaining), BudgetrColors.error),
                  const SizedBox(height: 4),
                  _buildMetricRow("Payable",
                      currencyFmt.format(loan.totalAmount), Colors.white54),
                  const SizedBox(height: 4),
                  // EMI Row with date
                  Row(
                    children: [
                      SizedBox(
                          width: 60,
                          child: const Text("EMI",
                              style: TextStyle(
                                  color: Colors.white38, fontSize: 10))),
                      Text("₹ ${currencyFmt.format(loan.emiAmount ?? 0)}",
                          style: const TextStyle(
                              color: Colors.white70,
                              fontWeight: FontWeight.bold,
                              fontSize: 12)),
                      if (loan.nextPaymentDate != null)
                        Text(
                            "  (${DateFormat('dd/MMM').format(loan.nextPaymentDate!)})",
                            style: const TextStyle(
                                color: Colors.white38, fontSize: 10)),
                    ],
                  )
                ],
              ),
            ),

            const SizedBox(width: 16),

            // Right: Donut Chart
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: 60,
                  height: 60,
                  child: Stack(
                    children: [
                      Center(
                        child: SizedBox(
                          width: 60,
                          height: 60,
                          child: CircularProgressIndicator(
                            value: progress,
                            backgroundColor: Colors.white10,
                            color: BudgetrColors.error,
                            strokeWidth: 6,
                            strokeCap: StrokeCap.round,
                          ),
                        ),
                      ),
                      Center(
                        child: Text("${(progress * 100).toInt()}%",
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.bold)),
                      )
                    ],
                  ),
                ),
                const SizedBox(height: 6),
                const Text("PAID",
                    style: TextStyle(
                        color: Colors.white38,
                        fontSize: 8,
                        fontWeight: FontWeight.bold)),
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget _buildMetricRow(String label, String value, Color valueColor) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
            width: 60,
            child: Text(label,
                style: const TextStyle(color: Colors.white38, fontSize: 10))),
        Text("₹ $value",
            style: TextStyle(
                color: valueColor, fontWeight: FontWeight.bold, fontSize: 12)),
      ],
    );
  }
}
