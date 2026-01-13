import 'package:budget/core/widgets/status_bottom_sheet.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:intl/intl.dart';
import 'package:collection/collection.dart';
import '../../../core/widgets/modern_loader.dart';
import '../../../core/models/transaction_category_model.dart';
import '../../../core/services/category_service.dart';
import '../../../core/constants/icon_constants.dart';
import '../models/expense_models.dart';
import '../services/expense_service.dart';
import '../widgets/transaction_item.dart';
import '../widgets/add_expense_txn_sheet.dart';

class AllTransactionsScreen extends StatefulWidget {
  const AllTransactionsScreen({super.key});

  @override
  State<AllTransactionsScreen> createState() => _AllTransactionsScreenState();
}

class _AllTransactionsScreenState extends State<AllTransactionsScreen> {
  final ExpenseService _service = GetIt.I<ExpenseService>();
  final CategoryService _categoryService = GetIt.I<CategoryService>();

  @override
  Widget build(BuildContext context) {
    // 1. Fetch Categories (For Icons)
    return StreamBuilder<List<TransactionCategoryModel>>(
      stream: _categoryService.getCategories(),
      builder: (context, catSnapshot) {
        final Map<String, IconData> categoryIconMap = {};
        if (catSnapshot.hasData) {
          for (var cat in catSnapshot.data!) {
            if (cat.iconCode != null) {
              categoryIconMap[cat.name] =
                  IconConstants.getIconByCode(cat.iconCode!);
            }
          }
        }

        // 2. Fetch Accounts (For Account Names)
        return StreamBuilder<List<ExpenseAccountModel>>(
          stream: _service.getAccounts(),
          builder: (context, accountSnapshot) {
            // Create a lookup map for Account Names
            final Map<String, ExpenseAccountModel> accountMap = {
              if (accountSnapshot.hasData)
                for (var acc in accountSnapshot.data!) acc.id: acc
            };

            // 3. Fetch All Transactions
            return StreamBuilder<List<ExpenseTransactionModel>>(
              stream: _service.getAllTransactions(),
              builder: (context, txnSnapshot) {
                if (txnSnapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: ModernLoader());
                }

                final transactions = txnSnapshot.data ?? [];

                if (transactions.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.receipt_long_outlined,
                            size: 64, color: Colors.white.withOpacity(0.1)),
                        const SizedBox(height: 16),
                        Text("No transactions yet",
                            style: TextStyle(
                                color: Colors.white.withOpacity(0.5))),
                      ],
                    ),
                  );
                }

                // Group transactions by Month (Just like Account Details)
                final grouped =
                    groupBy(transactions, (ExpenseTransactionModel t) {
                  return DateFormat('MMMM yyyy').format(t.date);
                });

                return ListView.builder(
                  padding: const EdgeInsets.fromLTRB(20, 10, 20, 100),
                  itemCount: grouped.length,
                  itemBuilder: (context, index) {
                    final month = grouped.keys.elementAt(index);
                    final txns = grouped[month]!;

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Month Header
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          child: Text(
                            month,
                            style: const TextStyle(
                              color: Colors.white54,
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1,
                            ),
                          ),
                        ),
                        // Transaction List for this Month
                        ...txns.map((txn) {
                          final account = accountMap[txn.accountId];
                          final accountName = account != null
                              ? account.name
                              : "Unknown Account";

                          return TransactionItem(
                            txn: txn,
                            // Use actual category icon from map
                            iconData: categoryIconMap[txn.category] ??
                                Icons.category_outlined,
                            sourceAccountName: accountName,
                            onEdit: () {
                              showModalBottomSheet(
                                context: context,
                                isScrollControlled: true,
                                backgroundColor: Colors.transparent,
                                builder: (ctx) => AddExpenseTransactionSheet(
                                  // [FIXED] Correct Parameter Name
                                  txnToEdit: txn,
                                ),
                              );
                            },
                            onDelete: () async {
                              await _handleDelete(context, txn);
                            },
                          );
                        }),
                      ],
                    );
                  },
                );
              },
            );
          },
        );
      },
    );
  }

  Future<void> _handleDelete(
      BuildContext context, ExpenseTransactionModel txn) async {
    // final confirm = await showDialog<bool>(
    //   context: context,
    //   builder: (c) => AlertDialog(
    //     backgroundColor: const Color(0xFF1B263B),
    //     title: const Text("Delete Transaction?",
    //         style: TextStyle(color: Colors.white)),
    //     content: const Text("This will revert the balance on the account.",
    //         style: TextStyle(color: Colors.white70)),
    //     actions: [
    //       TextButton(
    //           onPressed: () => Navigator.pop(c, false),
    //           child: const Text("Cancel")),
    //       TextButton(
    //           onPressed: () => Navigator.pop(c, true),
    //           child: const Text("Delete",
    //               style: TextStyle(color: Colors.redAccent))),
    //     ],
    //   ),
    // );

    // if (confirm == true) {
    //   await _service.deleteTransaction(txn);
    // }

    showStatusSheet(
      context: context,
      title: "Delete Transaction?",
      message:
          "Are you sure you want to remove this transaction? This action cannot be undone.",
      icon: Icons.delete_sweep_sharp,
      color: Colors.redAccent,
      cancelButtonText: "Cancel",
      onCancel: () {},
      buttonText: "Delete",
      onDismiss: () async {
        await _service.deleteTransaction(txn);
      },
    );
  }
}
