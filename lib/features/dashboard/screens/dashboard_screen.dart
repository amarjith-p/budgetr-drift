// lib/features/dashboard/screens/dashboard_screen.dart

import 'dart:async';
import 'package:budget/core/widgets/futuristic_loader.dart';
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
import '../../settlement/services/settlement_service.dart';
import '../widgets/add_record_sheet.dart';
import '../widgets/dashboard_summary_card.dart';
import '../widgets/budget_allocations_list.dart';
import '../widgets/jump_to_date_sheet.dart';
import '../widgets/budget_closure_sheet.dart';
import '../../../core/design/budgetr_colors.dart';
import '../../../core/design/budgetr_styles.dart';
import '../../../core/widgets/modern_app_bar.dart'; // [NEW IMPORT]

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final DashboardService _dashboardService = GetIt.I<DashboardService>();
  final SettlementService _settlementService = GetIt.I<SettlementService>();

  // Infinite Scroll Logic
  final int _initialIndex = 12 * 50;
  late final PageController _pageController;

  // Streams & State
  late Stream<List<FinancialRecord>> _recordsStream;
  DateTime _currentDate = DateTime.now();
  bool _isMonthSettled = false;
  bool _showSwipeHint = true;
  final _currencyFormat = NumberFormat.currency(locale: 'en_IN', symbol: '₹');

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _initialIndex);
    // Initialize stream here to prevent reloading on setState (Fixes Blinking)
    _recordsStream = _dashboardService.getFinancialRecords();
    _checkSettlementStatus();

    // Auto-hide the swipe hint after 4 seconds
    Timer(const Duration(seconds: 5), () {
      if (mounted) setState(() => _showSwipeHint = false);
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

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
    final newDate = DateTime(now.year, now.month + diff);

    // Only trigger setState if the month actually changed to avoid unnecessary rebuilds
    if (newDate.month != _currentDate.month ||
        newDate.year != _currentDate.year) {
      setState(() {
        _currentDate = newDate;
        if (_showSwipeHint) _showSwipeHint = false; // Hide hint on first swipe
      });
      _checkSettlementStatus();
    }
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
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      useSafeArea: true,
      builder: (context) =>
          AddRecordSheet(recordToEdit: record, initialDate: _currentDate),
    ).then((_) => _checkSettlementStatus());
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
            if (!_isMonthSettled)
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.05),
                  borderRadius: BudgetrStyles.radiusM,
                ),
                child: ListTile(
                  onTap: () async {
                    Navigator.pop(context);

                    showDialog(
                      context: context,
                      barrierDismissible: false,
                      builder: (c) => const Center(
                          child:
                              FuturisticLoader(size: 80, label: "LOADING...")),
                    );

                    final spendingMap = await _dashboardService
                        .getMonthlyBucketSpending(record.year, record.month)
                        .first;

                    if (mounted) {
                      Navigator.pop(context);

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
                      _checkSettlementStatus();
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
        _checkSettlementStatus();
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
    // Current date formatted for the subtitle
    final dateString = DateFormat('MMMM yyyy').format(_currentDate);

    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                // 1. MODERN APP BAR (Replaced Custom Row)
                ModernAppBar(
                  title: "Budget Insights",
                  subtitle: dateString,
                  trailingIcon: Icons.calendar_month_rounded,
                  onTrailingPressed: _showJumpToDateSheet,
                ),

                // 2. FULL PAGE SWIPER
                Expanded(
                  child: StreamBuilder<List<FinancialRecord>>(
                    stream: _recordsStream, // Use initialized stream
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(
                            child: FuturisticLoader(
                                size: 80, label: "LOADING..."));
                      }

                      final records = snapshot.data ?? [];

                      return PageView.builder(
                        controller: _pageController,
                        onPageChanged: _onPageChanged,
                        // Physics ensures smooth snapping like a carousel
                        physics: const BouncingScrollPhysics(),
                        itemBuilder: (context, index) {
                          // Calculate date for this specific page index
                          final now = DateTime.now();
                          final diff = index - _initialIndex;
                          final pageDate = DateTime(now.year, now.month + diff);

                          // Find record for this page
                          final currentRecord = records.firstWhere(
                            (r) =>
                                r.year == pageDate.year &&
                                r.month == pageDate.month,
                            orElse: () => FinancialRecord(
                              id: '',
                              salary: 0,
                              extraIncome: 0,
                              emi: 0,
                              year: pageDate.year,
                              month: pageDate.month,
                              effectiveIncome: 0,
                              allocations: {},
                              allocationPercentages: {},
                              bucketOrder: [],
                              createdAt: DateTime.timestamp(),
                              updatedAt: DateTime.timestamp(),
                            ),
                          );

                          final hasData = currentRecord.id.isNotEmpty;

                          // Pass data to a pure display widget to keep logic clean
                          return _buildPageContent(
                              pageDate, currentRecord, hasData);
                        },
                      );
                    },
                  ),
                ),
              ],
            ),

            // 3. SWIPE HINT (User Notification)
            if (_showSwipeHint)
              Positioned(
                bottom: 100,
                left: 0,
                right: 0,
                child: Center(
                  child: IgnorePointer(
                    child: AnimatedOpacity(
                      opacity: _showSwipeHint ? 1.0 : 0.0,
                      duration: const Duration(milliseconds: 500),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.black,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Colors.white24, width: 0.5),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.arrow_back_ios_rounded,
                                size: 12, color: Colors.white70),
                            const SizedBox(width: 8),
                            Text(
                              "Swipe for Other Months",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(width: 8),
                            const Icon(Icons.arrow_forward_ios_rounded,
                                size: 12, color: Colors.white70),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  // --- PAGE CONTENT BUILDER ---
  Widget _buildPageContent(
      DateTime pageDate, FinancialRecord currentRecord, bool hasData) {
    // We determine if THIS specific page is closed/settled based on the global state
    // matched with the page's date.
    // Note: Ideally, each page should fetch its own settlement status, but for
    // simplicity and consistency with your old code, we rely on the primary
    // _currentDate check for the FAB interactions.
    // However, for the UI *inside* the list (the Banner), we display it if
    // this page is the one currently selected AND settled.

    final isPageFocused = pageDate.year == _currentDate.year &&
        pageDate.month == _currentDate.month;

    return StreamBuilder<Map<String, double>>(
      stream: _dashboardService.getMonthlyBucketSpending(
        pageDate.year,
        pageDate.month,
      ),
      builder: (context, spendingSnapshot) {
        final spendingMap = spendingSnapshot.data ?? {};

        return Stack(
          children: [
            SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
              child: Column(
                children: [
                  // Closed Budget Indicator (Only show if this is the active page & settled)
                  if (_isMonthSettled && isPageFocused)
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
                          color: Colors.orangeAccent.withOpacity(0.3),
                        ),
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.lock,
                            color: Colors.orangeAccent,
                            size: 18,
                          ),
                          SizedBox(width: 8),
                          Text(
                            "Budget Closed & Locked",
                            style: TextStyle(
                              color: Colors.orangeAccent,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),

                  if (hasData) ...[
                    DashboardSummaryCard(
                      record: currentRecord,
                      currencyFormat: _currencyFormat,
                      onOptionsTap: () => _showRecordOptions(currentRecord),
                      onCardTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => MonthlySpendingScreen(
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
                    _buildEmptyState(pageDate),
                ],
              ),
            ),

            // FAB
            // We show the FAB *only* if this page matches the currently selected date.
            // This prevents FABs from "sliding" in from the side.
            if (isPageFocused)
              Positioned(
                bottom: 20,
                left: 0,
                right: 0,
                child: Center(
                  child: GestureDetector(
                    onTap: () {
                      if (_isMonthSettled) {
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
                        color: _isMonthSettled ? Colors.grey[800] : null,
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
                            color:
                                _isMonthSettled ? Colors.white54 : Colors.white,
                          ),
                          const SizedBox(width: 12),
                          Text(
                            _isMonthSettled
                                ? "Closed Budget"
                                : (hasData ? "Edit Budget" : "Create Budget"),
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
  }

  Widget _buildEmptyState(DateTime date) {
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
              "Tap 'Create Budget' to plan\nfor ${DateFormat('MMMM').format(date)}.",
              textAlign: TextAlign.center,
              style: BudgetrStyles.body.copyWith(color: Colors.white54),
            ),
          ],
        ),
      ),
    );
  }
}
