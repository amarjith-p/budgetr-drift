import 'dart:ui';
import 'package:budget/core/widgets/futuristic_loader.dart';
import 'package:budget/core/widgets/status_bottom_sheet.dart';
import 'package:budget/features/credit_tracker/widgets/modern_credit_txn_sheet.dart';
import 'package:budget/features/credit_tracker/screens/new_credit_transaction_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get_it/get_it.dart';
import 'package:intl/intl.dart';
import '../../../core/widgets/modern_loader.dart';
import '../../../core/widgets/modern_app_bar.dart';
import '../../daily_expense/models/expense_models.dart';
import '../../daily_expense/services/expense_service.dart';
import '../../settings/services/settings_service.dart';
import '../models/credit_models.dart';
import '../services/credit_service.dart';
import '../widgets/add_credit_card_sheet.dart';
import '../widgets/credit_bal_summary_card.dart';
import '../widgets/payable_account_selection_sheet.dart';
import '../widgets/credit_card_list_item.dart';

class CreditTrackerScreen extends StatefulWidget {
  const CreditTrackerScreen({super.key});

  @override
  State<CreditTrackerScreen> createState() => _CreditTrackerScreenState();
}

class _CreditTrackerScreenState extends State<CreditTrackerScreen> {
  final CreditService _service = GetIt.I<CreditService>();
  final ExpenseService _expenseService = GetIt.I<ExpenseService>();
  final SettingsService _settingsService = GetIt.I<SettingsService>();

  final NumberFormat _currency = NumberFormat.currency(
    locale: 'en_IN',
    symbol: '₹',
  );
  final Color _accentColor = const Color(0xFF3A86FF);

  bool _isLoading = false;

  // [UPDATED] Using the new Smart Dashboard Data stream instead of just the Card Model
  late Stream<List<CreditCardDashboardData>> _cardsStream;

  Stream<List<ExpenseAccountModel>>? _payableAccountsStream;

  // --- SORTING STATE ---
  String _selectedSort = 'Balance (High to Low)';

  final List<String> _sortOptions = [
    'Payment Pending First',
    'Card Name (A-Z)',
    'Balance (High to Low)',
    'Balance (Low to High)',
    'Due Date (Ascending)',
    'Bill Date (Ascending)'
  ];

  @override
  void initState() {
    super.initState();
    // [UPDATED] Fetching the smart dashboard aggregator
    _cardsStream = _service.getSmartCreditCardsDashboard();
    _loadPayableAccounts();
  }

  Future<void> _loadPayableAccounts() async {
    final ids = await _settingsService.getCreditPayableAccountIds();
    setState(() {
      _payableAccountsStream = _expenseService.watchAccountsByIds(ids);
    });
  }

