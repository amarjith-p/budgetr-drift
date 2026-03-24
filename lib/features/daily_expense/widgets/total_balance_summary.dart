import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import '../models/expense_models.dart';
import 'balance_calculator_sheet.dart';

class TotalBalanceSummary extends StatefulWidget {
  final List<ExpenseAccountModel> accounts;

  const TotalBalanceSummary({
    super.key,
    required this.accounts,
  });

  @override
  State<TotalBalanceSummary> createState() => _TotalBalanceSummaryState();
}

class _TotalBalanceSummaryState extends State<TotalBalanceSummary> {
  bool _isObscured = true;

  @override
  Widget build(BuildContext context) {
    final double totalBalance = widget.accounts.fold(
      0.0,
      (sum, account) => sum + account.currentBalance,
    );

    final currency = NumberFormat.currency(
      locale: 'en_IN',
      symbol: '₹',
      decimalDigits: 2,
    );

    final formattedTotal = currency.format(totalBalance);
    final symbol = formattedTotal.substring(0, 1);
    final value = formattedTotal.substring(1);

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.03),
        borderRadius:
            BorderRadius.circular(8), // Slightly adjusted for better aesthetics
        border: Border.all(color: Colors.white.withOpacity(0.06)),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(18, 16, 18, 18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- TOP ROW: Minimal Header & Action Pills ---
            Row(
              children: [
                Text(
                  "TOTAL BALANCE",
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 10,
                    letterSpacing: 2.0,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const Spacer(),
                _buildHeaderAction(
                  icon: Icons.calculate_outlined,
                  onTap: () {
                    HapticFeedback.lightImpact();
                    showModalBottomSheet(
                      context: context,
                      backgroundColor: Colors.transparent,
                      isScrollControlled: true,
                      builder: (ctx) =>
                          BalanceCalculatorSheet(accounts: widget.accounts),
                    );
                  },
                ),
                const SizedBox(width: 8),
                _buildHeaderAction(
                  icon: _isObscured
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
                  active: !_isObscured,
                  onTap: () => setState(() => _isObscured = !_isObscured),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // --- BOTTOM SECTION: The Balance Presentation ---
            // Added SizedOverflowBox or constrained height to ensure consistency
            SizedBox(
              width: double.infinity,
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                transitionBuilder: (child, animation) => FadeTransition(
                  opacity: animation,
                  child: child,
                ),
                child: _isObscured
                    ? Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          "₹ ••••••••",
                          key: const ValueKey('obscured'),
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.8),
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 2,
                          ),
                        ),
                      )
                    : Align(
                        alignment: Alignment.centerLeft,
                        // --- [FIX] FittedBox prevents overflow by scaling down the text ---
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: RichText(
                            key: const ValueKey('visible'),
                            text: TextSpan(
                              children: [
                                TextSpan(
                                  text: symbol,
                                  style: TextStyle(
                                    color: const Color(0xFF00B4D8)
                                        .withOpacity(0.8),
                                    fontSize: 24,
                                    fontWeight: FontWeight.w300,
                                  ),
                                ),
                                const TextSpan(text: " "),
                                TextSpan(
                                  text: value,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 24,
                                    fontWeight: FontWeight.w600,
                                    letterSpacing: -0.5,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              "Linked across ${widget.accounts.length} accounts",
              style: TextStyle(
                color: Colors.white.withOpacity(0.2),
                fontSize: 11,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderAction(
      {required IconData icon,
      required VoidCallback onTap,
      bool active = false}) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: active
              ? const Color(0xFF00B4D8).withOpacity(0.15)
              : Colors.white.withOpacity(0.05),
          shape: BoxShape.circle,
        ),
        child: Icon(
          icon,
          color:
              active ? const Color(0xFF00B4D8) : Colors.white.withOpacity(0.4),
          size: 18,
        ),
      ),
    );
  }
}
