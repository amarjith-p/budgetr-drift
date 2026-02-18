import 'dart:ui';
import 'package:budget/core/widgets/futuristic_loader.dart';
import 'package:budget/core/widgets/status_bottom_sheet.dart';
import 'package:budget/features/credit_tracker/widgets/modern_credit_txn_sheet.dart';
import 'package:budget/features/credit_tracker/screens/new_credit_transaction_screen.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:intl/intl.dart';
import '../../../core/widgets/modern_loader.dart';
import '../../../core/widgets/modern_app_bar.dart'; // [IMPORT NEW WIDGET]
import '../models/credit_models.dart';
import '../services/credit_service.dart';
import '../widgets/add_credit_card_sheet.dart';
import '../widgets/credit_status_header.dart';
import '../widgets/credit_card_list_item.dart';

class CreditTrackerScreen extends StatefulWidget {
  const CreditTrackerScreen({super.key});

  @override
  State<CreditTrackerScreen> createState() => _CreditTrackerScreenState();
}

class _CreditTrackerScreenState extends State<CreditTrackerScreen> {
  final CreditService _service = GetIt.I<CreditService>();
  final NumberFormat _currency = NumberFormat.currency(
    locale: 'en_IN',
    symbol: '₹',
  );
  final Color _accentColor = const Color(0xFF3A86FF);

  // State to manage loading overlay instead of Dialogs
  bool _isLoading = false;

  late Stream<List<CreditCardModel>> _cardsStream;

  @override
  void initState() {
    super.initState();
    _cardsStream = _service.getCreditCards();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xff0D1B2A),
      // [FIX] Removed standard AppBar property
      body: SafeArea(
        child: Column(
          children: [
            // 1. NEW MODERN APP BAR
            ModernAppBar(
              title: "Credit Cards",
              subtitle: "Transaction Tracker",
              trailingIcon: Icons.add_card_rounded,
              onTrailingPressed: () {
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  backgroundColor: Colors.transparent,
                  builder: (ctx) => const AddCreditCardSheet(),
                );
              },
            ),

            // 2. MAIN CONTENT AREA
            Expanded(
              child: Stack(
                children: [
                  // Main Data Stream
                  StreamBuilder<List<CreditCardModel>>(
                    stream: _cardsStream,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(
                            child: FuturisticLoader(
                                size: 80, label: "LOADING ACCOUNTS..."));
                      }

                      if (snapshot.hasError) {
                        return Center(
                          child: Text(
                            "Error: ${snapshot.error}",
                            style: const TextStyle(color: Colors.red),
                          ),
                        );
                      }

                      if (!snapshot.hasData || snapshot.data!.isEmpty) {
                        return _buildEmptyState(context);
                      }

                      final cards = snapshot.data!;
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
                      }

                      // Inner Stack for List + FAB
                      return Stack(
                        children: [
                          Column(
                            children: [
                              CreditStatusHeader(
                                label: label,
                                amount: displayAmount,
                                color: valueColor,
                                currency: _currency,
                              ),
                              Expanded(
                                child: ListView.builder(
                                  padding:
                                      const EdgeInsets.fromLTRB(16, 0, 16, 100),
                                  itemCount: cards.length,
                                  itemBuilder: (context, index) =>
                                      CreditCardListItem(
                                    card: cards[index],
                                    accentColor: _accentColor,
                                    currency: _currency,
                                    onEdit: () => showModalBottomSheet(
                                      context: context,
                                      isScrollControlled: true,
                                      backgroundColor: Colors.transparent,
                                      builder: (c) => AddCreditCardSheet(
                                          cardToEdit: cards[index]),
                                    ),
                                    onDelete: () =>
                                        _handleDelete(context, cards[index]),
                                  ),
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
                                  builder: (ctx) =>
                                      const NewCreditTransactionScreen(),
                                ),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 24,
                                    vertical: 16,
                                  ),
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        _accentColor,
                                        const Color(0xFF2563EB)
                                      ],
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    ),
                                    borderRadius: BorderRadius.circular(30),
                                    boxShadow: [
                                      BoxShadow(
                                        color: _accentColor.withOpacity(0.4),
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
                                      Icon(Icons.add_rounded,
                                          color: Colors.white),
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

                  // Loading Overlay (Global for this screen)
                  if (_isLoading)
                    Container(
                      color: Colors.black54,
                      child: const Center(child: ModernLoader(size: 60)),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) => Center(
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

  void _handleDelete(BuildContext context, CreditCardModel card) {
    showStatusSheet(
      context: context,
      title: "Delete Account?",
      message:
          "Are you sure you want to delete '${card.name}'? This will permanently remove the account and all its associated transactions.",
      icon: Icons.delete_forever,
      color: Colors.redAccent,

      // 1. The "Cancel" Button
      cancelButtonText: "Cancel",
      onCancel: () {
        // The sheet closes automatically
      },

      // 2. The "Delete" Action
      buttonText: "Delete",
      onDismiss: () async {
        setState(() {
          _isLoading = true;
        });

        try {
          await _service.deleteCreditCard(card.id);
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text("Account deleted successfully"),
                backgroundColor: Colors.redAccent,
              ),
            );
          }
        } catch (e) {
          if (mounted) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text("Error: $e")));
          }
        } finally {
          if (mounted) {
            setState(() {
              _isLoading = false;
            });
          }
        }
      },
    );
  }
}
