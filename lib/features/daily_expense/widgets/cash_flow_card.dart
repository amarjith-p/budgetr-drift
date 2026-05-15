// lib/features/daily_expense/widgets/cash_flow_card.dart

import 'dart:ui'; // Added for BackdropFilter
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:intl/intl.dart';
import 'package:collection/collection.dart';
import '../models/expense_models.dart';
import '../services/expense_service.dart';
import '../../credit_tracker/models/credit_models.dart';
import '../../credit_tracker/services/credit_service.dart';

class CashFlowCard extends StatefulWidget {
  const CashFlowCard({super.key});

  @override
  State<CashFlowCard> createState() => _CashFlowCardState();
}

class _CashFlowCardState extends State<CashFlowCard> {
  final ExpenseService _expenseService = GetIt.I<ExpenseService>();
  final CreditService _creditService = GetIt.I<CreditService>();
  String _selectedPeriod = 'This Month';
  String? _selectedAccountId;

  // New State for Budget Mode
  bool _isBudgetMode = false;

  // Constants for group filters
  static const String kGroupBanks = 'group_banks';
  static const String kGroupCredits = 'group_credits';

  List<dynamic> _filterTransactions(
    List<ExpenseTransactionModel> expenseTxns,
    List<CreditTransactionModel> creditTxns,
  ) {
    final now = DateTime.now();
    List<dynamic> combined = [];

    // --- 1. Filter by Account / Group ---
    if (_selectedAccountId == null) {
      combined.addAll(expenseTxns);
      combined.addAll(creditTxns);
    } else if (_selectedAccountId == kGroupBanks) {
      combined.addAll(expenseTxns);
    } else if (_selectedAccountId == kGroupCredits) {
      combined.addAll(creditTxns);
    } else {
      combined
          .addAll(expenseTxns.where((t) => t.accountId == _selectedAccountId));
      combined.addAll(creditTxns.where((t) => t.cardId == _selectedAccountId));
    }

    // --- 2. Filter by Date ---
    combined = combined.where((txn) {
      final date = (txn is ExpenseTransactionModel)
          ? txn.date
          : (txn as CreditTransactionModel).date;

      if (_selectedPeriod == 'This Month') {
        return date.year == now.year && date.month == now.month;
      } else if (_selectedPeriod == 'Last Month') {
        final lastMonth = DateTime(now.year, now.month - 1, 1);
        return date.year == lastMonth.year && date.month == lastMonth.month;
      } else if (_selectedPeriod == 'This Year') {
        return date.year == now.year;
      } else if (_selectedPeriod == 'Last Year') {
        return date.year == now.year - 1;
      }
      return true;
    }).toList();

    // --- 3. Filter by Budget Mode ---
    if (_isBudgetMode) {
      combined = combined.where((txn) {
        String category = '';
        String bucket = '';

        if (txn is ExpenseTransactionModel) {
          category = txn.category;
          bucket = txn.bucket;
        } else if (txn is CreditTransactionModel) {
          category = txn.category;
          bucket = txn.bucket;
        }

        // Exclusion Logic
        if (bucket == 'Out of Bucket') return false;
        if (category == 'Non-Calculated Expense') return false;
        if (category == 'Non-Calculated Income') return false;

        return true;
      }).toList();
    }

    return combined;
  }

