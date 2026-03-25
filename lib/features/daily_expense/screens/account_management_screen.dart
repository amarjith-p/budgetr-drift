import 'package:budget/core/widgets/futuristic_loader.dart';
import 'package:budget/core/widgets/status_bottom_sheet.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import '../../../core/widgets/modern_loader.dart';
import '../models/expense_models.dart';
import '../services/expense_service.dart';
import '../widgets/add_account_sheet.dart';
import '../widgets/bank_account_card.dart';
import '../widgets/total_balance_summary.dart';
import '../widgets/account_options_dialog.dart';
import 'account_detail_screen.dart';
import '../../../core/widgets/glass_card.dart'; // [NEW IMPORT]

class AccountManagementScreen extends StatefulWidget {
  const AccountManagementScreen({super.key});

  @override
  State<AccountManagementScreen> createState() =>
      _AccountManagementScreenState();
}

class _AccountManagementScreenState extends State<AccountManagementScreen> {
  List<ExpenseAccountModel> _accounts = [];
  bool _isLoading = false;
  bool _hasLoaded = false;
  bool _showTip = true;

  @override
  void initState() {
    super.initState();
    GetIt.I<ExpenseService>().getAccounts().listen((data) {
      if (mounted) {
        setState(() {
          _accounts = data;
          _hasLoaded = true;
        });
      }
    });
  }

  void _onReorder(int oldIndex, int newIndex) {
    if (oldIndex < newIndex) {
      newIndex -= 1;
    }
    setState(() {
      final item = _accounts.removeAt(oldIndex);
      _accounts.insert(newIndex, item);
    });

    GetIt.I<ExpenseService>().updateAccountOrder(_accounts);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xff0D1B2A), // Dark Background
      // [FIX] Removed standard AppBar
      // Switched to SafeArea > Column layout for Modern Header
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                // 1. MODERN HEADER
                _buildModernHeader(),

