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
      }
      return true; // All Time
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<ExpenseTransactionModel>>(
      stream: _service.getAllTransactions(),
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
        // Avoid division by zero
        final double maxValue = (income > expense ? income : expense);
        final double safeMax = maxValue == 0 ? 1 : maxValue;

        final double incomeRatio = income / safeMax;
        final double expenseRatio = expense / safeMax;

        // Formatter with 2 decimal places
        final currencyFmt = NumberFormat.currency(
          locale: 'en_IN',
          symbol: '₹',
          decimalDigits: 2,
        );

        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFF151D29),
            borderRadius: BorderRadius.circular(20),
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
              // --- Header ---
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.05),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.analytics_outlined,
                            color: Colors.white70, size: 14),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        "CASH FLOW • ${_selectedPeriod.toUpperCase()}",
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.0,
                        ),
                      ),
                    ],
                  ),
                  _buildPeriodDropdown(),
                ],
              ),
              const SizedBox(height: 16),

              // --- Visual Meters ---
              _buildMeterRow(
                label: "INCOME",
                amount: income,
                ratio: incomeRatio,
                color: const Color(0xFF00E676), // Neon Green
                bgGradient: [const Color(0xFF00E676), const Color(0xFF69F0AE)],
                formatter: currencyFmt,
              ),
              const SizedBox(height: 12),
              _buildMeterRow(
                label: "EXPENSE",
                amount: expense,
                ratio: expenseRatio,
                color: const Color(0xFFFF4D6D), // Red/Pink
                bgGradient: [const Color(0xFFFF4D6D), const Color(0xFFC9184A)],
                formatter: currencyFmt,
              ),

              const SizedBox(height: 16),
              Divider(color: Colors.white.withOpacity(0.05), height: 1),
              const SizedBox(height: 12),

              // --- Net Flow Footer ---
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Net Position",
                    style: TextStyle(color: Colors.white54, fontSize: 12),
                  ),
                  Text(
                    "${netFlow >= 0 ? '+' : ''}${currencyFmt.format(netFlow)}",
                    style: TextStyle(
                      color: netFlow >= 0
                          ? const Color(0xFF00E676)
                          : const Color(0xFFFF4D6D),
                      fontSize: 14,
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
                    fontSize: 10,
                    fontWeight: FontWeight.w600)),
            Text(
              formatter.format(amount),
              style: TextStyle(
                  color: color, fontSize: 12, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Container(
          height: 6,
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(3),
          ),
          child: FractionallySizedBox(
            alignment: Alignment.centerLeft,
            widthFactor: ratio.clamp(0.0, 1.0),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 500),
              curve: Curves.easeOutCubic,
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: bgGradient),
                borderRadius: BorderRadius.circular(3),
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
      height: 24,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(6),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _selectedPeriod,
          dropdownColor: const Color(0xFF1B263B),
          icon: const Icon(Icons.keyboard_arrow_down,
              color: Colors.white54, size: 14),
          style: const TextStyle(color: Colors.white, fontSize: 10),
          isDense: true,
          items: ['This Month', 'Last Month', 'This Year', 'All Time']
              .map((e) => DropdownMenuItem(value: e, child: Text(e)))
              .toList(),
          onChanged: (val) {
            if (val != null) setState(() => _selectedPeriod = val);
          },
        ),
      ),
    );
  }
}
