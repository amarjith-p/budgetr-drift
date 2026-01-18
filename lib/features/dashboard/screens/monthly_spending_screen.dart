import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:intl/intl.dart';
import '../../../core/design/budgetr_colors.dart';
import '../../../core/constants/icon_constants.dart';
import '../../../core/widgets/modern_loader.dart';
import '../../../core/services/category_service.dart';
import '../../../core/models/transaction_category_model.dart';
import '../../../core/models/financial_record_model.dart';

// Credit Tracker
import '../../credit_tracker/models/credit_models.dart';
import '../../credit_tracker/services/credit_service.dart';

// Daily Expense
import '../../daily_expense/models/expense_models.dart';
import '../../daily_expense/services/expense_service.dart';

// Dashboard
import '../services/dashboard_service.dart';
import '../models/dashboard_transaction.dart'; // Unified Model
import '../widgets/bucket_trends_chart.dart';

class MonthlySpendingScreen extends StatefulWidget {
  final FinancialRecord record;

  const MonthlySpendingScreen({super.key, required this.record});

  @override
  State<MonthlySpendingScreen> createState() => _MonthlySpendingScreenState();
}

class _MonthlySpendingScreenState extends State<MonthlySpendingScreen> {
  final DashboardService _dashboardService = GetIt.I<DashboardService>();
  final CreditService _creditService = GetIt.I<CreditService>();
  final ExpenseService _expenseService = GetIt.I<ExpenseService>();
  final CategoryService _categoryService = GetIt.I<CategoryService>();

  Map<String, String> _accountNames = {};
  Map<String, String> _bankNames = {};
  Map<String, IconData> _categoryIcons = {};

  bool _isLoadingInfo = true;
  bool _hideOutOfBucket = false;

  @override
  void initState() {
    super.initState();
    _loadMetadata();
  }

