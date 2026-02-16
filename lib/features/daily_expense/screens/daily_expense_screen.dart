import 'dart:ui';
import 'package:budget/core/widgets/futuristic_loader.dart';
import 'package:budget/features/daily_expense/screens/new_expense_screen.dart';
import 'package:budget/features/daily_expense/screens/spending_calendar_screen.dart';
import 'package:budget/features/daily_expense/widgets/modern_expense_sheet.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get_it/get_it.dart';
import '../../../core/widgets/modern_loader.dart';
import '../models/expense_models.dart';
import '../services/expense_service.dart';
import '../widgets/bank_account_mini_card.dart';
import 'account_detail_screen.dart';
import 'account_management_screen.dart';

// --- IMPORTS ---
import 'all_transactions_screen.dart';
import 'expense_analytics_screen.dart';
import 'category_breakdown_screen.dart';
import '../widgets/cash_flow_card.dart';
import '../widgets/balance_trend_chart.dart';
import '../../home/screens/home_screen.dart'; // [ADDED] For Navigation

class DailyExpenseScreen extends StatefulWidget {
  const DailyExpenseScreen({super.key});

  @override
  State<DailyExpenseScreen> createState() => _DailyExpenseScreenState();
}

class _DailyExpenseScreenState extends State<DailyExpenseScreen> {
  final ExpenseService _service = GetIt.I<ExpenseService>();
  late Stream<List<ExpenseAccountModel>> _accountsStream;

  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _accountsStream = _service.getDashboardAccounts();
  }

  void _onTabTapped(int index) {
    if (_currentIndex != index) {
      HapticFeedback.lightImpact();
      setState(() => _currentIndex = index);
    }
  }

  // [NEW] Logic to handle Back Press
  void _handlePopInvoked(bool didPop) {
    if (didPop) return;

    // Check if we can pop normally (e.g. opened from Home)
    if (Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
    } else {
      // If we can't pop (Quick Launch), manually go to Home
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const HomeScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    const Color bgColor = Color(0xff0D1B2A);

    // [CHANGED] Wrap Scaffold in PopScope
    return PopScope(
      canPop: false, // We handle the pop manually
      onPopInvoked: _handlePopInvoked,
      child: Scaffold(
        backgroundColor: bgColor,
        extendBody: true,
        appBar: _buildAppBar(bgColor),
        body: IndexedStack(
          index: _currentIndex,
          children: [
            _buildOriginalHomeContent(), // 0: Overview
            const AllTransactionsScreen(), // 1: Transactions
            const ExpenseAnalyticsScreen(), // 2: Analytics
            const CategoryBreakdownScreen(), // 3: Breakdown
          ],
        ),
        bottomNavigationBar: _buildFullWidthAnimatedBar(context),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(Color bgColor) {
    String title = "Daily Tracker";
    if (_currentIndex == 1) title = "All Transactions";
    if (_currentIndex == 2) title = "Analytics";
    if (_currentIndex == 3) title = "Insights";

    return AppBar(
      backgroundColor: bgColor.withOpacity(0.85),
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: true,

      // [NEW] Leading Icon that calls our smart pop logic
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_rounded, color: Colors.white),
        onPressed: () => _handlePopInvoked(false),
      ),

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
      actions: [
        GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const SpendingCalendarScreen()),
            );
          },
          child: Container(
            margin: const EdgeInsets.only(right: 16),
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.08),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.white.withOpacity(0.15)),
            ),
            child: Column(
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 3),
                  decoration: const BoxDecoration(
                    color: Color(0xFFE71D36),
                    borderRadius:
                        BorderRadius.vertical(top: Radius.circular(9)),
                  ),
                  alignment: Alignment.center,
                  child: const Text(
                    "HEATMAP",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 7,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
                Expanded(
                  child: Center(
                    child: Text(
                      DateTime.now().day.toString(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        height: 1.0,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        )
      ],
    );
  }

  // ... [ALL OTHER METHODS REMAIN EXACTLY AS THEY WERE] ...

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
          bottom: false,
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

  Widget _buildDualRowAccounts() {
    return StreamBuilder<List<ExpenseAccountModel>>(
      stream: _accountsStream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
              child: FuturisticLoader(size: 80, label: "LOADING ACCOUNTS..."));
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
          padding: const EdgeInsets.only(bottom: 110),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (accounts.isNotEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                  child: Text(
                    "My Accounts",
                    style: TextStyle(
                      color: Colors.white54,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.0,
                    ),
                  ),
                ),
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
              const CashFlowCard(),
              const BalanceTrendChart(),
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

  Widget _buildFullWidthAnimatedBar(BuildContext context) {
    final double bottomPadding = MediaQuery.of(context).padding.bottom;

    return Container(
      width: double.infinity,
      height: 70 + bottomPadding,
      decoration: BoxDecoration(
        color: const Color(0xFF101825).withOpacity(0.90),
        border: Border(
          top: BorderSide(color: Colors.white.withOpacity(0.08), width: 1),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.4),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: ClipRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Padding(
            padding: EdgeInsets.fromLTRB(16, 8, 16, bottomPadding + 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                _buildAnimatedNavItem(0, CupertinoIcons.house_fill, "Home"),
                _buildAnimatedNavItem(
                    1, CupertinoIcons.list_bullet, "Transactions"),
                _buildCenterFab(),
                _buildAnimatedNavItem(
                    2, Icons.donut_large_outlined, "Analytics"),
                _buildAnimatedNavItem(3, CupertinoIcons.layers_alt, "Insights"),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAnimatedNavItem(int index, IconData icon, String label) {
    final bool isSelected = _currentIndex == index;

    return GestureDetector(
      onTap: () => _onTabTapped(index),
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutQuint,
        padding: EdgeInsets.symmetric(
          horizontal: isSelected ? 16 : 10,
          vertical: 10,
        ),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFF00B4D8).withOpacity(0.15)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isSelected ? const Color(0xFF00B4D8) : Colors.white54,
              size: 24,
            ),
            if (isSelected) ...[
              const SizedBox(width: 8),
              Text(
                label,
                style: const TextStyle(
                  color: Color(0xFF00B4D8),
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildCenterFab() {
    return GestureDetector(
      onTap: () {
        HapticFeedback.mediumImpact();
        showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          builder: (ctx) => const NewExpenseScreen(),
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
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF00B4D8).withOpacity(0.4),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
          border: Border.all(color: Colors.white.withOpacity(0.2), width: 1.5),
        ),
        child: const Icon(Icons.add_rounded, color: Colors.white, size: 28),
      ),
    );
  }
}
