import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // For Haptics
import '../../../core/widgets/modern_loader.dart';
import '../models/expense_models.dart';
import '../services/expense_service.dart';
import '../widgets/add_expense_txn_sheet.dart';
import '../widgets/bank_account_mini_card.dart';
import 'account_detail_screen.dart';
import 'account_management_screen.dart';

class DailyExpenseScreen extends StatefulWidget {
  const DailyExpenseScreen({super.key});

  @override
  State<DailyExpenseScreen> createState() => _DailyExpenseScreenState();
}

class _DailyExpenseScreenState extends State<DailyExpenseScreen> {
  final ExpenseService _service = ExpenseService();
  late Stream<List<ExpenseAccountModel>> _accountsStream;

  @override
  void initState() {
    super.initState();
    // CHANGED: Use the dashboard specific stream to respect user order & limits
    _accountsStream = _service.getDashboardAccounts();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xff0D1B2A),
      appBar: AppBar(
        backgroundColor: const Color(0xff0D1B2A),
        elevation: 0,
        centerTitle: false,
        title: const Padding(
          padding: EdgeInsets.only(left: 8.0),
          child: Text("Daily Tracker",
              style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 22)),
        ),
      ),
      body: Stack(
        children: [
          // --- Ambient Background Glow ---
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

          // --- Main Content ---
          SafeArea(
            child: Column(
              children: [
                const SizedBox(height: 10),
                Expanded(
                  child: _buildDualRowAccounts(),
                ),
              ],
            ),
          ),

          // --- FAB ---
          Positioned(
            bottom: 24,
            left: 0,
            right: 0,
            child: Center(
              child: FloatingActionButton.extended(
                onPressed: () => showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  backgroundColor: Colors.transparent,
                  builder: (ctx) => const AddExpenseTransactionSheet(),
                ),
                backgroundColor: const Color(0xFF00B4D8),
                elevation: 8,
                icon: const Icon(Icons.add, color: Colors.white),
                label: const Text("Log Expense",
                    style: TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDualRowAccounts() {
    return StreamBuilder<List<ExpenseAccountModel>>(
      stream: _accountsStream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: ModernLoader());
        }

        // The Service already limits to 6, but we keep .take(6) as a UI safeguard
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

        // Add "All Accounts" Gateway Card to Row 2
        row2Items.add("ALL_ACCOUNTS_CARD");

        return SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- Row 1 ---
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

              // --- Row 2 ---
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
                        width: 160,
                        child: _buildAllAccountsCard(context),
                      );
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

              const SizedBox(height: 100),
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

  // --- The "Gateway" Card ---
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
}
