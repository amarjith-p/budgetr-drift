import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:get_it/get_it.dart';
import '../../../core/widgets/futuristic_loader.dart';
import '../../credit_tracker/services/credit_service.dart';
import '../../credit_tracker/models/credit_models.dart';
import '../../credit_tracker/utils/billing_cycle_utils.dart';

class CreditSummaryAnalyticsWidget extends StatefulWidget {
  const CreditSummaryAnalyticsWidget({super.key});

  @override
  State<CreditSummaryAnalyticsWidget> createState() =>
      _CreditSummaryAnalyticsWidgetState();
}

class _CreditSummaryAnalyticsWidgetState
    extends State<CreditSummaryAnalyticsWidget>
    with SingleTickerProviderStateMixin {
  final CreditService _creditService = GetIt.I<CreditService>();

  // --- INTERACTIVE FILTER STATE ---
  final Set<String> _activeFilters = {};

  // --- DANGER ZONE ANIMATION ---
  late AnimationController _pulseController;

  // --- COLORS ---
  final Color _paidColor = const Color(0xFF06D6A0); // Bill Paid
  final Color _pendingColor = const Color(0xFF4CC9F0); // Bill Pending
  final Color _billedColor = Colors.orangeAccent; // Billed
  final Color _overdueColor = const Color(0xFFFF5252); // Overdue

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

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

  (String, Color) _getSmartCardStatus(CreditCardDashboardData data) {
    final info = BillingCycleUtils.getSmartCycleInfo(data);

    switch (info.phase) {
      case SmartCyclePhase.overdue:
        return ('Overdue', _overdueColor);
      case SmartCyclePhase.paymentDue:
        return ('Billed', _billedColor);
      case SmartCyclePhase.unbilledSpending:
        return ('Bill Pending', _pendingColor);
      case SmartCyclePhase.statementPaid:
        return ('Bill Paid', _paidColor);
      case SmartCyclePhase.noActivity:
        return ('No Spend', Colors.white38);
    }
  }

  int _getStatusPriority(String status) {
    switch (status) {
      case 'Overdue':
        return 1;
      case 'Billed':
        return 2;
      case 'Bill Pending':
        return 3;
      case 'Bill Paid':
        return 4;
      default:
        return 5;
    }
  }

  void _toggleFilter(String status) {
    HapticFeedback.lightImpact();
    setState(() {
      if (_activeFilters.contains(status)) {
        _activeFilters.remove(status);
      } else {
        _activeFilters.add(status);
      }
    });
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

          double totalPayable = 0.0;
          double statementDue = 0.0;

          int overdueCount = 0;
          int billedCount = 0;
          int pendingCount = 0;
          int paidCount = 0;

          List<Map<String, dynamic>> enrichedCards = [];

          for (var data in cardsData) {
            if (data.card.currentBalance > 0) {
              totalPayable += data.card.currentBalance;
            }
            if (data.statementBalance > 0) {
              statementDue += data.statementBalance;
            }

            final (status, color) = _getSmartCardStatus(data);

            if (status == 'Overdue') {
              overdueCount++;
            } else if (status == 'Billed') {
              billedCount++;
            } else if (status == 'Bill Pending') {
              pendingCount++;
            } else if (status == 'Bill Paid') {
              paidCount++;
            }

            if (status != 'No Spend') {
              enrichedCards.add({
                'data': data,
                'status': status,
                'color': color,
              });
            }
          }

          var displayCards = enrichedCards
              .where((c) => _activeFilters.contains(c['status'] as String))
              .toList();

          displayCards.sort((a, b) {
            int pA = _getStatusPriority(a['status'] as String);
            int pB = _getStatusPriority(b['status'] as String);
            if (pA != pB) return pA.compareTo(pB);

            double balA =
                (a['data'] as CreditCardDashboardData).card.currentBalance;
            double balB =
                (b['data'] as CreditCardDashboardData).card.currentBalance;
            return balB.compareTo(balA);
          });

          return AnimatedBuilder(
            animation: _pulseController,
            builder: (context, child) {
              final double pulseVal = _pulseController.value;

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
                      Expanded(
                        child: _buildMetricCard(
                          "Total Payable",
                          currencyFmt.format(totalPayable),
                          Icons.account_balance_wallet,
                          color:
                              totalPayable > 0 ? Colors.white : Colors.white54,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildMetricCard(
                          "Statement Due",
                          currencyFmt.format(statementDue),
                          Icons.receipt_long,
                          color: statementDue > 0 ? _overdueColor : _paidColor,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    "CARD STATUS OVERVIEW",
                    style: TextStyle(
                      color: Colors.white38,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: _buildInteractiveGridCard(
                                "Overdue",
                                overdueCount,
                                _overdueColor,
                                Icons.warning_rounded,
                                pulseVal),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildInteractiveGridCard(
                                "Billed",
                                billedCount,
                                _billedColor,
                                Icons.receipt_long_rounded,
                                pulseVal),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: _buildInteractiveGridCard(
                                "Bill Pending",
                                pendingCount,
                                _pendingColor,
                                Icons.hourglass_empty_rounded,
                                pulseVal),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildInteractiveGridCard(
                                "Bill Paid",
                                paidCount,
                                _paidColor,
                                Icons.check_circle_outline_rounded,
                                pulseVal),
                          ),
                        ],
                      ),
                    ],
                  ),
                  AnimatedSize(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOutCubic,
                    child: _activeFilters.isEmpty || displayCards.isEmpty
                        ? const SizedBox.shrink()
                        : Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 24),
                              Divider(
                                  color: Colors.white.withOpacity(0.05),
                                  height: 1),
                              const SizedBox(height: 16),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    "Active Cards Breakdown (${displayCards.length})",
                                    style: const TextStyle(
                                      color: Colors.white70,
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  InkWell(
                                    onTap: () {
                                      HapticFeedback.lightImpact();
                                      setState(() => _activeFilters.clear());
                                    },
                                    child: const Text(
                                      "Clear All",
                                      style: TextStyle(
                                        color: Colors.white38,
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  )
                                ],
                              ),
                              const SizedBox(height: 12),
                              ListView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: displayCards.length,
                                padding: EdgeInsets.zero,
                                itemBuilder: (context, index) {
                                  final item = displayCards[index];
                                  final data =
                                      item['data'] as CreditCardDashboardData;
                                  final statusText = item['status'] as String;
                                  final statusColor = item['color'] as Color;
                                  final card = data.card;

                                  final smartInfo =
                                      BillingCycleUtils.getSmartCycleInfo(data);

                                  Widget dynamicDateRow;

                                  if (smartInfo.phase ==
                                      SmartCyclePhase.overdue) {
                                    dynamicDateRow = Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceAround,
                                      children: [
                                        _buildDateInfo('Overdue By',
                                            '${smartInfo.daysRemaining} Days',
                                            valueColor: _overdueColor),
                                        Container(
                                            width: 1,
                                            height: 16,
                                            color: Colors.white10),
                                        _buildDateInfo('Next Bill',
                                            '${_calculateDaysRemaining(card.billDate)} Days'),
                                      ],
                                    );
                                  } else if (smartInfo.phase ==
                                      SmartCyclePhase.paymentDue) {
                                    dynamicDateRow = Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceAround,
                                      children: [
                                        _buildDateInfo(
                                            'Due In',
                                            smartInfo.daysRemaining == 0
                                                ? 'Today'
                                                : '${smartInfo.daysRemaining} Days',
                                            valueColor: _billedColor),
                                        Container(
                                            width: 1,
                                            height: 16,
                                            color: Colors.white10),
                                        _buildDateInfo('Next Bill',
                                            '${_calculateDaysRemaining(card.billDate)} Days'),
                                      ],
                                    );
                                  } else {
                                    dynamicDateRow = Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceAround,
                                      children: [
                                        _buildDateInfo(
                                            'Bill In',
                                            smartInfo.daysRemaining == 0
                                                ? 'Today'
                                                : '${smartInfo.daysRemaining} Days'),
                                        Container(
                                            width: 1,
                                            height: 16,
                                            color: Colors.white10),
                                        _buildDateInfo('Next Due',
                                            '${_calculateDaysRemaining(card.dueDate)} Days'),
                                      ],
                                    );
                                  }

                                  return Container(
                                    margin: const EdgeInsets.only(bottom: 12),
                                    padding: const EdgeInsets.all(16),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.02),
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(
                                          color:
                                              Colors.white.withOpacity(0.04)),
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
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
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 8,
                                                      vertical: 4),
                                              decoration: BoxDecoration(
                                                color: statusColor
                                                    .withOpacity(0.1),
                                                borderRadius:
                                                    BorderRadius.circular(6),
                                                border: Border.all(
                                                    color: statusColor
                                                        .withOpacity(0.2)),
                                              ),
                                              child: Text(
                                                statusText,
                                                style: TextStyle(
                                                    color: statusColor,
                                                    fontSize: 10,
                                                    fontWeight:
                                                        FontWeight.bold),
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
                                                  currencyFmt.format(
                                                      card.currentBalance),
                                                  Colors.white),
                                            ),
                                            Container(
                                                width: 1,
                                                height: 24,
                                                color: Colors.white10),
                                            Expanded(
                                              child: Padding(
                                                padding: const EdgeInsets.only(
                                                    left: 12),
                                                child: _buildMiniDetail(
                                                    "Payable",
                                                    currencyFmt.format(
                                                        data.statementBalance >
                                                                0
                                                            ? data
                                                                .statementBalance
                                                            : 0.0),
                                                    data.statementBalance > 0
                                                        ? _overdueColor
                                                        : Colors.white54),
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 12),
                                        Container(
                                          padding: const EdgeInsets.all(10),
                                          decoration: BoxDecoration(
                                            color:
                                                Colors.black.withOpacity(0.2),
                                            borderRadius:
                                                BorderRadius.circular(8),
                                          ),
                                          child: dynamicDateRow,
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                  ),
                ],
              );
            },
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
        borderRadius: BorderRadius.circular(8),
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

  // --- UPDATED VISUAL HIERARCHY: NO BACKGROUND GLOW ON SELECTION ---
  Widget _buildInteractiveGridCard(
      String label, int count, Color color, IconData icon, double pulseValue) {
    final bool isZero = count == 0;
    final bool isSelected = _activeFilters.contains(label);
    final Color displayColor = isZero ? Colors.white24 : color;

    final bool isDangerZone =
        !isZero && (label == 'Overdue' || label == 'Billed');

    Color activeBorderColor;
    double borderWidth = 1.0;
    List<BoxShadow>? activeShadow;

    // Background remains static to avoid full card glow
    final Color bgColor = Colors.white.withOpacity(0.02);

    // The Danger glow remains entirely dependent on condition, independent of selection
    if (isDangerZone) {
      activeShadow = [
        BoxShadow(
            color: displayColor.withOpacity(0.15 * pulseValue), blurRadius: 6)
      ];
    }

    if (isSelected && !isZero) {
      // SELECTION: Solid bright border, slightly thicker
      activeBorderColor = displayColor;
      borderWidth = 1.5;
    } else if (isDangerZone) {
      // DANGER ZONE (unselected): Pulsing subtle border
      activeBorderColor = displayColor.withOpacity(0.2 + (0.7 * pulseValue));
    } else {
      // NORMAL
      activeBorderColor = isZero
          ? Colors.white.withOpacity(0.02)
          : Colors.white.withOpacity(0.08);
    }

    return GestureDetector(
      onTap: isZero ? null : () => _toggleFilter(label),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: activeBorderColor, width: borderWidth),
          boxShadow: activeShadow, // Applies only if danger conditions are met
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      icon,
                      color: displayColor.withOpacity(isZero ? 0.3 : 0.8),
                      size: 16,
                    ),
                    if (isSelected) ...[
                      const SizedBox(width: 6),
                      Icon(Icons.check_circle, color: displayColor, size: 14),
                    ]
                  ],
                ),
                Text(
                  count.toString(),
                  style: TextStyle(
                    color: displayColor,
                    fontWeight: FontWeight.w900,
                    fontSize: 18,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                color: displayColor.withOpacity(isZero ? 0.5 : 0.9),
                fontSize: 11,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
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

  Widget _buildDateInfo(String label, String value, {Color? valueColor}) {
    return Row(
      children: [
        Text('$label: ',
            style: const TextStyle(color: Colors.white38, fontSize: 10)),
        Text(value,
            style: TextStyle(
                color: valueColor ?? Colors.white70,
                fontSize: 11,
                fontWeight: FontWeight.bold)),
      ],
    );
  }
}
