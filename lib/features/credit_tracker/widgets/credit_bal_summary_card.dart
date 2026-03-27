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

    // --- NEW: 3-STATE STATUS LOGIC ---
    double difference = allocatedFunds - totalPayable;

    String statusLabel;
    Color statusColor;
    IconData statusIcon;

    // Using 0.01 to avoid floating-point precision issues
    if (difference <= -0.01 && hasDebt) {
      statusLabel = "Shortfall";
      statusColor = const Color(0xFFE71D36); // Red
      statusIcon = Icons.warning_rounded;
    } else if (difference >= 0.01) {
      statusLabel = "Excess Reserve";
      statusColor = const Color(0xFF4CC9F0); // Blue (matches surplus)
      statusIcon = Icons.account_balance_wallet_rounded;
    } else {
      statusLabel = "Fully Funded";
      statusColor = const Color(0xFF06D6A0); // Green
      statusIcon = Icons.check_circle_rounded;
    }
    // ---------------------------------

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
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.white.withOpacity(0.3), width: 1),
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
                const SizedBox(width: 12), // Spacing guard
                // OVERFLOW FIX: Shrinks huge numbers instead of throwing error
                Flexible(
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerRight,
                    child: Text(
                      currencyFormat.format(displayedDebt),
                      style: TextStyle(
                        color: debtColor,
                        fontSize: 24,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
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
                  const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
              child: Row(
                children: [
                  // Container(
                  //   padding: const EdgeInsets.all(8),
                  //   decoration: BoxDecoration(
                  //     color: Colors.white.withOpacity(0.05),
                  //     borderRadius: BorderRadius.circular(8),
                  //   ),
                  //   child: const FaIcon(FontAwesomeIcons.chessKnight,
                  //       color: Color(0xFF4CC9F0), size: 16),
                  // ),
                  // const SizedBox(width: 12),

                  // This Expanded pushes the amount and icon completely to the right
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text("Allocated Fund Reserve",
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
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

                  const SizedBox(width: 12),

                  // No Flexible or FittedBox wrappers to prevent phantom blank space
                  Text(
                    currencyFormat.format(allocatedFunds),
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
                  // OVERFLOW FIX: Expanded around the left side text
                  Expanded(
                    child: Row(
                      children: [
                        Icon(
                          statusIcon,
                          color: statusColor,
                          size: 16,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            "Status: $statusLabel",
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                                color: Colors.white70, fontSize: 13),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12), // Spacing guard
                  // OVERFLOW FIX: Protects the difference amount
                  Flexible(
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerRight,
                      child: Text(
                        currencyFormat.format(difference.abs()),
                        style: TextStyle(
                          color: statusColor,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
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
