import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import '../models/expense_models.dart';

class BalanceCalculatorSheet extends StatefulWidget {
  final List<ExpenseAccountModel> accounts;
  const BalanceCalculatorSheet({super.key, required this.accounts});

  @override
  State<BalanceCalculatorSheet> createState() => _BalanceCalculatorSheetState();
}

class _BalanceCalculatorSheetState extends State<BalanceCalculatorSheet> {
  final Set<String> _selectedIds = {};

  @override
  Widget build(BuildContext context) {
    final currencyFmt =
        NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: 2);

    // Calculate total dynamically based on selection
    double totalBalance = 0.0;
    if (_selectedIds.isEmpty) {
      totalBalance = widget.accounts.fold(0.0, (s, a) => s + a.currentBalance);
    } else {
      totalBalance = widget.accounts
          .where((a) => _selectedIds.contains(a.id))
          .fold(0.0, (s, a) => s + a.currentBalance);
    }

    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
      child: Container(
        height: MediaQuery.of(context).size.height * 0.7, // 70% of screen
        decoration: BoxDecoration(
          color: const Color(0xFF151D29),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
          border: Border(top: BorderSide(color: Colors.white.withOpacity(0.1))),
        ),
        child: Column(
          children: [
            const SizedBox(height: 12),
            Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                    color: Colors.white24,
                    borderRadius: BorderRadius.circular(2))),
            const SizedBox(height: 16),

            // Sticky Header (Total)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    _selectedIds.isEmpty
                        ? "TOTAL LIQUIDITY (ALL)"
                        : "COMBINED BALANCE (${_selectedIds.length})",
                    style: TextStyle(
                        color: _selectedIds.isEmpty
                            ? Colors.white38
                            : Colors.orangeAccent,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.5),
                  ),
                  const SizedBox(height: 8),
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      currencyFmt.format(totalBalance),
                      style: TextStyle(
                          color: _selectedIds.isEmpty
                              ? Colors.white
                              : Colors.orangeAccent,
                          fontSize: 28,
                          fontWeight: FontWeight.w300,
                          letterSpacing: -1.0),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Divider(color: Colors.white10, height: 1),
                ],
              ),
            ),

            // List of Accounts
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 40),
                itemCount: widget.accounts.length,
                itemBuilder: (context, index) {
                  final account = widget.accounts[index];
                  final isSelected = _selectedIds.contains(account.id);

                  return GestureDetector(
                    onTap: () {
                      HapticFeedback.selectionClick();
                      setState(() {
                        if (isSelected)
                          _selectedIds.remove(account.id);
                        else
                          _selectedIds.add(account.id);
                      });
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 14),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? Colors.orangeAccent.withOpacity(0.1)
                            : Colors.white.withOpacity(0.03),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                            color: isSelected
                                ? Colors.orangeAccent.withOpacity(0.5)
                                : Colors.white.withOpacity(0.05)),
                      ),
                      child: Row(
                        children: [
                          Icon(
                              isSelected
                                  ? Icons.check_circle_rounded
                                  : Icons.radio_button_unchecked_rounded,
                              color: isSelected
                                  ? Colors.orangeAccent
                                  : Colors.white38,
                              size: 20),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(account.name,
                                    style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold)),
                                Text(account.bankName,
                                    style: const TextStyle(
                                        color: Colors.white54, fontSize: 11)),
                              ],
                            ),
                          ),
                          Text(currencyFmt.format(account.currentBalance),
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
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
