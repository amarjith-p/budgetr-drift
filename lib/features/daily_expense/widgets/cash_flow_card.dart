import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../core/widgets/modern_loader.dart';
import '../models/expense_models.dart';
import '../services/expense_service.dart';

class CashFlowCard extends StatefulWidget {
  const CashFlowCard({super.key});

  @override
  State<CashFlowCard> createState() => _CashFlowCardState();
}

class _CashFlowCardState extends State<CashFlowCard> {
  final ExpenseService _service = ExpenseService();
  String _selectedPeriod = 'This Month';
  String? _selectedAccountId; // Account Filter State

  // Helper: Filter Transactions by Date
  List<ExpenseTransactionModel> _filterTransactions(
      List<ExpenseTransactionModel> allTxns) {
    final now = DateTime.now();
    return allTxns.where((txn) {
      final date = txn.date.toDate();
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
      return true; // All Time
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<ExpenseTransactionModel>>(
      // Uses optimized server-side filtering
      stream: _service.getTransactions(accountId: _selectedAccountId),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const SizedBox.shrink();

        final transactions = _filterTransactions(snapshot.data!);

        double income = 0;
        double expense = 0;

        for (var txn in transactions) {
          if (txn.type == 'Income') {
            income += txn.amount;
          } else if (txn.type == 'Expense') {
            expense += txn.amount;
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
            borderRadius: BorderRadius.circular(24),
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
              // --- HEADER SECTION (Reorganized) ---

              // 1. Title Row
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
              const SizedBox(height: 16),

              // 2. Filters Row (Separate line for better visibility)
              Row(
                children: [
                  // Account Filter (Expanded to take available width)
                  Expanded(child: _buildAccountFilter()),
                  const SizedBox(width: 8),
                  // Period Filter
                  _buildPeriodDropdown(),
                ],
              ),
              const SizedBox(height: 24),

              // --- VISUAL METERS ---
              _buildMeterRow(
                label: "INCOME",
                amount: income,
                ratio: incomeRatio,
                color: const Color(0xFF00E676),
                bgGradient: [const Color(0xFF00E676), const Color(0xFF69F0AE)],
                formatter: currencyFmt,
              ),
              const SizedBox(height: 16),
              _buildMeterRow(
                label: "EXPENSE",
                amount: expense,
                ratio: expenseRatio,
                color: const Color(0xFFFF4D6D),
                bgGradient: [const Color(0xFFFF4D6D), const Color(0xFFC9184A)],
                formatter: currencyFmt,
              ),

              const SizedBox(height: 20),
              Divider(color: Colors.white.withOpacity(0.05), height: 1),
              const SizedBox(height: 16),

              // --- NET FLOW FOOTER ---
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
            ],
          ),
        );
      },
    );
  }

  // --- Widgets ---

  Widget _buildAccountFilter() {
    return StreamBuilder<List<ExpenseAccountModel>>(
      stream: _service.getAccounts(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const SizedBox();

        final accounts = snapshot.data!;
        if (_selectedAccountId != null &&
            !accounts.any((a) => a.id == _selectedAccountId)) {
          _selectedAccountId = null;
        }

        return Container(
          height: 32, // Slightly taller for better touch target
          padding: const EdgeInsets.symmetric(horizontal: 10),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(8),
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
              isExpanded: true, // Ensures it uses the Expanded space
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
                ...accounts.map((acc) => DropdownMenuItem(
                      value: acc.id,
                      child: Text(
                        "${acc.name} - ${acc.bankName}",
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
                borderRadius: BorderRadius.circular(4),
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
        borderRadius: BorderRadius.circular(8),
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
