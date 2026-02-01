import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:intl/intl.dart';
import '../../../core/design/budgetr_colors.dart';
import '../../../core/design/budgetr_styles.dart';
import '../../../core/models/net_worth_split_model.dart';
import '../services/net_worth_service.dart';
import 'split_input_sheet.dart';

class NetWorthSplitsTab extends StatefulWidget {
  const NetWorthSplitsTab({super.key});

  @override
  State<NetWorthSplitsTab> createState() => _NetWorthSplitsTabState();
}

class _NetWorthSplitsTabState extends State<NetWorthSplitsTab> {
  // Open the new 3-section input sheet
  void _openAddSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const SplitInputSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      // [FIX] Center Floating Action Button
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openAddSheet,
        backgroundColor: BudgetrColors.accent,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text("Add Net Worth Split",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
      body: StreamBuilder<List<NetWorthSplitModel>>(
        stream: GetIt.I<NetWorthService>().getSplits(),
        builder: (context, snapshot) {
          if (!snapshot.hasData)
            return const Center(child: CircularProgressIndicator());
          final splits = snapshot.data!;

          if (splits.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.pie_chart_outline,
                      size: 48, color: Colors.white.withOpacity(0.1)),
                  const SizedBox(height: 16),
                  const Text("No Net Worth entries yet",
                      style: TextStyle(color: Colors.white38)),
                ],
              ),
            );
          }

          return ListView.separated(
            // Extra padding at bottom for the Center Float FAB
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
            itemCount: splits.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              return _NetWorthCard(split: splits[index]);
            },
          );
        },
      ),
    );
  }
}

class _NetWorthCard extends StatefulWidget {
  final NetWorthSplitModel split;
  const _NetWorthCard({required this.split});

  @override
  State<_NetWorthCard> createState() => _NetWorthCardState();
}

class _NetWorthCardState extends State<_NetWorthCard> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final s = widget.split;
    final fullCurrency = NumberFormat('#,##0.00');

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      decoration: BoxDecoration(
        color: BudgetrColors.cardSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Column(
        children: [
          // Header (Always Visible)
          InkWell(
            onTap: () => setState(() => _expanded = !_expanded),
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(8)),
                    child: Column(
                      children: [
                        Text(DateFormat('dd').format(s.date),
                            style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 16)),
                        Text(DateFormat('MMM').format(s.date),
                            style: const TextStyle(
                                color: Colors.white54, fontSize: 10)),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text("Net Worth",
                            style: TextStyle(
                                color: Colors.white38,
                                fontSize: 10,
                                letterSpacing: 1)),
                        const SizedBox(height: 4),
                        Text("₹${fullCurrency.format(s.netWorth)}",
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                  Icon(
                      _expanded
                          ? Icons.keyboard_arrow_up
                          : Icons.keyboard_arrow_down,
                      color: Colors.white38),
                ],
              ),
            ),
          ),

          // Expanded Details (3 Sections)
          AnimatedCrossFade(
            firstChild: const SizedBox(height: 0, width: double.infinity),
            secondChild: Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Column(
                children: [
                  const Divider(color: Colors.white10),
                  const SizedBox(height: 8),

                  // 1. Assets
                  _buildSection(
                      "ASSETS",
                      s.totalAssets,
                      BudgetrColors.success,
                      [
                        _item("Bank A/C", s.bankAccounts),
                        _item("Cash in Hand", s.cashInHand),
                        _item("Mutual Funds", s.mutualFunds),
                        _item("Equity", s.equity),
                        _item("Bonds", s.bonds),
                        _item("Deposits", s.deposits),
                        _item("Real Estate", s.realEstate),
                        _item("Others", s.otherAssets),
                      ],
                      notes: s.assetNotes),

                  const SizedBox(height: 16),

                  // 2. Liabilities
                  _buildSection(
                      "LIABILITIES",
                      s.totalLiabilities,
                      BudgetrColors.error,
                      [
                        _item("Loans", s.loans),
                        _item("Credit Cards", s.creditCardOutstanding),
                        _item("Other Debts", s.otherDebts),
                      ],
                      notes: s.liabilityNotes),

                  const SizedBox(height: 16),

                  // 3. Cashflow
                  _buildSection("CASHFLOW (MONTHLY)", null, Colors.blueAccent, [
                    _item("Budget Income", s.budgetedIncome),
                    _item("Budget Expense", s.budgetedExpense),
                    _item("Non-Calc Income", s.nonCalcIncome),
                    _item("Non-Calc Exp", s.nonCalcExpense),
                    _item("Out of Bucket", s.outOfBucketExpense),
                  ]),

                  const SizedBox(height: 16),

                  // Edit/Delete Actions
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton.icon(
                        icon: const Icon(Icons.edit,
                            size: 16, color: Colors.white70),
                        label: const Text("Edit",
                            style: TextStyle(color: Colors.white70)),
                        onPressed: () => showModalBottomSheet(
                            context: context,
                            isScrollControlled: true,
                            backgroundColor: Colors.transparent,
                            builder: (_) => SplitInputSheet(splitToEdit: s)),
                      ),
                      const SizedBox(width: 8),
                      TextButton.icon(
                        icon: const Icon(Icons.delete,
                            size: 16, color: BudgetrColors.error),
                        label: const Text("Delete",
                            style: TextStyle(color: BudgetrColors.error)),
                        onPressed: () =>
                            GetIt.I<NetWorthService>().deleteSplit(s.id),
                      ),
                    ],
                  )
                ],
              ),
            ),
            crossFadeState: _expanded
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 200),
          )
        ],
      ),
    );
  }

  Widget _buildSection(
      String title, double? total, Color color, List<Widget> items,
      {String? notes}) {
    // Hide zero values to keep UI clean
    final validItems =
        items.where((w) => w is _DetailRow && w.value != 0).toList();
    if (validItems.isEmpty && (notes == null || notes.isEmpty))
      return const SizedBox();

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
          color: Colors.black26, borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title,
                  style: TextStyle(
                      color: color, fontWeight: FontWeight.bold, fontSize: 11)),
              if (total != null)
                Text("₹${NumberFormat.compact().format(total)}",
                    style: TextStyle(
                        color: color,
                        fontWeight: FontWeight.bold,
                        fontSize: 11)),
            ],
          ),
          const SizedBox(height: 8),
          ...validItems,
          if (notes != null && notes.isNotEmpty) ...[
            if (validItems.isNotEmpty) const SizedBox(height: 8),
            Text("Note: $notes",
                style: const TextStyle(
                    color: Colors.white38,
                    fontSize: 11,
                    fontStyle: FontStyle.italic)),
          ]
        ],
      ),
    );
  }

  Widget _item(String label, double val) =>
      _DetailRow(label: label, value: val);
}

class _DetailRow extends StatelessWidget {
  final String label;
  final double value;
  const _DetailRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    if (value == 0) return const SizedBox();
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: const TextStyle(color: Colors.white70, fontSize: 12)),
          Text("₹${NumberFormat('#,##0.##').format(value)}",
              style: const TextStyle(color: Colors.white, fontSize: 12)),
        ],
      ),
    );
  }
}
