import 'dart:ui'; // Required for ImageFilter
import 'package:budget/core/widgets/futuristic_loader.dart';
import 'package:budget/core/widgets/glass_card.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:intl/intl.dart';
import '../../../core/design/budgetr_colors.dart';
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
  bool _showHistory = false; // Toggle for Active vs History

  // Animation
  bool _isFabExpanded = false;
  late AnimationController _fabAnimController;
  late Animation<double> _fabAnimation;
  late Animation<double> _rotateAnimation;

  @override
  void initState() {
    super.initState();
    _fabAnimController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 300));

    // Bounce effect for menu items
    _fabAnimation =
        CurvedAnimation(parent: _fabAnimController, curve: Curves.easeOutBack);

    // Smooth rotation for main FAB
    _rotateAnimation =
        CurvedAnimation(parent: _fabAnimController, curve: Curves.easeInOut);
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
      body: Stack(
        children: [
          // Background Gradient Element
          Positioned(
            top: -100,
            right: -100,
            child: ImageFiltered(
              imageFilter: ImageFilter.blur(sigmaX: 80, sigmaY: 80),
              child: Container(
                width: 300,
                height: 300,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: (_selectedIndex == 0
                          ? BudgetrColors.accent
                          : BudgetrColors.error)
                      .withOpacity(0.2),
                ),
              ),
            ),
          ),

          SafeArea(
            child: Column(
              children: [
                // 1. Updated App Bar
                _buildModernAppBar(),

                // 2. Updated Toggle Pills
                _buildControlsArea(),

                // 3. Content Area
                Expanded(
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 400),
                    switchInCurve: Curves.easeOutBack,
                    switchOutCurve: Curves.easeIn,
                    child: _selectedIndex == 0
                        ? _buildGoalsView()
                        : _buildLoansView(),
                  ),
                ),
              ],
            ),
          ),

          // --- BLURRED DIMMER OVERLAY ---
          if (_isFabExpanded)
            Positioned.fill(
              child: GestureDetector(
                onTap: _toggleFab,
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                  child: Container(
                    color: Colors.black.withOpacity(0.4),
                  ),
                ),
              ),
            ),

          // --- MODERN FAB MENU ---
          Positioned(
            bottom: 24,
            right: 24,
            child: _buildFabMenu(),
          ),
        ],
      ),
    );
  }

  // --- 1. MODERN APP BAR ---
  Widget _buildModernAppBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        children: [
          // Back Button (Glass)
          GestureDetector(
            onTap: () => Navigator.maybePop(context),
            child: GlassCard(
              borderRadius: 12,
              padding: const EdgeInsets.all(10),
              margin: EdgeInsets.zero,
              color: Colors.white.withOpacity(0.05),
              child: const Icon(Icons.arrow_back_rounded,
                  color: Colors.white70, size: 20),
            ),
          ),

          const SizedBox(width: 16),

          // Title
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text("SAVE & BORROW",
                    style: TextStyle(
                        color: Colors.white38,
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 2.0)),
                SizedBox(height: 2),
                Text("Goals & Loans Tracker",
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        letterSpacing: -0.5)),
              ],
            ),
          ),

          // Action Button (Glass)
          GlassCard(
            borderRadius: 12,
            padding: const EdgeInsets.all(10),
            margin: EdgeInsets.zero,
            color: Colors.white.withOpacity(0.05),
            child: const Icon(Icons.more_horiz_rounded,
                color: Colors.white70, size: 20),
          ),
        ],
      ),
    );
  }

  // --- 2. CONTROLS AREA ---
  Widget _buildControlsArea() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: _buildMainToggle(),
        ),
        const SizedBox(height: 16),
        // Active/History Filter
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _selectedIndex == 0 ? "Goal Progress" : "Debt Overview",
                style: const TextStyle(
                    color: Colors.white38,
                    fontSize: 12,
                    fontWeight: FontWeight.w600),
              ),
              _buildHistoryFilter(),
            ],
          ),
        ),
        const SizedBox(height: 12),
      ],
    );
  }

  // Neon Pill Toggle
  Widget _buildMainToggle() {
    return Container(
      height: 56,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color(0xFF020617), // Very dark slate
        borderRadius: BorderRadius.circular(100),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
        boxShadow: [
          BoxShadow(
              color: Colors.white.withOpacity(0.02),
              blurRadius: 2,
              spreadRadius: 0,
              offset: const Offset(0, 1)),
        ],
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final width = constraints.maxWidth / 2;
          return Stack(
            children: [
              // The Glowing Slider
              AnimatedAlign(
                alignment: _selectedIndex == 0
                    ? Alignment.centerLeft
                    : Alignment.centerRight,
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeOutBack,
                child: Container(
                  width: width,
                  height: double.infinity,
                  decoration: BoxDecoration(
                    color: _selectedIndex == 0
                        ? BudgetrColors.accent
                        : BudgetrColors.error,
                    borderRadius: BorderRadius.circular(100),
                    boxShadow: [
                      BoxShadow(
                        color: (_selectedIndex == 0
                                ? BudgetrColors.accent
                                : BudgetrColors.error)
                            .withOpacity(0.4),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                ),
              ),
              // Text Labels
              Row(
                children: [
                  _buildToggleText("GOALS", 0),
                  _buildToggleText("LOANS", 1),
                ],
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildToggleText(String label, int index) {
    final isSelected = _selectedIndex == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedIndex = index),
        behavior: HitTestBehavior.opaque,
        child: AnimatedDefaultTextStyle(
          duration: const Duration(milliseconds: 200),
          style: TextStyle(
            fontFamily: 'Roboto',
            color: isSelected ? Colors.white : Colors.white54,
            fontWeight: isSelected ? FontWeight.w900 : FontWeight.w600,
            fontSize: 13,
            letterSpacing: 1.0,
          ),
          child: Center(child: Text(label)),
        ),
      ),
    );
  }

  // Refined History Filter
  Widget _buildHistoryFilter() {
    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildFilterChip("Active", !_showHistory),
          _buildFilterChip("History", _showHistory),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, bool isSelected) {
    return GestureDetector(
      onTap: () {
        if (!isSelected) setState(() => _showHistory = !_showHistory);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color:
              isSelected ? Colors.white.withOpacity(0.15) : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.white38,
            fontSize: 11,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  // --- 3. VIEWS ---

  Widget _buildGoalsView() {
    return StreamBuilder<List<GoalModel>>(
      stream: GetIt.I<GoalLoanService>().getGoals(showHistory: _showHistory),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
              child: FuturisticLoader(size: 80, label: "LOADING GOALS..."));
        }

        if (snapshot.hasError) {
          return const Center(
              child: Text("Unable to load goals",
                  style: TextStyle(color: Colors.white24)));
        }

        final goals = snapshot.data ?? [];

        if (goals.isEmpty) {
          return _buildEmptyState(
            _showHistory ? "No completed goals yet" : "No active goals",
            _showHistory ? Icons.emoji_events_outlined : Icons.flag_outlined,
            _showHistory
                ? "Keep pushing! You'll get there."
                : "Create a goal to start tracking.",
          );
        }

        return ListView.separated(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 100),
          itemCount: goals.length,
          separatorBuilder: (_, __) => const SizedBox(height: 16),
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
      stream: GetIt.I<GoalLoanService>().getLoans(showHistory: _showHistory),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
              child: FuturisticLoader(size: 80, label: "LOADING LOANS..."));
        }

        if (snapshot.hasError) {
          return const Center(
              child: Text("Unable to load loans",
                  style: TextStyle(color: Colors.white24)));
        }

        final loans = snapshot.data ?? [];

        if (loans.isEmpty) {
          return _buildEmptyState(
            _showHistory ? "No closed loans" : "Debt free",
            _showHistory
                ? Icons.check_circle_outline
                : Icons.thumb_up_alt_outlined,
            _showHistory
                ? "Your financial victories will appear here."
                : "Great job! You have no active debts.",
          );
        }

        // Calculations
        final totalBorrowed =
            loans.fold(0.0, (sum, item) => sum + item.principalAmount);
        final totalOutstanding =
            loans.fold(0.0, (sum, item) => sum + item.remaining);

        return Column(
          children: [
            // Loan Summary Card (Only show if Active to stay relevant)
            if (!_showHistory)
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                child: _buildSummaryHeader(
                    item1Label: "TOTAL PRINCIPAL",
                    item1Value: totalBorrowed,
                    item2Label: "OUTSTANDING",
                    item2Value: totalOutstanding,
                    item2Color: BudgetrColors.error),
              ),

            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
                itemCount: loans.length,
                separatorBuilder: (_, __) => const SizedBox(height: 16),
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
    return GlassCard(
      borderRadius: 16,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            Expanded(
                child:
                    _buildDashboardStat(item1Label, item1Value, isMain: false)),
            Container(width: 1, height: 40, color: Colors.white10),
            Expanded(
                child: _buildDashboardStat(item2Label, item2Value,
                    valueColor: item2Color, isMain: true)),
          ],
        ),
      ),
    );
  }

  Widget _buildDashboardStat(String label, double value,
      {Color? valueColor, bool isMain = false}) {
    final fmt = NumberFormat('#,##0.00');
    final displayValue = value > 9999999
        ? NumberFormat.compact().format(value)
        : fmt.format(value);

    return Column(
      children: [
        Text(label,
            style: const TextStyle(
                color: Colors.white38,
                fontSize: 9,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.0)),
        const SizedBox(height: 6),
        Text("₹$displayValue",
            style: TextStyle(
                color: valueColor ?? Colors.white,
                fontWeight: isMain ? FontWeight.w900 : FontWeight.bold,
                fontSize: isMain ? 18 : 16)),
      ],
    );
  }

  Widget _buildEmptyState(String title, IconData icon, String subtitle) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.02),
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white.withOpacity(0.05))),
            child: Icon(icon, size: 48, color: Colors.white.withOpacity(0.1)),
          ),
          const SizedBox(height: 20),
          Text(title,
              style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 16,
                  fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text(subtitle,
              style: const TextStyle(color: Colors.white24, fontSize: 12)),
        ],
      ),
    );
  }

  // --- MODERN FAB IMPLEMENTATION ---

  Widget _buildFabMenu() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Option 1: Loan (Red)
        _buildFabOption(
          "New Loan",
          Icons.credit_score_rounded,
          BudgetrColors.error,
          () => _showAddSheet(1),
        ),
        const SizedBox(height: 16),

        // Option 2: Goal (Cyan/Accent)
        _buildFabOption(
          "New Goal",
          Icons.flag_circle_rounded,
          BudgetrColors.accent,
          () => _showAddSheet(0),
        ),
        const SizedBox(height: 24),

        // Main Toggle Button
        _buildMainFab(),
      ],
    );
  }

  Widget _buildMainFab() {
    return GestureDetector(
      onTap: _toggleFab,
      child: RotationTransition(
        turns: _rotateAnimation
            .drive(Tween(begin: 0.0, end: 0.125)), // 45 deg rotation
        child: Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              colors: [BudgetrColors.accent, Colors.blue.shade600],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color: BudgetrColors.accent.withOpacity(0.5),
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: const Icon(Icons.add_rounded, color: Colors.white, size: 32),
        ),
      ),
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
            // Glass Label
            GlassCard(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              margin: EdgeInsets.zero,
              borderRadius: 12,
              color: Colors.black.withOpacity(0.6),
              border: Border.all(color: Colors.white.withOpacity(0.1)),
              child: Text(
                label,
                style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 12),
              ),
            ),
            const SizedBox(width: 16),

            // Neon Icon Button
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [color, color.withOpacity(0.7)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: color.withOpacity(0.4),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Icon(icon, color: Colors.white, size: 22),
            ),
          ],
        ),
      ),
    );
  }
}

