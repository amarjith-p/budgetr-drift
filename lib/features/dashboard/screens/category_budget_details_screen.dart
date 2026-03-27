// lib/features/dashboard/screens/category_budget_details_screen.dart
import 'package:budget/core/database/app_database.dart';
import 'package:budget/core/design/budgetr_colors.dart';
import 'package:budget/core/widgets/futuristic_loader.dart';
import 'package:budget/core/widgets/modern_app_bar.dart';
import 'package:budget/core/constants/icon_constants.dart';
import 'package:budget/core/services/category_service.dart';
import 'package:budget/features/credit_tracker/models/credit_models.dart';
import 'package:budget/features/credit_tracker/services/credit_service.dart';
import 'package:budget/features/daily_expense/models/expense_models.dart';
import 'package:budget/features/daily_expense/services/expense_service.dart';
import 'package:budget/features/dashboard/models/category_budget_models.dart';
import 'package:budget/features/dashboard/widgets/category_trends_chart.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:intl/intl.dart';
import 'package:rxdart/rxdart.dart';

class CategoryBudgetDetailsScreen extends StatefulWidget {
  final CategoryBudgetSummaryModel model;
  final NumberFormat currencyFormat;

  const CategoryBudgetDetailsScreen({
    super.key,
    required this.model,
    required this.currencyFormat,
  });

  @override
  State<CategoryBudgetDetailsScreen> createState() =>
      _CategoryBudgetDetailsScreenState();
}

