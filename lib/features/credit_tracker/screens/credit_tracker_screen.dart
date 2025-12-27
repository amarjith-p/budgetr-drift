import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/bank_list.dart';
import '../../../core/widgets/modern_loader.dart';
import '../models/credit_models.dart';
import '../services/credit_service.dart';
import '../widgets/add_credit_card_sheet.dart';
import '../widgets/add_credit_txn_sheet.dart';
import 'card_detail_screen.dart';

class CreditTrackerScreen extends StatelessWidget {
  const CreditTrackerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final CreditService service = CreditService();
    final currency = NumberFormat.currency(locale: 'en_IN', symbol: '₹');

    // Theme Colors
    final bgColor = const Color(0xff0D1B2A);
    final accentColor = const Color(0xFF3A86FF);

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          "Credit Tracker",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            onPressed: () => showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              backgroundColor: Colors.transparent,
              builder: (ctx) => const AddCreditCardSheet(),
            ),
            icon: const Icon(Icons.add_card),
            tooltip: "Add New Card",
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: StreamBuilder<List<CreditCardModel>>(
        stream: service.getCreditCards(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: ModernLoader());
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return _buildEmptyState(context);
          }

          final cards = snapshot.data!;

          // CALCULATION LOGIC
          final double totalDebt = cards
              .where((c) => c.currentBalance > 0)
              .fold(0.0, (sum, c) => sum + c.currentBalance);

          final double totalSurplus = cards
              .where((c) => c.currentBalance < 0)
              .fold(0.0, (sum, c) => sum + c.currentBalance);

          double displayAmount = 0;
          String label = "STATUS";
          Color valueColor = const Color(0xFF00B4D8);

          if (totalDebt > 0.01) {
            label = "TOTAL PAYABLE";
            displayAmount = -totalDebt;
            valueColor = Colors.white;
          } else if (totalSurplus.abs() > 0.01) {
            label = "TOTAL SURPLUS";
            displayAmount = -totalSurplus;
            valueColor = const Color(0xFF4CC9F0);
          } else {
            label = "STATUS";
            displayAmount = 0;
            valueColor = const Color(0xFF00B4D8);
          }

          return Stack(
            children: [
              Column(
                children: [
                  _buildTotalHeader(label, displayAmount, valueColor, currency),
                  Expanded(
                    child: ListView.builder(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
                      itemCount: cards.length,
                      itemBuilder: (context, index) {
                        final card = cards[index];
                        return _buildCreditCard(
                          context,
                          card,
                          accentColor,
                          currency,
                        );
                      },
                    ),
                  ),
                ],
              ),
              Positioned(
                bottom: 20,
                left: 0,
                right: 0,
                child: Center(
                  child: GestureDetector(
                    onTap: () => showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      backgroundColor: Colors.transparent,
                      builder: (ctx) => const AddCreditTransactionSheet(),
                    ),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 16,
                      ),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [accentColor, const Color(0xFF2563EB)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(30),
                        boxShadow: [
                          BoxShadow(
                            color: accentColor.withOpacity(0.4),
                            blurRadius: 20,
                            spreadRadius: -5,
                            offset: const Offset(0, 10),
                          ),
                        ],
                        border: Border.all(
                          color: Colors.white.withOpacity(0.2),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: const [
                          Icon(Icons.add_rounded, color: Colors.white),
                          SizedBox(width: 12),
                          Text(
                            "Add Transaction",
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildTotalHeader(
    String label,
    double amount,
    Color color,
    NumberFormat currency,
  ) {
    String displayString;
    if (label == "STATUS") {
      displayString = "All Settled";
    } else if (amount > 0) {
      displayString = "+ ${currency.format(amount)}";
    } else {
      displayString = currency.format(amount);
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            label,
            style: TextStyle(
              color: Colors.white.withOpacity(0.6),
              fontSize: 12,
              fontWeight: FontWeight.bold,
              letterSpacing: 2.0,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            displayString,
            style: TextStyle(
              color: color,
              fontSize: 32,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.credit_card_off,
            size: 60,
            color: Colors.white.withOpacity(0.2),
          ),
          const SizedBox(height: 16),
          const Text(
            "No Credit Cards Added",
            style: TextStyle(color: Colors.white54),
          ),
        ],
      ),
    );
  }

  Widget _buildCreditCard(
    BuildContext context,
    CreditCardModel card,
    Color accent,
    NumberFormat currency,
  ) {
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
        height: 160,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
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
                backgroundColor: accent.withOpacity(0.05),
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
                      Row(
                        children: [
                          // --- UPDATED LOGO DISPLAY ---
                          Container(
                            width: 36, // Fixed size for consistency
                            height: 36,
                            padding: const EdgeInsets.all(4), // Inner padding
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                            ),
                            child: ClipOval(
                              child: Image.asset(
                                BankConstants.getBankLogoPath(card.bankName),
                                fit: BoxFit.contain,
                                errorBuilder: (context, error, stackTrace) {
                                  // Fallback to Initials if image fails
                                  return Center(
                                    child: Text(
                                      BankConstants.getBankInitials(
                                        card.bankName,
                                      ),
                                      style: TextStyle(
                                        color: accent,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 10,
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                          // ---------------------------
                          const SizedBox(width: 10),
                          Text(
                            card.bankName.toUpperCase(),
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.2,
                            ),
                          ),
                        ],
                      ),
                      InkWell(
                        onTap: () => _showCardDetails(context, card, currency),
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
                            size: 18,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  Text(
                    card.name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const Spacer(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
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
                          Text(
                            currency.format(displayBalance),
                            style: TextStyle(
                              color: isSurplus
                                  ? const Color(0xFF4CC9F0)
                                  : Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
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

  void _showCardDetails(
    BuildContext context,
    CreditCardModel card,
    NumberFormat currency,
  ) {
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
                          child: const Icon(
                            Icons.credit_card,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          "Card Details",
                          style: Theme.of(context).textTheme.titleLarge
                              ?.copyWith(
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
                  "Credit Limit",
                  currency.format(card.creditLimit),
                ),
                const Divider(color: Colors.white10, height: 24),
                _buildDetailRow(
                  "Statement Date",
                  "${_getOrdinal(card.billDate)} of month",
                ),
                const Divider(color: Colors.white10, height: 24),
                _buildDetailRow(
                  "Payment Due Date",
                  "${_getOrdinal(card.dueDate)} of month",
                ),
                const SizedBox(height: 32),
                Row(
                  children: [
                    Expanded(
                      child: TextButton.icon(
                        onPressed: () {
                          Navigator.pop(ctx);
                          _handleDelete(context, card);
                        },
                        icon: const Icon(
                          Icons.delete_outline,
                          color: Colors.redAccent,
                          size: 20,
                        ),
                        label: const Text(
                          "Delete",
                          style: TextStyle(color: Colors.redAccent),
                        ),
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          backgroundColor: Colors.redAccent.withOpacity(0.1),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: TextButton.icon(
                        onPressed: () {
                          Navigator.pop(ctx);
                          showModalBottomSheet(
                            context: context,
                            isScrollControlled: true,
                            backgroundColor: Colors.transparent,
                            builder: (c) =>
                                AddCreditCardSheet(cardToEdit: card),
                          );
                        },
                        icon: const Icon(
                          Icons.edit_outlined,
                          color: Colors.white,
                          size: 20,
                        ),
                        label: const Text(
                          "Edit",
                          style: TextStyle(color: Colors.white),
                        ),
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          backgroundColor: Colors.white.withOpacity(0.1),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
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

  void _handleDelete(BuildContext context, CreditCardModel card) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xff0D1B2A),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: Colors.white.withOpacity(0.1)),
        ),
        title: const Text(
          "Delete Account?",
          style: TextStyle(color: Colors.white),
        ),
        content: Text(
          "Are you sure you want to delete '${card.name}'? This will permanently remove the account and all its associated transactions.",
          style: TextStyle(color: Colors.white.withOpacity(0.7)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text(
              "Cancel",
              style: TextStyle(color: Colors.white54),
            ),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              try {
                await CreditService().deleteCreditCard(card.id);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Account deleted successfully"),
                      backgroundColor: Colors.redAccent,
                    ),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text("Error: $e")));
                }
              }
            },
            child: const Text(
              "Delete",
              style: TextStyle(
                color: Colors.redAccent,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 14),
        ),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 15,
          ),
        ),
      ],
    );
  }

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
