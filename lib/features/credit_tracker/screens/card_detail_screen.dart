import 'dart:ui';
import 'package:flutter/material.dart';
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

class CreditCardDetailScreen extends StatefulWidget {
  final CreditCardModel card;
  const CreditCardDetailScreen({super.key, required this.card});

  @override
  State<CreditCardDetailScreen> createState() => _CreditCardDetailScreenState();
}

class _CreditCardDetailScreenState extends State<CreditCardDetailScreen> {
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
    _categoryStream = CategoryService().getCategories();
    _transactionStream = CreditService().getTransactionsForCard(widget.card.id);
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
                  // Check if it's a payment for the Last Statement (Grace Period)
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

              // 3. Group History with "Shift Back" logic for Payments
              final groupedHistory = groupBy(pastStatementTxns, (txn) {
                final naturalStmtDate =
                    BillingCycleUtils.getStatementDateForTxn(
                        txn.date.toDate(), widget.card.billDate);

                // If it's a Repayment, check if it belongs to PREVIOUS statement (Late payment or Grace Period history)
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
                  _buildSmartSummary(
                    currentUnbilledTotal,
                    lastStatementDate,
                    groupedHistory[lastStatementDate] ?? [],
                    lastStatementPayments,
                  ),
                  Expanded(
                    child: ListView(
                      padding: const EdgeInsets.all(16),
                      children: [
                        if (currentCycleSpends.isNotEmpty) ...[
                          _buildSectionHeader("CURRENT CYCLE (UNBILLED)"),
                          ...currentCycleSpends.map((t) => TransactionItem(
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
                              )),
                          const SizedBox(height: 24),
                        ],
                        if (sortedDates.isNotEmpty)
                          _buildSectionHeader("STATEMENTS"),
                        ...sortedDates.map((date) {
                          final rawTxns = groupedHistory[date]!;

                          // Split Expenses (Bill) vs Repayments (Settlement)
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

                          // If this is the last statement, append the "Unbilled" grace period payments
                          final isLastStatement = BillingCycleUtils.isSameDay(
                              date, lastStatementDate);
                          if (isLastStatement) {
                            statementPayments.addAll(lastStatementPayments);
                          }

                          // Calculate Bill Total (Expenses - Refunds)
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
                              ...statementExpenses.map((t) => TransactionItem(
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
                                  )),
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
                                ...statementPayments.map((t) => TransactionItem(
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
      );

      await CreditService().updateTransaction(updatedTxn);
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

  Widget _buildSmartSummary(
    double currentUnbilled,
    DateTime lastBillDate,
    List<CreditTransactionModel> lastBillTxns,
    List<CreditTransactionModel> payments,
  ) {
    final currency =
        NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: 2);

    // Calculate Due Date
    final actualDueDate = BillingCycleUtils.getDueDateForStatement(
        lastBillDate, widget.card.dueDate);
    final daysRemaining = actualDueDate.difference(DateTime.now()).inDays;

    final billExpenses = lastBillTxns
        .where((t) =>
            t.type == 'Expense' ||
            (t.type == 'Income' &&
                !BillingCycleUtils.isRepaymentCategory(t.category)))
        .toList();

    final billPayments = lastBillTxns
        .where((t) =>
            t.type == 'Income' &&
            BillingCycleUtils.isRepaymentCategory(t.category))
        .toList()
      ..addAll(payments);

    double billAmount = _calculateTotal(billExpenses);
    double totalPaid = billPayments.fold(0.0, (sum, t) => sum + t.amount);

    double netBillPosition = billAmount - totalPaid;
    double remainingDue = 0;
    double surplus = 0;

    if (netBillPosition > 0) {
      remainingDue = netBillPosition;
    } else {
      surplus = netBillPosition.abs();
    }

    double adjustedUnbilled = currentUnbilled - surplus;
    bool isNetLiability = adjustedUnbilled > 0;

    bool isPaidOff = billAmount > 0 && remainingDue <= 0;
    bool isOverPaid = surplus > 0;

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [const Color(0xFF1B263B), const Color(0xff0D1B2A)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
        boxShadow: [
          BoxShadow(color: Colors.black26, blurRadius: 10, offset: Offset(0, 5))
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "NEW SPENDS",
                  style: TextStyle(
                      color: Colors.white54,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1),
                ),
                const SizedBox(height: 4),
                Text(
                  isNetLiability
                      ? "- ${currency.format(adjustedUnbilled)}"
                      : "+ ${currency.format(adjustedUnbilled.abs())}",
                  style: TextStyle(
                      color: isNetLiability
                          ? Colors.redAccent
                          : Colors.greenAccent,
                      fontSize: 24,
                      fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(
                  isOverPaid ? "Adjusted with Surplus" : "Current Cycle",
                  style: TextStyle(color: Colors.white38, fontSize: 11),
                ),
              ],
            ),
          ),
          Container(width: 1, height: 50, color: Colors.white10),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "LAST BILL",
                      style: TextStyle(
                          color: Colors.white54,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1),
                    ),
                    if (isPaidOff && !isOverPaid)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                            color: Colors.green.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(4)),
                        child: Text("PAID",
                            style: TextStyle(
                                color: Colors.greenAccent,
                                fontSize: 10,
                                fontWeight: FontWeight.bold)),
                      ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  isOverPaid
                      ? "+ ${currency.format(surplus)}"
                      : currency.format(remainingDue),
                  style: TextStyle(
                      color: isOverPaid
                          ? Colors.greenAccent
                          : (isPaidOff ? Colors.white60 : Colors.redAccent),
                      fontSize: 24,
                      fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                // UPDATED SUBTITLE LOGIC:
                Text(
                  isOverPaid
                      ? "Surplus (Paid: ${currency.format(totalPaid)})"
                      : (isPaidOff
                          ? "Settled fully"
                          : "Bill: ${currency.format(billAmount)}  •  Paid: ${currency.format(totalPaid)}"),
                  style: TextStyle(color: Colors.white38, fontSize: 11),
                ),

                // DUE DATE LOGIC:
                if (!isOverPaid && !isPaidOff)
                  Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Text(
                      "Due: ${DateFormat('dd MMM').format(actualDueDate)}",
                      style: TextStyle(
                        color: daysRemaining < 3
                            ? Colors.redAccent
                            : Colors.orangeAccent,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ... (Rest of helpers remain unchanged)
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
        builder: (c) => AddCreditTransactionSheet(transactionToEdit: txn));
  }

  void _handleDeleteTransaction(
      BuildContext context, CreditTransactionModel txn) {
    showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
                backgroundColor: const Color(0xff0D1B2A),
                title: const Text("Delete?",
                    style: TextStyle(color: Colors.white)),
                actions: [
                  TextButton(
                      onPressed: () => Navigator.pop(ctx),
                      child: const Text("Cancel",
                          style: TextStyle(color: Colors.white54))),
                  TextButton(
                      onPressed: () async {
                        Navigator.pop(ctx);
                        setState(() => _isLoading = true);
                        await CreditService().deleteTransaction(txn);
                        if (mounted) setState(() => _isLoading = false);
                      },
                      child: const Text("Delete",
                          style: TextStyle(
                              color: Colors.redAccent,
                              fontWeight: FontWeight.bold)))
                ]));
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
                  border: Border.all(color: Colors.redAccent.withOpacity(0.3))),
              child: const Center(
                  child: Text("Clear All",
                      style: TextStyle(
                          color: Colors.redAccent,
                          fontWeight: FontWeight.bold,
                          fontSize: 11))),
            ),
          ),
          if (_selectedType != 'All')
            _buildFilterChip(
                _selectedType, () => setState(() => _selectedType = 'All')),
          if (_dateRange != null)
            _buildFilterChip(
                "Date Range", () => setState(() => _dateRange = null)),
          ..._selectedCategories.map((c) => _buildFilterChip(
              c, () => setState(() => _selectedCategories.remove(c)))),
          ..._selectedBuckets.map((b) => _buildFilterChip(
              "Bucket: $b", () => setState(() => _selectedBuckets.remove(b)))),
          if (_sortOption != 'Newest')
            _buildFilterChip("Sort: $_sortOption",
                () => setState(() => _sortOption = 'Newest')),
        ],
      ),
    );
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
      ]),
    );
  }

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
        child: Container(
          padding:
              EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
          decoration: BoxDecoration(
              color: _bgColor,
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(24)),
              border: Border.all(color: Colors.white.withOpacity(0.1))),
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: StatefulBuilder(
                builder: (ctx, setModalState) {
                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("Filter & Sort",
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold)),
                      const SizedBox(height: 24),
                      _buildSectionTitle("Sort By"),
                      const SizedBox(height: 12),
                      SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(children: [
                            _sortChip("Newest", setModalState),
                            _sortChip("Oldest", setModalState),
                            _sortChip("Amount High", setModalState),
                            _sortChip("Amount Low", setModalState)
                          ])),
                      const SizedBox(height: 24),
                      _buildSectionTitle("Type"),
                      const SizedBox(height: 12),
                      Row(children: [
                        Expanded(child: _typeButton("All", setModalState)),
                        const SizedBox(width: 8),
                        Expanded(child: _typeButton("Expense", setModalState)),
                        const SizedBox(width: 8),
                        Expanded(child: _typeButton("Income", setModalState))
                      ]),
                      const SizedBox(height: 24),
                      SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                              onPressed: () => Navigator.pop(ctx),
                              style: ElevatedButton.styleFrom(
                                  backgroundColor: _accentColor,
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 16)),
                              child: const Text("Apply Filters",
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                      color: Colors.white)))),
                    ],
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(String msg) => Center(
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Icon(Icons.search_off, size: 48, color: Colors.white.withOpacity(0.2)),
        const SizedBox(height: 16),
        Text(msg, style: TextStyle(color: Colors.white.withOpacity(0.5)))
      ]));

  Widget _buildSectionTitle(String t) => Text(t.toUpperCase(),
      style: TextStyle(
          color: Colors.white54, fontSize: 12, fontWeight: FontWeight.bold));
  Widget _sortChip(String l, StateSetter s) => GestureDetector(
      onTap: () {
        s(() => _sortOption = l);
        setState(() => _sortOption = l);
      },
      child: Container(
          margin: const EdgeInsets.only(right: 8),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
              color: _sortOption == l ? _accentColor : Colors.transparent,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                  color: _sortOption == l ? _accentColor : Colors.white12)),
          child: Text(l,
              style: TextStyle(
                  color: _sortOption == l ? Colors.white : Colors.white70))));
  Widget _typeButton(String l, StateSetter s) => GestureDetector(
      onTap: () {
        s(() => _selectedType = l);
        setState(() => _selectedType = l);
      },
      child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
              color: _selectedType == l
                  ? _accentColor.withOpacity(0.2)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                  color: _selectedType == l ? _accentColor : Colors.white12)),
          child: Center(
              child: Text(l,
                  style: TextStyle(
                      color: _selectedType == l ? _accentColor : Colors.white54,
                      fontWeight: FontWeight.bold)))));
}

