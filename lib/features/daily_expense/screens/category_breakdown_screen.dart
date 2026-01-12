import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:intl/intl.dart';
import 'package:collection/collection.dart';
import '../../../core/constants/icon_constants.dart';
import '../../../core/models/transaction_category_model.dart';
import '../../../core/services/category_service.dart';
import '../../../core/widgets/modern_loader.dart';
import '../models/expense_models.dart';
import '../services/expense_service.dart';
// Note: keeping this import if you need the original item elsewhere,
// but we use local read-only widgets here.
import '../widgets/transaction_item.dart';
import '../../credit_tracker/models/credit_models.dart';
import '../../credit_tracker/services/credit_service.dart';

class CategoryBreakdownScreen extends StatefulWidget {
  const CategoryBreakdownScreen({super.key});

  @override
  State<CategoryBreakdownScreen> createState() =>
      _CategoryBreakdownScreenState();
}

class _CategoryBreakdownScreenState extends State<CategoryBreakdownScreen> {
  final ExpenseService _service = GetIt.I<ExpenseService>();
  final CreditService _creditService = GetIt.I<CreditService>();
  final CategoryService _categoryService = GetIt.I<CategoryService>();

  String _selectedRange = 'This Month';
  String? _selectedAccountId;
  bool _showIncome = false;

  // Constants for group filters
  static const String kGroupBanks = 'group_banks';
  static const String kGroupCredits = 'group_credits';

  // Helper: Date Filter
  bool _matchesDateFilter(DateTime date) {
    final now = DateTime.now();
    switch (_selectedRange) {
      case 'This Month':
        return date.year == now.year && date.month == now.month;
      case 'Last Month':
        final last = DateTime(now.year, now.month - 1, 1);
        return date.year == last.year && date.month == last.month;
      case 'This Year':
        return date.year == now.year;
      case 'Last Year':
        return date.year == now.year - 1;
      case 'All Time':
        return true;
      default:
        return true;
    }
  }

  @override
  Widget build(BuildContext context) {
    final currencyFmt =
        NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: 2);

    final String? fetchId = (_selectedAccountId == kGroupBanks ||
            _selectedAccountId == kGroupCredits)
        ? null
        : _selectedAccountId;

