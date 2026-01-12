import 'package:budget/core/widgets/status_bottom_sheet.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
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
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: const Text("Accounts", style: TextStyle(color: Colors.white)),
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
            Column(
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
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              child: Row(
                                children: [
                                  const Expanded(
                                      child: Divider(color: Colors.white24)),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8),
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
    // [CHANGED] Check if Credit Card Pool already exists in the list
    final bool hasCreditPool =
        _accounts.any((acc) => acc.accountType == 'Credit Card');

    // [CHANGED] Logic to decide if we should allow creating a Credit Card
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
        // [CHANGED] Pass the restriction flag
        isCreditPoolAvailable: isCreditPoolAvailable,
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

    // showDialog(
    //   context: context,
    //   builder: (ctx) => AlertDialog(
    //     backgroundColor: const Color(0xff0D1B2A),
    //     shape: RoundedRectangleBorder(
    //         borderRadius: BorderRadius.circular(16),
    //         side: BorderSide(color: Colors.white.withOpacity(0.1))),
    //     title: const Text("Delete Account?",
    //         style: TextStyle(color: Colors.white)),
    //     content: Text(
    //       "Are you sure you want to delete '${account.name}'? This will permanently delete the account and ALL its transactions.",
    //       style: TextStyle(color: Colors.white.withOpacity(0.7)),
    //     ),
    //     actions: [
    //       TextButton(
    //           onPressed: () => Navigator.pop(ctx),
    //           child: const Text("Cancel",
    //               style: TextStyle(color: Colors.white54))),
    //       TextButton(
    //         onPressed: () async {
    //           Navigator.pop(ctx);
    //           setState(() {
    //             _isLoading = true;
    //             _accounts.removeWhere((a) => a.id == account.id);
    //           });

    //           try {
    //             await ExpenseService().deleteAccount(account.id);
    //             if (mounted) {
    //               ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
    //                   content: Text("Account deleted successfully"),
    //                   backgroundColor: Colors.redAccent));
    //             }
    //           } catch (e) {
    //             if (mounted) {
    //               ScaffoldMessenger.of(context)
    //                   .showSnackBar(SnackBar(content: Text("Error: $e")));
    //             }
    //           } finally {
    //             if (mounted) setState(() => _isLoading = false);
    //           }
    //         },
    //         child: const Text("Delete",
    //             style: TextStyle(
    //                 color: Colors.redAccent, fontWeight: FontWeight.bold)),
    //       ),
    //     ],
    //   ),
    // );
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
