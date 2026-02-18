import 'package:budget/core/widgets/futuristic_loader.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:intl/intl.dart';
import 'package:collection/collection.dart';

import '../../../core/widgets/modern_loader.dart';
import '../../../core/models/transaction_category_model.dart';
import '../../../core/services/category_service.dart';
import '../../../core/constants/icon_constants.dart';
import '../../../core/design/budgetr_colors.dart';
import '../../../core/widgets/status_bottom_sheet.dart';

import '../models/expense_models.dart';
import '../models/filter_criteria.dart';
import '../services/expense_service.dart';
import '../widgets/transaction_item.dart';
import '../widgets/smart_filter_sheet.dart';
import 'new_expense_screen.dart';

class AllTransactionsScreen extends StatefulWidget {
  const AllTransactionsScreen({super.key});

  @override
  State<AllTransactionsScreen> createState() => _AllTransactionsScreenState();
}

class _AllTransactionsScreenState extends State<AllTransactionsScreen> {
  final ExpenseService _service = GetIt.I<ExpenseService>();
  final CategoryService _categoryService = GetIt.I<CategoryService>();

  // Active Filter State
  FilterCriteria _criteria = FilterCriteria();

  // Cache for Live Count
  List<ExpenseTransactionModel> _allCachedTransactions = [];

