import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/widgets/modern_loader.dart';
import '../models/expense_models.dart';
import '../services/expense_service.dart';
import '../widgets/add_expense_txn_sheet.dart';
import '../widgets/bank_account_mini_card.dart';
import 'account_detail_screen.dart';
import 'account_management_screen.dart';

// --- NEW IMPORTS ---
import 'all_transactions_screen.dart';
import 'expense_analytics_screen.dart';

class DailyExpenseScreen extends StatefulWidget {
  const DailyExpenseScreen({super.key});

  @override
  State<DailyExpenseScreen> createState() => _DailyExpenseScreenState();
}

class _DailyExpenseScreenState extends State<DailyExpenseScreen> {
  final ExpenseService _service = ExpenseService();
  late Stream<List<ExpenseAccountModel>> _accountsStream;

  // --- NAVIGATION STATE ---
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    // Use the dashboard specific stream to respect user order & limits
    _accountsStream = _service.getDashboardAccounts();
  }

  void _onTabTapped(int index) {
    if (_currentIndex != index) {
      HapticFeedback.lightImpact();
      setState(() => _currentIndex = index);
    }
  }

  @override
  Widget build(BuildContext context) {
    const Color bgColor = Color(0xff0D1B2A);

    return Scaffold(
      backgroundColor: bgColor,
      extendBody: true, // Allows content to flow behind the floating dock
      appBar: _buildAppBar(bgColor),
      body: IndexedStack(
        index: _currentIndex,
        children: [
          _buildOriginalHomeContent(),
          const AllTransactionsScreen(),
          const ExpenseAnalyticsScreen(),
        ],
      ),
      bottomNavigationBar: _buildPrismDock(),
    );
  }

  PreferredSizeWidget _buildAppBar(Color bgColor) {
    String title = "Daily Tracker";
    if (_currentIndex == 1) title = "Transactions";
    if (_currentIndex == 2) title = "Analytics";

    return AppBar(
      backgroundColor: bgColor.withOpacity(0.9), // Slight translucency
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: false,
      title: Padding(
        padding: const EdgeInsets.only(left: 8.0),
        child: Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
      ),
      flexibleSpace: ClipRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(color: Colors.transparent),
        ),
      ),
    );
  }

  // --- WRAPPER FOR ORIGINAL CONTENT ---
  Widget _buildOriginalHomeContent() {
    return Stack(
      children: [
        Positioned(
          top: -50,
          right: -50,
          child: Container(
            width: 200,
            height: 200,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFF00B4D8).withOpacity(0.1),
              backgroundBlendMode: BlendMode.plus,
            ),
          ),
        ),
        SafeArea(
          bottom: false, // Let scrolling handle bottom padding
          child: Column(
            children: [
              const SizedBox(height: 10),
              Expanded(
                child: _buildDualRowAccounts(),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // --- ORIGINAL LOGIC PRESERVED ---
  Widget _buildDualRowAccounts() {
    return StreamBuilder<List<ExpenseAccountModel>>(
      stream: _accountsStream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: ModernLoader());
        }

        final accounts = snapshot.data ?? [];
        final displayAccounts = accounts.take(6).toList();

        final List<ExpenseAccountModel> row1Items = [];
        final List<dynamic> row2Items = [];

        for (int i = 0; i < displayAccounts.length; i++) {
          if (i < 3) {
            row1Items.add(displayAccounts[i]);
          } else {
            row2Items.add(displayAccounts[i]);
          }
        }
        row2Items.add("ALL_ACCOUNTS_CARD");

        return SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (row1Items.isNotEmpty) ...[
                SizedBox(
                  height: 90,
                  child: ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    scrollDirection: Axis.horizontal,
                    itemCount: row1Items.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 12),
                    itemBuilder: (context, index) {
                      return SizedBox(
                        width: 160,
                        child: BankAccountMiniCard(
                          account: row1Items[index],
                          onTap: () => _openAccount(context, row1Items[index]),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 16),
              ],
              SizedBox(
                height: 90,
                child: ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  scrollDirection: Axis.horizontal,
                  itemCount: row2Items.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 12),
                  itemBuilder: (context, index) {
                    final item = row2Items[index];
                    if (item == "ALL_ACCOUNTS_CARD") {
                      return SizedBox(
                          width: 160, child: _buildAllAccountsCard(context));
                    }
                    return SizedBox(
                      width: 160,
                      child: BankAccountMiniCard(
                        account: item as ExpenseAccountModel,
                        onTap: () => _openAccount(context, item),
                      ),
                    );
                  },
                ),
              ),
              // Extra padding for the floating dock
              const SizedBox(height: 140),
            ],
          ),
        );
      },
    );
  }

  void _openAccount(BuildContext context, ExpenseAccountModel account) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AccountDetailScreen(account: account),
      ),
    );
  }

  Widget _buildAllAccountsCard(BuildContext context) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const AccountManagementScreen()),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF1B263B),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withOpacity(0.1), width: 1),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 4,
              offset: const Offset(0, 2),
            )
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [
                      const Color(0xFF00B4D8).withOpacity(0.2),
                      const Color(0xFF0077B6).withOpacity(0.2)
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: const Icon(Icons.grid_view_rounded,
                    size: 18, color: Color(0xFF00B4D8)),
              ),
              const SizedBox(width: 12),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "All Accounts",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    "Manage & Edit",
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.5),
                      fontSize: 10,
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  // --- THE PRISM DOCK ---
  Widget _buildPrismDock() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 30),
      child: Container(
        height: 72,
        decoration: BoxDecoration(
          color: const Color(0xFF101825).withOpacity(0.95), // Deep Navy
          borderRadius: BorderRadius.circular(24),
          // Gradient Border simulating a high-end device edge
          border: Border.all(color: Colors.white.withOpacity(0.08), width: 1),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.4),
              blurRadius: 25,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildPrismTab(0, Icons.grid_view_rounded, "Home"),
                _buildPrismTab(1, Icons.receipt_long_rounded, "History"),

                // Floating Action Button
                _buildPrismFab(),

                _buildPrismTab(2, Icons.bar_chart_rounded, "Analytics"),
                _buildPrismTab(3, Icons.settings_rounded, "Settings",
                    isDisabled: true),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPrismTab(int index, IconData icon, String label,
      {bool isDisabled = false}) {
    if (isDisabled) {
      return const SizedBox(
          width: 60,
          child: Center(
              child: Icon(Icons.settings, color: Colors.white24, size: 24)));
    }

    final bool isSelected = _currentIndex == index;
    final Color inactiveColor = Colors.white54;

    return GestureDetector(
      onTap: () => _onTabTapped(index),
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 60,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Active Gradient Icon
            isSelected
                ? ShaderMask(
                    shaderCallback: (bounds) => const LinearGradient(
                      colors: [Color(0xFF00B4D8), Color(0xFF0077B6)],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ).createShader(bounds),
                    child: Icon(icon, color: Colors.white, size: 26),
                  )
                : Icon(icon, color: inactiveColor, size: 26),

            const SizedBox(height: 4),

            // Label
            Text(
              label,
              style: TextStyle(
                color: isSelected ? const Color(0xFF00B4D8) : inactiveColor,
                fontSize: 10,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPrismFab() {
    return GestureDetector(
      onTap: () {
        HapticFeedback.mediumImpact();
        showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          builder: (ctx) => const AddExpenseTransactionSheet(),
        );
      },
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF00B4D8), Color(0xFF0077B6)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16), // "Squircle" shape
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF00B4D8).withOpacity(0.4),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
          border: Border.all(color: Colors.white.withOpacity(0.2)),
        ),
        child: const Icon(Icons.add_rounded, color: Colors.white, size: 30),
      ),
    );
  }
}