  // [UPDATED] Helper method to sort the smart data cards
  List<CreditCardDashboardData> _sortCards(
      List<CreditCardDashboardData> dashboardDataList) {
    final sortedList = List<CreditCardDashboardData>.from(dashboardDataList);
    sortedList.sort((aData, bData) {
      final a = aData.card;
      final b = bData.card;
      switch (_selectedSort) {
        case 'Payment Pending First':
          final bool aIsPending = aData.statementBalance > 0;
          final bool bIsPending = bData.statementBalance > 0;

          // 1. Prioritize pending payments to the top
          if (aIsPending && !bIsPending) return -1;
          if (!aIsPending && bIsPending) return 1;

          // 2. Helper to calculate actual days remaining from today
          int getDaysUntil(int day) {
            final now = DateTime.now();
            final today = DateTime(now.year, now.month, now.day);
            var target = DateTime(now.year, now.month, day);

            // If the day has already passed this month, the due date is next month
            if (target.isBefore(today)) {
              target = DateTime(now.year, now.month + 1, day);
            }
            return target.difference(today).inDays;
          }

          // 3. Sort ascending by who is due the soonest (smallest days remaining first)
          return getDaysUntil(a.dueDate).compareTo(getDaysUntil(b.dueDate));

        case 'Balance (High to Low)':
          return b.currentBalance.compareTo(a.currentBalance);
        case 'Balance (Low to High)':
          return a.currentBalance.compareTo(b.currentBalance);
        case 'Due Date (Ascending)':
          int getDaysUntil(int day) {
            final now = DateTime.now();
            final today = DateTime(now.year, now.month, now.day);
            var target = DateTime(now.year, now.month, day);
            if (target.isBefore(today)) {
              target = DateTime(now.year, now.month + 1, day);
            }
            return target.difference(today).inDays;
          }
          return getDaysUntil(a.dueDate).compareTo(getDaysUntil(b.dueDate));
        case 'Bill Date (Ascending)':
          return a.billDate.compareTo(b.billDate);
        case 'Card Name (A-Z)':
        default:
          return a.name.toLowerCase().compareTo(b.name.toLowerCase());
      }
    });
    return sortedList;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xff0D1B2A),
      body: SafeArea(
        child: Column(
          children: [
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
            Expanded(
              child: Stack(
                children: [
                  // [UPDATED] StreamBuilder now uses CreditCardDashboardData
                  StreamBuilder<List<CreditCardDashboardData>>(
                    stream: _cardsStream,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(
                            child: FuturisticLoader(
                                size: 80,
                                label: "DECRYPTING CREDIT PROFILES..."));
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

                      final dashboardDataList = snapshot.data!;

                      // Calculate aggregates before sorting
                      final double totalDebt = dashboardDataList
                          .where((data) => data.card.currentBalance > 0)
                          .fold(0.0,
                              (sum, data) => sum + data.card.currentBalance);
                      final double totalSurplus = dashboardDataList
                          .where((data) => data.card.currentBalance < 0)
                          .fold(0.0,
                              (sum, data) => sum + data.card.currentBalance);

                      // Apply Sorting
                      final sortedCardsData = _sortCards(dashboardDataList);

                      return Stack(
                        children: [
                          Column(
                            children: [
                              StreamBuilder<List<ExpenseAccountModel>>(
                                  stream: _payableAccountsStream ??
                                      Stream.value([]),
                                  builder: (context, accountSnapshot) {
                                    return CreditSummaryCard(
                                      totalPayable: totalDebt,
                                      totalSurplus: -totalSurplus,
                                      linkedAccounts:
                                          accountSnapshot.data ?? [],
                                      currencyFormat: _currency,
                                      onLinkAccountTapped: () async {
                                        await showModalBottomSheet(
                                          context: context,
                                          isScrollControlled: true,
                                          backgroundColor: Colors.transparent,
                                          builder: (ctx) =>
                                              const PayableAccountSelectionSheet(),
                                        );
                                        _loadPayableAccounts();
                                      },
                                    );
                                  }),

                              // --- SORTING HEADER ---
                              _buildSortHeader(),

                              Expanded(
                                child: ListView.builder(
                                  padding:
                                      const EdgeInsets.fromLTRB(16, 0, 16, 100),
                                  itemCount: sortedCardsData.length,
                                  itemBuilder: (context, index) {
                                    final currentData = sortedCardsData[index];

                                    // [UPDATED] Using the SmartCreditCardListItem widget
                                    return SmartCreditCardListItem(
                                      dashboardData: currentData,
                                      accentColor: _accentColor,
                                      currency: _currency,
                                      onEdit: () => showModalBottomSheet(
                                        context: context,
                                        isScrollControlled: true,
                                        backgroundColor: Colors.transparent,
                                        builder: (c) => AddCreditCardSheet(
                                            cardToEdit: currentData.card),
                                      ),
                                      onDelete: () => _handleDelete(
                                          context, currentData.card),
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

  Widget _buildSortHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            "Saved Cards",
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            ),
          ),
          GestureDetector(
            onTap: _showSortSheet,
            behavior: HitTestBehavior.opaque,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.05),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.white.withOpacity(0.1)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    _selectedSort,
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(width: 6),
                  const Icon(Icons.sort_rounded,
                      color: Colors.white54, size: 16),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showSortSheet() {
    HapticFeedback.lightImpact();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return SingleChildScrollView(
          child: Container(
            padding: EdgeInsets.only(
              top: 12,
              bottom: MediaQuery.of(context).padding.bottom + 24,
            ),
            decoration: const BoxDecoration(
              color: Color(0xFF1E293B), // Deep modern premium background
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // --- Modern Drag Handle ---
                Center(
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 24),
                    width: 48,
                    height: 5,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),

                // --- Header ---
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: _accentColor.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(Icons.sort_rounded,
                            color: _accentColor, size: 22),
                      ),
                      const SizedBox(width: 16),
                      const Text(
                        "Sort Strategy",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          letterSpacing: -0.5,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // --- Options List ---
                ..._sortOptions.map((option) {
                  final isSelected = _selectedSort == option;

                  // Assign relevant icons to each sorting strategy
                  IconData getIconForOption(String opt) {
                    if (opt.contains('Payment'))
                      return Icons.priority_high_rounded;
                    if (opt.contains('Due'))
                      return Icons.event_available_rounded;
                    if (opt.contains('Bill')) return Icons.receipt_long_rounded;
                    if (opt.contains('High'))
                      return Icons.keyboard_double_arrow_down_rounded;
                    if (opt.contains('Low'))
                      return Icons.keyboard_double_arrow_up_rounded;
                    return Icons.sort_by_alpha_rounded;
                  }

                  return GestureDetector(
                    onTap: () {
                      HapticFeedback.selectionClick();
                      setState(() {
                        _selectedSort = option;
                      });
                      Navigator.pop(context);
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 250),
                      curve: Curves.easeOutCubic,
                      margin: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 6),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 16),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? _accentColor.withOpacity(0.08)
                            : Colors.white.withOpacity(0.03),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isSelected
                              ? _accentColor.withOpacity(0.4)
                              : Colors.white.withOpacity(0.05),
                          width: 1.5,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            getIconForOption(option),
                            color: isSelected ? _accentColor : Colors.white54,
                            size: 20,
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Text(
                              option,
                              style: TextStyle(
                                color: isSelected
                                    ? Colors.white
                                    : Colors.white.withOpacity(0.8),
                                fontSize: 15,
                                fontWeight: isSelected
                                    ? FontWeight.w600
                                    : FontWeight.w500,
                              ),
                            ),
                          ),
                          AnimatedScale(
                            scale: isSelected ? 1.0 : 0.8,
                            duration: const Duration(milliseconds: 200),
                            child: Icon(
                              isSelected
                                  ? Icons.radio_button_checked_rounded
                                  : Icons.radio_button_off_rounded,
                              color: isSelected ? _accentColor : Colors.white24,
                              size: 22,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }),
              ],
            ),
          ),
        );
      },
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
      cancelButtonText: "Cancel",
      onCancel: () {},
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
