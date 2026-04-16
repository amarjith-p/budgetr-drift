import 'package:budget/core/design/budgetr_colors.dart';
import 'package:budget/core/widgets/status_bottom_sheet.dart';
import 'package:budget/features/investments/models/investment_log_dto.dart';
import 'package:budget/features/investments/services/portfolio_service.dart';
import 'package:budget/features/investments/widgets/log_transaction_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:get_it/get_it.dart';
import 'package:intl/intl.dart';

class InvestmentHistoryList extends StatefulWidget {
  final List<InvestmentLogDto> logs;
  final bool isClosed; // [NEW] Added to manage read-only state

  const InvestmentHistoryList({
    super.key,
    required this.logs,
    this.isClosed = false,
  });

  @override
  State<InvestmentHistoryList> createState() => _InvestmentHistoryListState();
}

class _InvestmentHistoryListState extends State<InvestmentHistoryList> {
  int _displayLimit = 5;

  String _formatAmount(double amount, {bool showPlusSign = false}) {
    final format =
        NumberFormat.currency(locale: 'en_IN', symbol: '₹ ', decimalDigits: 2);
    final formattedStr = format.format(amount.abs());

    if (amount < 0) {
      return "-$formattedStr";
    } else if (showPlusSign && amount > 0) {
      return "+$formattedStr";
    }
    return formattedStr;
  }

  @override
  Widget build(BuildContext context) {
    if (widget.logs.isEmpty) {
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

    final displayedLogs = widget.logs.take(_displayLimit).toList();
    final hasMore = widget.logs.length > _displayLimit;

    return Column(
      children: [
        SlidableAutoCloseBehavior(
          child: ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: displayedLogs.length,
            itemBuilder: (context, index) {
              final log = displayedLogs[index];
              final isInvested = log.type == 'invested';
              final isWithdrawal = log.type == 'withdrawn';
              final isValueUpdate = log.type == 'valueUpdate';

              // [NEW] Identify if this is the concluding transaction of a closed asset
              final isClosureLog = widget.isClosed && index == 0;

              double incrementalChange = 0.0;
              if (isValueUpdate || isClosureLog) {
                if (index < widget.logs.length - 1) {
                  incrementalChange =
                      log.currentValue - widget.logs[index + 1].currentValue;
                } else {
                  incrementalChange = log.gainLoss;
                }
              }

              // [NEW] The inner row widget
              Widget listItem = Container(
                padding:
                    const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                decoration: BoxDecoration(
                  color: Colors.transparent,
                  border: Border(
                      bottom:
                          BorderSide(color: Colors.white.withOpacity(0.05))),
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
                            isClosureLog
                                ? "Asset Closed"
                                : (isWithdrawal
                                    ? "Capital Withdrawn"
                                    : (isInvested
                                        ? "Investment Added"
                                        : "Market Valuation")),
                            style: TextStyle(
                                color: isClosureLog
                                    ? BudgetrColors.success
                                    : Colors.white,
                                fontWeight: FontWeight.w500),
                          ),
                          Text(
                            isClosureLog
                                ? "Final Realized Value"
                                : (isWithdrawal
                                    ? "Payout"
                                    : (isInvested
                                        ? "SIP / Lumpsum"
                                        : "Gain/Loss Updated")),
                            style: TextStyle(
                                color: isClosureLog
                                    ? BudgetrColors.success.withOpacity(0.5)
                                    : Colors.white.withOpacity(0.4),
                                fontSize: 11),
                          ),
                        ],
                      ),
                    ),

                    // Amount / Gain
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        if (isValueUpdate || isClosureLog) ...[
                          Text(
                            _formatAmount(log.currentValue),
                            style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 13),
                          ),
                          const SizedBox(height: 4),
                          // Total Gain
                          Text(
                            "Total: ${_formatAmount(log.gainLoss, showPlusSign: true)}",
                            style: TextStyle(
                              color: log.gainLoss >= 0
                                  ? BudgetrColors.success
                                  : BudgetrColors.error,
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          // Incremental Change Pill
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 4, vertical: 2),
                            decoration: BoxDecoration(
                              color: (incrementalChange >= 0
                                      ? BudgetrColors.success
                                      : BudgetrColors.error)
                                  .withOpacity(0.1),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  incrementalChange >= 0
                                      ? Icons.arrow_upward_rounded
                                      : Icons.arrow_downward_rounded,
                                  size: 10,
                                  color: incrementalChange >= 0
                                      ? BudgetrColors.success
                                      : BudgetrColors.error,
                                ),
                                const SizedBox(width: 2),
                                Text(
                                  _formatAmount(incrementalChange.abs()),
                                  style: TextStyle(
                                    color: incrementalChange >= 0
                                        ? BudgetrColors.success
                                        : BudgetrColors.error,
                                    fontSize: 9,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ] else ...[
                          // Invested OR Withdrawn
                          Text(
                            _formatAmount(log.amountInvested,
                                showPlusSign: !isWithdrawal),
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
              );

              // [NEW] If the asset is closed, bypass the Slidable wrapper entirely to prevent edits/deletes
              if (widget.isClosed) {
                return listItem;
              }

              return Slidable(
                key: ValueKey(log.id),
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
                child: listItem,
              );
            },
          ),
        ),
        if (hasMore)
          Padding(
            padding: const EdgeInsets.only(top: 16.0, bottom: 8.0),
            child: TextButton.icon(
              onPressed: () {
                setState(() {
                  _displayLimit += 5;
                });
              },
              icon: const Icon(Icons.keyboard_arrow_down_rounded,
                  color: BudgetrColors.accent),
              label: const Text(
                "Show Older History",
                style: TextStyle(
                  color: BudgetrColors.accent,
                  fontWeight: FontWeight.bold,
                ),
              ),
              style: TextButton.styleFrom(
                backgroundColor: BudgetrColors.accent.withOpacity(0.1),
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
      ],
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
      onCancel: () {},
      onDismiss: () async {
        await GetIt.I<PortfolioService>().deleteTransaction(transactionId);
      },
    );
  }

  void _showEditSheet(BuildContext context, InvestmentLogDto log) {
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
