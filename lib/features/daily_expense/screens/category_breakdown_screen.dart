// lib/features/daily_expense/screens/category_breakdown_screen.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:collection/collection.dart';
import '../../../core/constants/icon_constants.dart';
import '../../../core/models/transaction_category_model.dart';
import '../../../core/services/category_service.dart';
import '../../../core/widgets/modern_loader.dart';
import '../models/expense_models.dart';
import '../services/expense_service.dart';
import '../../credit_tracker/models/credit_models.dart';
import '../../credit_tracker/services/credit_service.dart';

class CategoryBreakdownScreen extends StatefulWidget {
  const CategoryBreakdownScreen({super.key});

  @override
  State<CategoryBreakdownScreen> createState() =>
      _CategoryBreakdownScreenState();
}

class _CategoryBreakdownScreenState extends State<CategoryBreakdownScreen> {
  final ExpenseService _service = ExpenseService();
  final CreditService _creditService = CreditService();
  final CategoryService _categoryService = CategoryService();

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

        return StreamBuilder<List<ExpenseTransactionModel>>(
          stream: _service.getTransactions(accountId: fetchId),
          builder: (context, expenseSnapshot) {
            return StreamBuilder<List<CreditTransactionModel>>(
              stream: fetchId == null
                  ? _creditService.getAllTransactions()
                  : _creditService.getTransactionsForCard(fetchId),
              builder: (context, creditSnapshot) {
                if (!expenseSnapshot.hasData && !creditSnapshot.hasData) {
                  return const Center(child: ModernLoader());
                }

                final expenses = expenseSnapshot.data ?? [];
                final credits = creditSnapshot.data ?? [];

                final List<dynamic> allTxns = [];

                // 1. Add valid expenses (Banks)
                if (_selectedAccountId != kGroupCredits) {
                  allTxns.addAll(expenses.where((t) {
                    if (_selectedAccountId != null &&
                        _selectedAccountId != kGroupBanks &&
                        t.accountId != _selectedAccountId) return false;
                    return _matchesDateFilter(t.date.toDate());
                  }));
                }

                // 2. Add valid credits (Cards)
                if (_selectedAccountId != kGroupBanks) {
                  allTxns.addAll(credits.where((t) {
                    if (_selectedAccountId != null &&
                        _selectedAccountId != kGroupCredits &&
                        t.cardId != _selectedAccountId) return false;
                    return _matchesDateFilter(t.date.toDate());
                  }));
                }

                double totalIncome = 0;
                double totalExpense = 0;
                final List<dynamic> targetTxns = [];

                for (var t in allTxns) {
                  final bool isCredit = t is CreditTransactionModel;

                  final String type = isCredit ? t.type : t.type;
                  final double amount = isCredit ? t.amount : t.amount;

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

                final currentTotal = _showIncome ? totalIncome : totalExpense;

                // Group by Category -> Subcategory
                final groupedByCategory = groupBy(targetTxns, (t) {
                  return (t is ExpenseTransactionModel)
                      ? t.category
                      : (t as CreditTransactionModel).category;
                });

                final List<CategoryBreakdownItem> breakdownItems = [];

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
                    subItems
                        .add(SubCategoryItem(name: subName, amount: subTotal));
                  });

                  subItems.sort((a, b) => b.amount.compareTo(a.amount));

                  breakdownItems.add(CategoryBreakdownItem(
                    name: catName,
                    totalAmount: catTotal,
                    subcategories: subItems,
                    icon: iconMap[catName] ?? Icons.category_outlined,
                  ));
                });

                breakdownItems
                    .sort((a, b) => b.totalAmount.compareTo(a.totalAmount));

                return ListView(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 120),
                  physics: const BouncingScrollPhysics(),
                  children: [
                    // --- 1. Filters (Account + Time) ---
                    Row(
                      children: [
                        Expanded(child: _buildAccountFilter()),
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
                            onTap: () => setState(() => _showIncome = true),
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
                            onTap: () => setState(() => _showIncome = false),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 30),

                    // --- 3. Breakdown List ---
                    Text(
                      _showIncome ? "INCOME SOURCES" : "EXPENSE BREAKDOWN",
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
                                  color: Colors.white.withOpacity(0.1)),
                              const SizedBox(height: 16),
                              Text(
                                "No records found for this period",
                                style: TextStyle(
                                    color: Colors.white.withOpacity(0.3)),
                              ),
                            ],
                          ),
                        ),
                      )
                    else
                      ...breakdownItems.map((item) =>
                          _buildCategoryTile(item, currentTotal, currencyFmt)),
                  ],
                );
              },
            );
          },
        );
      },
    );
  }

  // --- Widgets ---

  Widget _buildAccountFilter() {
    return StreamBuilder<List<ExpenseAccountModel>>(
      stream: _service.getAccounts(),
      builder: (context, expenseSnapshot) {
        return StreamBuilder<List<CreditCardModel>>(
            stream: _creditService.getCreditCards(),
            builder: (context, creditSnapshot) {
              final accounts = expenseSnapshot.data ?? [];
              final cards = creditSnapshot.data ?? [];

              if (_selectedAccountId != null &&
                  _selectedAccountId != kGroupBanks &&
                  _selectedAccountId != kGroupCredits) {
                bool exists = accounts.any((a) => a.id == _selectedAccountId) ||
                    cards.any((c) => c.id == _selectedAccountId);
                if (!exists) _selectedAccountId = null;
              }

              return Container(
                height: 36,
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
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
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.w600),
                    isExpanded: true,
                    hint: const Text(
                      "All Accounts",
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.w600),
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
            });
      },
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

  Widget _buildCategoryTile(
      CategoryBreakdownItem item, double totalAmount, NumberFormat fmt) {
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
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Column(
                children: item.subcategories.map((sub) {
                  return Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                    child: Row(
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

  SubCategoryItem({required this.name, required this.amount});
}
