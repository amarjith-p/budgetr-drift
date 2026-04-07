import 'dart:async';
import 'dart:ui';

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

  bool _isSearching = false;
  final TextEditingController _searchCtrl = TextEditingController();
  Timer? _debounce;

  int _currentRenderLimit = 50;
  final ScrollController _scrollController = ScrollController();

  late Stream<List<ExpenseTransactionModel>> _transactionsStream;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _updateStream();
  }

  void _updateStream() {
    _transactionsStream = _service.getFilteredTransactions(
        _criteria); // Restored your native DB Filter Stream
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      setState(() {
        _currentRenderLimit += 50;
      });
    }
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    _debounce?.cancel();
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();

    _debounce = Timer(const Duration(milliseconds: 300), () {
      setState(() {
        _currentRenderLimit = 50;
        _criteria = _criteria.copyWithSearch(query);
        _updateStream();
      });
    });
  }

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
            _currentRenderLimit = 50;
            newFilters.searchQuery = _criteria.searchQuery;
            _criteria = newFilters;
            _updateStream();
          });
        },
      ),
    );
  }

  void _toggleTypeFilter(String type) {
    setState(() {
      _currentRenderLimit = 50;
      if (_criteria.transactionTypes.contains(type)) {
        _criteria.transactionTypes.remove(type);
      } else {
        _criteria.transactionTypes.add(type);
      }
      _updateStream();
    });
  }

  // --- [NEW] Strict Memory Filter ---
  List<ExpenseTransactionModel> _applyFilters(
      List<ExpenseTransactionModel> data) {
    return data.where((t) => _criteria.matches(t)).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // --- Animated Expandable Search Bar ---
        AnimatedSize(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOutQuint,
          child: _isSearching
              ? Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                  child: TextField(
                    controller: _searchCtrl,
                    onChanged: _onSearchChanged,
                    autofocus: true,
                    style: const TextStyle(color: Colors.white, fontSize: 14),
                    decoration: InputDecoration(
                      hintText: "Search notes, amounts, or categories...",
                      hintStyle:
                          TextStyle(color: Colors.white.withOpacity(0.3)),
                      prefixIcon: const Icon(Icons.search_rounded,
                          color: BudgetrColors.accent),
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.cancel_rounded,
                            color: Colors.white38),
                        onPressed: () {
                          _searchCtrl.clear();
                          _onSearchChanged("");
                          setState(() => _isSearching = false);
                          FocusScope.of(context).unfocus();
                        },
                      ),
                      filled: true,
                      fillColor: Colors.white.withOpacity(0.05),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: const BorderSide(color: Colors.white10),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: const BorderSide(color: Colors.white10),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide(
                            color: BudgetrColors.accent.withOpacity(0.5)),
                      ),
                      contentPadding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                  ),
                )
              : const SizedBox.shrink(),
        ),

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
              _buildTuneButton(),
              const SizedBox(width: 8),
              _buildSearchTriggerButton(),
              const SizedBox(width: 12),
              if (_criteria.hasFilters) ...[
                _buildClearButton(),
                const SizedBox(width: 12),
              ],
              _buildQuickFilterChip("Expense"),
              const SizedBox(width: 8),
              _buildQuickFilterChip("Income"),
              const SizedBox(width: 8),
              _buildQuickFilterChip("Transfer Out"),
              const SizedBox(width: 8),
              _buildQuickFilterChip("Transfer In"),
              const SizedBox(width: 8),
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

                  // --- [NEW INJECTION: Invisible Balance Map Builder] ---
                  return StreamBuilder<List<ExpenseTransactionModel>>(
                      stream: _service
                          .getAllTransactions(), // Used ONLY to compute proper math
                      builder: (context, allTxnSnapshot) {
                        Map<String, double> balanceMap = {};
                        if (allTxnSnapshot.hasData && accountSnapshot.hasData) {
                          double globalBal = accountSnapshot.data!.fold(
                              0.0, (sum, acc) => sum + acc.currentBalance);
                          double tempBal = globalBal;
                          for (var t in allTxnSnapshot.data!) {
                            balanceMap[t.id] = tempBal;
                            if (t.type == 'Expense' || t.type == 'Transfer Out')
                              tempBal += t.amount;
                            else if (t.type == 'Income' ||
                                t.type == 'Transfer In') tempBal -= t.amount;
                          }
                        }

                        // Return your perfectly untouched original filtered stream
                        return StreamBuilder<List<ExpenseTransactionModel>>(
                          stream: _transactionsStream,
                          builder: (context, txnSnapshot) {
                            if (txnSnapshot.connectionState ==
                                ConnectionState.waiting) {
                              return const Center(
                                  child: FuturisticLoader(
                                      size: 80,
                                      label: "COMPILING GLOBAL LEDGER..."));
                            }

                            // Fetch Raw Data
                            var allTransactions = txnSnapshot.data ?? [];

                            // Apply Strict Memory Filter to prevent "Past Commitments"
                            allTransactions = _applyFilters(allTransactions);

                            if (!_criteria.hasFilters) {
                              _allCachedTransactions = allTransactions;
                            } else if (_allCachedTransactions.isEmpty) {
                              _allCachedTransactions = allTransactions;
                            }

                            if (allTransactions.isEmpty) {
                              return _buildEmptyState();
                            }

                            final displayedTransactions = allTransactions
                                .take(_currentRenderLimit)
                                .toList();

                            final grouped = groupBy(displayedTransactions,
                                (ExpenseTransactionModel t) {
                              return DateFormat('MMMM yyyy').format(t.date);
                            });

                            return Column(
                              children: [
                                // Dynamic Summary Strip
                                _buildFilteredSummaryStrip(allTransactions),

                                // CustomScrollView for Transactions
                                Expanded(
                                  child: CustomScrollView(
                                    controller: _scrollController,
                                    physics: const BouncingScrollPhysics(),
                                    slivers: [
                                      ...grouped.entries.map((entry) {
                                        final month = entry.key;
                                        final txns = entry.value;

                                        return SliverMainAxisGroup(
                                          slivers: [
                                            // The Sticky Header
                                            SliverPersistentHeader(
                                              pinned: true,
                                              delegate:
                                                  _MonthHeaderDelegate(month),
                                            ),
                                            // The List of Transactions for this month
                                            SliverPadding(
                                              padding: const EdgeInsets.only(
                                                  left: 20,
                                                  right: 20,
                                                  bottom: 12),
                                              sliver: SliverList(
                                                delegate:
                                                    SliverChildBuilderDelegate(
                                                  (context, index) {
                                                    final rawTxn = txns[index];
                                                    // --- [NEW INJECTION: Pass the calculated balance] ---
                                                    final txn = rawTxn.copyWith(
                                                        runningBalance:
                                                            balanceMap[
                                                                rawTxn.id]);

                                                    final account = accountMap[
                                                        txn.accountId];
                                                    final accountName = account !=
                                                            null
                                                        ? "${account.name} - ${account.bankName}"
                                                        : "Unknown Account";

                                                    return TransactionItem(
                                                      txn: txn,
                                                      iconData: categoryIconMap[
                                                              txn.category] ??
                                                          Icons
                                                              .category_outlined,
                                                      sourceAccountName:
                                                          accountName,
                                                      onEdit: () {
                                                        showModalBottomSheet(
                                                          context: context,
                                                          isScrollControlled:
                                                              true,
                                                          backgroundColor:
                                                              Colors
                                                                  .transparent,
                                                          builder: (ctx) =>
                                                              NewExpenseScreen(
                                                            txnToEdit: txn,
                                                          ),
                                                        );
                                                      },
                                                      onDuplicate: () {
                                                        showModalBottomSheet(
                                                          context: context,
                                                          isScrollControlled:
                                                              true,
                                                          backgroundColor:
                                                              Colors
                                                                  .transparent,
                                                          builder: (_) =>
                                                              NewExpenseScreen(
                                                            txnToEdit: txn,
                                                            isDuplicate: true,
                                                          ),
                                                        );
                                                      },
                                                      onDelete: () async {
                                                        await _handleDelete(
                                                            context, txn);
                                                      },
                                                    );
                                                  },
                                                  childCount: txns.length,
                                                ),
                                              ),
                                            ),
                                          ],
                                        );
                                      }).toList(),

                                      // Bottom Padding
                                      const SliverToBoxAdapter(
                                        child: SizedBox(height: 100),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            );
                          },
                        );
                      });
                },
              );
            },
          ),
        ),
      ],
    );
  }

  // --- WIDGETS ---

  Widget _buildFilteredSummaryStrip(
      List<ExpenseTransactionModel> transactions) {
    if (!_criteria.hasFilters) return const SizedBox.shrink();

    double totalIncome = 0;
    double totalExpense = 0;

    for (var txn in transactions) {
      if (txn.type == 'Income') {
        totalIncome += txn.amount;
      } else if (txn.type == 'Expense') {
        totalExpense += txn.amount;
      }
    }

    double netFlow = totalIncome - totalExpense;
    Color netColor = netFlow >= 0 ? BudgetrColors.success : BudgetrColors.error;
    final formatCurrency = NumberFormat.currency(symbol: '₹', decimalDigits: 2);

    return AnimatedSize(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOutQuint,
      child: Container(
        margin: const EdgeInsets.fromLTRB(16, 8, 16, 8),
        decoration: BoxDecoration(
          color: const Color(0xFF1B263B).withOpacity(0.5),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.white.withOpacity(0.05)),
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "NET FLOW",
                    style: TextStyle(
                        color: Colors.white54,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.0),
                  ),
                  const SizedBox(width: 12),
                  Flexible(
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerRight,
                      child: Text(
                        (netFlow < 0 ? "-" : "") +
                            formatCurrency.format(netFlow.abs()),
                        style: TextStyle(
                            color: netColor,
                            fontSize: 18,
                            fontWeight: FontWeight.w800),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 1, color: Colors.white10),
            IntrinsicHeight(
              child: Row(
                children: [
                  Expanded(
                    child: _buildSummaryColumn(
                        "INCOME", totalIncome, BudgetrColors.success),
                  ),
                  Container(width: 1, color: Colors.white10),
                  Expanded(
                    child: _buildSummaryColumn(
                        "EXPENSE", totalExpense, BudgetrColors.error),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryColumn(String label, double amount, Color color) {
    final formattedAmount = NumberFormat.currency(symbol: '₹', decimalDigits: 2)
        .format(amount.abs());

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
                color: Colors.white38,
                fontSize: 10,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5),
          ),
          const SizedBox(height: 4),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              formattedAmount,
              style: TextStyle(
                  color: color, fontSize: 15, fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchTriggerButton() {
    return GestureDetector(
      onTap: () {
        setState(() {
          _isSearching = !_isSearching;
          if (!_isSearching) {
            _searchCtrl.clear();
            _onSearchChanged("");
            FocusScope.of(context).unfocus();
          }
        });
      },
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
            color: _isSearching
                ? BudgetrColors.accent
                : Colors.white.withOpacity(0.08),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white10)),
        child: Icon(Icons.search_rounded,
            size: 18, color: _isSearching ? Colors.white : Colors.white70),
      ),
    );
  }

  Widget _buildTuneButton() {
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

  Widget _buildClearButton() {
    return GestureDetector(
      onTap: () {
        setState(() {
          _criteria = FilterCriteria();
          _currentRenderLimit = 50;
          _searchCtrl.clear();
          _isSearching = false;
          _updateStream();
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
            onPressed: () => setState(() {
              _criteria = FilterCriteria();
              _currentRenderLimit = 50;
              _searchCtrl.clear();
              _isSearching = false;
              _updateStream();
            }),
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

  Widget _buildFilterChip(String label, VoidCallback onRemove) {
    return Container(
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.only(left: 12, right: 4, top: 6, bottom: 6),
        decoration: BoxDecoration(
            color: BudgetrColors.accent.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: BudgetrColors.accent.withOpacity(0.3))),
        child: Row(children: [
          Text(label,
              style: const TextStyle(
                  color: BudgetrColors.accent,
                  fontWeight: FontWeight.w600,
                  fontSize: 11)),
          const SizedBox(width: 4),
          InkWell(
              onTap: onRemove,
              borderRadius: BorderRadius.circular(10),
              child: const Icon(Icons.close,
                  size: 16, color: BudgetrColors.accent))
        ]));
  }

  String _getSortLabel(SortOption option) {
    switch (option) {
      case SortOption.newest:
        return "Newest";
      case SortOption.oldest:
        return "Oldest";
      case SortOption.highestAmount:
        return "Highest";
      case SortOption.lowestAmount:
        return "Lowest";
    }
  }
}

class _MonthHeaderDelegate extends SliverPersistentHeaderDelegate {
  final String month;

  _MonthHeaderDelegate(this.month);

  @override
  double get minExtent => 45.0;
  @override
  double get maxExtent => 45.0;

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          color: BudgetrColors.background.withOpacity(0.85),
          padding: const EdgeInsets.symmetric(horizontal: 20),
          alignment: Alignment.centerLeft,
          child: Text(
            month.toUpperCase(),
            style: const TextStyle(
              color: Colors.white54,
              fontSize: 12,
              fontWeight: FontWeight.w800,
              letterSpacing: 2.0,
            ),
          ),
        ),
      ),
    );
  }

  @override
  bool shouldRebuild(covariant _MonthHeaderDelegate oldDelegate) {
    return oldDelegate.month != month;
  }
}
