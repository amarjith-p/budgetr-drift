import 'package:budget/core/widgets/modern_loader.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
// Removed: import 'package:local_auth/local_auth.dart';

import '../../../core/models/financial_record_model.dart';
import '../services/dashboard_service.dart';
import '../widgets/add_record_sheet.dart';
import '../widgets/dashboard_summary_card.dart';
import '../widgets/budget_allocations_list.dart';
import '../widgets/jump_to_date_sheet.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final DashboardService _dashboardService = DashboardService();
  // Removed: final LocalAuthentication auth = LocalAuthentication();

  // Infinite Scroll Logic
  final int _initialIndex = 12 * 50;
  late final PageController _pageController;

  final Color _bgColor = const Color(0xff0D1B2A);
  final Color _accentColor = const Color(0xFF3A86FF);

  DateTime _currentDate = DateTime.now();
  final _currencyFormat = NumberFormat.currency(locale: 'en_IN', symbol: '₹');

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _initialIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onPageChanged(int index) {
    final now = DateTime.now();
    final diff = index - _initialIndex;
    setState(() {
      _currentDate = DateTime(now.year, now.month + diff);
    });
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
    );
  }

  // --- NEW: Modern Options Sheet ---
  void _showRecordOptions(FinancialRecord record) {
    HapticFeedback.lightImpact();
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: _bgColor,
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
              style: TextStyle(
                color: Colors.white.withOpacity(0.5),
                fontSize: 14,
                fontWeight: FontWeight.bold,
                letterSpacing: 1,
              ),
            ),
            const SizedBox(height: 16),

            // Delete Action
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.05),
                borderRadius: BorderRadius.circular(16),
              ),
              child: ListTile(
                onTap: () {
                  Navigator.pop(context); // Close options
                  _handleDeleteRecord(record); // Trigger Delete Flow
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
    // 1. Confirm Delete
    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: _bgColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: Colors.white.withOpacity(0.1)),
        ),
        title: const Text(
          "Delete Budget?",
          style: TextStyle(color: Colors.white),
        ),
        content: Text(
          "Are you sure you want to delete the budget for ${DateFormat('MMMM yyyy').format(DateTime(record.year, record.month))}? This cannot be undone.",
          style: TextStyle(color: Colors.white.withOpacity(0.7)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text(
              "Cancel",
              style: TextStyle(color: Colors.white54),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text(
              "Delete",
              style: TextStyle(
                color: Colors.redAccent,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    // Removed: Secure Auth Check

    // 2. Delete (Service handles cascading delete of Settlement)
    await _dashboardService.deleteFinancialRecord(record.id);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Budget & Settlement data deleted."),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bgColor,
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
                          const Icon(
                            Icons.calendar_month,
                            color: Colors.white70,
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
                            color: _accentColor,
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
                // Find record for current date view or create empty one
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
                    createdAt: Timestamp.now(),
                  ),
                );

                final hasData = currentRecord.id.isNotEmpty;

                return Stack(
                  children: [
                    SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
                      child: Column(
                        children: [
                          if (hasData) ...[
                            // --- Refactored Widget: Summary Card ---
                            DashboardSummaryCard(
                              record: currentRecord,
                              currencyFormat: _currencyFormat,
                              onOptionsTap: () =>
                                  _showRecordOptions(currentRecord),
                            ),

                            const SizedBox(height: 24),
                            Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                "Budget Allocations",
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.7),
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            const SizedBox(height: 12),

                            // --- Refactored Widget: Allocations List ---
                            BudgetAllocationsList(
                              record: currentRecord,
                              currencyFormat: _currencyFormat,
                            ),
                          ] else
                            _buildEmptyState(),
                        ],
                      ),
                    ),

                    // --- Floating Action Button (Edit/Create) ---
                    Positioned(
                      bottom: 20,
                      left: 0,
                      right: 0,
                      child: Center(
                        child: GestureDetector(
                          onTap: () {
                            if (hasData) {
                              // REMOVED: Authentication Check
                              _showAddRecordSheet(currentRecord);
                            } else {
                              // CREATE NEW (Use passed date)
                              _showAddRecordSheet(null);
                            }
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 16,
                            ),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [_accentColor, const Color(0xFF2563EB)],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(30),
                              boxShadow: [
                                BoxShadow(
                                  color: _accentColor.withOpacity(0.4),
                                  blurRadius: 20,
                                  spreadRadius: -5,
                                  offset: const Offset(0, 10),
                                ),
                              ],
                              border: Border.all(
                                color: Colors.white.withOpacity(0.2),
                                width: 1,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  hasData
                                      ? Icons.edit_outlined
                                      : Icons.add_rounded,
                                  color: Colors.white,
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  hasData ? "Edit Budget" : "Create Budget",
                                  style: const TextStyle(
                                    color: Colors.white,
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
            const Text(
              "No Budget Found",
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "Tap 'Create Budget' to plan\nfor ${DateFormat('MMMM').format(_currentDate)}.",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white.withOpacity(0.5)),
            ),
          ],
        ),
      ),
    );
  }
}
