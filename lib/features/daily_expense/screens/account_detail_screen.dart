// lib/features/daily_expense/screens/account_detail_screen.dart

import 'package:budget/core/widgets/status_bottom_sheet.dart';
import 'package:budget/features/daily_expense/widgets/modern_expense_sheet.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:intl/intl.dart';
import 'package:collection/collection.dart';
import '../../../core/widgets/modern_loader.dart';
import '../../../core/models/transaction_category_model.dart';
import '../../../core/services/category_service.dart';
import '../../../core/constants/icon_constants.dart';
import '../../credit_tracker/models/credit_models.dart';
import '../../credit_tracker/services/credit_service.dart';
import '../models/expense_models.dart';
import '../services/expense_service.dart';
import '../widgets/add_expense_txn_sheet.dart';
import '../widgets/transaction_item.dart';
import '../widgets/expense_filter_sheet.dart';

class AccountDetailScreen extends StatefulWidget {
  final ExpenseAccountModel account;
  const AccountDetailScreen({super.key, required this.account});

  @override
  State<AccountDetailScreen> createState() => _AccountDetailScreenState();
}

class _AccountDetailScreenState extends State<AccountDetailScreen> {
  // --- Filter States ---
  String _selectedType = 'All';
  String _sortOption = 'Newest';
  DateTimeRange? _dateRange;
  Set<String> _selectedCategories = {};
  Set<String> _selectedBuckets = {};

  final Color _bgColor = const Color(0xff0D1B2A);
  final Color _accentColor = const Color(0xFF00B4D8);

  bool _isLoading = false;

  late Stream<List<TransactionCategoryModel>> _categoryStream;
  late Stream<List<ExpenseTransactionModel>> _transactionStream;

  @override
  void initState() {
    super.initState();
    _categoryStream = GetIt.I<CategoryService>().getCategories();
    _transactionStream =
        GetIt.I<ExpenseService>().getTransactionsForAccount(widget.account.id);
  }

