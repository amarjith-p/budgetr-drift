import 'dart:ui';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../core/widgets/modern_loader.dart';
import '../models/expense_models.dart';
import '../services/expense_service.dart';
import '../widgets/add_account_sheet.dart';
import '../widgets/bank_account_card.dart';
import '../widgets/dashboard_account_config_sheet.dart';
import 'account_detail_screen.dart';

class AccountManagementScreen extends StatefulWidget {
  const AccountManagementScreen({super.key});

  @override
  State<AccountManagementScreen> createState() =>
      _AccountManagementScreenState();
}

class _AccountManagementScreenState extends State<AccountManagementScreen> {
  // Loading state for Delete/Edit operations
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xff0D1B2A), // Dark Background
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: const Text("My Wallet", style: TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          // --- UPDATED: Explicit "Customize" Button ---
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
            child: TextButton.icon(
              onPressed: () {
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  backgroundColor: Colors.transparent,
                  builder: (ctx) => const DashboardAccountConfigSheet(),
                );
              },
              style: TextButton.styleFrom(
                backgroundColor: Colors.white.withOpacity(0.1),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 12),
              ),
              icon: const Icon(
                Icons.tune_rounded,
                size: 16,
                color: Colors.white,
              ),
              label: const Text(
                "Customize",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),

          // Add Account Button
          IconButton(
            onPressed: () => _showAddAccountSheet(context, null),
            icon: const Icon(Icons.add),
            tooltip: "Add Account",
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: Stack(
        children: [
          StreamBuilder<List<ExpenseAccountModel>>(
            stream: ExpenseService().getAccounts(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: ModernLoader());
              }

              if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return _buildEmptyState();
              }

              final accounts = snapshot.data!;

              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: accounts.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: BankAccountCard(
                      account: accounts[index],
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              AccountDetailScreen(account: accounts[index]),
                        ),
                      ),
                      // Trigger the options dialog here
                      onMoreTap: () =>
                          _showAccountOptions(context, accounts[index]),
                    ),
                  );
                },
              );
            },
          ),

          // Loading Overlay for Delete operations
          if (_isLoading)
            Container(
              color: Colors.black54,
              child: const Center(child: ModernLoader(size: 60)),
            ),
        ],
      ),
    );
  }

  // --- 1. OPTIONS DIALOG (Edit/Delete) ---
  void _showAccountOptions(BuildContext context, ExpenseAccountModel account) {
    final currency =
        NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: 0);

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
                // Header
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

                // --- SUMMARY ---
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

                // Action Buttons
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
                          _showAddAccountSheet(context, account); // Edit Mode
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

  // --- 2. ADD/EDIT SHEET LOGIC ---
  void _showAddAccountSheet(
      BuildContext context, ExpenseAccountModel? accountToEdit) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => AddAccountSheet(
        accountToEdit: accountToEdit,
        onAccountAdded: (data) async {
          // If editing, preserve ID, CreatedAt and Dashboard Config
          // If adding, generate new ID and CreatedAt
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
            // Preserve dashboard settings if editing
            showOnDashboard: accountToEdit?.showOnDashboard ?? true,
            dashboardOrder: accountToEdit?.dashboardOrder ?? 0,
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

  // --- 3. DELETE LOGIC ---
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
