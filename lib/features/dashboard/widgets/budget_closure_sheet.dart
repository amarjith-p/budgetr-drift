import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../core/design/budgetr_colors.dart';
import '../../../core/design/budgetr_styles.dart';
import '../../../core/models/financial_record_model.dart';
import '../../../core/models/settlement_model.dart';
import '../../settlement/services/settlement_service.dart';

class BudgetClosureSheet extends StatefulWidget {
  final FinancialRecord record;
  final Map<String, double> spendingMap;

  const BudgetClosureSheet({
    super.key,
    required this.record,
    required this.spendingMap,
  });

  @override
  State<BudgetClosureSheet> createState() => _BudgetClosureSheetState();
}

class _BudgetClosureSheetState extends State<BudgetClosureSheet> {
  final SettlementService _settlementService = SettlementService();
  final NumberFormat _currencyFormat = NumberFormat.currency(
    locale: 'en_IN',
    symbol: '₹',
  );
  bool _isSaving = false;

  /// Returns the expenses map WITHOUT 'Out of Bucket' items
  Map<String, double> get _budgetedExpenses {
    final Map<String, double> filtered = Map.from(widget.spendingMap);
    filtered.remove('Out of Bucket');
    return filtered;
  }

  /// Calculates total expense excluding 'Out of Bucket'
  double get _totalBudgetedExpense {
    return _budgetedExpenses.values.fold(0.0, (sum, item) => sum + item);
  }

  /// Calculates ONLY 'Out of Bucket' expense
  double get _outOfBucketTotal {
    return widget.spendingMap['Out of Bucket'] ?? 0.0;
  }

  Future<void> _confirmAndLock() async {
    setState(() => _isSaving = true);

    try {
      // 1. Create Settlement Object using only BUDGETED expenses
      final settlement = Settlement(
        id: widget.record.id,
        year: widget.record.year,
        month: widget.record.month,
        allocations: widget.record.allocations,
        expenses: _budgetedExpenses, // 'Out of Bucket' is removed here
        totalIncome: widget.record.effectiveIncome,
        totalExpense: _totalBudgetedExpense,
        settledAt: Timestamp.now(),
      );

      // 2. Save to Firestore
      await _settlementService.saveSettlement(settlement);

      if (mounted) {
        Navigator.pop(context); // Close Sheet
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Budget Closed & Locked Successfully!"),
            backgroundColor: BudgetrColors.success,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSaving = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Error: $e"),
            backgroundColor: BudgetrColors.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final effectiveIncome = widget.record.effectiveIncome;
    final totalSpent = _totalBudgetedExpense;
    final balance = effectiveIncome - totalSpent;
    final isSurplus = balance >= 0;

    // Current Timestamp for "As on" display
    final String asOnDate = DateFormat(
      'dd MMM yyyy, hh:mm a',
    ).format(DateTime.now());

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: BudgetrColors.background,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        border: Border(top: BorderSide(color: Colors.white.withOpacity(0.1))),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Handle
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.white24,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.greenAccent.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.lock_outline_rounded,
                  color: Colors.greenAccent,
                ),
              ),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Close Budget",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    DateFormat(
                      'MMMM yyyy',
                    ).format(DateTime(widget.record.year, widget.record.month)),
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.5),
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 32),

          // Summary Card
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: BudgetrColors.cardSurface,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: Colors.white.withOpacity(0.05)),
            ),
            child: Column(
              children: [
                _buildSummaryRow(
                  "Effective Income",
                  effectiveIncome,
                  Colors.white70,
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 12),
                  child: Divider(color: Colors.white10),
                ),
                _buildSummaryRow(
                  "Budget Spent",
                  totalSpent,
                  BudgetrColors.accent,
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 12),
                  child: Divider(color: Colors.white10),
                ),
                _buildSummaryRow(
                  isSurplus ? "Net Savings" : "Overspent By",
                  balance.abs(),
                  isSurplus ? BudgetrColors.success : BudgetrColors.error,
                  isBold: true,
                  scale: 1.2,
                ),
              ],
            ),
          ),

          // --- NEW: Out of Bucket Info ---
          if (_outOfBucketTotal > 0) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.orangeAccent.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.orangeAccent.withOpacity(0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Total Out of Bucket",
                        style: TextStyle(
                          color: Colors.orangeAccent,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        _currencyFormat.format(_outOfBucketTotal),
                        style: const TextStyle(
                          color: Colors.orangeAccent,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(
                        Icons.access_time_rounded,
                        color: Colors.white38,
                        size: 12,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        "As on $asOnDate",
                        style: const TextStyle(
                          color: Colors.white38,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(
                        Icons.info_outline,
                        color: Colors.white38,
                        size: 12,
                      ),
                      const SizedBox(width: 4),
                      const Text(
                        "Will not be recorded on Settlement",
                        style: TextStyle(
                          color: Colors.white38,
                          fontSize: 11,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      const Icon(
                        Icons.info_outline,
                        color: Colors.white38,
                        size: 12,
                      ),
                      const SizedBox(width: 4),
                      const Text(
                        "You may record them in Networth Split Analysis",
                        style: TextStyle(
                          color: Colors.white38,
                          fontSize: 11,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],

          // -------------------------------
          const SizedBox(height: 24),

          // Bucket Breakdown Preview
          Text(
            "BUDGET BREAKDOWN",
            style: BudgetrStyles.caption.copyWith(letterSpacing: 1.2),
          ),
          const SizedBox(height: 12),
          Container(
            constraints: const BoxConstraints(maxHeight: 200),
            // We iterate over allocations, so 'Out of Bucket' naturally doesn't appear here
            child: ListView(
              shrinkWrap: true,
              children: widget.record.allocations.entries.map((entry) {
                final spent = widget.spendingMap[entry.key] ?? 0.0;
                final isOver = spent > entry.value;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        entry.key,
                        style: const TextStyle(color: Colors.white70),
                      ),
                      Row(
                        children: [
                          Text(
                            _currencyFormat.format(spent),
                            style: TextStyle(
                              color: isOver ? Colors.redAccent : Colors.white,
                              fontWeight: isOver
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                            ),
                          ),
                          if (isOver)
                            const Padding(
                              padding: EdgeInsets.only(left: 6),
                              child: Icon(
                                Icons.warning_amber_rounded,
                                color: Colors.redAccent,
                                size: 14,
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),

          const SizedBox(height: 32),

          // Action Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _isSaving ? null : _confirmAndLock,
              style: ElevatedButton.styleFrom(
                backgroundColor: BudgetrColors.success,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 0,
              ),
              child: _isSaving
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : const Text(
                      "Confirm & Lock Budget",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
            ),
          ),
          const SizedBox(height: 12),
          const Center(
            child: Text(
              "This action cannot be undone.",
              style: TextStyle(color: Colors.white24, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(
    String label,
    double amount,
    Color color, {
    bool isBold = false,
    double scale = 1.0,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withOpacity(0.6),
            fontSize: 14 * scale,
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        Text(
          _currencyFormat.format(amount),
          style: TextStyle(
            color: color,
            fontSize: 16 * scale,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