  // --- SYNC LOGIC ---
  Future<void> _handleSync(List<ExpenseTransactionModel> transactions) async {
    final creditEntries = transactions
        .where((t) =>
            t.linkedCreditCardId != null && t.linkedCreditCardId!.isNotEmpty)
        .toList();

    if (creditEntries.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("No transactions to sync.")));
      return;
    }

    showStatusSheet(
        context: context,
        title: "Sync to Credit Tracker?",
        message:
            "This will move ${creditEntries.length} transactions to the Credit Tracker.\n\nNote: Transfers will be linked. If you delete them in Credit Tracker, the Bank deduction will also be removed.",
        icon: Icons.sync_sharp,
        color: Colors.cyanAccent,
        cancelButtonText: "Cancel",
        onCancel: () {},
        buttonText: "Sync Now",
        onDismiss: () async {
          setState(() => _isLoading = true);

          try {
            int successCount = 0;

            for (var txn in creditEntries) {
              String creditType = 'Expense';
              String finalNotes = txn.notes;
              String? linkedExpenseId;

              if (txn.type == 'Transfer In' || txn.type == 'Income') {
                creditType = 'Income';
                final sourceTxn =
                    await GetIt.I<ExpenseService>().findLinkedTransfer(txn);
                if (sourceTxn != null) {
                  linkedExpenseId = sourceTxn.id;
                }

                if (txn.type == 'Transfer In' &&
                    txn.transferAccountBankName != null) {
                  final sourceInfo =
                      "Transfer from ${txn.transferAccountBankName} - ${txn.transferAccountName}";
                  if (txn.notes.isEmpty) {
                    finalNotes = sourceInfo;
                  } else {
                    finalNotes = "$sourceInfo. ${txn.notes}";
                  }
                }
              }

              final creditTxn = CreditTransactionModel(
                id: '',
                cardId: txn.linkedCreditCardId!,
                amount: txn.amount,
                date: txn.date,
                bucket: txn.bucket,
                type: creditType,
                category: txn.category,
                subCategory: txn.subCategory,
                notes: finalNotes,
                linkedExpenseId: linkedExpenseId,
              );

              await GetIt.I<CreditService>().addTransaction(creditTxn);
              await GetIt.I<ExpenseService>().deleteTransactionSingle(txn);
              successCount++;
            }

            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content:
                      Text("Successfully synced $successCount transactions!"),
                  backgroundColor: Colors.green));
            }
          } catch (e) {
            if (mounted) {
              ScaffoldMessenger.of(context)
                  .showSnackBar(SnackBar(content: Text("Sync Error: $e")));
            }
          } finally {
            if (mounted) setState(() => _isLoading = false);
          }
        });
  }

  @override
  Widget build(BuildContext context) {
    final isPoolAccount =
        widget.account.bankName == 'Credit Card Pool Account' ||
            widget.account.accountType == 'Credit Card';

    return StreamBuilder<List<TransactionCategoryModel>>(
      stream: _categoryStream,
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

        return Scaffold(
          backgroundColor: _bgColor,
          floatingActionButton: FloatingActionButton(
            onPressed: () {
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                backgroundColor: Colors.transparent,
                builder: (context) => ModernExpenseSheet(
                  preSelectedAccount: widget.account,
                ),
              );
            },
            backgroundColor: _accentColor,
            child: const Icon(Icons.add, color: Colors.white),
          ),
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            titleSpacing: 0,
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.account.name,
                  style: const TextStyle(color: Colors.white, fontSize: 16),
                ),
                Text(
                  widget.account.bankName,
                  style: const TextStyle(color: Colors.white54, fontSize: 12),
                ),
              ],
            ),
            iconTheme: const IconThemeData(color: Colors.white),
            actions: [
              StreamBuilder<List<ExpenseTransactionModel>>(
                stream: _transactionStream,
                builder: (context, snapshot) {
                  final hasData = snapshot.hasData && snapshot.data!.isNotEmpty;
                  final txns = snapshot.data ?? [];
                  return Row(
                    children: [
                      if (isPoolAccount)
                        IconButton(
                          onPressed: hasData ? () => _handleSync(txns) : null,
                          icon: const Icon(Icons.sync_rounded,
                              color: Colors.cyanAccent),
                          tooltip: "Sync to Credit Tracker",
                        ),
                      Stack(
                        alignment: Alignment.topRight,
                        children: [
                          IconButton(
                            onPressed: hasData
                                ? () =>
                                    _openFilterSheet(context, snapshot.data!)
                                : null,
                            icon: const Icon(Icons.filter_list_rounded),
                            tooltip: "Filter Transactions",
                          ),
                          if (_hasActiveFilters)
                            Container(
                              margin: const EdgeInsets.all(10),
                              width: 8,
                              height: 8,
                              decoration: const BoxDecoration(
                                  color: Colors.redAccent,
                                  shape: BoxShape.circle),
                            ),
                        ],
                      ),
                    ],
                  );
                },
              ),
              const SizedBox(width: 8),
            ],
          ),
          body: Stack(
            children: [
              Column(
                children: [
                  if (_hasActiveFilters) _buildActiveFiltersList(),
                  Expanded(
                    child: StreamBuilder<List<ExpenseTransactionModel>>(
                      stream: _transactionStream,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(child: ModernLoader());
                        }
                        if (snapshot.hasError) {
                          return Center(
                              child: Text("Error: ${snapshot.error}",
                                  style: const TextStyle(color: Colors.red)));
                        }
                        if (!snapshot.hasData || snapshot.data!.isEmpty) {
                          return isPoolAccount
                              ? _buildEmptyState(
                                  "All caught up! No unsynced entries.")
                              : _buildEmptyState("No transactions found.");
                        }

                        final filteredList = _applyFilters(snapshot.data!);
                        if (filteredList.isEmpty) {
                          return _buildEmptyState(
                              "No transactions match your filters.");
                        }

                        final grouped =
                            groupBy(filteredList, (ExpenseTransactionModel t) {
                          return DateFormat('MMMM yyyy').format(t.date);
                        });

                        return ListView.builder(
                          padding: const EdgeInsets.all(16),
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
                                        fontSize: 13,
                                        fontWeight: FontWeight.bold,
                                        letterSpacing: 1),
                                  ),
                                ),
                                ...txns
                                    .map((t) => TransactionItem(
                                          txn: t,
                                          iconData:
                                              categoryIconMap[t.category] ??
                                                  Icons.category_outlined,
                                          onEdit: () => _handleEdit(context, t),
                                          onDelete: () =>
                                              _handleDeleteTransaction(
                                                  context, t),
                                        ))
                                    .toList(),
                              ],
                            );
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
              if (_isLoading)
                Container(
                    color: Colors.black54,
                    child: const Center(child: ModernLoader(size: 60))),
            ],
          ),
        );
      },
    );
  }

  void _handleEdit(BuildContext context, ExpenseTransactionModel txn) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (c) => ModernExpenseSheet(txnToEdit: txn),
    );
  }

  void _handleDeleteTransaction(
      BuildContext context, ExpenseTransactionModel txn) {
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
        setState(() => _isLoading = true);
        try {
          await GetIt.I<ExpenseService>().deleteTransaction(txn);
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                content: Text("Transaction deleted"),
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

  List<ExpenseTransactionModel> _applyFilters(
      List<ExpenseTransactionModel> data) {
    var list = List<ExpenseTransactionModel>.from(data);
    if (_selectedType != 'All') {
      if (_selectedType == 'Transfer') {
        list = list
            .where((t) => t.type == 'Transfer Out' || t.type == 'Transfer In')
            .toList();
      } else {
        list = list.where((t) => t.type == _selectedType).toList();
      }
    }
    if (_dateRange != null) {
      list = list.where((t) {
        final date = t.date;
        final end = _dateRange!.end
            .add(const Duration(days: 1))
            .subtract(const Duration(seconds: 1));
        return date.isAfter(_dateRange!.start) && date.isBefore(end);
      }).toList();
    }
    if (_selectedCategories.isNotEmpty) {
      list =
          list.where((t) => _selectedCategories.contains(t.category)).toList();
    }
    if (_selectedBuckets.isNotEmpty) {
      list = list.where((t) => _selectedBuckets.contains(t.bucket)).toList();
    }

    switch (_sortOption) {
      case 'Newest':
        list.sort((a, b) => b.date.compareTo(a.date));
        break;
      case 'Oldest':
        list.sort((a, b) => a.date.compareTo(b.date));
        break;
      case 'Amount High':
        list.sort((a, b) => b.amount.compareTo(a.amount));
        break;
      case 'Amount Low':
        list.sort((a, b) => a.amount.compareTo(b.amount));
        break;
    }
    return list;
  }

  bool get _hasActiveFilters =>
      _selectedType != 'All' ||
      _dateRange != null ||
      _selectedCategories.isNotEmpty ||
      _selectedBuckets.isNotEmpty ||
      _sortOption != 'Newest';

  Widget _buildEmptyState(String msg) => Center(
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Icon(Icons.search_off, size: 48, color: Colors.white.withOpacity(0.2)),
        const SizedBox(height: 16),
        Text(msg, style: TextStyle(color: Colors.white.withOpacity(0.5)))
      ]));

  void _openFilterSheet(
      BuildContext context, List<ExpenseTransactionModel> allTxns) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => ExpenseFilterSheet(
        allTxns: allTxns,
        currentType: _selectedType,
        currentSort: _sortOption,
        currentDateRange: _dateRange,
        currentCategories: _selectedCategories,
        currentBuckets: _selectedBuckets,
        onApply: (type, sort, range, categories, buckets) {
          setState(() {
            _selectedType = type;
            _sortOption = sort;
            _dateRange = range;
            _selectedCategories = categories;
            _selectedBuckets = buckets;
          });
        },
      ),
    );
  }

  Widget _buildActiveFiltersList() {
    return Container(
        height: 50,
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: ListView(scrollDirection: Axis.horizontal, children: [
          GestureDetector(
              onTap: () => setState(() {
                    _selectedType = 'All';
                    _sortOption = 'Newest';
                    _dateRange = null;
                    _selectedCategories.clear();
                    _selectedBuckets.clear();
                  }),
              child: Container(
                  margin: const EdgeInsets.only(right: 8),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                      color: Colors.redAccent.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                      border:
                          Border.all(color: Colors.redAccent.withOpacity(0.3))),
                  child: const Center(
                      child: Text("Clear All",
                          style: TextStyle(
                              color: Colors.redAccent,
                              fontWeight: FontWeight.bold,
                              fontSize: 11))))),
          if (_selectedType != 'All')
            _buildFilterChip(
                _selectedType, () => setState(() => _selectedType = 'All')),
          if (_dateRange != null)
            _buildFilterChip(
                "${DateFormat('dd MMM').format(_dateRange!.start)} - ${DateFormat('dd MMM').format(_dateRange!.end)}",
                () => setState(() => _dateRange = null)),
          ..._selectedCategories.map((c) => _buildFilterChip(c, () {
                setState(() => _selectedCategories.remove(c));
              })),
          ..._selectedBuckets.map((b) => _buildFilterChip("Bucket: $b", () {
                setState(() => _selectedBuckets.remove(b));
              })),
          if (_sortOption != 'Newest')
            _buildFilterChip("Sort: $_sortOption",
                () => setState(() => _sortOption = 'Newest')),
        ]));
  }

  Widget _buildFilterChip(String label, VoidCallback onRemove) {
    return Container(
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.only(left: 12, right: 4, top: 6, bottom: 6),
        decoration: BoxDecoration(
            color: _accentColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: _accentColor.withOpacity(0.3))),
        child: Row(children: [
          Text(label,
              style: TextStyle(
                  color: _accentColor,
                  fontWeight: FontWeight.w600,
                  fontSize: 11)),
          const SizedBox(width: 4),
          InkWell(
              onTap: onRemove,
              borderRadius: BorderRadius.circular(10),
              child: Icon(Icons.close, size: 16, color: _accentColor))
        ]));
  }
}
