import 'package:budget/core/widgets/modern_loader.dart';
import 'package:budget/core/widgets/status_bottom_sheet.dart';
import 'package:budget/features/settlement/screens/settlement_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get_it/get_it.dart';
import 'package:intl/intl.dart';
import 'monthly_spending_screen.dart';
import '../../../core/models/financial_record_model.dart';
import '../services/dashboard_service.dart';
import '../../settlement/services/settlement_service.dart'; // Import SettlementService
import '../widgets/add_record_sheet.dart';
import '../widgets/dashboard_summary_card.dart';
import '../widgets/budget_allocations_list.dart';
import '../widgets/jump_to_date_sheet.dart';
import '../widgets/budget_closure_sheet.dart';
// --- DESIGN SYSTEM ---
import '../../../core/design/budgetr_colors.dart';
import '../../../core/design/budgetr_styles.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final DashboardService _dashboardService = GetIt.I<DashboardService>();
  final SettlementService _settlementService =
      GetIt.I<SettlementService>(); // Initialize Service

  // Infinite Scroll Logic
  final int _initialIndex = 12 * 50;
  late final PageController _pageController;

  DateTime _currentDate = DateTime.now();
  bool _isMonthSettled = false; // Track settlement status
  final _currencyFormat = NumberFormat.currency(locale: 'en_IN', symbol: '₹');

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _initialIndex);
    _checkSettlementStatus(); // Check on init
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  // Check if current month is settled
  Future<void> _checkSettlementStatus() async {
    final isSettled = await _settlementService.isMonthSettled(
      _currentDate.year,
      _currentDate.month,
    );
    if (mounted) {
      setState(() {
        _isMonthSettled = isSettled;
      });
    }
  }

  void _onPageChanged(int index) {
    final now = DateTime.now();
    final diff = index - _initialIndex;
    setState(() {
      _currentDate = DateTime(now.year, now.month + diff);
    });
    _checkSettlementStatus(); // Check whenever month changes
  }

  void _handleDateJump(int selectedYear, int selectedMonth) {
    final now = DateTime.now();
    final monthDiff =
        (selectedYear - now.year) * 12 + (selectedMonth - now.month);
    final targetIndex = _initialIndex + monthDiff;

    _pageController.animateToPage(
      targetIndex,
      duration: const Duration(milliseconds: 600),
      curve: Curves.easeInOutCubic,
    );
  }

  void _showJumpToDateSheet() {
    HapticFeedback.lightImpact();
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => JumpToDateSheet(
        currentDate: _currentDate,
        onDateSelected: _handleDateJump,
      ),
    );
  }

  void _showAddRecordSheet([FinancialRecord? record]) {
    HapticFeedback.lightImpact();
    // Prevent editing if settled, unless you want to allow viewing in read-only mode here
    // For now, we just show the sheet, but logic inside could also be restricted.
    // However, since we change the FAB button for settled months, this is less critical.
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      useSafeArea: true,
      builder: (context) =>
          AddRecordSheet(recordToEdit: record, initialDate: _currentDate),
    ).then((_) => _checkSettlementStatus()); // Re-check after potential save
  }

  void _showRecordOptions(FinancialRecord record) {
    HapticFeedback.lightImpact();
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: BudgetrColors.background,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          border: Border(top: BorderSide(color: Colors.white.withOpacity(0.1))),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              "Budget Options",
              style: BudgetrStyles.caption.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),

            // Disable "Close Budget" option if already closed
            if (!_isMonthSettled)
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.05),
                  borderRadius: BudgetrStyles.radiusM,
                ),
                child: ListTile(
                  onTap: () async {
                    Navigator.pop(context); // Close Options Sheet

                    // 1. Show Loading
                    showDialog(
                      context: context,
                      barrierDismissible: false,
                      builder: (c) => const Center(child: ModernLoader()),
                    );

                    // 2. Fetch Aggregated Spending
                    final spendingMap = await _dashboardService
                        .getMonthlyBucketSpending(record.year, record.month)
                        .first;

                    if (mounted) {
                      Navigator.pop(context); // Close Loader

                      // 3. Open Budget Closure Sheet
                      await showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        backgroundColor: Colors.transparent,
                        useSafeArea: true,
                        builder: (context) => BudgetClosureSheet(
                          record: record,
                          spendingMap: spendingMap,
                        ),
                      );
                      _checkSettlementStatus(); // Refresh status after closure
                    }
                  },
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.greenAccent.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.lock_outline_rounded,
                      color: Colors.greenAccent,
                      size: 20,
                    ),
                  ),
                  title: const Text(
                    "Close & Lock Budget",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  subtitle: const Text(
                    "Finalize month and prevent changes",
                    style: TextStyle(color: Colors.white38, fontSize: 12),
                  ),
                ),
              ),
            if (!_isMonthSettled) const SizedBox(height: 16),

            // --- SETTLEMENT ANALYSIS OPTION ---
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.05),
                borderRadius: BudgetrStyles.radiusM,
              ),
              child: ListTile(
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const SettlementScreen(),
                    ),
                  );
                },
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.purpleAccent.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.analytics_outlined,
                    color: Colors.purpleAccent,
                    size: 20,
                  ),
                ),
                title: const Text(
                  "Settlement Analysis",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                subtitle: const Text(
                  "View past settlements & stats",
                  style: TextStyle(color: Colors.white38, fontSize: 12),
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Delete Action
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.05),
                borderRadius: BudgetrStyles.radiusM,
              ),
              child: ListTile(
                onTap: () {
                  Navigator.pop(context);
                  _handleDeleteRecord(record);
                },
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.redAccent.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.delete_outline_rounded,
                    color: Colors.redAccent,
                    size: 20,
                  ),
                ),
                title: const Text(
                  "Delete Record",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                subtitle: const Text(
                  "Permanently remove budget & settlement",
                  style: TextStyle(color: Colors.white38, fontSize: 12),
                ),
              ),
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  Future<void> _handleDeleteRecord(FinancialRecord record) async {
    // final bool? confirm = await showDialog<bool>(
    //   context: context,
    //   builder: (ctx) => AlertDialog(
    //     title: const Text("Delete Budget?"),
    //     content: Text(
    //       "Are you sure you want to delete the budget for ${DateFormat('MMMM yyyy').format(DateTime(record.year, record.month))}? This cannot be undone.",
    //     ),
    //     actions: [
    //       TextButton(
    //         onPressed: () => Navigator.pop(ctx, false),
    //         child: const Text("Cancel"),
    //       ),
    //       TextButton(
    //         onPressed: () => Navigator.pop(ctx, true),
    //         child: const Text(
    //           "Delete",
    //           style: TextStyle(
    //             color: Colors.redAccent,
    //             fontWeight: FontWeight.bold,
    //           ),
    //         ),
    //       ),
    //     ],
    //   ),
    // );

    // if (confirm != true) return;

    // await _dashboardService.deleteFinancialRecord(record.id);
    // _checkSettlementStatus(); // Refresh settlement status
    // if (mounted) {
    //   ScaffoldMessenger.of(context).showSnackBar(
    //     const SnackBar(
    //       content: Text("Budget & Settlement data deleted."),
    //       backgroundColor: Colors.redAccent,
    //     ),
    //   );
    // }
    showStatusSheet(
      context: context,
      title: "Delete Budget?",
      message:
          "Are you sure you want to delete the budget for ${DateFormat('MMMM yyyy').format(DateTime(record.year, record.month))}? \nThis cannot be undone.",
      icon: Icons.delete_sweep_sharp,
      color: Colors.redAccent,
      cancelButtonText: "Cancel",
      onCancel: () {},
      buttonText: "Delete",
      onDismiss: () async {
        await _dashboardService.deleteFinancialRecord(record.id);
        _checkSettlementStatus(); // Refresh settlement status
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Budget & Settlement data deleted."),
              backgroundColor: Colors.redAccent,
            ),
          );
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: BudgetrColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Budget Dashboard',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Column(
        children: [
          // --- Month Selector ---
          Container(
            height: 60,
            margin: const EdgeInsets.symmetric(vertical: 8),
            child: PageView.builder(
              controller: _pageController,
              onPageChanged: _onPageChanged,
              itemBuilder: (context, index) {
                final now = DateTime.now();
                final diff = index - _initialIndex;
                final date = DateTime(now.year, now.month + diff);

                return Center(
                  child: GestureDetector(
                    onTap: _showJumpToDateSheet,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(30),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.1),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            // Show Lock icon in title if this specific page is settled
                            // Note: This relies on _isMonthSettled matching _currentDate which is only accurate for the active page
                            // For a perfect list, we'd need FutureBuilder here, but for now we keep it simple.
                            // Better: Only show lock if it IS the current date
                            (date.year == _currentDate.year &&
                                    date.month == _currentDate.month &&
                                    _isMonthSettled)
                                ? Icons.lock_outline
                                : Icons.calendar_month,
                            color: (date.year == _currentDate.year &&
                                    date.month == _currentDate.month &&
                                    _isMonthSettled)
                                ? Colors.orangeAccent
                                : Colors.white70,
                            size: 18,
                          ),
                          const SizedBox(width: 12),
                          Text(
                            DateFormat('MMMM yyyy').format(date),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Icon(
                            Icons.arrow_drop_down,
                            color: BudgetrColors.accent,
                            size: 20,
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          // --- Content ---
          Expanded(
            child: StreamBuilder<List<FinancialRecord>>(
              stream: _dashboardService.getFinancialRecords(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: ModernLoader());
                }

                final records = snapshot.data ?? [];
                final currentRecord = records.firstWhere(
                  (r) =>
                      r.year == _currentDate.year &&
                      r.month == _currentDate.month,
                  orElse: () => FinancialRecord(
                    id: '',
                    salary: 0,
                    extraIncome: 0,
                    emi: 0,
                    year: _currentDate.year,
                    month: _currentDate.month,
                    effectiveIncome: 0,
                    allocations: {},
                    allocationPercentages: {},
                    bucketOrder: [],
                    createdAt: DateTime.timestamp(),
                    updatedAt: DateTime.timestamp(),
                  ),
                );

                final hasData = currentRecord.id.isNotEmpty;

                return StreamBuilder<Map<String, double>>(
                  stream: _dashboardService.getMonthlyBucketSpending(
                    _currentDate.year,
                    _currentDate.month,
                  ),
                  builder: (context, spendingSnapshot) {
                    final spendingMap = spendingSnapshot.data ?? {};

                    return Stack(
                      children: [
                        SingleChildScrollView(
                          padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
                          child: Column(
                            children: [
                              // --- VISUAL INDICATOR FOR CLOSED BUDGET ---
                              if (_isMonthSettled)
                                Container(
                                  width: double.infinity,
                                  margin: const EdgeInsets.only(bottom: 16),
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 12,
                                    horizontal: 16,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.orangeAccent.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: Colors.orangeAccent.withOpacity(
                                        0.3,
                                      ),
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const Icon(
                                        Icons.lock,
                                        color: Colors.orangeAccent,
                                        size: 18,
                                      ),
                                      const SizedBox(width: 8),
                                      const Text(
                                        "Budget Closed & Locked",
                                        style: TextStyle(
                                          color: Colors.orangeAccent,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                              // ------------------------------------------
                              if (hasData) ...[
                                DashboardSummaryCard(
                                  record: currentRecord,
                                  currencyFormat: _currencyFormat,
                                  onOptionsTap: () =>
                                      _showRecordOptions(currentRecord),
                                  onCardTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            MonthlySpendingScreen(
                                          record: currentRecord,
                                        ),
                                      ),
                                    );
                                  },
                                ),
                                const SizedBox(height: 24),
                                Align(
                                  alignment: Alignment.centerLeft,
                                  child: Text(
                                    "Budget Allocations",
                                    style: BudgetrStyles.h3.copyWith(
                                      color: Colors.white70,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 12),
                                BudgetAllocationsList(
                                  record: currentRecord,
                                  currencyFormat: _currencyFormat,
                                  spendingMap: spendingMap,
                                ),
                              ] else
                                _buildEmptyState(),
                            ],
                          ),
                        ),

                        // --- FAB ---
                        Positioned(
                          bottom: 20,
                          left: 0,
                          right: 0,
                          child: Center(
                            child: GestureDetector(
                              onTap: () {
                                if (_isMonthSettled) {
                                  // Optionally show a message or just open in read-only mode if implemented
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        "This budget is closed and cannot be edited.",
                                      ),
                                      backgroundColor: Colors.orangeAccent,
                                    ),
                                  );
                                } else if (hasData) {
                                  _showAddRecordSheet(currentRecord);
                                } else {
                                  _showAddRecordSheet(null);
                                }
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 24,
                                  vertical: 16,
                                ),
                                decoration: BoxDecoration(
                                  // Change style if closed
                                  color:
                                      _isMonthSettled ? Colors.grey[800] : null,
                                  gradient: _isMonthSettled
                                      ? null
                                      : BudgetrColors.primaryGradient,
                                  borderRadius: BorderRadius.circular(30),
                                  boxShadow: _isMonthSettled
                                      ? []
                                      : BudgetrStyles.glowBoxShadow(
                                          BudgetrColors.accent,
                                        ),
                                  border: Border.all(
                                    color: Colors.white.withOpacity(0.2),
                                    width: 1,
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      _isMonthSettled
                                          ? Icons.lock_outline
                                          : (hasData
                                              ? Icons.edit_outlined
                                              : Icons.add_rounded),
                                      color: _isMonthSettled
                                          ? Colors.white54
                                          : Colors.white,
                                    ),
                                    const SizedBox(width: 12),
                                    Text(
                                      _isMonthSettled
                                          ? "Closed Budget"
                                          : (hasData
                                              ? "Edit Budget"
                                              : "Create Budget"),
                                      style: TextStyle(
                                        color: _isMonthSettled
                                            ? Colors.white54
                                            : Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Padding(
      padding: const EdgeInsets.only(top: 60),
      child: Center(
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.05),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.account_balance_wallet_outlined,
                size: 48,
                color: Colors.white.withOpacity(0.2),
              ),
            ),
            const SizedBox(height: 24),
            Text("No Budget Found", style: BudgetrStyles.h2),
            const SizedBox(height: 8),
            Text(
              "Tap 'Create Budget' to plan\nfor ${DateFormat('MMMM').format(_currentDate)}.",
              textAlign: TextAlign.center,
              style: BudgetrStyles.body.copyWith(color: Colors.white54),
            ),
          ],
        ),
      ),
    );
  }
}