class TransactionItem extends StatefulWidget {
  final CreditTransactionModel txn;
  final IconData iconData;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onMarkAsRepayment;
  final VoidCallback onIgnore;
  final bool isIgnored;

  const TransactionItem({
    super.key,
    required this.txn,
    required this.iconData,
    required this.onEdit,
    required this.onDelete,
    required this.onMarkAsRepayment,
    required this.onIgnore,
    required this.isIgnored,
  });

  @override
  State<TransactionItem> createState() => _TransactionItemState();
}

class _TransactionItemState extends State<TransactionItem> {
  bool _isExpanded = false;

  bool get _isUnverifiedTransfer =>
      !widget.isIgnored &&
      widget.txn.type == 'Income' &&
      widget.txn.category.toLowerCase() == 'transfer';

  @override
  Widget build(BuildContext context) {
    final currency = NumberFormat.currency(locale: 'en_IN', symbol: '₹');
    final isExpense = widget.txn.type == 'Expense';
    final amountColor = isExpense ? Colors.redAccent : Colors.greenAccent;
    final iconColor = isExpense ? const Color(0xFF3A86FF) : Colors.green;

    return GestureDetector(
      onTap: () => setState(() => _isExpanded = !_isExpanded),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF1B263B).withOpacity(0.5),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
              color: _isUnverifiedTransfer
                  ? Colors.orangeAccent.withOpacity(0.5)
                  : (_isExpanded
                      ? Colors.white.withOpacity(0.2)
                      : Colors.white.withOpacity(0.05))),
          boxShadow: _isExpanded
              ? [
                  BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 10,
                      offset: const Offset(0, 4))
                ]
              : [],
        ),
        child: Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Stack(
                  children: [
                    CircleAvatar(
                        backgroundColor: iconColor.withOpacity(0.1),
                        child:
                            Icon(widget.iconData, color: iconColor, size: 20)),
                    if (_isUnverifiedTransfer)
                      Positioned(
                          right: 0,
                          top: 0,
                          child: Container(
                              width: 8,
                              height: 8,
                              decoration: const BoxDecoration(
                                  color: Colors.orangeAccent,
                                  shape: BoxShape.circle))),
                  ],
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(widget.txn.category,
                          style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 15)),
                      if (widget.txn.subCategory.isNotEmpty &&
                          widget.txn.subCategory != 'General')
                        Padding(
                            padding: const EdgeInsets.only(top: 2),
                            child: Text(widget.txn.subCategory,
                                style: TextStyle(
                                    color: Colors.white.withOpacity(0.6),
                                    fontSize: 12))),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                        "${isExpense ? '-' : '+'} ${currency.format(widget.txn.amount)}",
                        style: TextStyle(
                            color: amountColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 15)),
                    const SizedBox(height: 4),
                    Text(DateFormat('dd MMM').format(widget.txn.date.toDate()),
                        style: const TextStyle(
                            color: Colors.white38, fontSize: 11)),
                  ],
                ),
              ],
            ),
            if (_isUnverifiedTransfer)
              Container(
                margin: const EdgeInsets.only(top: 12),
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                    color: Colors.orangeAccent.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                        color: Colors.orangeAccent.withOpacity(0.3))),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(children: const [
                      Icon(Icons.warning_amber_rounded,
                          color: Colors.orangeAccent, size: 16),
                      SizedBox(width: 8),
                      Text("Action Required",
                          style: TextStyle(
                              color: Colors.orangeAccent,
                              fontSize: 11,
                              fontWeight: FontWeight.bold))
                    ]),
                    const SizedBox(height: 4),
                    const Text("Is this a Bill Repayment?",
                        style: TextStyle(color: Colors.white70, fontSize: 12)),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                            child: GestureDetector(
                                onTap: widget.onMarkAsRepayment,
                                child: Container(
                                    padding:
                                        const EdgeInsets.symmetric(vertical: 8),
                                    decoration: BoxDecoration(
                                        color: Colors.green.withOpacity(0.2),
                                        borderRadius: BorderRadius.circular(6),
                                        border: Border.all(
                                            color:
                                                Colors.green.withOpacity(0.3))),
                                    child: const Center(
                                        child: Text("Mark as Repayment",
                                            style: TextStyle(
                                                color: Colors.green,
                                                fontSize: 11,
                                                fontWeight:
                                                    FontWeight.bold)))))),
                        const SizedBox(width: 8),
                        Expanded(
                            child: GestureDetector(
                                onTap: widget.onIgnore,
                                child: Container(
                                    padding:
                                        const EdgeInsets.symmetric(vertical: 8),
                                    decoration: BoxDecoration(
                                        color: Colors.grey.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(6),
                                        border:
                                            Border.all(color: Colors.white12)),
                                    child: const Center(
                                        child: Text("Ignore",
                                            style: TextStyle(
                                                color: Colors.white70,
                                                fontSize: 11)))))),
                      ],
                    )
                  ],
                ),
              ),
            AnimatedCrossFade(
              firstChild: const SizedBox.shrink(),
              secondChild: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 16),
                  const Divider(color: Colors.white10),
                  const SizedBox(height: 8),
                  if (widget.txn.notes.isNotEmpty) ...[
                    Text("Notes:",
                        style: TextStyle(
                            color: Colors.white.withOpacity(0.5),
                            fontSize: 11,
                            fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Text(widget.txn.notes,
                        style: const TextStyle(
                            color: Colors.white70, fontSize: 13)),
                    const SizedBox(height: 20),
                  ],
                  Row(children: [
                    Expanded(
                        child: _buildActionButton(
                            icon: Icons.edit_outlined,
                            label: "Edit",
                            color: Colors.white,
                            onTap: widget.onEdit)),
                    const SizedBox(width: 12),
                    Expanded(
                        child: _buildActionButton(
                            icon: Icons.delete_outline,
                            label: "Delete",
                            color: Colors.redAccent,
                            onTap: widget.onDelete))
                  ]),
                ],
              ),
              crossFadeState: _isExpanded
                  ? CrossFadeState.showSecond
                  : CrossFadeState.showFirst,
              duration: const Duration(milliseconds: 300),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton(
          {required IconData icon,
          required String label,
          required Color color,
          required VoidCallback onTap}) =>
      InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Container(
              padding: const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: color.withOpacity(0.2))),
              child:
                  Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                Icon(icon, size: 18, color: color),
                const SizedBox(width: 8),
                Text(label,
                    style: TextStyle(
                        color: color,
                        fontWeight: FontWeight.bold,
                        fontSize: 13))
              ])));
}