    // 1. Fetch Categories
    return StreamBuilder<List<TransactionCategoryModel>>(
      stream: _categoryService.getCategories(),
      builder: (context, catSnapshot) {
        final Map<String, IconData> iconMap = {};
        if (catSnapshot.hasData) {
          for (var c in catSnapshot.data!) {
            if (c.iconCode != null) {
              iconMap[c.name] = IconConstants.getIconByCode(c.iconCode!);
            }
          }
        }

        // 2. Fetch Accounts (For Name Lookup)
        return StreamBuilder<List<ExpenseAccountModel>>(
            stream: _service.getAccounts(),
            builder: (context, accountListSnap) {
              // 3. Fetch Credit Cards (For Name Lookup)
              return StreamBuilder<List<CreditCardModel>>(
                  stream: _creditService.getCreditCards(),
                  builder: (context, cardListSnap) {
                    // Create Lookup Map: ID -> Name
                    final Map<String, String> accountNameMap = {};

                    if (accountListSnap.hasData) {
                      for (var acc in accountListSnap.data!) {
                        accountNameMap[acc.id] =
                            "${acc.name} (${acc.bankName})";
                      }
                    }
                    if (cardListSnap.hasData) {
                      for (var card in cardListSnap.data!) {
                        accountNameMap[card.id] =
                            "${card.name} (${card.bankName})";
                      }
                    }

                    // 4. Fetch Expense Transactions
                    return StreamBuilder<List<ExpenseTransactionModel>>(
                      stream: _service.getTransactions(accountId: fetchId),
                      builder: (context, expenseSnapshot) {
                        // 5. Fetch Credit Transactions
                        return StreamBuilder<List<CreditTransactionModel>>(
                          stream: fetchId == null
                              ? _creditService.getAllTransactions()
                              : _creditService.getTransactionsForCard(fetchId),
                          builder: (context, creditSnapshot) {
                            if (!expenseSnapshot.hasData &&
                                !creditSnapshot.hasData) {
                              return const Center(child: ModernLoader());
                            }

                            final expenses = expenseSnapshot.data ?? [];
                            final credits = creditSnapshot.data ?? [];

                            final List<dynamic> allTxns = [];

                            // --- Filter Logic ---

                            // Add valid expenses (Banks)
                            if (_selectedAccountId != kGroupCredits) {
                              allTxns.addAll(expenses.where((t) {
                                if (_selectedAccountId != null &&
                                    _selectedAccountId != kGroupBanks &&
                                    t.accountId != _selectedAccountId)
                                  return false;
                                return _matchesDateFilter(t.date.toDate());
                              }));
                            }

                            // Add valid credits (Cards)
                            if (_selectedAccountId != kGroupBanks) {
                              allTxns.addAll(credits.where((t) {
                                if (_selectedAccountId != null &&
                                    _selectedAccountId != kGroupCredits &&
                                    t.cardId != _selectedAccountId)
                                  return false;
                                return _matchesDateFilter(t.date.toDate());
                              }));
                            }

                            double totalIncome = 0;
                            double totalExpense = 0;
                            final List<dynamic> targetTxns = [];

                            for (var t in allTxns) {
                              final bool isCredit = t is CreditTransactionModel;

                              final String type = isCredit ? t.type : t.type;
                              final double amount =
                                  isCredit ? t.amount : t.amount;

                              // Exclude Credit Card Repayments (Income)
                              if (type == 'Income') {
                                if (!isCredit) {
                                  totalIncome += amount;
                                  if (_showIncome) targetTxns.add(t);
                                }
                              } else if (type == 'Expense') {
                                totalExpense += amount;
                                if (!_showIncome) targetTxns.add(t);
                              }
                            }

                            final currentTotal =
                                _showIncome ? totalIncome : totalExpense;

                            // Group by Category -> Subcategory
                            final groupedByCategory = groupBy(targetTxns, (t) {
                              return (t is ExpenseTransactionModel)
                                  ? t.category
                                  : (t as CreditTransactionModel).category;
                            });

                            final List<CategoryBreakdownItem> breakdownItems =
                                [];

                            groupedByCategory.forEach((catName, txns) {
                              final catTotal = txns.fold(0.0, (sum, t) {
                                final amt = (t is ExpenseTransactionModel)
                                    ? t.amount
                                    : (t as CreditTransactionModel).amount;
                                return sum + amt;
                              });

                              // Group Subcategories
                              final groupedBySub = groupBy(txns, (t) {
                                return (t is ExpenseTransactionModel)
                                    ? t.subCategory
                                    : (t as CreditTransactionModel).subCategory;
                              });

                              final List<SubCategoryItem> subItems = [];

                              groupedBySub.forEach((subName, subTxns) {
                                final subTotal = subTxns.fold(0.0, (sum, t) {
                                  final amt = (t is ExpenseTransactionModel)
                                      ? t.amount
                                      : (t as CreditTransactionModel).amount;
                                  return sum + amt;
                                });

                                // Sort transactions by Date Descending
                                subTxns.sort((a, b) {
                                  final dateA = (a is ExpenseTransactionModel)
                                      ? a.date
                                      : (a as CreditTransactionModel).date;
                                  final dateB = (b is ExpenseTransactionModel)
                                      ? b.date
                                      : (b as CreditTransactionModel).date;
                                  return dateB.compareTo(dateA);
                                });

                                subItems.add(SubCategoryItem(
                                  name: subName,
                                  amount: subTotal,
                                  transactions: subTxns,
                                ));
                              });

                              subItems
                                  .sort((a, b) => b.amount.compareTo(a.amount));

                              breakdownItems.add(CategoryBreakdownItem(
                                name: catName,
                                totalAmount: catTotal,
                                subcategories: subItems,
                                icon:
                                    iconMap[catName] ?? Icons.category_outlined,
                              ));
                            });

                            breakdownItems.sort((a, b) =>
                                b.totalAmount.compareTo(a.totalAmount));

                            return ListView(
                              padding:
                                  const EdgeInsets.fromLTRB(20, 20, 20, 120),
                              physics: const BouncingScrollPhysics(),
                              children: [
                                // --- 1. Filters (Account + Time) ---
                                Row(
                                  children: [
                                    Expanded(
                                        child: _buildAccountFilter(
                                            accountListSnap.data ?? [],
                                            cardListSnap.data ?? [])),
                                    const SizedBox(width: 12),
                                    _buildTimeFilter(),
                                  ],
                                ),
                                const SizedBox(height: 20),

                                // --- 2. Summary Cards ---
                                Row(
                                  children: [
                                    Expanded(
                                      child: _buildSummaryCard(
                                        "Total Income",
                                        totalIncome,
                                        const Color(0xFF00E676),
                                        Icons.arrow_downward_rounded,
                                        isActive: _showIncome,
                                        onTap: () =>
                                            setState(() => _showIncome = true),
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: _buildSummaryCard(
                                        "Total Expense",
                                        totalExpense,
                                        const Color(0xFFFF4D6D),
                                        Icons.arrow_upward_rounded,
                                        isActive: !_showIncome,
                                        onTap: () =>
                                            setState(() => _showIncome = false),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 30),

                                // --- 3. Breakdown List ---
                                Text(
                                  _showIncome
                                      ? "INCOME SOURCES"
                                      : "EXPENSE BREAKDOWN",
                                  style: TextStyle(
                                    color: Colors.white.withOpacity(0.5),
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 1.2,
                                  ),
                                ),
                                const SizedBox(height: 16),

                                if (breakdownItems.isEmpty)
                                  Padding(
                                    padding: const EdgeInsets.only(top: 40),
                                    child: Center(
                                      child: Column(
                                        children: [
                                          Icon(Icons.analytics_outlined,
                                              size: 48,
                                              color: Colors.white
                                                  .withOpacity(0.1)),
                                          const SizedBox(height: 16),
                                          Text(
                                            "No records found for this period",
                                            style: TextStyle(
                                                color: Colors.white
                                                    .withOpacity(0.3)),
                                          ),
                                        ],
                                      ),
                                    ),
                                  )
                                else
                                  ...breakdownItems.map((item) =>
                                      _buildCategoryTile(item, currentTotal,
                                          currencyFmt, accountNameMap)),
                              ],
                            );
                          },
                        );
                      },
                    );
                  });
            });
      },
    );
  }

  // --- Widgets ---

  Widget _buildAccountFilter(
      List<ExpenseAccountModel> accounts, List<CreditCardModel> cards) {
    if (_selectedAccountId != null &&
        _selectedAccountId != kGroupBanks &&
        _selectedAccountId != kGroupCredits) {
      bool exists = accounts.any((a) => a.id == _selectedAccountId) ||
          cards.any((c) => c.id == _selectedAccountId);
      if (!exists) _selectedAccountId = null;
    }

    return Container(
      height: 36,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String?>(
          value: _selectedAccountId,
          dropdownColor: const Color(0xFF1B263B),
          icon: const Icon(Icons.account_balance_wallet_outlined,
              color: Colors.white70, size: 16),
          style: const TextStyle(
              color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600),
          isExpanded: true,
          hint: const Text(
            "All Accounts",
            style: TextStyle(
                color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600),
            overflow: TextOverflow.ellipsis,
          ),
          items: [
            const DropdownMenuItem<String?>(
              value: null,
              child: Text("All Accounts"),
            ),
            // --- Bank Section ---
            if (accounts.isNotEmpty)
              const DropdownMenuItem<String?>(
                enabled: false,
                value: 'header_bank',
                child: Text("BANK ACCOUNTS",
                    style: TextStyle(
                        color: Colors.white38,
                        fontSize: 10,
                        fontWeight: FontWeight.bold)),
              ),
            if (accounts.isNotEmpty)
              const DropdownMenuItem<String?>(
                value: kGroupBanks,
                child: Text("All Bank Accounts",
                    style: TextStyle(fontWeight: FontWeight.w500)),
              ),
            ...accounts.map((acc) => DropdownMenuItem(
                  value: acc.id,
                  child: Text(
                    "${acc.name} ( ${acc.bankName} )",
                    overflow: TextOverflow.ellipsis,
                  ),
                )),
            // --- Credit Section ---
            if (cards.isNotEmpty)
              const DropdownMenuItem<String?>(
                enabled: false,
                value: 'header_credit',
                child: Text("CREDIT CARDS",
                    style: TextStyle(
                        color: Colors.white38,
                        fontSize: 10,
                        fontWeight: FontWeight.bold)),
              ),
            if (cards.isNotEmpty)
              const DropdownMenuItem<String?>(
                value: kGroupCredits,
                child: Text("All Credit Cards",
                    style: TextStyle(fontWeight: FontWeight.w500)),
              ),
            ...cards.map((card) => DropdownMenuItem(
                  value: card.id,
                  child: Text(
                    "${card.name} ( ${card.bankName} )",
                    overflow: TextOverflow.ellipsis,
                  ),
                )),
          ],
          onChanged: (val) {
            setState(() => _selectedAccountId = val);
          },
        ),
      ),
    );
  }

  Widget _buildTimeFilter() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _selectedRange,
          dropdownColor: const Color(0xFF1B263B),
          icon: const Icon(Icons.keyboard_arrow_down_rounded,
              color: Colors.white70, size: 18),
          style: const TextStyle(
              color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600),
          isDense: true,
          items: [
            'This Month',
            'Last Month',
            'This Year',
            'Last Year',
            'All Time'
          ].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
          onChanged: (val) {
            if (val != null) setState(() => _selectedRange = val);
          },
        ),
      ),
    );
  }

  Widget _buildSummaryCard(
      String title, double amount, Color color, IconData icon,
      {required bool isActive, required VoidCallback onTap}) {
    final currencyFmt =
        NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: 2);

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isActive ? color.withOpacity(0.15) : const Color(0xFF151D29),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isActive ? color.withOpacity(0.5) : Colors.transparent,
            width: 1.5,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: color, size: 16),
                ),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.7),
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                currencyFmt.format(amount),
                style: TextStyle(
                  color: color,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryTile(CategoryBreakdownItem item, double totalAmount,
      NumberFormat fmt, Map<String, String> accountNameMap) {
    final double percentage =
        totalAmount > 0 ? (item.totalAmount / totalAmount) : 0.0;
    final Color color =
        _showIncome ? const Color(0xFF00E676) : const Color(0xFFFF4D6D);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF151D29),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          leading: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(item.icon, color: color, size: 20),
          ),
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                item.name,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                fmt.format(item.totalAmount),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(2),
                child: LinearProgressIndicator(
                  value: percentage,
                  backgroundColor: Colors.white.withOpacity(0.05),
                  valueColor: AlwaysStoppedAnimation(color),
                  minHeight: 4,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                "${(percentage * 100).toStringAsFixed(1)}% of total",
                style: TextStyle(
                    color: Colors.white.withOpacity(0.4), fontSize: 10),
              ),
            ],
          ),
          children: [
            Container(
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.2),
                borderRadius:
                    const BorderRadius.vertical(bottom: Radius.circular(16)),
              ),
              child: Column(
                children: item.subcategories.map((sub) {
                  return Theme(
                    data: Theme.of(context)
                        .copyWith(dividerColor: Colors.transparent),
                    child: ExpansionTile(
                      tilePadding: const EdgeInsets.only(
                          left: 24, right: 16, top: 4, bottom: 4),
                      title: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            sub.name,
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.7),
                              fontSize: 13,
                            ),
                          ),
                          Text(
                            fmt.format(sub.amount),
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.9),
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                      children: [
                        ...sub.transactions.map((txn) {
                          if (txn is ExpenseTransactionModel) {
                            return Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 4),
                              child: _ReadOnlyExpenseTransactionItem(
                                key: ValueKey(txn.id),
                                txn: txn,
                                iconData: item.icon,
                                sourceAccountName:
                                    accountNameMap[txn.accountId],
                              ),
                            );
                          } else if (txn is CreditTransactionModel) {
                            return Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 4),
                              // [UPDATED] Use the new animated widget for Credit Txns
                              child: _ReadOnlyCreditTransactionItem(
                                key: ValueKey(txn.id),
                                txn: txn,
                                iconData: item.icon,
                                cardName: accountNameMap[txn.cardId],
                              ),
                            );
                          }
                          return const SizedBox();
                        }),
                      ],
                    ),
                  );
                }).toList(),
              ),
            )
          ],
        ),
      ),
    );
  }
}