  void _openSmartFilterSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => SmartFilterSheet(
        initialFilters: _criteria,
        allTransactions: _allCachedTransactions,
        onApply: (newFilters) {
          setState(() {
            _criteria = newFilters;
          });
        },
      ),
    );
  }

  void _toggleTypeFilter(String type) {
    setState(() {
      if (_criteria.transactionTypes.contains(type)) {
        _criteria.transactionTypes.remove(type);
      } else {
        _criteria.transactionTypes.add(type);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // --- SMART HORIZONTAL FILTER BAR ---
        Container(
          height: 60,
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
              color: BudgetrColors.background,
              border: Border(
                  bottom: BorderSide(color: Colors.white.withOpacity(0.05)))),
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            children: [
              // 1. Tune/Filter Button
              _buildTuneButton(),
              const SizedBox(width: 12),

              // 2. Clear Button (Only visible if filters are active)
              if (_criteria.hasFilters) ...[
                _buildClearButton(),
                const SizedBox(width: 12),
              ],

              // 3. Quick Multi-Select Toggles
              _buildQuickFilterChip("Expense"),
              const SizedBox(width: 8),
              _buildQuickFilterChip("Income"),
              const SizedBox(width: 8),
              _buildQuickFilterChip("Transfer Out"),
              const SizedBox(width: 8),
              _buildQuickFilterChip(
                  "Transfer In"), // [UPDATED] Added Transfer In

              const SizedBox(width: 8),
              // Indicator for complex filters (Date/Amount/Cats/Buckets)
              if (_criteria.dateRange != null ||
                  _criteria.amountRange != null ||
                  _criteria.selectedCategories.isNotEmpty ||
                  _criteria.selectedBuckets.isNotEmpty)
                _buildActiveFilterIndicator(),
            ],
          ),
        ),

        // --- CONTENT ---
        Expanded(
          child: StreamBuilder<List<TransactionCategoryModel>>(
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

              return StreamBuilder<List<ExpenseAccountModel>>(
                stream: _service.getAccounts(),
                builder: (context, accountSnapshot) {
                  final Map<String, ExpenseAccountModel> accountMap = {
                    if (accountSnapshot.hasData)
                      for (var acc in accountSnapshot.data!) acc.id: acc
                  };

                  return StreamBuilder<List<ExpenseTransactionModel>>(
                    stream: _service.getFilteredTransactions(_criteria),
                    builder: (context, txnSnapshot) {
                      if (txnSnapshot.connectionState ==
                          ConnectionState.waiting) {
                        return const Center(
                            child: FuturisticLoader(
                                size: 80, label: "LOADING TRANSACTIONS..."));
                      }

                      final transactions = txnSnapshot.data ?? [];

                      if (!_criteria.hasFilters) {
                        _allCachedTransactions = transactions;
                      } else if (_allCachedTransactions.isEmpty) {
                        _allCachedTransactions = transactions;
                      }

                      if (transactions.isEmpty) {
                        return _buildEmptyState();
                      }

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
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 12),
                                child: Text(
                                  month,
                                  style: const TextStyle(
                                    color: Colors.white54,
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 1,
                                  ),
                                ),
                              ),
                              ...txns.map((txn) {
                                final account = accountMap[txn.accountId];
                                final accountName = account != null
                                    ? "${account.name} - ${account.bankName}"
                                    : "Unknown Account";

                                return TransactionItem(
                                  txn: txn,
                                  iconData: categoryIconMap[txn.category] ??
                                      Icons.category_outlined,
                                  sourceAccountName: accountName,
                                  onEdit: () {
                                    showModalBottomSheet(
                                      context: context,
                                      isScrollControlled: true,
                                      backgroundColor: Colors.transparent,
                                      builder: (ctx) => NewExpenseScreen(
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
          ),
        ),
      ],
    );
  }

  // --- WIDGETS ---

  Widget _buildTuneButton() {
    // Check if complex filters are active (anything other than basic type toggles)
    bool hasComplexFilters = _criteria.dateRange != null ||
        _criteria.amountRange != null ||
        _criteria.selectedCategories.isNotEmpty ||
        _criteria.selectedBuckets.isNotEmpty;

    return GestureDetector(
      onTap: _openSmartFilterSheet,
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
            color: hasComplexFilters
                ? BudgetrColors.accent
                : Colors.white.withOpacity(0.08),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white10)),
        child: Icon(Icons.tune_rounded,
            size: 18, color: hasComplexFilters ? Colors.white : Colors.white70),
      ),
    );
  }

  // [NEW] Clear Filter Button
  Widget _buildClearButton() {
    return GestureDetector(
      onTap: () {
        setState(() {
          _criteria = FilterCriteria(); // Reset filters
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.redAccent.withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.redAccent.withOpacity(0.3)),
        ),
        child: const Row(
          children: [
            Icon(Icons.close, size: 14, color: Colors.redAccent),
            SizedBox(width: 4),
            Text("Clear",
                style: TextStyle(
                    color: Colors.redAccent,
                    fontSize: 12,
                    fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickFilterChip(String label) {
    bool isActive = _criteria.transactionTypes.contains(label);

    return GestureDetector(
      onTap: () => _toggleTypeFilter(label),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
            color: isActive ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
            border:
                Border.all(color: isActive ? Colors.white : Colors.white24)),
        alignment: Alignment.center,
        child: Text(
          label,
          style: TextStyle(
              color: isActive ? Colors.black : Colors.white70,
              fontWeight: FontWeight.w600,
              fontSize: 13),
        ),
      ),
    );
  }

  Widget _buildActiveFilterIndicator() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.08),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.white10)),
      child: const Row(
        children: [
          Icon(Icons.filter_list, size: 14, color: BudgetrColors.accent),
          SizedBox(width: 6),
          Text("Active",
              style: TextStyle(
                  color: BudgetrColors.accent,
                  fontSize: 12,
                  fontWeight: FontWeight.bold))
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.filter_list_off,
              size: 64, color: Colors.white.withOpacity(0.1)),
          const SizedBox(height: 16),
          Text("No transactions match",
              style: TextStyle(color: Colors.white.withOpacity(0.5))),
          const SizedBox(height: 16),
          TextButton(
            onPressed: () => setState(() => _criteria = FilterCriteria()),
            child: const Text("Clear All Filters",
                style: TextStyle(color: BudgetrColors.accent)),
          )
        ],
      ),
    );
  }

  Future<void> _handleDelete(
      BuildContext context, ExpenseTransactionModel txn) async {
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
