import 'package:budget/core/design/budgetr_colors.dart';
import 'package:budget/core/widgets/status_bottom_sheet.dart';
import 'package:budget/features/investments/models/investment_log_dto.dart';
import 'package:budget/features/investments/services/portfolio_service.dart';
import 'package:budget/features/investments/widgets/log_transaction_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart'; // [NEW IMPORT]
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

    // [NEW] Wraps the list to ensure only one slidable item is open at a time
    return SlidableAutoCloseBehavior(
      child: ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: logs.length,
        itemBuilder: (context, index) {
          final log = logs[index];
          final isInvested = log.type == 'invested';
          final isWithdrawal = log.type == 'withdrawn';
          final isValueUpdate = log.type == 'valueUpdate';

          return Slidable(
            key: ValueKey(log.id),

            // --- SWIPE RIGHT: EDIT ACTION ---
            startActionPane: ActionPane(
              motion: const ScrollMotion(),
              extentRatio: 0.25,
              children: [
                SlidableAction(
                  onPressed: (_) => _showEditSheet(context, log),
                  backgroundColor: Colors.blueAccent,
                  foregroundColor: Colors.white,
                  icon: Icons.edit_rounded,
                  label: 'Edit',
                ),
              ],
            ),

            // --- SWIPE LEFT: DELETE ACTION ---
            endActionPane: ActionPane(
              motion: const ScrollMotion(),
              extentRatio: 0.25,
              children: [
                SlidableAction(
                  onPressed: (_) => _showDeleteSheet(context, log.id),
                  backgroundColor: const Color(0xFFFE4A49),
                  foregroundColor: Colors.white,
                  icon: Icons.delete_rounded,
                  label: 'Delete',
                ),
              ],
            ),

            // --- MAIN CONTENT ---
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.transparent,
                border: Border(
                    bottom: BorderSide(color: Colors.white.withOpacity(0.05))),
              ),
              child: Row(
                children: [
                  // Date
                  Container(
                    width: 40,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: const EdgeInsets.all(4),
                    child: Column(
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
                            fontSize: 8,
                            fontWeight: FontWeight.normal,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),

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
                              color: Colors.white.withOpacity(0.4),
                              fontSize: 11),
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
      ),
    );
  }

  void _showDeleteSheet(BuildContext context, int transactionId) {
    showStatusSheet(
      context: context,
      title: "Delete Record?",
      message:
          "This will remove this transaction and recalculate your portfolio balance.",
      icon: Icons.delete_forever_rounded,
      color: Colors.redAccent,
      buttonText: "Delete",
      cancelButtonText: "Cancel",
      onCancel: () {}, // Just closes sheet
      onDismiss: () async {
        // Perform deletion
        await GetIt.I<PortfolioService>().deleteTransaction(transactionId);
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
