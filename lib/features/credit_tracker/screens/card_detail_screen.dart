import 'dart:ui';
import 'package:budget/core/widgets/status_bottom_sheet.dart';
import 'package:budget/features/credit_tracker/widgets/modern_credit_txn_sheet.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:intl/intl.dart';
import 'package:collection/collection.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/widgets/modern_loader.dart';
import '../../../core/models/transaction_category_model.dart';
import '../../../core/services/category_service.dart';
import '../../../core/constants/icon_constants.dart';
import '../models/credit_models.dart';
import '../services/credit_service.dart';
import '../widgets/add_credit_txn_sheet.dart';
import '../utils/billing_cycle_utils.dart';
import '../widgets/credit_summary_card.dart';
import '../widgets/transaction_list_item.dart';
// IMPORT NEW FILTER SHEET
import '../widgets/credit_filter_sheet.dart';

class CreditCardDetailScreen extends StatefulWidget {
  final CreditCardModel card;
  const CreditCardDetailScreen({super.key, required this.card});

  @override
  State<CreditCardDetailScreen> createState() => _CreditCardDetailScreenState();
}

class _CreditCardDetailScreenState extends State<CreditCardDetailScreen> {
  // --- Filter States ---
  String _selectedType = 'All';
  String _sortOption = 'Newest';
  DateTimeRange? _dateRange;
  final Set<String> _selectedCategories = {};
  final Set<String> _selectedBuckets = {};

  final Set<String> _ignoredTransactionIds = {};
  static const String _ignoredPrefsKey = 'ignored_transfers_list';

  final Color _bgColor = const Color(0xff0D1B2A);
  final Color _accentColor = const Color(0xFF3A86FF);

  bool _isLoading = false;

  late Stream<List<TransactionCategoryModel>> _categoryStream;
  late Stream<List<CreditTransactionModel>> _transactionStream;

  @override
  void initState() {
    super.initState();
    _categoryStream = GetIt.I<CategoryService>().getCategories();
    _transactionStream =
        GetIt.I<CreditService>().getTransactionsForCard(widget.card.id);
    _loadIgnoredTransactions();
  }

