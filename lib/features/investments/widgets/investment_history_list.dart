import 'package:budget/core/design/budgetr_colors.dart';
import 'package:budget/features/investments/models/investment_log_dto.dart';
import 'package:budget/features/investments/services/portfolio_service.dart';
import 'package:budget/features/investments/widgets/log_transaction_sheet.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:intl/intl.dart';

class InvestmentHistoryList extends StatelessWidget {
  final List<InvestmentLogDto> logs;

  const InvestmentHistoryList({super.key, required this.logs});

  @override
  Widget build(BuildContext context) {
    if (logs.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Text(
            "No history recorded yet.",
            style: TextStyle(color: Colors.white.withOpacity(0.3)),
          ),
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: logs.length,
      itemBuilder: (context, index) {
        final log = logs[index];
        final isInvested = log.type == 'invested';
        final isWithdrawal = log.type == 'withdrawn';
        final isValueUpdate = log.type == 'valueUpdate';

        return Dismissible(
          key: ValueKey(log.id),
          direction: DismissDirection.horizontal,
          // --- SWIPE RIGHT TO EDIT ---
          background: Container(
            color: Colors.blueAccent.withOpacity(0.2),
            alignment: Alignment.centerLeft,
            padding: const EdgeInsets.only(left: 20),
            child: const Icon(Icons.edit, color: Colors.blueAccent),
          ),
          // --- SWIPE LEFT TO DELETE ---
          secondaryBackground: Container(
            color: Colors.redAccent.withOpacity(0.2),
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.only(right: 20),
            child: const Icon(Icons.delete, color: Colors.redAccent),
          ),
          confirmDismiss: (direction) async {
            if (direction == DismissDirection.endToStart) {
              // DELETE ACTION
              return await showDialog(
                context: context,
                builder: (ctx) => AlertDialog(
                  backgroundColor: const Color(0xFF1B263B),
                  title: const Text("Delete Log?",
                      style: TextStyle(color: Colors.white)),
                  content: const Text(
                    "This will remove this transaction record. Calculations will be updated.",
                    style: TextStyle(color: Colors.white70),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(ctx, false),
                      child: const Text("Cancel",
                          style: TextStyle(color: Colors.white54)),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(ctx, true),
                      child: const Text("Delete",
                          style: TextStyle(color: Colors.redAccent)),
                    ),
                  ],
                ),
              );
            } else {
              // EDIT ACTION
              _showEditSheet(context, log);
              return false; // Don't dismiss the row
            }
          },
          onDismissed: (direction) {
            if (direction == DismissDirection.endToStart) {
              GetIt.I<PortfolioService>().deleteTransaction(log.id);
            }
          },
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.transparent, // Needed for dismissal visual
              border: Border(
                  bottom: BorderSide(color: Colors.white.withOpacity(0.05))),
            ),
            child: Row(
              children: [
                // Date
                SizedBox(
                  width: 50,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        DateFormat('dd').format(log.date),
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      Text(
                        DateFormat('MMM').format(log.date).toUpperCase(),
                        style: const TextStyle(
                          color: Colors.white54,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        DateFormat('yyyy').format(log.date),
                        style: const TextStyle(
                          color: Colors.white54,
                          fontSize: 7,
                          fontWeight: FontWeight.normal,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),

                // Description
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isWithdrawal
                            ? "Capital Withdrawn"
                            : (isInvested
                                ? "Investment Added"
                                : "Market Valuation"),
                        style: const TextStyle(
                            color: Colors.white, fontWeight: FontWeight.w500),
                      ),
                      Text(
                        isWithdrawal
                            ? "Payout / Booking Profit"
                            : (isInvested
                                ? "SIP / Lumpsum"
                                : "Gain/Loss Updated"),
                        style: TextStyle(
                            color: Colors.white.withOpacity(0.4), fontSize: 11),
                      ),
                    ],
                  ),
                ),

                // Amount / Gain
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    if (isValueUpdate) ...[
                      Text(
                        "₹${log.currentValue.toStringAsFixed(2)}",
                        style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 12),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        "${log.gainLoss >= 0 ? '+' : ''}₹${log.gainLoss.toStringAsFixed(2)}",
                        style: TextStyle(
                          color: log.gainLoss >= 0
                              ? BudgetrColors.success
                              : BudgetrColors.error,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ] else ...[
                      // Invested OR Withdrawn
                      Text(
                        "${isWithdrawal ? '' : '+'}₹${log.amountInvested.toStringAsFixed(2)}",
                        style: TextStyle(
                          color: isWithdrawal
                              ? Colors.redAccent
                              : BudgetrColors.accent,
                          fontWeight: FontWeight.bold,
                        ),
                      )
                    ]
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showEditSheet(BuildContext context, InvestmentLogDto log) {
    // Determine type for sheet
    LogType initialType =
        log.type == 'valueUpdate' ? LogType.valueUpdate : LogType.invested;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => LogTransactionSheet(
        investmentId: log.investmentId,
        initialType: initialType,
        logToEdit: log,
      ),
    );
  }
}