// --- PROFESSIONAL CARDS (Preserved) ---

class _GoalCard extends StatelessWidget {
  final GoalModel goal;
  final VoidCallback onTap;
  const _GoalCard({required this.goal, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final isHistory = goal.isCompleted;
    // Use Gold for History, otherwise Goal Color
    final color = isHistory ? const Color(0xFFFFD700) : Color(goal.color);
    final remaining = goal.targetAmount - goal.currentAmount;
    final currencyFmt = NumberFormat('#,##0.00');

    return GestureDetector(
      onTap: onTap,
      child: GlassCard(
        borderRadius: 20,
        // Subtle gold tint if history, else standard dark glass
        color: isHistory
            ? const Color(0xFFFFD700).withOpacity(0.05)
            : const Color(0xFF1E293B).withOpacity(0.6),
        border: Border.all(
          color: isHistory
              ? const Color(0xFFFFD700).withOpacity(0.2)
              : Colors.white.withOpacity(0.05),
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Row(
              children: [
                // Icon Box
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: color.withOpacity(0.2)),
                  ),
                  child: Icon(
                      isHistory
                          ? Icons.emoji_events_rounded
                          : Icons.flag_circle_rounded,
                      color: color,
                      size: 24),
                ),
                const SizedBox(width: 16),

                // Title & Subtitle
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        goal.name.toUpperCase(),
                        style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
                            fontSize: 14,
                            letterSpacing: 0.5,
                            decoration:
                                isHistory ? TextDecoration.lineThrough : null,
                            decorationColor: Colors.white38),
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        isHistory
                            ? "GOAL ACHIEVED"
                            : "TARGET: ₹${NumberFormat.compact().format(goal.targetAmount)}",
                        style: TextStyle(
                            color: isHistory ? color : Colors.white54,
                            fontSize: 10,
                            fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ),

                // Percentage Badge (if active)
                if (!isHistory)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                        color: color.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20)),
                    child: Text("${(goal.progress * 100).toInt()}%",
                        style: TextStyle(
                            color: color,
                            fontSize: 11,
                            fontWeight: FontWeight.bold)),
                  ),