  @override
  Widget build(BuildContext context) {
    final String? fetchId = (_selectedAccountId == kGroupBanks ||
            _selectedAccountId == kGroupCredits)
        ? null
        : _selectedAccountId;

    return StreamBuilder<List<ExpenseTransactionModel>>(
      stream: _expenseService.getTransactions(accountId: fetchId),
      builder: (context, expenseSnapshot) {
        return StreamBuilder<List<CreditTransactionModel>>(
          stream: fetchId == null
              ? _creditService.getAllTransactions()
              : _creditService.getTransactionsForCard(fetchId),
          builder: (context, creditSnapshot) {
            if (!expenseSnapshot.hasData && !creditSnapshot.hasData) {
              return const SizedBox.shrink();
            }

            final expenses = expenseSnapshot.data ?? [];
            final credits = creditSnapshot.data ?? [];

            final transactions = _filterTransactions(expenses, credits);

            double income = 0;
            double expense = 0;

            for (var txn in transactions) {
              if (txn is ExpenseTransactionModel) {
                if (txn.type == 'Income') {
                  income += txn.amount;
                } else if (txn.type == 'Expense') {
                  expense += txn.amount;
                }
              } else if (txn is CreditTransactionModel) {
                if (txn.type == 'Expense') {
                  expense += txn.amount;
                } else if (txn.type == 'Income') {
                  // Allow credit income (like cashback) BUT exclude bill repayments
                  final cat = txn.category.toLowerCase();
                  if (cat != 'repayment' && cat != 'payment') {
                    income += txn.amount;
                  }
                }
              }
            }

            final double netFlow = income - expense;
            final double maxValue = (income > expense ? income : expense);
            final double safeMax = maxValue == 0 ? 1 : maxValue;

            final double incomeRatio = income / safeMax;
            final double expenseRatio = expense / safeMax;

            final currencyFmt = NumberFormat.currency(
              locale: 'en_IN',
              symbol: '₹',
              decimalDigits: 2,
            );

            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFF151D29),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white.withOpacity(0.08)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 15,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // --- HEADER WITH MODERN TOGGLE ---
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.05),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.analytics_outlined,
                                color: Colors.white70, size: 16),
                          ),
                          const SizedBox(width: 10),
                          const Text(
                            "CASH FLOW",
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.2,
                            ),
                          ),
                        ],
                      ),
                      _buildModernToggle(),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(child: _buildAccountFilter()),
                      const SizedBox(width: 8),
                      _buildPeriodDropdown(),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Income Meter
                  _buildMeterRow(
                    label: "INCOME",
                    amount: income,
                    ratio: incomeRatio,
                    color: const Color(0xFF00E676),
                    bgGradient: [
                      const Color(0xFF00E676),
                      const Color(0xFF69F0AE)
                    ],
                    formatter: currencyFmt,
                  ),
                  const SizedBox(height: 16),

                  // Expense Meter
                  _buildMeterRow(
                    label: "EXPENSE",
                    amount: expense,
                    ratio: expenseRatio,
                    color: const Color(0xFFFF4D6D),
                    bgGradient: [
                      const Color(0xFFFF4D6D),
                      const Color(0xFFC9184A)
                    ],
                    formatter: currencyFmt,
                  ),
                  const SizedBox(height: 20),
                  Divider(color: Colors.white.withOpacity(0.05), height: 1),
                  const SizedBox(height: 16),

                  // Net Position
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Net Position",
                        style: TextStyle(color: Colors.white54, fontSize: 13),
                      ),
                      Text(
                        "${netFlow >= 0 ? '+' : ''}${currencyFmt.format(netFlow)}",
                        style: TextStyle(
                          color: netFlow >= 0
                              ? const Color(0xFF00E676)
                              : const Color(0xFFFF4D6D),
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),

                  // --- DISCLAIMER SECTION ---
                  if (_isBudgetMode) ...[
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: const Color(0xFF00B4D8).withOpacity(0.08),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                            color: const Color(0xFF00B4D8).withOpacity(0.2)),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(Icons.info_outline_rounded,
                              color: Color(0xFF00B4D8), size: 14),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              "Budget Mode active. Excludes 'Non-Calculated' expenses/income and 'Out of Bucket' transactions.",
                              style: TextStyle(
                                color: const Color(0xFF00B4D8).withOpacity(0.9),
                                fontSize: 10,
                                height: 1.3,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildModernToggle() {
    return GestureDetector(
      onTap: () {
        setState(() => _isBudgetMode = !_isBudgetMode);
      },
      behavior: HitTestBehavior.opaque,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            "Budget Mode",
            style: TextStyle(
              color: _isBudgetMode ? const Color(0xFF00B4D8) : Colors.white38,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(width: 8),
          AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeInOut,
            width: 40,
            height: 22,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              color: _isBudgetMode
                  ? const Color(0xFF00B4D8).withOpacity(0.2)
                  : Colors.white.withOpacity(0.1),
              border: Border.all(
                color: _isBudgetMode
                    ? const Color(0xFF00B4D8)
                    : Colors.white.withOpacity(0.2),
                width: 1,
              ),
            ),
            child: Stack(
              children: [
                AnimatedPositioned(
                  duration: const Duration(milliseconds: 250),
                  curve: Curves.easeOutBack,
                  left: _isBudgetMode ? 20 : 2,
                  top: 2,
                  bottom: 2,
                  child: Container(
                    width: 16,
                    height: 16,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _isBudgetMode
                          ? const Color(0xFF00B4D8)
                          : Colors.white38,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 2,
                          offset: const Offset(0, 1),
                        )
                      ],
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

  Widget _buildAccountFilter() {
    return StreamBuilder<List<ExpenseAccountModel>>(
      stream: _expenseService.getAccounts(),
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

              return GestureDetector(
                onTap: () => _showAccountSelectionSheet(accounts, cards),
                child: Container(
                  height: 32,
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: Colors.white.withOpacity(0.1)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          _getAccountDisplayText(
                              _selectedAccountId, accounts, cards),
                          style: const TextStyle(
                              color: Colors.white, fontSize: 12),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const Icon(Icons.keyboard_arrow_down_rounded,
                          color: Colors.white54, size: 16),
                    ],
                  ),
                ),
              );
            });
      },
    );
  }

  Widget _buildMeterRow({
    required String label,
    required double amount,
    required double ratio,
    required Color color,
    required List<Color> bgGradient,
    required NumberFormat formatter,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label,
                style: TextStyle(
                    color: Colors.white.withOpacity(0.5),
                    fontSize: 11,
                    fontWeight: FontWeight.w600)),
            Text(
              formatter.format(amount),
              style: TextStyle(
                  color: color, fontSize: 13, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Container(
          height: 8,
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(4),
          ),
          child: FractionallySizedBox(
            alignment: Alignment.centerLeft,
            widthFactor: ratio.clamp(0.0, 1.0),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 500),
              curve: Curves.easeOutCubic,
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: bgGradient),
                borderRadius: BorderRadius.circular(2),
                boxShadow: [
                  BoxShadow(
                    color: bgGradient.first.withOpacity(0.4),
                    blurRadius: 4,
                    offset: const Offset(0, 1),
                  )
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPeriodDropdown() {
    return GestureDetector(
      onTap: _showPeriodSelectionSheet,
      child: Container(
        height: 32,
        padding: const EdgeInsets.symmetric(horizontal: 10),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(4),
          border: Border.all(color: Colors.white.withOpacity(0.1)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              _selectedPeriod,
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w500),
            ),
            const SizedBox(width: 4),
            const Icon(Icons.keyboard_arrow_down_rounded,
                color: Colors.white54, size: 16),
          ],
        ),
      ),
    );
  }

  // ===========================================================================
  // --- BOTTOM SHEETS & LIST HELPERS ---
  // ===========================================================================

  String _getAccountDisplayText(String? id, List<ExpenseAccountModel> accounts,
      List<CreditCardModel> cards) {
    if (id == null) return "All Accounts";
    if (id == kGroupBanks) return "All Bank Accounts";
    if (id == kGroupCredits) return "All Credit Cards";

    final acc = accounts.firstWhereOrNull((a) => a.id == id);
    if (acc != null) return "${acc.name} (${acc.bankName})";

    final card = cards.firstWhereOrNull((c) => c.id == id);
    if (card != null) return "${card.name} (${card.bankName})";

    return "Unknown Account";
  }

  Widget _buildEnhancedListTile({
    required String title,
    required bool isSelected,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFF00B4D8).withOpacity(0.15)
              : Colors.white.withOpacity(0.03),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected
                ? const Color(0xFF00B4D8).withOpacity(0.5)
                : Colors.white.withOpacity(0.05),
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: isSelected ? const Color(0xFF00B4D8) : Colors.white38,
              size: 20,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  color: isSelected ? Colors.white : Colors.white70,
                  fontSize: 14,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                ),
              ),
            ),
            if (isSelected)
              const Icon(Icons.check_circle_rounded,
                  color: Color(0xFF00B4D8), size: 20)
            else
              const Icon(Icons.circle_outlined,
                  color: Colors.white12, size: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildAccountListHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 16, 4, 8),
      child: Text(
        title,
        style: const TextStyle(
          color: Colors.white38,
          fontSize: 11,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.5,
        ),
      ),
    );
  }

  void _showPeriodSelectionSheet() {
    final periods = [
      'This Month',
      'Last Month',
      'This Year',
      'Last Year',
      'All Time'
    ];

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding:
              EdgeInsets.only(bottom: MediaQuery.of(context).padding.bottom),
          decoration: BoxDecoration(
            color: const Color(0xFF151D29).withOpacity(0.9),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            border:
                Border(top: BorderSide(color: Colors.white.withOpacity(0.1))),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 12),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 20, 24, 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "Select Period",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.05),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.close,
                            color: Colors.white54, size: 18),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: periods.map((p) {
                    return _buildEnhancedListTile(
                      title: p,
                      isSelected: _selectedPeriod == p,
                      icon: Icons.calendar_today_rounded,
                      onTap: () {
                        setState(() => _selectedPeriod = p);
                        Navigator.pop(context);
                      },
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  void _showAccountSelectionSheet(
      List<ExpenseAccountModel> accounts, List<CreditCardModel> cards) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: DraggableScrollableSheet(
            initialChildSize: 0.6,
            minChildSize: 0.4,
            maxChildSize: 0.9,
            builder: (_, controller) {
              return Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF151D29).withOpacity(0.9),
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(24)),
                  border: Border(
                      top: BorderSide(color: Colors.white.withOpacity(0.1))),
                ),
                child: Column(
                  children: [
                    const SizedBox(height: 12),
                    Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.white24,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(24, 20, 24, 8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            "Select Account",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          GestureDetector(
                            onTap: () => Navigator.pop(context),
                            child: Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.05),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.close,
                                  color: Colors.white54, size: 18),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: ListView(
                        controller: controller,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 8),
                        children: [
                          _buildEnhancedListTile(
                            title: "All Accounts",
                            isSelected: _selectedAccountId == null,
                            icon: Icons.account_balance_wallet_rounded,
                            onTap: () {
                              setState(() => _selectedAccountId = null);
                              Navigator.pop(context);
                            },
                          ),
                          if (accounts.isNotEmpty) ...[
                            _buildAccountListHeader("BANK ACCOUNTS"),
                            _buildEnhancedListTile(
                              title: "All Bank Accounts",
                              isSelected: _selectedAccountId == kGroupBanks,
                              icon: Icons.account_balance_rounded,
                              onTap: () {
                                setState(
                                    () => _selectedAccountId = kGroupBanks);
                                Navigator.pop(context);
                              },
                            ),
                            ...accounts.map((acc) => _buildEnhancedListTile(
                                  title: "${acc.name} (${acc.bankName})",
                                  isSelected: _selectedAccountId == acc.id,
                                  icon: Icons.account_balance_rounded,
                                  onTap: () {
                                    setState(() => _selectedAccountId = acc.id);
                                    Navigator.pop(context);
                                  },
                                )),
                          ],
                          if (cards.isNotEmpty) ...[
                            _buildAccountListHeader("CREDIT CARDS"),
                            _buildEnhancedListTile(
                              title: "All Credit Cards",
                              isSelected: _selectedAccountId == kGroupCredits,
                              icon: Icons.credit_card_rounded,
                              onTap: () {
                                setState(
                                    () => _selectedAccountId = kGroupCredits);
                                Navigator.pop(context);
                              },
                            ),
                            ...cards.map((card) => _buildEnhancedListTile(
                                  title: "${card.name} (${card.bankName})",
                                  isSelected: _selectedAccountId == card.id,
                                  icon: Icons.credit_card_rounded,
                                  onTap: () {
                                    setState(
                                        () => _selectedAccountId = card.id);
                                    Navigator.pop(context);
                                  },
                                )),
                          ],
                          const SizedBox(height: 40),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }
}
