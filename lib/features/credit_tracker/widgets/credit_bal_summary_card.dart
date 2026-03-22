import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import '../../daily_expense/models/expense_models.dart';

class CreditSummaryCard extends StatelessWidget {
  final double totalPayable;
  final double totalSurplus;
  final List<ExpenseAccountModel> linkedAccounts;
  final NumberFormat currencyFormat;
  final VoidCallback onLinkAccountTapped;

  const CreditSummaryCard({
    super.key,
    required this.totalPayable,
    required this.totalSurplus,
    required this.linkedAccounts,
    required this.currencyFormat,
    required this.onLinkAccountTapped,
  });

  @override
  Widget build(BuildContext context) {
    // 1. Calculate debt values & handle 0.00 properly
    bool hasDebt = totalPayable > 0.01;
    bool hasSurplus = totalSurplus > 0.01;

    // [FIX 1] Handle zero-balance correctly to avoid "-0.00"
    String debtLabel = hasDebt
        ? "TOTAL PAYABLE"
        : (hasSurplus ? "TOTAL SURPLUS" : "TOTAL PAYABLE");
    double displayedDebt =
        hasDebt ? totalPayable : (hasSurplus ? totalSurplus : 0.0);

    // [FIX 2] Total Payable in Red, Surplus in Blue, 0.00 in White
    Color debtColor = hasDebt
        ? const Color(0xFFE71D36) // Red for Debt
        : (hasSurplus ? const Color(0xFF4CC9F0) : Colors.white);

    // Sum up balances across multiple accounts
    double allocatedFunds =
        linkedAccounts.fold(0.0, (sum, acc) => sum + acc.currentBalance);

    // Calculate difference
    double difference = allocatedFunds - totalPayable;
    bool isShortfall = difference <= -0.000001 && hasDebt;
    String statusLabel = isShortfall ? "Shortfall" : "Fully Funded";
    Color statusColor =
        isShortfall ? const Color(0xFFE71D36) : const Color(0xFF06D6A0);

    // Determine subtitle text based on selection count
    String accountText = "Tap to link bank accounts";
    if (linkedAccounts.length == 1) {
      accountText =
          "${linkedAccounts.first.bankName} - ${linkedAccounts.first.name}";
    } else if (linkedAccounts.length > 1) {
      accountText = "${linkedAccounts.length} Accounts Linked";
    }

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1B263B), Color(0xFF0D1B2A)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.1), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          // ROW 1: Total Payable
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  debtLabel,
                  style: const TextStyle(
                    color: Colors.white54,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.5,
                  ),
                ),
                Text(
                  currencyFormat.format(displayedDebt),
                  style: TextStyle(
                    color: debtColor,
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
          ),

          Divider(height: 1, color: Colors.white.withOpacity(0.05)),

          // ROW 2: Allocated Funds (Bank Account)
          InkWell(
            onTap: onLinkAccountTapped,
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const FaIcon(FontAwesomeIcons.chessKnight,
                        color: Color(0xFF4CC9F0), size: 16),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text("Allocated Fund Reserve",
                            style:
                                TextStyle(color: Colors.white70, fontSize: 13)),
                        const SizedBox(height: 2),
                        Text(
                          accountText,
                          style: TextStyle(
                            color: linkedAccounts.isNotEmpty
                                ? Colors.white54
                                : const Color(0xFF4CC9F0),
                            fontSize: 11,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  Row(
                    children: [
                      Text(
                        currencyFormat.format(allocatedFunds),
                        // [FIX 3] Allocated Funds explicitly set to Green
                        style: const TextStyle(
                            color: Color(0xFF06D6A0),
                            fontSize: 16,
                            fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(width: 8),
                      const Icon(Icons.edit_rounded,
                          color: Colors.white38, size: 14),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // Only show Status Row if at least one account is linked
          if (linkedAccounts.isNotEmpty) ...[
            Divider(height: 1, color: Colors.white.withOpacity(0.05)),
            // ROW 3: Status
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(
                          isShortfall
                              ? Icons.warning_rounded
                              : Icons.check_circle_rounded,
                          color: statusColor,
                          size: 16),
                      const SizedBox(width: 8),
                      Text(
                        "Status: $statusLabel",
                        style: const TextStyle(
                            color: Colors.white70, fontSize: 13),
                      ),
                    ],
                  ),
                  Text(
                    currencyFormat.format(difference.abs()),
                    style: TextStyle(
                      color: statusColor,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ]
        ],
      ),
    );
  }
}