  Future<void> _loadIgnoredTransactions() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String>? storedList = prefs.getStringList(_ignoredPrefsKey);
    if (storedList != null && mounted) {
      setState(() {
        _ignoredTransactionIds.addAll(storedList);
      });
    }
  }

  Future<void> _handleIgnoreTransaction(String txnId) async {
    setState(() {
      _ignoredTransactionIds.add(txnId);
    });
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(
        _ignoredPrefsKey, _ignoredTransactionIds.toList());
  }

  @override
  Widget build(BuildContext context) {
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
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            titleSpacing: 0,
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.card.name,
                  style: const TextStyle(color: Colors.white, fontSize: 16),
                ),
                Text(
                  widget.card.bankName,
                  style: const TextStyle(color: Colors.white54, fontSize: 12),
                ),
              ],
            ),
            iconTheme: const IconThemeData(color: Colors.white),
            actions: [
              StreamBuilder<List<CreditTransactionModel>>(
                stream: _transactionStream,
                builder: (context, snapshot) {
                  final hasData = snapshot.hasData && snapshot.data!.isNotEmpty;
                  return Stack(
                    alignment: Alignment.topRight,
                    children: [
                      IconButton(
                        onPressed: hasData
                            ? () => _openFilterSheet(context, snapshot.data!)
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
                            shape: BoxShape.circle,
                          ),
                        ),
                    ],
                  );
                },
              ),
              const SizedBox(width: 8),
            ],
          ),
          body: StreamBuilder<List<CreditTransactionModel>>(
            stream: _transactionStream,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: ModernLoader());
              }
              if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return _buildEmptyState("No transactions found.");
              }

              final allTxns = _applyFilters(snapshot.data!);

              // 1. Determine Key Dates
              final now = DateTime.now();
              final lastStatementDate =
                  BillingCycleUtils.getLastBillDate(now, widget.card.billDate);

              // 2. Buckets
              final currentCycleSpends = <CreditTransactionModel>[];
              final lastStatementPayments = <CreditTransactionModel>[];
              final pastStatementTxns = <CreditTransactionModel>[];

              for (var txn in allTxns) {
                if (BillingCycleUtils.isUnbilled(txn, widget.card.billDate)) {
                  if (BillingCycleUtils.isPaymentForStatement(
                      txn, lastStatementDate, widget.card.dueDate)) {
                    lastStatementPayments.add(txn);
                  } else {
                    currentCycleSpends.add(txn);
                  }
                } else {
                  pastStatementTxns.add(txn);
                }
              }

              double currentUnbilledTotal = _calculateTotal(currentCycleSpends);

              // 3. Group History
              final groupedHistory = groupBy(pastStatementTxns, (txn) {
                final naturalStmtDate =
                    BillingCycleUtils.getStatementDateForTxn(
                        txn.date.toDate(), widget.card.billDate,
                        forceNextCycle: txn.includeInNextStatement);

                if (txn.type == 'Income' &&
                    BillingCycleUtils.isRepaymentCategory(txn.category)) {
                  final prevStmtDate =
                      BillingCycleUtils.getPreviousStatementDate(
                          naturalStmtDate, widget.card.billDate);
                  if (BillingCycleUtils.isPaymentForStatement(
                      txn, prevStmtDate, widget.card.dueDate)) {
                    return prevStmtDate;
                  }
                }

                return naturalStmtDate;
              });

              if (!groupedHistory.containsKey(lastStatementDate)) {
                groupedHistory[lastStatementDate] = [];
              }

              final sortedDates = groupedHistory.keys.toList()
                ..sort((a, b) => b.compareTo(a));

              return Column(
                children: [
                  // --- NEW: Active Filters List ---
                  if (_hasActiveFilters) _buildActiveFiltersList(),

                  CreditSummaryCard(
                    currentUnbilled: currentUnbilledTotal,
                    lastBillDate: lastStatementDate,
                    lastBillTxns: groupedHistory[lastStatementDate] ?? [],
                    payments: lastStatementPayments,
                    card: widget.card,
                  ),
                  Expanded(
                    child: ListView(
                      padding: const EdgeInsets.all(16),
                      children: [
                        if (currentCycleSpends.isNotEmpty) ...[
                          _buildSectionHeader("CURRENT CYCLE (UNBILLED)"),
                          ...currentCycleSpends.map((t) => TransactionListItem(
                                txn: t,
                                iconData: categoryIconMap[t.category] ??
                                    Icons.category_outlined,
                                isIgnored:
                                    _ignoredTransactionIds.contains(t.id),
                                onEdit: () => _handleEdit(context, t),
                                onDelete: () =>
                                    _handleDeleteTransaction(context, t),
                                onMarkAsRepayment: () =>
                                    _handleMarkAsRepayment(t),
                                onIgnore: () => _handleIgnoreTransaction(t.id),
                                onDeferToNextBill: t.includeInNextStatement
                                    ? () => _handleDeferTransaction(t, false)
                                    : null,
                              )),
                          const SizedBox(height: 24),
                        ],
                        if (sortedDates.isNotEmpty)
                          _buildSectionHeader("STATEMENTS"),
                        ...sortedDates.map((date) {
                          final rawTxns = groupedHistory[date]!;
                          final statementExpenses = <CreditTransactionModel>[];
                          final statementPayments = <CreditTransactionModel>[];

                          for (var t in rawTxns) {
                            if (t.type == 'Income' &&
                                BillingCycleUtils.isRepaymentCategory(
                                    t.category)) {
                              statementPayments.add(t);
                            } else {
                              statementExpenses.add(t);
                            }
                          }

                          final isLastStatement = BillingCycleUtils.isSameDay(
                              date, lastStatementDate);
                          if (isLastStatement) {
                            statementPayments.addAll(lastStatementPayments);
                          }

                          final billTotal = _calculateTotal(statementExpenses);

                          if (statementExpenses.isEmpty &&
                              statementPayments.isEmpty) {
                            return const SizedBox.shrink();
                          }

                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildStatementHeader(date, billTotal,
                                  isLastStatement, statementPayments),
                              ...statementExpenses.map((t) {
                                final bool isDanger =
                                    BillingCycleUtils.isDangerZone(
                                        t.date.toDate(), widget.card.billDate);

                                final bool showWarning = isDanger &&
                                    !t.includeInNextStatement &&
                                    !t.isSettlementVerified;

                                return TransactionListItem(
                                  txn: t,
                                  iconData: categoryIconMap[t.category] ??
                                      Icons.category_outlined,
                                  isIgnored:
                                      _ignoredTransactionIds.contains(t.id),
                                  onEdit: () => _handleEdit(context, t),
                                  onDelete: () =>
                                      _handleDeleteTransaction(context, t),
                                  onMarkAsRepayment: () =>
                                      _handleMarkAsRepayment(t),
                                  onIgnore: () =>
                                      _handleIgnoreTransaction(t.id),
                                  onDeferToNextBill: t.isSettlementVerified
                                      ? null
                                      : () => _handleDeferTransaction(
                                          t, !t.includeInNextStatement),
                                  onVerifySettlement: () =>
                                      _handleVerifySettlement(t),
                                  showDangerWarning: showWarning,
                                );
                              }),
                              if (statementPayments.isNotEmpty) ...[
                                Padding(
                                  padding: const EdgeInsets.only(
                                      left: 16, top: 8, bottom: 8),
                                  child: Row(
                                    children: [
                                      Icon(Icons.subdirectory_arrow_right,
                                          color: Colors.greenAccent, size: 16),
                                      const SizedBox(width: 8),
                                      const Text("Payments Received",
                                          style: TextStyle(
                                              color: Colors.greenAccent,
                                              fontSize: 12)),
                                    ],
                                  ),
                                ),
                                ...statementPayments.map((t) =>
                                    TransactionListItem(
                                      txn: t,
                                      iconData: Icons.payment,
                                      isIgnored:
                                          _ignoredTransactionIds.contains(t.id),
                                      onEdit: () => _handleEdit(context, t),
                                      onDelete: () =>
                                          _handleDeleteTransaction(context, t),
                                      onMarkAsRepayment: () =>
                                          _handleMarkAsRepayment(t),
                                      onIgnore: () =>
                                          _handleIgnoreTransaction(t.id),
                                    )),
                              ],
                              const SizedBox(height: 24),
                            ],
                          );
                        }),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        );
      },
    );
  }

  // --- Filter Helpers ---

  // REPLACED OLD METHOD with Widget Call
  void _openFilterSheet(
      BuildContext context, List<CreditTransactionModel> allTxns) {
    final uniqueCategories = allTxns
        .map((e) => e.category)
        .where((e) => e.isNotEmpty)
        .toSet()
        .toList()
      ..sort();
    final uniqueBuckets = allTxns
        .map((e) => e.bucket)
        .where((e) => e.isNotEmpty)
        .toSet()
        .toList()
      ..sort();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
        child: CreditFilterSheet(
          initialType: _selectedType,
          initialSort: _sortOption,
          initialDateRange: _dateRange,
          initialCategories: _selectedCategories,
          initialBuckets: _selectedBuckets,
          availableCategories: uniqueCategories,
          availableBuckets: uniqueBuckets,
          onApply: (type, sort, dateRange, categories, buckets) {
            setState(() {
              _selectedType = type;
              _sortOption = sort;
              _dateRange = dateRange;
              _selectedCategories.clear();
              _selectedCategories.addAll(categories);
              _selectedBuckets.clear();
              _selectedBuckets.addAll(buckets);
            });
          },
        ),
      ),
    );
  }

  // --- NEW: Active Filters List (Same as AccountDetail) ---
  Widget _buildActiveFiltersList() {
    return Container(
      height: 50,
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
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
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.redAccent.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.redAccent.withOpacity(0.3)),
              ),
              child: const Center(
                child: Text(
                  "Clear All",
                  style: TextStyle(
                    color: Colors.redAccent,
                    fontWeight: FontWeight.bold,
                    fontSize: 11,
                  ),
                ),
              ),
            ),
          ),
          if (_selectedType != 'All')
            _buildFilterChip(
              _selectedType,
              () => setState(() => _selectedType = 'All'),
            ),
          if (_dateRange != null)
            _buildFilterChip(
              "${DateFormat('dd MMM').format(_dateRange!.start)} - ${DateFormat('dd MMM').format(_dateRange!.end)}",
              () => setState(() => _dateRange = null),
            ),
          ..._selectedCategories.map((c) => _buildFilterChip(c, () {
                setState(() => _selectedCategories.remove(c));
              })),
          ..._selectedBuckets.map((b) => _buildFilterChip("Bucket: $b", () {
                setState(() => _selectedBuckets.remove(b));
              })),
          if (_sortOption != 'Newest')
            _buildFilterChip(
              "Sort: $_sortOption",
              () => setState(() => _sortOption = 'Newest'),
            ),
        ],
      ),
    );
  }

  // Helper for Active Filters
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
      ]),
    );
  }

  // ... (Existing Methods: verify, defer, markAsRepayment, etc. remain unchanged) ...

  Future<void> _handleVerifySettlement(CreditTransactionModel txn) async {
    try {
      final updatedTxn = CreditTransactionModel(
        id: txn.id,
        cardId: txn.cardId,
        amount: txn.amount,
        date: txn.date,
        type: txn.type,
        category: txn.category,
        subCategory: txn.subCategory,
        notes: txn.notes,
        bucket: txn.bucket,
        linkedExpenseId: txn.linkedExpenseId,
        includeInNextStatement: txn.includeInNextStatement,
        isSettlementVerified: true,
      );
      await GetIt.I<CreditService>().updateTransaction(updatedTxn);
    } catch (e) {
      if (mounted)
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text("Error: $e")));
    }
  }

  Future<void> _handleDeferTransaction(
      CreditTransactionModel txn, bool shouldDefer) async {
    setState(() => _isLoading = true);
    try {
      final updatedTxn = CreditTransactionModel(
        id: txn.id,
        cardId: txn.cardId,
        amount: txn.amount,
        date: txn.date,
        type: txn.type,
        category: txn.category,
        subCategory: txn.subCategory,
        notes: txn.notes,
        bucket: txn.bucket,
        linkedExpenseId: txn.linkedExpenseId,
        includeInNextStatement: shouldDefer,
        isSettlementVerified: false,
      );

      await GetIt.I<CreditService>().updateTransaction(updatedTxn);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(shouldDefer
              ? "Moved to Next Cycle"
              : "Restored to Original Date"),
          backgroundColor: const Color(0xFF4CC9F0),
          duration: const Duration(seconds: 1),
        ));
      }
    } catch (e) {
      if (mounted)
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text("Error: $e")));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _handleMarkAsRepayment(CreditTransactionModel txn) async {
    setState(() => _isLoading = true);
    try {
      final updatedTxn = CreditTransactionModel(
        id: txn.id,
        cardId: txn.cardId,
        amount: txn.amount,
        date: txn.date,
        type: txn.type,
        category: 'Repayment',
        subCategory: txn.subCategory,
        notes: txn.notes,
        bucket: txn.bucket,
        linkedExpenseId: txn.linkedExpenseId,
        includeInNextStatement: txn.includeInNextStatement,
        isSettlementVerified: txn.isSettlementVerified,
      );

      await GetIt.I<CreditService>().updateTransaction(updatedTxn);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text("Marked as Bill Repayment"),
            backgroundColor: Colors.green));
      }
    } catch (e) {
      if (mounted)
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text("Error: $e")));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Widget _buildStatementHeader(DateTime date, double total, bool isLastStmt,
      List<CreditTransactionModel> payments) {
    final currency =
        NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: 2);
    final totalPaid = payments.fold(0.0, (sum, t) => sum + t.amount);
    double netPosition = total - totalPaid;
    double surplus = netPosition < 0 ? netPosition.abs() : 0;
    bool isOverPaid = surplus > 0;
    bool isPaid = isLastStmt && total > 0 && (total - totalPaid) < 0;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12, top: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Text(
                "Statement: ${DateFormat('dd MMM').format(date)}",
                style: const TextStyle(
                    color: Colors.white54,
                    fontSize: 13,
                    fontWeight: FontWeight.w600),
              ),
              if (isPaid || isOverPaid) ...[
                const SizedBox(width: 8),
                const Icon(Icons.check_circle,
                    color: Colors.greenAccent, size: 14),
              ]
            ],
          ),
          Row(
            children: [
              if (isOverPaid && isLastStmt)
                Text(
                  "Surplus: ${currency.format(surplus)}  ",
                  style: const TextStyle(
                      color: Colors.greenAccent,
                      fontSize: 11,
                      fontWeight: FontWeight.bold),
                ),
              Text(
                "Bill: ${currency.format(total)}",
                style: const TextStyle(color: Colors.white38, fontSize: 12),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Container(
              width: 4,
              height: 16,
              decoration: BoxDecoration(
                  color: _accentColor, borderRadius: BorderRadius.circular(2))),
          const SizedBox(width: 8),
          Text(title,
              style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2)),
        ],
      ),
    );
  }

  double _calculateTotal(List<CreditTransactionModel> txns) {
    double total = 0;
    for (var t in txns) {
      if (t.type == 'Expense')
        total += t.amount;
      else
        total -= t.amount;
    }
    return total;
  }

  void _handleEdit(BuildContext context, CreditTransactionModel txn) {
    showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (c) => ModernCreditTxnSheet(transactionToEdit: txn));
  }

  void _handleDeleteTransaction(
      BuildContext context, CreditTransactionModel txn) {
    showStatusSheet(
      context: context,
      title: "Delete Transaction?",
      message:
          "Are you sure you want to remove this transaction? This action cannot be undone.",
      icon: Icons.delete_sweep_sharp,
      color: Colors.redAccent,

      // 1. The "Cancel" Button
      cancelButtonText: "Cancel",
      onCancel: () {
        // The sheet closes automatically, so we don't need extra code here
        // unless you want to log the cancellation.
      },

      // 2. The "Delete" Action
      buttonText: "Delete",
      onDismiss: () async {
        // The sheet has already closed here (Navigator.pop is built-in),
        // so we immediately start the loading state on the screen behind it.
        setState(() => _isLoading = true);

        await GetIt.I<CreditService>().deleteTransaction(txn);

        if (mounted) setState(() => _isLoading = false);
      },
    );

    //   showDialog(
    //       context: context,
    //       builder: (ctx) => AlertDialog(
    //               backgroundColor: const Color(0xff0D1B2A),
    //               title: const Text("Delete?",
    //                   style: TextStyle(color: Colors.white)),
    //               actions: [
    //                 TextButton(
    //                     onPressed: () => Navigator.pop(ctx),
    //                     child: const Text("Cancel",
    //                         style: TextStyle(color: Colors.white54))),
    //                 TextButton(
    //                     onPressed: () async {
    //                       Navigator.pop(ctx);
    //                       setState(() => _isLoading = true);
    //                       await CreditService().deleteTransaction(txn);
    //                       if (mounted) setState(() => _isLoading = false);
    //                     },
    //                     child: const Text("Delete",
    //                         style: TextStyle(
    //                             color: Colors.redAccent,
    //                             fontWeight: FontWeight.bold)))
    //               ]));
  }

  List<CreditTransactionModel> _applyFilters(
      List<CreditTransactionModel> data) {
    var list = List<CreditTransactionModel>.from(data);
    if (_selectedType != 'All')
      list = list.where((t) => t.type == _selectedType).toList();
    if (_dateRange != null) {
      list = list.where((t) {
        final date = t.date.toDate();
        final end = _dateRange!.end
            .add(const Duration(days: 1))
            .subtract(const Duration(seconds: 1));
        return date.isAfter(_dateRange!.start) && date.isBefore(end);
      }).toList();
    }
    if (_selectedCategories.isNotEmpty)
      list =
          list.where((t) => _selectedCategories.contains(t.category)).toList();
    if (_selectedBuckets.isNotEmpty)
      list = list.where((t) => _selectedBuckets.contains(t.bucket)).toList();

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
}
