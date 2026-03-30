import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/bank_list.dart';
import '../models/credit_models.dart';
import '../screens/card_detail_screen.dart';
import '../utils/billing_cycle_utils.dart';

// ==============================================================
// --- [NEW] SMART CREDIT CARD LIST ITEM (Uses Contextual DTO)---
// ==============================================================
class SmartCreditCardListItem extends StatelessWidget {
  final CreditCardDashboardData dashboardData;
  final Color accentColor;
  final NumberFormat currency;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const SmartCreditCardListItem({
    super.key,
    required this.dashboardData,
    required this.accentColor,
    required this.currency,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final card = dashboardData.card;

    double displayBalance = -card.currentBalance;
    if (displayBalance.abs() < 0.01) displayBalance = 0.0;
    final bool isSurplus = displayBalance > 0;

    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => CreditCardDetailScreen(card: card)),
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        height: 130,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              const Color(0xFF1B263B),
              const Color(0xff0D1B2A).withOpacity(0.95),
            ],
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 15,
              offset: const Offset(0, 8),
            ),
          ],
          border: Border.all(color: Colors.white.withOpacity(0.1), width: 1),
        ),
        child: Stack(
          children: [
            Positioned(
              right: -40,
              top: -40,
              child: CircleAvatar(
                radius: 90,
                backgroundColor: accentColor.withOpacity(0.05),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Row(
                          children: [
                            Container(
                              width: 25,
                              height: 25,
                              padding: const EdgeInsets.all(4),
                              decoration: const BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                              ),
                              child: ClipOval(
                                child: Image.asset(
                                  BankConstants.getBankLogoPath(card.bankName),
                                  fit: BoxFit.contain,
                                  errorBuilder: (c, e, s) => Center(
                                    child: Text(
                                      BankConstants.getBankInitials(
                                          card.bankName),
                                      style: TextStyle(
                                        color: accentColor,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 10,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                card.bankName.toUpperCase(),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: Colors.white70,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 1.2,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      InkWell(
                        onTap: () => _showCardDetails(context, card),
                        borderRadius: BorderRadius.circular(20),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.1),
                            ),
                          ),
                          child: const Icon(
                            Icons.more_horiz,
                            color: Colors.white70,
                            size: 15,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  Text(
                    card.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const Spacer(),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Padding(
                          padding:
                              const EdgeInsets.only(right: 16.0, bottom: 2.0),
                          child: _SmartCycleProgressBar(data: dashboardData),
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            "CREDIT BALANCE",
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.5),
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.2,
                            ),
                          ),
                          const SizedBox(height: 2),
                          // --- [FIXED] Constrained Box + FittedBox for auto-scaling amount font ---
                          Container(
                            constraints: const BoxConstraints(maxWidth: 110),
                            child: FittedBox(
                              fit: BoxFit.scaleDown,
                              alignment: Alignment.centerRight,
                              child: Text(
                                currency.format(displayBalance),
                                style: TextStyle(
                                  color: isSurplus
                                      ? const Color(0xFF4CC9F0)
                                      : Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showCardDetails(BuildContext context, CreditCardModel card) {
    showDialog(
      context: context,
      builder: (ctx) => BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
        child: Dialog(
          backgroundColor: const Color(0xff1B263B).withOpacity(0.9),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: BorderSide(color: Colors.white.withOpacity(0.1)),
          ),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.credit_card,
                              color: Colors.white, size: 20),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          "Card Details",
                          style:
                              Theme.of(context).textTheme.titleLarge?.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                  ),
                        ),
                      ],
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.white54),
                      onPressed: () => Navigator.pop(ctx),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                _buildDetailRow("Card Name", card.name),
                const Divider(color: Colors.white10, height: 24),
                _buildDetailRow(
                    "Credit Limit", currency.format(card.creditLimit)),
                const Divider(color: Colors.white10, height: 24),
                _buildDetailRow(
                    "Statement Date", "${_getOrdinal(card.billDate)} of month"),
                const Divider(color: Colors.white10, height: 24),
                _buildDetailRow("Payment Due Date",
                    "${_getOrdinal(card.dueDate)} of month"),
                const SizedBox(height: 32),
                Row(
                  children: [
                    Expanded(
                      child: TextButton.icon(
                        onPressed: () {
                          Navigator.pop(ctx);
                          onDelete();
                        },
                        icon: const Icon(Icons.delete_outline,
                            color: Colors.redAccent, size: 20),
                        label: const Text("Delete",
                            style: TextStyle(color: Colors.redAccent)),
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          backgroundColor: Colors.redAccent.withOpacity(0.1),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: TextButton.icon(
                        onPressed: () {
                          Navigator.pop(ctx);
                          onEdit();
                        },
                        icon: const Icon(Icons.edit_outlined,
                            color: Colors.white, size: 20),
                        label: const Text("Edit",
                            style: TextStyle(color: Colors.white)),
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          backgroundColor: Colors.white.withOpacity(0.1),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) => Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              label,
              style:
                  TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 14),
            ),
          ),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.right,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 15),
            ),
          ),
        ],
      );

  String _getOrdinal(int number) {
    if (number >= 11 && number <= 13) return '${number}th';
    switch (number % 10) {
      case 1:
        return '${number}st';
      case 2:
        return '${number}nd';
      case 3:
        return '${number}rd';
      default:
        return '${number}th';
    }
  }
}

// =========================================================
// --- [NEW] SMART CYCLE UI MAPPER ---
// =========================================================
class _SmartCycleProgressBar extends StatelessWidget {
  final CreditCardDashboardData data;

  const _SmartCycleProgressBar({required this.data});

  @override
  Widget build(BuildContext context) {
    final info = BillingCycleUtils.getSmartCycleInfo(data);

    final Color trackColor = Colors.white.withOpacity(0.05);
    Color fillColor;
    String label;
    IconData icon;

    final String dayWord = info.daysRemaining == 1 ? "day" : "days";

    // UI Mapping based on Intelligent State
    switch (info.phase) {
      case SmartCyclePhase.noActivity:
        fillColor = Colors.white.withOpacity(0.2);
        label = "No Current Spends";
        icon = Icons.check_circle_outline;
        break;

      case SmartCyclePhase.paymentDue:
        fillColor = Colors.orangeAccent;
        label = info.daysRemaining == 0
            ? "Payment Due Today"
            : "Payment Due in ${info.daysRemaining} $dayWord";
        icon = Icons.warning_amber_rounded;
        break;

      case SmartCyclePhase.statementPaid:
        fillColor = Colors.greenAccent;
        label = info.daysRemaining == 0
            ? "Statement Paid • Next Bill Today"
            : "Statement Paid • Next Bill in ${info.daysRemaining} $dayWord";
        icon = Icons.verified;
        break;

      case SmartCyclePhase.unbilledSpending:
        fillColor = const Color(0xFF4CC9F0);
        label = info.daysRemaining == 0
            ? "Billed Today"
            : "Next Bill in ${info.daysRemaining} $dayWord";
        icon = Icons.sync_rounded;
        break;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            Icon(icon, size: 10, color: fillColor),
            const SizedBox(width: 4),
            Expanded(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: fillColor,
                  fontSize: 9,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.2,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 5),
        LayoutBuilder(
          builder: (context, constraints) {
            return Container(
              height: 4,
              width: constraints.maxWidth,
              decoration: BoxDecoration(
                color: trackColor,
                borderRadius: BorderRadius.circular(2),
              ),
              alignment: Alignment.centerLeft,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 1000),
                curve: Curves.easeOutCubic,
                height: 4,
                width: constraints.maxWidth * info.progress,
                decoration: BoxDecoration(
                    color: fillColor,
                    borderRadius: BorderRadius.circular(2),
                    boxShadow: [
                      BoxShadow(
                        color: fillColor.withOpacity(0.4),
                        blurRadius: 4,
                        offset: const Offset(0, 1),
                      )
                    ]),
              ),
            );
          },
        ),
      ],
    );
  }
}

// =========================================================
// --- [LEGACY] CREDIT CARD LIST ITEM ---
// =========================================================

class CreditCardListItem extends StatelessWidget {
  final CreditCardModel card;
  final Color accentColor;
  final NumberFormat currency;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const CreditCardListItem({
    super.key,
    required this.card,
    required this.accentColor,
    required this.currency,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    double displayBalance = -card.currentBalance;
    if (displayBalance.abs() < 0.01) displayBalance = 0.0;
    final bool isSurplus = displayBalance > 0;

    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => CreditCardDetailScreen(card: card)),
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        height: 130, // [RESTORED] Fixed height
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              const Color(0xFF1B263B),
              const Color(0xff0D1B2A).withOpacity(0.95),
            ],
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 15,
              offset: const Offset(0, 8),
            ),
          ],
          border: Border.all(color: Colors.white.withOpacity(0.1), width: 1),
        ),
        child: Stack(
          children: [
            Positioned(
              right: -40,
              top: -40,
              child: CircleAvatar(
                radius: 90,
                backgroundColor: accentColor.withOpacity(0.05),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Row(
                          children: [
                            Container(
                              width: 25,
                              height: 25,
                              padding: const EdgeInsets.all(4),
                              decoration: const BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                              ),
                              child: ClipOval(
                                child: Image.asset(
                                  BankConstants.getBankLogoPath(card.bankName),
                                  fit: BoxFit.contain,
                                  errorBuilder: (c, e, s) => Center(
                                    child: Text(
                                      BankConstants.getBankInitials(
                                          card.bankName),
                                      style: TextStyle(
                                        color: accentColor,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 10,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                card.bankName.toUpperCase(),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: Colors.white70,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 1.2,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      InkWell(
                        onTap: () => _showCardDetails(context),
                        borderRadius: BorderRadius.circular(20),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.1),
                            ),
                          ),
                          child: const Icon(Icons.more_horiz,
                              color: Colors.white70, size: 15),
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  Text(
                    card.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const Spacer(),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Padding(
                          padding:
                              const EdgeInsets.only(right: 16.0, bottom: 2.0),
                          child: _CompactCycleProgressBar(card: card),
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            "CREDIT BALANCE",
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.5),
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.2,
                            ),
                          ),
                          const SizedBox(height: 2),
                          // --- [FIXED] Constrained Box + FittedBox for auto-scaling amount font ---
                          Container(
                            constraints: const BoxConstraints(maxWidth: 110),
                            child: FittedBox(
                              fit: BoxFit.scaleDown,
                              alignment: Alignment.centerRight,
                              child: Text(
                                currency.format(displayBalance),
                                style: TextStyle(
                                  color: isSurplus
                                      ? const Color(0xFF4CC9F0)
                                      : Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showCardDetails(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
        child: Dialog(
          backgroundColor: const Color(0xff1B263B).withOpacity(0.9),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: BorderSide(color: Colors.white.withOpacity(0.1)),
          ),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.credit_card,
                              color: Colors.white, size: 20),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          "Card Details",
                          style:
                              Theme.of(context).textTheme.titleLarge?.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                  ),
                        ),
                      ],
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.white54),
                      onPressed: () => Navigator.pop(ctx),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                _buildDetailRow("Card Name", card.name),
                const Divider(color: Colors.white10, height: 24),
                _buildDetailRow(
                    "Credit Limit", currency.format(card.creditLimit)),
                const Divider(color: Colors.white10, height: 24),
                _buildDetailRow(
                    "Statement Date", "${_getOrdinal(card.billDate)} of month"),
                const Divider(color: Colors.white10, height: 24),
                _buildDetailRow("Payment Due Date",
                    "${_getOrdinal(card.dueDate)} of month"),
                const SizedBox(height: 32),
                Row(
                  children: [
                    Expanded(
                      child: TextButton.icon(
                        onPressed: () {
                          Navigator.pop(ctx);
                          onDelete();
                        },
                        icon: const Icon(Icons.delete_outline,
                            color: Colors.redAccent, size: 20),
                        label: const Text("Delete",
                            style: TextStyle(color: Colors.redAccent)),
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          backgroundColor: Colors.redAccent.withOpacity(0.1),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: TextButton.icon(
                        onPressed: () {
                          Navigator.pop(ctx);
                          onEdit();
                        },
                        icon: const Icon(Icons.edit_outlined,
                            color: Colors.white, size: 20),
                        label: const Text("Edit",
                            style: TextStyle(color: Colors.white)),
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          backgroundColor: Colors.white.withOpacity(0.1),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) => Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              label,
              style:
                  TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 14),
            ),
          ),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.right,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 15),
            ),
          ),
        ],
      );

  String _getOrdinal(int number) {
    if (number >= 11 && number <= 13) return '${number}th';
    switch (number % 10) {
      case 1:
        return '${number}st';
      case 2:
        return '${number}nd';
      case 3:
        return '${number}rd';
      default:
        return '${number}th';
    }
  }
}

class _CompactCycleProgressBar extends StatelessWidget {
  final CreditCardModel card;

  const _CompactCycleProgressBar({required this.card});

  @override
  Widget build(BuildContext context) {
    final info =
        BillingCycleUtils.getCurrentCycleInfo(card.billDate, card.dueDate);
    final isPaymentPhase = info.phase == CyclePhase.payment;

    final trackColor = Colors.white.withOpacity(0.05);
    final fillColor =
        isPaymentPhase ? Colors.orangeAccent : const Color(0xFF4CC9F0);
    final String dayWord = info.daysRemaining == 1 ? "day" : "days";

    final label = isPaymentPhase
        ? (info.daysRemaining == 0
            ? "Payment Due Today"
            : "Payment Due in ${info.daysRemaining} $dayWord")
        : (info.daysRemaining == 0
            ? "Billed Today"
            : "Next Bill in ${info.daysRemaining} $dayWord");

    final icon =
        isPaymentPhase ? Icons.warning_amber_rounded : Icons.sync_rounded;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            Icon(icon, size: 10, color: fillColor),
            const SizedBox(width: 4),
            Expanded(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                    color: fillColor,
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.2),
              ),
            ),
          ],
        ),
        const SizedBox(height: 5),
        LayoutBuilder(
          builder: (context, constraints) {
            return Container(
              height: 4,
              width: constraints.maxWidth,
              decoration: BoxDecoration(
                  color: trackColor, borderRadius: BorderRadius.circular(2)),
              alignment: Alignment.centerLeft,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 1000),
                curve: Curves.easeOutCubic,
                height: 4,
                width: constraints.maxWidth * info.progress,
                decoration: BoxDecoration(
                    color: fillColor,
                    borderRadius: BorderRadius.circular(2),
                    boxShadow: [
                      BoxShadow(
                          color: fillColor.withOpacity(0.4),
                          blurRadius: 4,
                          offset: const Offset(0, 1))
                    ]),
              ),
            );
          },
        ),
      ],
    );
  }
}