                // 2. CONTENT
                if (!_hasLoaded)
                  const Expanded(
                      child: Center(
                          child: FuturisticLoader(
                              size: 80,
                              label: "ASSEMBLING ACCOUNT PORTFOLIO...")))
                else if (_accounts.isEmpty)
                  Expanded(child: _buildEmptyState())
                else
                  Expanded(
                    child: Column(
                      children: [
                        TotalBalanceSummary(accounts: _accounts),
                        Expanded(
                          child: ReorderableListView.builder(
                            padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
                            itemCount: _accounts.length,
                            onReorder: _onReorder,
                            header: _showTip
                                ? _buildReorderTip()
                                : const SizedBox(height: 0),
                            proxyDecorator: (child, index, animation) {
                              return AnimatedBuilder(
                                animation: animation,
                                builder: (BuildContext context, Widget? child) {
                                  return Material(
                                    elevation: 8,
                                    color: Colors.transparent,
                                    shadowColor: Colors.black54,
                                    child: child,
                                  );
                                },
                                child: child,
                              );
                            },
                            itemBuilder: (context, index) {
                              final account = _accounts[index];

                              return Column(
                                key: ValueKey(account.id),
                                children: [
                                  if (index == 6)
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 12),
                                      child: Row(
                                        children: [
                                          const Expanded(
                                              child: Divider(
                                                  color: Colors.white24)),
                                          Padding(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 8),
                                            child: Text(
                                              "Not on Dashboard",
                                              style: TextStyle(
                                                  color: Colors.white
                                                      .withOpacity(0.5),
                                                  fontSize: 12),
                                            ),
                                          ),
                                          const Expanded(
                                              child: Divider(
                                                  color: Colors.white24)),
                                        ],
                                      ),
                                    ),
                                  Padding(
                                    padding: const EdgeInsets.only(bottom: 16),
                                    child: BankAccountCard(
                                      account: account,
                                      onTap: () => Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) => AccountDetailScreen(
                                              account: account),
                                        ),
                                      ),
                                      onMoreTap: () =>
                                          _showAccountOptions(context, account),
                                    ),
                                  ),
                                ],
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
            if (_isLoading)
              Container(
                color: Colors.black54,
                child: const Center(child: ModernLoader(size: 60)),
              ),
          ],
        ),
      ),
    );
  }

  // --- NEW: Modern Header Implementation ---
  Widget _buildModernHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        children: [
          // Back Button
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

          // Title Section
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "OVERVIEW",
                  style: TextStyle(
                    color: Colors.white38,
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 2.0,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  "Accounts & Wallets",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    letterSpacing: -0.5,
                  ),
                ),
              ],
            ),
          ),

          // Add Account Button
          GestureDetector(
            onTap: () => _showAddAccountSheet(context, null),
            child: GlassCard(
              borderRadius: 12,
              padding: const EdgeInsets.all(10),
              margin: EdgeInsets.zero,
              color: Colors.white.withOpacity(0.05),
              child: const Icon(Icons.add_rounded,
                  color: Colors.white70, size: 20),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReorderTip() {
    return Container(
      margin: const EdgeInsets.only(bottom: 16, top: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF00B4D8).withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF00B4D8).withOpacity(0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.info_outline_rounded,
              color: Color(0xFF00B4D8), size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Customize Your View",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  "Long press & drag cards to reorder. The top 6 accounts will appear on your Home Dashboard.",
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.7),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () => setState(() => _showTip = false),
            icon: const Icon(Icons.close, size: 18, color: Colors.white54),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          )
        ],
      ),
    );
  }

  void _showAccountOptions(BuildContext context, ExpenseAccountModel account) {
    showDialog(
      context: context,
      builder: (ctx) => AccountOptionsDialog(
        account: account,
        onDelete: () => _handleDeleteAccount(context, account),
        onEdit: () => _showAddAccountSheet(context, account),
      ),
    );
  }

  void _showAddAccountSheet(
      BuildContext context, ExpenseAccountModel? accountToEdit) {
    // Check if Credit Card Pool already exists in the list
    final bool hasCreditPool =
        _accounts.any((acc) => acc.accountType == 'Credit Card');

    // Logic to decide if we should allow creating a Credit Card
    // 1. If we are adding a NEW account, allow only if NONE exist.
    // 2. If we are EDITING, allow if none exist OR if the one we are editing IS the credit card.
    bool isCreditPoolAvailable = true;

    if (accountToEdit == null) {
      isCreditPoolAvailable = !hasCreditPool;
    } else {
      isCreditPoolAvailable =
          !hasCreditPool || accountToEdit.accountType == 'Credit Card';
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => AddAccountSheet(
        accountToEdit: accountToEdit,
        // Pass the restriction flag
        isCreditPoolAvailable: isCreditPoolAvailable,
        onAccountAdded: (data) async {
          double rawBalance =
              double.tryParse(data['currentBalance'].toString()) ?? 0.0;
          // Format to 2 decimal places (e.g., "150.55") and parse back to double
          double formattedBalance = double.parse(rawBalance.toStringAsFixed(2));
          final newAccount = ExpenseAccountModel(
            id: accountToEdit?.id ??
                DateTime.now().millisecondsSinceEpoch.toString(),
            name: data['name'],
            bankName: data['bankName'],
            type: data['type'],
            currentBalance: formattedBalance,
            accountType: data['accountType'],
            accountNumber: data['accountNumber'],
            color: data['color'],
            createdAt: accountToEdit?.createdAt ?? DateTime.timestamp(),
            showOnDashboard: accountToEdit?.showOnDashboard ?? true,
            dashboardOrder: accountToEdit?.dashboardOrder ?? _accounts.length,
          );

          try {
            if (accountToEdit != null) {
              await GetIt.I<ExpenseService>().updateAccount(newAccount);
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                  content: Text("Account Updated"),
                  backgroundColor: Colors.green,
                ));
              }
            } else {
              await GetIt.I<ExpenseService>().addAccount(newAccount);
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                  content: Text("Account Added"),
                  backgroundColor: Colors.green,
                ));
              }
            }
          } catch (e) {
            debugPrint("Error saving account: $e");
          }
        },
      ),
    );
  }

  void _handleDeleteAccount(BuildContext context, ExpenseAccountModel account) {
    showStatusSheet(
      context: context,
      title: "Delete Account?",
      message:
          "Are you sure you want to delete '${account.name}'? This will permanently delete the account and ALL its transactions.",
      icon: Icons.delete_sweep_sharp,
      color: Colors.redAccent,
      cancelButtonText: "Cancel",
      onCancel: () {},
      buttonText: "Delete",
      onDismiss: () async {
        setState(() {
          _isLoading = true;
          _accounts.removeWhere((a) => a.id == account.id);
        });

        try {
          await GetIt.I<ExpenseService>().deleteAccount(account.id);
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                content: Text("Account deleted successfully"),
                backgroundColor: Colors.redAccent));
          }
        } catch (e) {
          if (mounted) {
            ScaffoldMessenger.of(context)
                .showSnackBar(SnackBar(content: Text("Error: $e")));
          }
        } finally {
          if (mounted) setState(() => _isLoading = false);
        }
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.account_balance_wallet_outlined,
              size: 64, color: Colors.white.withOpacity(0.2)),
          const SizedBox(height: 16),
          Text(
            "No accounts linked yet",
            style:
                TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 16),
          ),
        ],
      ),
    );
  }
}