// --- Models ---
class CategoryBreakdownItem {
  final String name;
  final double totalAmount;
  final List<SubCategoryItem> subcategories;
  final IconData icon;

  CategoryBreakdownItem({
    required this.name,
    required this.totalAmount,
    required this.subcategories,
    required this.icon,
  });
}

class SubCategoryItem {
  final String name;
  final double amount;
  final List<dynamic> transactions;

  SubCategoryItem({
    required this.name,
    required this.amount,
    required this.transactions,
  });
}

// --- Local Widgets ---

// 1. Read-Only Expense Item (Existing)
class _ReadOnlyExpenseTransactionItem extends StatefulWidget {
  final ExpenseTransactionModel txn;
  final IconData iconData;
  final String? sourceAccountName;

  const _ReadOnlyExpenseTransactionItem({
    required this.txn,
    required this.iconData,
    this.sourceAccountName,
    super.key,
  });

  @override
  State<_ReadOnlyExpenseTransactionItem> createState() =>
      _ReadOnlyExpenseTransactionItemState();
}

class _ReadOnlyExpenseTransactionItemState
    extends State<_ReadOnlyExpenseTransactionItem> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final currency = NumberFormat.currency(locale: 'en_IN', symbol: '₹');
    final isExpense = widget.txn.type == 'Expense';
    final isTransferOut = widget.txn.type == 'Transfer Out';
    final isTransferIn = widget.txn.type == 'Transfer In';
    Color amountColor;
    Color iconColor;
    IconData icon;
    String title;
    String sign;

    if (isExpense) {
      amountColor = Colors.redAccent;
      iconColor = const Color(0xFF00B4D8);
      icon = widget.iconData;
      title = widget.txn.category;
      sign = '-';
    } else if (isTransferOut) {
      amountColor = Colors.orangeAccent;
      iconColor = Colors.orangeAccent;
      icon = Icons.arrow_outward_rounded;
      final bank = widget.txn.transferAccountBankName ?? '';
      final acc = widget.txn.transferAccountName ?? 'Account';
      title = bank.isNotEmpty ? "Transfer to $bank - $acc" : "Transfer to $acc";
      sign = '-';
    } else if (isTransferIn) {
      amountColor = Colors.greenAccent;
      iconColor = Colors.greenAccent;
      icon = Icons.arrow_downward_rounded;
      final bank = widget.txn.transferAccountBankName ?? '';
      final acc = widget.txn.transferAccountName ?? 'Account';
      title =
          bank.isNotEmpty ? "Transfer from $bank - $acc" : "Transfer from $acc";
      sign = '+';
    } else {
      amountColor = Colors.greenAccent;
      iconColor = Colors.green;
      icon = widget.iconData;
      title = widget.txn.category;
      sign = '+';
    }

    final bool hasSummary = (isExpense && widget.txn.bucket.isNotEmpty) ||
        widget.txn.notes.isNotEmpty ||
        widget.sourceAccountName != null;

    return GestureDetector(
      onTap: () => setState(() => _isExpanded = !_isExpanded),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
            color: const Color(0xFF1B263B).withOpacity(0.5),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
                color: _isExpanded
                    ? Colors.white.withOpacity(0.2)
                    : Colors.white.withOpacity(0.05)),
            boxShadow: _isExpanded
                ? [
                    BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 10,
                        offset: const Offset(0, 4))
                  ]
                : []),
        child: Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                    backgroundColor: iconColor.withOpacity(0.1),
                    child: Icon(icon, color: iconColor, size: 20)),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title,
                          style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 15)),
                      if (widget.sourceAccountName != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 4.0),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(4)),
                            child: Text(
                              widget.sourceAccountName!,
                              style: const TextStyle(
                                  color: Colors.blueAccent,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600),
                            ),
                          ),
                        )
                      else if (widget.txn.subCategory.isNotEmpty &&
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
                    Text("$sign ${currency.format(widget.txn.amount)}",
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
            AnimatedCrossFade(
              duration: const Duration(milliseconds: 300),
              firstChild: hasSummary
                  ? Container(
                      width: double.infinity,
                      padding: const EdgeInsets.only(top: 8, left: 56),
                      child: Wrap(
                        spacing: 8,
                        runSpacing: 4,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          if (isExpense && widget.txn.bucket.isNotEmpty)
                            _buildTag(widget.txn.bucket),
                          if (widget.txn.notes.isNotEmpty)
                            Text(
                              widget.txn.notes,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.4),
                                fontSize: 11,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                        ],
                      ),
                    )
                  : const SizedBox(width: double.infinity),
              secondChild: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 16),
                  const Divider(color: Colors.white10),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        DateFormat('EEEE, hh:mm a')
                            .format(widget.txn.date.toDate()),
                        style: TextStyle(
                            color: Colors.white.withOpacity(0.5), fontSize: 12),
                      ),
                      if (isExpense && widget.txn.bucket.isNotEmpty)
                        _buildTag("Bucket: ${widget.txn.bucket}"),
                    ],
                  ),
                  const SizedBox(height: 12),
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
                  ],
                ],
              ),
              crossFadeState: _isExpanded
                  ? CrossFadeState.showSecond
                  : CrossFadeState.showFirst,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTag(String text) => Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
          color: Colors.white10,
          borderRadius: BorderRadius.circular(4),
          border: Border.all(color: Colors.white12)),
      child: Text(text,
          style: const TextStyle(
              color: Colors.white70,
              fontSize: 10,
              fontWeight: FontWeight.w500)));
}