  Future<void> _loadMetadata() async {
    try {
      final results = await Future.wait([
        _creditService.getCreditCards().first,
        _expenseService.getAccounts().first,
        _categoryService.getCategories().first,
      ]);

      if (!mounted) return;

      final cards = results[0] as List<CreditCardModel>;
      final accounts = results[1] as List<ExpenseAccountModel>;
      final categories = results[2] as List<TransactionCategoryModel>;

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
        _isLoadingInfo = false;
      });
    } catch (e) {
      debugPrint("Error loading metadata: $e");
      if (mounted) setState(() => _isLoadingInfo = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final dateString = DateFormat(
      'MMMM yyyy',
    ).format(DateTime(widget.record.year, widget.record.month));

    final double totalBudget = widget.record.effectiveIncome;

    return Scaffold(
      backgroundColor: BudgetrColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: Column(
          children: [
            const Text(
              "Monthly Overview",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              dateString,
              style: const TextStyle(color: Colors.white54, fontSize: 12),
            ),
          ],
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: _isLoadingInfo
          ? const Center(child: ModernLoader())
          : StreamBuilder<List<DashboardTransaction>>(
              stream: _dashboardService.getMonthlyTransactions(
                widget.record.year,
                widget.record.month,
              ),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: ModernLoader());
                }

                var transactions = snapshot.data ?? [];
                transactions = transactions
                    .where((t) => t.type == 'Expense' && t.sourceId != '')
                    .toList();

                if (_hideOutOfBucket) {
                  transactions = transactions
                      .where((t) => t.bucket != 'Out of Bucket')
                      .toList();
                }

                if (transactions.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.receipt_long_outlined,
                          size: 64,
                          color: Colors.white.withOpacity(0.1),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          _hideOutOfBucket
                              ? "No planned transactions found"
                              : "No transactions found",
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.5),
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    BucketTrendsChart(
                      transactions: transactions,
                      year: widget.record.year,
                      month: widget.record.month,
                      budgetLimit: totalBudget,
                    ),
                    const SizedBox(height: 8),
                    GestureDetector(
                      onTap: () =>
                          setState(() => _hideOutOfBucket = !_hideOutOfBucket),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                        margin: const EdgeInsets.only(bottom: 24),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          color: _hideOutOfBucket
                              ? BudgetrColors.accent.withOpacity(0.15)
                              : BudgetrColors.cardSurface.withOpacity(0.4),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: _hideOutOfBucket
                                ? BudgetrColors.accent.withOpacity(0.5)
                                : Colors.white.withOpacity(0.05),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: _hideOutOfBucket
                                    ? BudgetrColors.accent
                                    : Colors.white10,
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.filter_alt_off_outlined,
                                size: 18,
                                color: _hideOutOfBucket
                                    ? Colors.white
                                    : Colors.white54,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Hide 'Out of Bucket'",
                                    style: TextStyle(
                                      color: _hideOutOfBucket
                                          ? Colors.white
                                          : Colors.white70,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    _hideOutOfBucket
                                        ? "Showing planned expenses only"
                                        : "Showing all expenses",
                                    style: TextStyle(
                                      color: _hideOutOfBucket
                                          ? Colors.white70
                                          : Colors.white38,
                                      fontSize: 11,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Icon(
                              _hideOutOfBucket
                                  ? Icons.check_circle
                                  : Icons.circle_outlined,
                              color: _hideOutOfBucket
                                  ? BudgetrColors.accent
                                  : Colors.white24,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const Padding(
                      padding: EdgeInsets.only(left: 4, bottom: 12),
                      child: Text(
                        "Transactions",
                        style: TextStyle(
                          color: Colors.white70,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    ...transactions.map((txn) => MonthlyTransactionCard(
                          txn: txn,
                          accountName: _accountNames[txn.sourceId] ?? "Unknown",
                          bankName: _bankNames[txn.sourceId] ?? "",
                          iconData: _categoryIcons[txn.category] ??
                              Icons.category_outlined,
                        )),
                  ],
                );
              },
            ),
    );
  }
}

class MonthlyTransactionCard extends StatefulWidget {
  final DashboardTransaction txn;
  final String accountName;
  final String bankName;
  final IconData iconData;

  const MonthlyTransactionCard({
    super.key,
    required this.txn,
    required this.accountName,
    required this.bankName,
    required this.iconData,
  });

  @override
  State<MonthlyTransactionCard> createState() => _MonthlyTransactionCardState();
}

class _MonthlyTransactionCardState extends State<MonthlyTransactionCard> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(locale: 'en_IN', symbol: '₹');
    final isCredit = widget.txn.sourceType == TransactionSourceType.creditCard;

    final primaryColor =
        isCredit ? const Color(0xFFE63946) : const Color(0xFF00B4D8);

    return GestureDetector(
      onTap: () => setState(() => _isExpanded = !_isExpanded),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: BudgetrColors.cardSurface.withOpacity(0.5),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: _isExpanded
                ? Colors.white.withOpacity(0.2)
                : Colors.white.withOpacity(0.05),
          ),
          boxShadow: _isExpanded
              ? [
                  BoxShadow(
                      color: Colors.black12,
                      blurRadius: 8,
                      offset: const Offset(0, 4))
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
                    shape: BoxShape.circle,
                  ),
                  child: Icon(widget.iconData, color: Colors.white70, size: 20),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.txn.category,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                              isCredit
                                  ? Icons.credit_card
                                  : Icons.account_balance,
                              size: 10,
                              color: primaryColor),
                          const SizedBox(width: 4),
                          Flexible(
                            child: Text(
                              widget.accountName,
                              style: TextStyle(
                                color: primaryColor,
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Container(
                              width: 3,
                              height: 3,
                              decoration: const BoxDecoration(
                                  color: Colors.white24,
                                  shape: BoxShape.circle)),
                          const SizedBox(width: 6),
                          Text(
                            DateFormat('dd MMM').format(widget.txn.date),
                            style: const TextStyle(
                                color: Colors.white54, fontSize: 12),
                          ),
                        ],
                      ),
                      if (widget.txn.bucket.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 6),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: widget.txn.bucket == 'Out of Bucket'
                                  ? Colors.redAccent.withOpacity(0.2)
                                  : Colors.white10,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              widget.txn.bucket,
                              style: TextStyle(
                                color: widget.txn.bucket == 'Out of Bucket'
                                    ? Colors.redAccent
                                    : Colors.white54,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                Text(
                  currencyFormat.format(widget.txn.amount),
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ],
            ),

            // --- EXPANDED DETAILS ---
            AnimatedCrossFade(
              // FIX: Use infinite width, 0 height to maintain width constraints during animation
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
                    Text(
                      widget.txn.notes,
                      style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 13,
                          fontStyle: FontStyle.italic),
                    ),
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