                // Check Badge (if history)
                if (isHistory)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                        color: color.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: color.withOpacity(0.3))),
                    child: Text("COMPLETED",
                        style: TextStyle(
                            color: color,
                            fontSize: 10,
                            fontWeight: FontWeight.w900)),
                  ),
              ],
            ),
            const SizedBox(height: 16),

            // Progress Bar
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: goal.progress,
                minHeight: 6,
                backgroundColor: Colors.white.withOpacity(0.05),
                valueColor: AlwaysStoppedAnimation(color),
              ),
            ),
            const SizedBox(height: 12),

            // Footer Metrics
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildMiniMetric("SAVED",
                    currencyFmt.format(goal.currentAmount), Colors.white),
                if (!isHistory)
                  _buildMiniMetric(
                      "REMAINING",
                      currencyFmt.format(remaining < 0 ? 0 : remaining),
                      Colors.white54),
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget _buildMiniMetric(String label, String value, Color valueColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(
                color: Colors.white24,
                fontSize: 9,
                fontWeight: FontWeight.bold)),
        const SizedBox(height: 2),
        Text("₹$value",
            style: TextStyle(
                color: valueColor, fontWeight: FontWeight.bold, fontSize: 13)),
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
    final isClosed = loan.isClosed;
    // Use Gold for History (Freedom!), Error Red for Active Debt
    final color = isClosed ? const Color(0xFFFFD700) : BudgetrColors.error;
    final progress =
        (loan.totalAmount == 0) ? 0.0 : (loan.paidAmount / loan.totalAmount);
    final currencyFmt = NumberFormat('#,##0.00');

    return GestureDetector(
      onTap: onTap,
      child: GlassCard(
        borderRadius: 20,
        color: isClosed
            ? const Color(0xFFFFD700).withOpacity(0.05)
            : const Color(0xFF1E293B).withOpacity(0.6),
        border: Border.all(
          color: isClosed
              ? const Color(0xFFFFD700).withOpacity(0.2)
              : Colors.white.withOpacity(0.05),
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Row(
              children: [
                // Icon Box
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: color.withOpacity(0.2)),
                  ),
                  child: Icon(
                      isClosed
                          ? Icons.lock_open_rounded
                          : Icons.credit_card_off_rounded,
                      color: color,
                      size: 20),
                ),
                const SizedBox(width: 16),

                // Title & Subtitle
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        loan.title.toUpperCase(),
                        style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
                            fontSize: 14,
                            letterSpacing: 0.5,
                            decoration:
                                isClosed ? TextDecoration.lineThrough : null,
                            decorationColor: Colors.white38),
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        isClosed ? "LOAN CLOSED" : loan.provider.toUpperCase(),
                        style: TextStyle(
                            color: isClosed ? color : Colors.white54,
                            fontSize: 10,
                            fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ),

                // EMI Badge
                if (!isClosed)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: Colors.white12)),
                    child: Column(
                      children: [
                        const Text("EMI",
                            style: TextStyle(
                                color: Colors.white38,
                                fontSize: 8,
                                fontWeight: FontWeight.bold)),
                        Text(
                            "₹${NumberFormat.compact().format(loan.emiAmount ?? 0)}",
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),

                if (isClosed)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                        color: color.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: color.withOpacity(0.3))),
                    child: Text("PAID OFF",
                        style: TextStyle(
                            color: color,
                            fontSize: 10,
                            fontWeight: FontWeight.w900)),
                  ),
              ],
            ),
            const SizedBox(height: 16),

            // Progress Bar
            Row(
              children: [
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: progress > 1 ? 1 : progress,
                      minHeight: 6,
                      backgroundColor: Colors.white.withOpacity(0.05),
                      valueColor: AlwaysStoppedAnimation(color),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Text("${(progress * 100).toInt()}%",
                    style: TextStyle(
                        color: color,
                        fontSize: 10,
                        fontWeight: FontWeight.bold))
              ],
            ),

            const SizedBox(height: 12),

            // Footer Metrics
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildMiniMetric("TOTAL PAID",
                    currencyFmt.format(loan.paidAmount), Colors.white),
                if (!isClosed)
                  _buildMiniMetric(
                      "OUTSTANDING",
                      currencyFmt
                          .format(loan.remaining < 0 ? 0 : loan.remaining),
                      BudgetrColors.error),
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget _buildMiniMetric(String label, String value, Color valueColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(
                color: Colors.white24,
                fontSize: 9,
                fontWeight: FontWeight.bold)),
        const SizedBox(height: 2),
        Text("₹$value",
            style: TextStyle(
                color: valueColor, fontWeight: FontWeight.bold, fontSize: 13)),
      ],
    );
  }
}