// 2. [NEW] Read-Only Credit Item (Animated & Expanded)
class _ReadOnlyCreditTransactionItem extends StatefulWidget {
  final CreditTransactionModel txn;
  final IconData iconData;
  final String? cardName;

  const _ReadOnlyCreditTransactionItem({
    required this.txn,
    required this.iconData,
    this.cardName,
    super.key,
  });

  @override
  State<_ReadOnlyCreditTransactionItem> createState() =>
      _ReadOnlyCreditTransactionItemState();
}

class _ReadOnlyCreditTransactionItemState
    extends State<_ReadOnlyCreditTransactionItem> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final currency = NumberFormat.currency(locale: 'en_IN', symbol: '₹');
    // Credit Txns are usually expenses unless specified otherwise
    final bool isIncome = widget.txn.type == 'Income';

    final Color amountColor = isIncome ? Colors.greenAccent : Colors.redAccent;
    // Credit often uses Purple/Orange theme, but let's stick to standard or blue for consistency
    final Color iconColor = const Color(0xFF00B4D8);

    final String title = widget.txn.category;
    final String sign = isIncome ? '+' : '-';

    final bool hasSummary = widget.txn.bucket.isNotEmpty ||
        widget.txn.notes.isNotEmpty ||
        widget.cardName != null;

    return GestureDetector(
      onTap: () => setState(() => _isExpanded = !_isExpanded),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
            color: const Color(0xFF1B263B).withOpacity(0.5),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
                color: _isExpanded
                    ? Colors.white.withOpacity(0.2)
                    : Colors.white.withOpacity(0.05)),
            boxShadow: _isExpanded
                ? [
                    BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 10,
                        offset: const Offset(0, 4))
                  ]
                : []),
        child: Column(
          children: [
            // Top Row (Always Visible)
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                    backgroundColor: iconColor.withOpacity(0.1),
                    child: Icon(widget.iconData, color: iconColor, size: 20)),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title,
                          style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 15)),
                      // Display Card Name Badge
                      if (widget.cardName != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 4.0),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(4)),
                            child: Text(
                              widget.cardName!,
                              style: const TextStyle(
                                  color: Colors.redAccent,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600),
                            ),
                          ),
                        )
                      else if (widget.txn.subCategory.isNotEmpty &&
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
                    Text("$sign ${currency.format(widget.txn.amount)}",
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

            // Animated Body (Summary vs Detailed)
            AnimatedCrossFade(
              duration: const Duration(milliseconds: 300),
              firstChild: hasSummary
                  ? Container(
                      width: double.infinity,
                      padding: const EdgeInsets.only(top: 8, left: 56),
                      child: Wrap(
                        spacing: 8,
                        runSpacing: 4,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          if (widget.txn.bucket.isNotEmpty)
                            _buildTag(widget.txn.bucket),
                          if (widget.txn.notes.isNotEmpty)
                            Text(
                              widget.txn.notes,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.4),
                                fontSize: 11,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                        ],
                      ),
                    )
                  : const SizedBox(width: double.infinity),
              secondChild: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 16),
                  const Divider(color: Colors.white10),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        DateFormat('EEEE, hh:mm a')
                            .format(widget.txn.date.toDate()),
                        style: TextStyle(
                            color: Colors.white.withOpacity(0.5), fontSize: 12),
                      ),
                      if (widget.txn.bucket.isNotEmpty)
                        _buildTag("Bucket: ${widget.txn.bucket}"),
                    ],
                  ),
                  const SizedBox(height: 12),
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
                  ],
                ],
              ),
              crossFadeState: _isExpanded
                  ? CrossFadeState.showSecond
                  : CrossFadeState.showFirst,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTag(String text) => Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
          color: Colors.white10,
          borderRadius: BorderRadius.circular(4),
          border: Border.all(color: Colors.white12)),
      child: Text(text,
          style: const TextStyle(
              color: Colors.white70,
              fontSize: 10,
              fontWeight: FontWeight.w500)));
}
