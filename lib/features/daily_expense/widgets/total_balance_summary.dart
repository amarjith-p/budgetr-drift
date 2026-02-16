import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/expense_models.dart';

class TotalBalanceSummary extends StatefulWidget {
  final List<ExpenseAccountModel> accounts;

  const TotalBalanceSummary({super.key, required this.accounts});

  @override
  State<TotalBalanceSummary> createState() => _TotalBalanceSummaryState();
}

class _TotalBalanceSummaryState extends State<TotalBalanceSummary> {
  // MODIFIED: Privacy by default (Blur initially)
  bool _isObscured = true;

  @override
  Widget build(BuildContext context) {
    // Calculate Total
    final double totalBalance = widget.accounts.fold(
      0.0,
      (sum, account) => sum + account.currentBalance,
    );

    final currency = NumberFormat.currency(
      locale: 'en_IN',
      symbol: '₹',
      decimalDigits: 2,
    );

    return Container(
      width: double.infinity,
      // subtle border at bottom to separate from list
      decoration: BoxDecoration(
        color: const Color(0xff0D1B2A), // Matches Scaffold background
        border: Border(
          bottom: BorderSide(
            color: Colors.white.withOpacity(0.05),
            width: 1,
          ),
        ),
      ),
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row with Label + Privacy Toggle
          Row(
            children: [
              Text(
                "TOTAL LIQUIDITY",
                style: TextStyle(
                  color: const Color(0xFF00B4D8), // Cyan Accent
                  fontSize: 11,
                  letterSpacing: 1.5,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const Spacer(),
              InkWell(
                onTap: () => setState(() => _isObscured = !_isObscured),
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  padding: const EdgeInsets.fromLTRB(12, 6, 12, 6),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        _isObscured
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined,
                        color: _isObscured
                            ? Colors.white54
                            : const Color(0xFF00B4D8),
                        size: 16,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        _isObscured ? "SHOW" : "HIDE",
                        style: TextStyle(
                          color: _isObscured
                              ? Colors.white54
                              : const Color(0xFF00B4D8),
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // The Big Number
          AnimatedCrossFade(
            firstChild: Text(
              currency.format(totalBalance),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 36,
                height: 1.1,
                fontWeight: FontWeight.w300, // Modern thin/light look
                letterSpacing: -1.0,
              ),
            ),
            secondChild: Text(
              "₹ ${"*" * totalBalance.toStringAsFixed(2).length}",
              style: TextStyle(
                color: Colors.white.withOpacity(0.5),
                fontSize: 36,
                height: 1.1,
                fontWeight: FontWeight.w300,
                letterSpacing: -1.0,
              ),
            ),
            crossFadeState: _isObscured
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 200),
          ),
        ],
      ),
    );
  }
}
