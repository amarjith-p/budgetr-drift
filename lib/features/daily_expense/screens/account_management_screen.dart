import 'dart:ui';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../core/widgets/modern_loader.dart';
import '../models/expense_models.dart';
import '../services/expense_service.dart';
import '../widgets/add_account_sheet.dart';
import '../widgets/bank_account_card.dart';
import 'account_detail_screen.dart';

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
    // Listen to stream to keep data fresh, but _accounts is modified by drag/drop
    ExpenseService().getAccounts().listen((data) {
      if (mounted && !_isLoading) {
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

    // Save new order to Firebase
    ExpenseService().updateAccountOrder(_accounts);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xff0D1B2A), // Dark Background
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: const Text("My Wallet", style: TextStyle(color: Colors.white)),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            onPressed: () => _showAddAccountSheet(context, null),
            icon: const Icon(Icons.add),
            tooltip: "Add Account",
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Stack(
        children: [
          if (!_hasLoaded)
            const Center(child: ModernLoader())
          else if (_accounts.isEmpty)
            _buildEmptyState()
          else
            ReorderableListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 80),
              itemCount: _accounts.length,
              onReorder: _onReorder,

              // Info Header tells user how to interact
              header:
                  _showTip ? _buildReorderTip() : const SizedBox(height: 16),

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
                    // Visual Divider for the "Top 6" dashboard cutoff
                    if (index == 6)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        child: Row(
                          children: [
                            const Expanded(
                                child: Divider(color: Colors.white24)),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 8),
                              child: Text(
                                "Not on Dashboard",
                                style: TextStyle(
                                    color: Colors.white.withOpacity(0.5),
                                    fontSize: 12),
                              ),
                            ),
                            const Expanded(
                                child: Divider(color: Colors.white24)),
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
                            builder: (_) =>
                                AccountDetailScreen(account: account),
                          ),
                        ),
                        onMoreTap: () => _showAccountOptions(context, account),
                      ),
                    ),
                  ],
                );
              },
            ),
          if (_isLoading)
            Container(
              color: Colors.black54,
              child: const Center(child: ModernLoader(size: 60)),
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
    final currency =
        NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: 2);

    showDialog(
      context: context,
      builder: (ctx) => BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
        child: Dialog(
          backgroundColor: const Color(0xff1B263B).withOpacity(0.9),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
              side: BorderSide(color: Colors.white.withOpacity(0.1))),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.account_balance_wallet,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          "Account Options",
                          style:
                              Theme.of(context).textTheme.titleLarge?.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                  ),
                        ),
                      ],
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.white54),
                      onPressed: () => Navigator.pop(ctx),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                _buildDetailRow("Account Name", account.name),
                const Divider(color: Colors.white10, height: 24),
                _buildDetailRow("Bank", account.bankName),
                const Divider(color: Colors.white10, height: 24),
                _buildDetailRow("Type", account.accountType),
                const Divider(color: Colors.white10, height: 24),
                _buildDetailRow("Account No", "**** ${account.accountNumber}"),
                const Divider(color: Colors.white10, height: 24),
                _buildDetailRow(
                    "Balance", currency.format(account.currentBalance)),
                const SizedBox(height: 32),
                Row(
                  children: [
                    Expanded(
                      child: TextButton.icon(
                        onPressed: () {
                          Navigator.pop(ctx);
                          _handleDeleteAccount(context, account);
                        },
                        icon: const Icon(Icons.delete_outline,
                            color: Colors.redAccent, size: 20),
                        label: const Text("Delete",
                            style: TextStyle(color: Colors.redAccent)),
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          backgroundColor: Colors.redAccent.withOpacity(0.1),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: TextButton.icon(
                        onPressed: () {
                          Navigator.pop(ctx);
                          _showAddAccountSheet(context, account);
                        },
                        icon: const Icon(Icons.edit_outlined,
                            color: Colors.white, size: 20),
                        label: const Text("Edit",
                            style: TextStyle(color: Colors.white)),
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          backgroundColor: Colors.white.withOpacity(0.1),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showAddAccountSheet(
      BuildContext context, ExpenseAccountModel? accountToEdit) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => AddAccountSheet(
        accountToEdit: accountToEdit,
        onAccountAdded: (data) async {
          final newAccount = ExpenseAccountModel(
            id: accountToEdit?.id ??
                DateTime.now().millisecondsSinceEpoch.toString(),
            name: data['name'],
            bankName: data['bankName'],
            type: data['type'],
            currentBalance: data['currentBalance'],
            accountType: data['accountType'],
            accountNumber: data['accountNumber'],
            color: data['color'],
            createdAt: accountToEdit?.createdAt ?? Timestamp.now(),
            showOnDashboard: accountToEdit?.showOnDashboard ?? true,
            dashboardOrder: accountToEdit?.dashboardOrder ?? _accounts.length,
          );

          try {
            if (accountToEdit != null) {
              await ExpenseService().updateAccount(newAccount);
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                  content: Text("Account Updated"),
                  backgroundColor: Colors.green,
                ));
              }
            } else {
              await ExpenseService().addAccount(newAccount);
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
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xff0D1B2A),
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(color: Colors.white.withOpacity(0.1))),
        title: const Text("Delete Account?",
            style: TextStyle(color: Colors.white)),
        content: Text(
          "Are you sure you want to delete '${account.name}'? This will permanently delete the account and ALL its transactions.",
          style: TextStyle(color: Colors.white.withOpacity(0.7)),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text("Cancel",
                  style: TextStyle(color: Colors.white54))),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              setState(() => _isLoading = true);

              try {
                await ExpenseService().deleteAccount(account.id);
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
            child: const Text("Delete",
                style: TextStyle(
                    color: Colors.redAccent, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
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

  Widget _buildDetailRow(String label, String value) =>
      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Text(label, style: TextStyle(color: Colors.white.withOpacity(0.5))),
        Text(value,
            style: const TextStyle(
                color: Colors.white, fontWeight: FontWeight.bold))
      ]);
}
