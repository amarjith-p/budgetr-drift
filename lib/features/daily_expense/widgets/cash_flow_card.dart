// lib/features/daily_expense/widgets/cash_flow_card.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
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
  final ExpenseService _expenseService = ExpenseService();
  final CreditService _creditService = CreditService();
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
          ? txn.date.toDate()
          : (txn as CreditTransactionModel).date.toDate();

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

    // --- 3. Filter by Budget Mode (NEW) ---
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
                borderRadius: BorderRadius.circular(16),
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
                      // Custom Budget Mode Toggle
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

  // --- NEW: Custom Modern Toggle Widget ---
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

              return Container(
                height: 32,
                padding: const EdgeInsets.symmetric(horizontal: 10),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: Colors.white.withOpacity(0.1)),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String?>(
                    value: _selectedAccountId,
                    dropdownColor: const Color(0xFF1B263B),
                    icon: const Icon(Icons.keyboard_arrow_down_rounded,
                        color: Colors.white54, size: 16),
                    style: const TextStyle(color: Colors.white, fontSize: 12),
                    isDense: true,
                    isExpanded: true,
                    hint: const Text(
                      "All Accounts",
                      style: TextStyle(color: Colors.white),
                      overflow: TextOverflow.ellipsis,
                    ),
                    items: [
                      const DropdownMenuItem<String?>(
                        value: null,
                        child: Text("All Accounts"),
                      ),
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
                              maxLines: 1,
                            ),
                          )),
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
                              maxLines: 1,
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
    return Container(
      height: 32,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _selectedPeriod,
          dropdownColor: const Color(0xFF1B263B),
          icon: const Icon(Icons.keyboard_arrow_down_rounded,
              color: Colors.white54, size: 16),
          style: const TextStyle(
              color: Colors.white, fontSize: 12, fontWeight: FontWeight.w500),
          isDense: true,
          items: [
            'This Month',
            'Last Month',
            'This Year',
            'Last Year',
            'All Time'
          ].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
          onChanged: (val) {
            if (val != null) setState(() => _selectedPeriod = val);
          },
        ),
      ),
    );
  }
}
