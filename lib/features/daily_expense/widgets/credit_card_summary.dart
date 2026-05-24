import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:get_it/get_it.dart';
import '../../../core/widgets/futuristic_loader.dart';
import '../../credit_tracker/services/credit_service.dart';
import '../../credit_tracker/models/credit_models.dart';

class CreditSummaryAnalyticsWidget extends StatefulWidget {
  const CreditSummaryAnalyticsWidget({super.key});

  @override
  State<CreditSummaryAnalyticsWidget> createState() =>
      _CreditSummaryAnalyticsWidgetState();
}

class _CreditSummaryAnalyticsWidgetState
    extends State<CreditSummaryAnalyticsWidget> {
  final CreditService _creditService = GetIt.I<CreditService>();
  bool _isExpanded = false;

  // --- COLORS ---
  final Color _goodColor = const Color(0xFF00E676);
  final Color _badColor = const Color(0xFFFF5252);
  final Color _accentColor = const Color(0xFF00B4D8);
  final Color _warningColor = Colors.orangeAccent;

  int _calculateDaysRemaining(int targetDay) {
    final now = DateTime.now();
    final today = now.day;
    if (targetDay >= today) {
      return targetDay - today;
    } else {
      final lastDayOfCurrentMonth = DateTime(now.year, now.month + 1, 0).day;
      return (lastDayOfCurrentMonth - today) + targetDay;
    }
  }

  bool _isOverdue(int billDate, int dueDate) {
    final today = DateTime.now().day;
    if (billDate < dueDate) {
      return today > dueDate;
    } else {
      return today > dueDate && today < billDate;
    }
  }

  (String, Color) _getCardStatus(double statementBalance,
      double unbilledBalance, int billDate, int dueDate) {
    if (statementBalance <= 0 && unbilledBalance <= 0) {
      return ('No Spend', Colors.white38);
    }
    // FIX: Statement Balance <= 0 means fully paid (even with surplus)
    else if (statementBalance <= 0) {
      return ('Paid', _goodColor);
    } else if (_isOverdue(billDate, dueDate)) {
      return ('Overdue', _badColor);
    }
    return ('Billed', _warningColor);
  }

  @override
  Widget build(BuildContext context) {
    final currencyFmt =
        NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: 2);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF151D29),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withOpacity(0.08)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.4),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: StreamBuilder<List<CreditCardDashboardData>>(
        stream: _creditService.getSmartCreditCardsDashboard(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const SizedBox(
              height: 120,
              child: Center(
                child: FuturisticLoader(
                    size: 60, label: "SYNCING CREDIT MATRIX..."),
              ),
            );
          }

          final cardsData = snapshot.data!;
          final totalCards = cardsData.length;

          // --- METRICS CALCULATION (FIXED) ---
          double totalPayable = 0.0; // The entire debt (matches main screen)
          double statementDue = 0.0; // Only the billed amount needing payment

          int overdueCount = 0;
          int billedCount = 0;
          int paidCount = 0;
          int noSpendCount = 0;

          for (var data in cardsData) {
            // 1. Matches CreditTrackerScreen exactly (Ignores surplus, sums all positive debt)
            if (data.card.currentBalance > 0) {
              totalPayable += data.card.currentBalance;
            }

            // 2. Calculates only what is billed and pending payment right now
            if (data.statementBalance > 0) {
              statementDue += data.statementBalance;
            }

            // Status checks
            final (status, _) = _getCardStatus(data.statementBalance,
                data.unbilledBalance, data.card.billDate, data.card.dueDate);

            if (status == 'Overdue') {
              overdueCount++;
            } else if (status == 'Billed') {
              billedCount++;
            } else if (status == 'Paid') {
              paidCount++;
            } else if (status == 'No Spend') {
              noSpendCount++;
            }
          }

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF00B4D8).withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(CupertinoIcons.creditcard,
                        color: Colors.white, size: 18),
                  ),
                  const SizedBox(width: 12),
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("CREDIT TRACKER",
                          style: TextStyle(
                              color: Colors.white70,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.2)),
                      Text("Live Summary",
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold)),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  // --- Box 1: Matches the Main Screen ---
                  Expanded(
                    child: _buildMetricCard(
                      "Total Payable",
                      currencyFmt.format(totalPayable),
                      Icons.account_balance_wallet,
                      color: totalPayable > 0 ? Colors.white : Colors.white54,
                    ),
                  ),
                  const SizedBox(width: 12),
                  // --- Box 2: Shows just the pending statement ---
                  Expanded(
                    child: _buildMetricCard(
                      "Statement Due",
                      currencyFmt.format(statementDue),
                      Icons.receipt_long,
                      color: statementDue > 0 ? _badColor : _goodColor,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              const Text(
                "CARD STATUS OVERVIEW",
                style: TextStyle(
                  color: Colors.white38,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _buildStatusChip("Overdue", overdueCount, _badColor),
                  _buildStatusChip("Billed", billedCount, _warningColor),
                  _buildStatusChip("Paid", paidCount, _goodColor),
                  _buildStatusChip("No Spend", noSpendCount, Colors.white54),
                ],
              ),
              if (cardsData.isNotEmpty) ...[
                const SizedBox(height: 20),
                Divider(color: Colors.white.withOpacity(0.05), height: 1),
                InkWell(
                  onTap: () {
                    HapticFeedback.selectionClick();
                    setState(() => _isExpanded = !_isExpanded);
                  },
                  borderRadius: BorderRadius.circular(8),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Card Wise Breakdown ($totalCards Cards)",
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        AnimatedRotation(
                          turns: _isExpanded ? 0.5 : 0.0,
                          duration: const Duration(milliseconds: 250),
                          child: const Icon(Icons.keyboard_arrow_down_rounded,
                              color: Colors.white54, size: 20),
                        ),
                      ],
                    ),
                  ),
                ),
                AnimatedSize(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                  child: SizedBox(
                    height: _isExpanded ? null : 0.0,
                    child: ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: cardsData.length,
                      padding: const EdgeInsets.only(top: 4, bottom: 8),
                      itemBuilder: (context, index) {
                        final data = cardsData[index];
                        final card = data.card;

                        final daysToBill =
                            _calculateDaysRemaining(card.billDate);
                        final daysToDue = _calculateDaysRemaining(card.dueDate);
                        final (statusText, statusColor) = _getCardStatus(
                            data.statementBalance,
                            data.unbilledBalance,
                            card.billDate,
                            card.dueDate);

                        return Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.02),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                                color: Colors.white.withOpacity(0.04)),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Text(
                                      '${card.name} (${card.bankName})',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 13,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: statusColor.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(6),
                                      border: Border.all(
                                          color: statusColor.withOpacity(0.2)),
                                    ),
                                    child: Text(
                                      statusText,
                                      style: TextStyle(
                                          color: statusColor,
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              Row(
                                children: [
                                  Expanded(
                                    child: _buildMiniDetail(
                                        "Outstanding",
                                        currencyFmt.format(card.currentBalance),
                                        Colors.white),
                                  ),
                                  Container(
                                      width: 1,
                                      height: 24,
                                      color: Colors.white10),
                                  Expanded(
                                    child: Padding(
                                      padding: const EdgeInsets.only(left: 12),
                                      child: _buildMiniDetail(
                                          "Payable",
                                          currencyFmt.format(
                                              data.statementBalance > 0
                                                  ? data.statementBalance
                                                  : 0.0),
                                          data.statementBalance > 0
                                              ? _badColor
                                              : Colors.white54),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: Colors.black.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceAround,
                                  children: [
                                    _buildDateInfo('Bill In', daysToBill),
                                    Container(
                                        width: 1,
                                        height: 16,
                                        color: Colors.white10),
                                    _buildDateInfo('Due In', daysToDue),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ],
            ],
          );
        },
      ),
    );
  }

  Widget _buildMetricCard(String label, String value, IconData icon,
      {Color? color}) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: Colors.white38, size: 14),
              const SizedBox(width: 6),
              Text(
                label,
                style: const TextStyle(
                    color: Colors.white54,
                    fontSize: 10,
                    fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
                color: color ?? Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusChip(String label, int count, Color color) {
    final bool isZero = count == 0;
    final displayColor = isZero ? Colors.white24 : color;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: isZero ? Colors.transparent : displayColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
            color: isZero ? Colors.white10 : displayColor.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            count.toString(),
            style: TextStyle(
                color: displayColor, fontWeight: FontWeight.bold, fontSize: 12),
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
                color: displayColor, fontSize: 10, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  Widget _buildMiniDetail(String label, String value, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(color: Colors.white38, fontSize: 10)),
        const SizedBox(height: 4),
        Text(value,
            style: TextStyle(
                color: color, fontSize: 13, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildDateInfo(String label, int days) {
    return Row(
      children: [
        Text('$label: ',
            style: const TextStyle(color: Colors.white38, fontSize: 10)),
        Text(days == 0 ? 'Today' : '$days Days',
            style: const TextStyle(
                color: Colors.white70,
                fontSize: 11,
                fontWeight: FontWeight.bold)),
      ],
    );
  }
}