class _CategoryBudgetDetailsScreenState
    extends State<CategoryBudgetDetailsScreen> {
  final AppDatabase _db = GetIt.I<AppDatabase>();
  final CreditService _creditService = GetIt.I<CreditService>();
  final ExpenseService _expenseService = GetIt.I<ExpenseService>();
  final CategoryService _categoryService = GetIt.I<CategoryService>();

  Map<String, String> _accountNames = {};
  Map<String, String> _bankNames = {};
  Map<String, IconData> _categoryIcons = {};
  bool _isLoadingContext = true;

  @override
  void initState() {
    super.initState();
    _loadContextData();
  }

  Future<void> _loadContextData() async {
    try {
      final results = await Future.wait([
        _creditService.getCreditCards().first,
        _expenseService.getAccounts().first,
        _categoryService.getCategories().first,
      ]);

      if (!mounted) return;

      final cards = results[0] as List<CreditCardModel>;
      final accounts = results[1] as List<ExpenseAccountModel>;
      final categories = results[2] as List<dynamic>;

      final Map<String, String> accNames = {};
      final Map<String, String> bankNames = {};

      for (var c in cards) {
        accNames[c.id] = c.name;
        bankNames[c.id] = c.bankName;
      }
      for (var a in accounts) {
        accNames[a.id] = a.name;
        bankNames[a.id] = a.bankName;
      }

      setState(() {
        _accountNames = accNames;
        _bankNames = bankNames;
        _categoryIcons = {
          for (var c in categories)
            if (c.iconCode != null)
              c.name: IconConstants.getIconByCode(c.iconCode!),
        };
        _isLoadingContext = false;
      });
    } catch (e) {
      if (mounted) setState(() => _isLoadingContext = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final dateStr =
        "${DateFormat('MMM d').format(widget.model.budget.startDate)} - ${DateFormat('MMM d, yyyy').format(widget.model.budget.endDate)}";

    String title = "Global Budget";
    if (widget.model.categoryList.isNotEmpty &&
        widget.model.bucketList.isNotEmpty) {
      title =
          "${widget.model.categoryList.length} Cats in ${widget.model.bucketList.length} Buckets";
    } else if (widget.model.categoryList.isNotEmpty) {
      title = widget.model.categoryList.length > 1
          ? "${widget.model.categoryList.length} Categories"
          : widget.model.categoryList.first;
    } else if (widget.model.bucketList.isNotEmpty) {
      title = widget.model.bucketList.length > 1
          ? "${widget.model.bucketList.length} Buckets"
          : widget.model.bucketList.first;
    }

    return Scaffold(
      backgroundColor: BudgetrColors.background,
      body: SafeArea(
        child: Column(
          children: [
            ModernAppBar(title: title, subtitle: dateStr),
            Expanded(
              child: _isLoadingContext
                  ? const Center(
                      child: FuturisticLoader(
                          size: 80, label: "LOADING BUDGET TELEMETRY..."))
                  : StreamBuilder<List<ExpenseTransaction>>(
                      stream: Rx.combineLatest2(
                          _db.select(_db.expenseTransactions).watch(),
                          _db.select(_db.creditTransactions).watch(),
                          (List<ExpenseTransaction> expenses,
                              List<CreditTransaction> credits) {
                        // 1. Filter Bank/Cash Expenses (Exclude Shadow Records)
                        final validExpenses = expenses.where((t) =>
                            t.accountId != null &&
                            t.accountId!.isNotEmpty &&
                            (widget.model.categoryList.isEmpty ||
                                widget.model.categoryList
                                    .contains(t.category)) &&
                            (widget.model.bucketList.isEmpty ||
                                widget.model.bucketList.contains(t.bucket)) &&
                            t.type == 'Expense' &&
                            t.date.isAfter(widget.model.budget.startDate
                                .subtract(const Duration(seconds: 1))) &&
                            t.date.isBefore(widget.model.budget.endDate
                                .add(const Duration(days: 1))));

                        // 2. Filter Credit Expenses & Map to ExpenseTransaction shape
                        final validCredits = credits
                            .where((c) =>
                                (widget.model.categoryList.isEmpty ||
                                    widget.model.categoryList
                                        .contains(c.category)) &&
                                (widget.model.bucketList.isEmpty ||
                                    widget.model.bucketList
                                        .contains(c.bucket)) &&
                                c.type == 'Expense' &&
                                c.date.isAfter(widget.model.budget.startDate
                                    .subtract(const Duration(seconds: 1))) &&
                                c.date.isBefore(widget.model.budget.endDate
                                    .add(const Duration(days: 1))))
                            .map((c) => ExpenseTransaction(
                                  id: c.id,
                                  accountId: c.cardId,
                                  amount: c.amount,
                                  date: c.date,
                                  bucket: c.bucket,
                                  type: c.type,
                                  category: c.category,
                                  subCategory: c.subCategory,
                                  notes: c.notes,
                                  linkedCreditCardId: c
                                      .cardId, // This triggers `isCredit = true` in the UI card automatically
                                ));

                        // 3. Combine & Sort
                        final combined = [...validExpenses, ...validCredits];
                        combined.sort((a, b) => b.date.compareTo(a.date));
                        return combined;
                      }),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                              child: FuturisticLoader(
                                  size: 80, label: "ANALYZING SPENDING..."));
                        }

                        final transactions = snapshot.data ?? [];

                        return ListView(
                          padding: const EdgeInsets.all(16),
                          children: [
                            CategoryTrendsChart(
                              budget: widget.model.budget,
                              transactions: transactions,
                            ),
                            if (transactions.isEmpty)
                              Center(
                                child: Column(
                                  children: [
                                    const SizedBox(height: 32),
                                    Icon(Icons.receipt_long_outlined,
                                        size: 64,
                                        color: Colors.white.withOpacity(0.1)),
                                    const SizedBox(height: 16),
                                    Text("No transactions found",
                                        style: TextStyle(
                                            color:
                                                Colors.white.withOpacity(0.5))),
                                  ],
                                ),
                              )
                            else ...[
                              const Padding(
                                padding: EdgeInsets.only(left: 4, bottom: 12),
                                child: Text("Transactions",
                                    style: TextStyle(
                                        color: Colors.white70,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16)),
                              ),
                              ...transactions.map((txn) {
                                bool isCredit =
                                    txn.linkedCreditCardId != null &&
                                        txn.linkedCreditCardId!.isNotEmpty;
                                String sourceId = isCredit
                                    ? txn.linkedCreditCardId!
                                    : txn.accountId ?? '';

                                return CategoryTransactionCard(
                                  txn: txn,
                                  isCredit: isCredit,
                                  accountName: _accountNames[sourceId] ??
                                      "Unknown Account",
                                  bankName: _bankNames[sourceId] ?? "",
                                  iconData: _categoryIcons[txn.category] ??
                                      Icons.category_outlined,
                                  currencyFormat: widget.currencyFormat,
                                );
                              }),
                            ]
                          ],
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class CategoryTransactionCard extends StatefulWidget {
  final ExpenseTransaction txn;
  final bool isCredit;
  final String accountName;
  final String bankName;
  final IconData iconData;
  final NumberFormat currencyFormat;

  const CategoryTransactionCard({
    super.key,
    required this.txn,
    required this.isCredit,
    required this.accountName,
    required this.bankName,
    required this.iconData,
    required this.currencyFormat,
  });

  @override
  State<CategoryTransactionCard> createState() =>
      _CategoryTransactionCardState();
}

class _CategoryTransactionCardState extends State<CategoryTransactionCard> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final primaryColor =
        widget.isCredit ? const Color(0xFFE63946) : const Color(0xFF00B4D8);

    return GestureDetector(
      onTap: () => setState(() => _isExpanded = !_isExpanded),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: BudgetrColors.cardSurface.withOpacity(0.5),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
              color: _isExpanded
                  ? Colors.white.withOpacity(0.2)
                  : Colors.white.withOpacity(0.05)),
          boxShadow: _isExpanded
              ? [
                  const BoxShadow(
                      color: Colors.black12,
                      blurRadius: 8,
                      offset: Offset(0, 4))
                ]
              : [],
        ),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.05),
                      shape: BoxShape.circle),
                  child: Icon(widget.iconData, color: Colors.white70, size: 20),
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
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                              widget.isCredit
                                  ? Icons.credit_card
                                  : Icons.account_balance,
                              size: 10,
                              color: primaryColor),
                          const SizedBox(width: 4),
                          Flexible(
                            child: Text(widget.accountName,
                                style: TextStyle(
                                    color: primaryColor,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500),
                                overflow: TextOverflow.ellipsis),
                          ),
                          const SizedBox(width: 6),
                          Container(
                              width: 3,
                              height: 3,
                              decoration: const BoxDecoration(
                                  color: Colors.white24,
                                  shape: BoxShape.circle)),
                          const SizedBox(width: 6),
                          Text(DateFormat('dd MMM').format(widget.txn.date),
                              style: const TextStyle(
                                  color: Colors.white54, fontSize: 12)),
                        ],
                      ),
                    ],
                  ),
                ),
                Text(widget.currencyFormat.format(widget.txn.amount),
                    style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16)),
              ],
            ),
            AnimatedCrossFade(
              firstChild: const SizedBox(width: double.infinity, height: 0),
              secondChild: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 12),
                  const Divider(color: Colors.white10),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      if (widget.bankName.isNotEmpty)
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("Bank / Issuer",
                                  style: TextStyle(
                                      color: Colors.white.withOpacity(0.5),
                                      fontSize: 10)),
                              const SizedBox(height: 2),
                              Text(widget.bankName,
                                  style: const TextStyle(
                                      color: Colors.white70, fontSize: 13)),
                            ],
                          ),
                        ),
                      if (widget.txn.subCategory.isNotEmpty &&
                          widget.txn.subCategory != 'General')
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text("Subcategory",
                                  style: TextStyle(
                                      color: Colors.white.withOpacity(0.5),
                                      fontSize: 10)),
                              const SizedBox(height: 2),
                              Text(widget.txn.subCategory,
                                  style: const TextStyle(
                                      color: Colors.white70, fontSize: 13)),
                            ],
                          ),
                        ),
                    ],
                  ),
                  if (widget.txn.notes.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    Text("Notes",
                        style: TextStyle(
                            color: Colors.white.withOpacity(0.5),
                            fontSize: 10)),
                    const SizedBox(height: 2),
                    Text(widget.txn.notes,
                        style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 13,
                            fontStyle: FontStyle.italic)),
                  ],
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
}
