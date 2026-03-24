import 'dart:ui';
import 'package:budget/core/widgets/futuristic_loader.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import '../../../core/widgets/glass_card.dart';
import '../../../core/widgets/modern_loader.dart';
import '../../daily_expense/models/expense_models.dart';
import '../../daily_expense/services/expense_service.dart';
import '../../settings/services/settings_service.dart';

class PayableAccountSelectionSheet extends StatefulWidget {
  const PayableAccountSelectionSheet({super.key});

  @override
  State<PayableAccountSelectionSheet> createState() =>
      _PayableAccountSelectionSheetState();
}

class _PayableAccountSelectionSheetState
    extends State<PayableAccountSelectionSheet> {
  final _expenseService = GetIt.I<ExpenseService>();
  final _settingsService = GetIt.I<SettingsService>();

  Set<String> _selectedIds = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadInitialSelections();
  }

  Future<void> _loadInitialSelections() async {
    final ids = await _settingsService.getCreditPayableAccountIds();
    if (mounted) {
      setState(() {
        _selectedIds = ids.toSet();
        _isLoading = false;
      });
    }
  }

  Future<void> _saveAndClose() async {
    await _settingsService.setCreditPayableAccountIds(_selectedIds.toList());
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
      // Wrapped inside SafeArea to prevent notch/notification bar overlap
      child: SafeArea(
        bottom: false,
        child: Container(
          // --- [ADDED]: Set height to 90% of screen height ---
          height: MediaQuery.of(context).size.height * 0.8,
          padding: const EdgeInsets.only(top: 16),
          decoration: BoxDecoration(
            color: const Color(0xFF0D1B2A).withOpacity(0.9),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
            border: Border.all(color: Colors.white.withOpacity(0.1), width: 1),
          ),
          child: Column(
            children: [
              // Drag Handle
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 20),

              // Header
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 24),
                child: Text(
                  "Select Payable Accounts",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                child: Text(
                  "Choose one or more bank accounts where you allocate funds to pay your credit card bills.",
                  style: TextStyle(color: Colors.white54, fontSize: 13),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 16),

              // Account List
              Expanded(
                child: _isLoading
                    ? const Center(
                        child: Padding(
                          padding: EdgeInsets.all(40.0),
                          child: FuturisticLoader(size: 40),
                        ),
                      )
                    : StreamBuilder<List<ExpenseAccountModel>>(
                        stream: _expenseService.getAccounts(),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                                  ConnectionState.waiting &&
                              snapshot.data == null) {
                            return const Center(
                              child: Padding(
                                padding: EdgeInsets.all(40.0),
                                child: FuturisticLoader(size: 40),
                              ),
                            );
                          }

                          final accounts = snapshot.data ?? [];

                          if (accounts.isEmpty) {
                            return const Center(
                              child: Padding(
                                padding: EdgeInsets.all(40.0),
                                child: Text(
                                  "No bank accounts found.",
                                  style: TextStyle(color: Colors.white54),
                                ),
                              ),
                            );
                          }

                          return ListView.builder(
                            shrinkWrap: true,
                            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                            itemCount:
                                accounts.length + 1, // +1 for "None" option
                            itemBuilder: (context, index) {
                              if (index == accounts.length) {
                                // Clear Selection Option
                                return GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      _selectedIds.clear();
                                    });
                                  },
                                  child: GlassCard(
                                    color: Colors.white.withOpacity(0.02),
                                    child: const Center(
                                      child: Text("Clear All Selections",
                                          style: TextStyle(
                                              color: Colors.redAccent)),
                                    ),
                                  ),
                                );
                              }

                              final account = accounts[index];
                              final isSelected =
                                  _selectedIds.contains(account.id);
                              // Standardized Bank Icon String Matcher
                              final normalizedBankName = account.bankName
                                  .toLowerCase()
                                  .replaceAll(' ', '')
                                  .replaceAll('-', '');

                              return GestureDetector(
                                onTap: () {
                                  setState(() {
                                    if (isSelected) {
                                      _selectedIds.remove(account.id);
                                    } else {
                                      _selectedIds.add(account.id);
                                    }
                                  });
                                },
                                child: GlassCard(
                                  color: isSelected
                                      ? const Color(0xFF4CC9F0)
                                          .withOpacity(0.15)
                                      : Colors.white.withOpacity(0.05),
                                  border: Border.all(
                                    color: isSelected
                                        ? const Color(0xFF4CC9F0)
                                            .withOpacity(0.5)
                                        : Colors.transparent,
                                    width: 1.5,
                                  ),
                                  child: Row(
                                    children: [
                                      // Fallback Bank Logo implementation matching Daily Expense Module
                                      Container(
                                        width: 40,
                                        height: 40,
                                        padding: const EdgeInsets.all(8),
                                        decoration: BoxDecoration(
                                          color: Colors.white.withOpacity(0.9),
                                          shape: BoxShape.circle,
                                        ),
                                        child: Image.asset(
                                          'assets/banks/$normalizedBankName.png',
                                          errorBuilder: (ctx, err, stack) =>
                                              Icon(Icons.account_balance_wallet,
                                                  color: Color(account.color),
                                                  size: 20),
                                        ),
                                      ),
                                      const SizedBox(width: 16),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(account.name,
                                                style: const TextStyle(
                                                    color: Colors.white,
                                                    fontWeight:
                                                        FontWeight.bold)),
                                            Text(account.bankName,
                                                style: const TextStyle(
                                                    color: Colors.white54,
                                                    fontSize: 12)),
                                          ],
                                        ),
                                      ),
                                      Icon(
                                        isSelected
                                            ? Icons.check_circle_rounded
                                            : Icons
                                                .radio_button_unchecked_rounded,
                                        color: isSelected
                                            ? const Color(0xFF4CC9F0)
                                            : Colors.white38,
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          );
                        },
                      ),
              ),

              // Save Button
              Padding(
                padding: EdgeInsets.fromLTRB(
                    24, 8, 24, MediaQuery.of(context).padding.bottom + 20),
                child: SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: ElevatedButton(
                    onPressed: _saveAndClose,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF4CC9F0),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8)),
                    ),
                    child: const Text(
                      "Save Preferences",
                      style: TextStyle(
                          color: Color(0xFF0D1B2A),
                          fontSize: 16,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
