import 'package:budget/core/design/budgetr_colors.dart';
import 'package:budget/core/widgets/status_bottom_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get_it/get_it.dart';
import 'package:intl/intl.dart';

import '../../../core/models/net_worth_split_model.dart';
import '../../../core/widgets/date_filter_row.dart';
import '../../../core/widgets/modern_loader.dart';
import '../services/net_worth_service.dart';
import 'split_input_sheet.dart';

class NetWorthSplitsTab extends StatefulWidget {
  const NetWorthSplitsTab({super.key});

  @override
  State<NetWorthSplitsTab> createState() => _NetWorthSplitsTabState();
}

class _NetWorthSplitsTabState extends State<NetWorthSplitsTab> {
  final NetWorthService _netWorthService = GetIt.I<NetWorthService>();
  final NumberFormat _currencyFormat = NumberFormat.currency(
    locale: 'en_IN',
    symbol: '₹',
  );
  final DateFormat _dateFormat = DateFormat('dd MMM yyyy');
  final Color _cardColor = const Color(0xFF1B263B).withOpacity(0.6);

  final Color _greenColor = const Color(0xFF00E676);
  final Color _redColor = const Color(0xFFFF5252);
  final Color _accentColor = const Color(0xFF2EC4B6);

  int? _filterYear;
  int? _filterMonth;

  Future<void> _deleteSplit(String id) async {
    // bool confirm =
    //     await showDialog(
    //       context: context,
    //       builder: (ctx) => AlertDialog(
    //         backgroundColor: const Color(0xFF0D1B2A),
    //         title: const Text(
    //           'Delete Record?',
    //           style: TextStyle(color: Colors.white),
    //         ),
    //         content: const Text(
    //           'This cannot be undone.',
    //           style: TextStyle(color: Colors.white70),
    //         ),
    //         actions: [
    //           TextButton(
    //             onPressed: () => Navigator.pop(ctx, false),
    //             child: const Text(
    //               'Cancel',
    //               style: TextStyle(color: Colors.white70),
    //             ),
    //           ),
    //           TextButton(
    //             onPressed: () => Navigator.pop(ctx, true),
    //             child: const Text(
    //               'Delete',
    //               style: TextStyle(color: Colors.redAccent),
    //             ),
    //           ),
    //         ],
    //       ),
    //     ) ??
    //     false;
    // if (confirm) await _netWorthService.deleteNetWorthSplit(id);

    showStatusSheet(
      context: context,
      title: "Delete Record?",
      message:
          "Are you sure you want to remove this transaction? This action cannot be undone.",
      icon: Icons.delete_sweep_sharp,
      color: Colors.redAccent,
      cancelButtonText: "Cancel",
      onCancel: () {},
      buttonText: "Delete",
      onDismiss: () async {
        await _netWorthService.deleteNetWorthSplit(id);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<NetWorthSplit>>(
      stream: _netWorthService.getNetWorthSplits(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: ModernLoader());
        }
        var records = snapshot.data ?? [];

        var filteredRecords = records.where((record) {
          bool matchesYear =
              _filterYear == null || record.date.year == _filterYear;
          bool matchesMonth =
              _filterMonth == null || record.date.month == _filterMonth;
          return matchesYear && matchesMonth;
        }).toList();

        filteredRecords.sort((a, b) => b.date.compareTo(a.date));

        return Stack(
          children: [
            Column(
              children: [
                _buildFilters(records),
                Expanded(
                  child: filteredRecords.isEmpty
                      ? Center(
                          child: Text(
                            'No split records found',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.5),
                            ),
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.only(
                            bottom: 100,
                            left: 16,
                            right: 16,
                          ),
                          itemCount: filteredRecords.length,
                          itemBuilder: (context, index) {
                            final split = filteredRecords[index];
                            return _buildSplitCard(split);
                          },
                        ),
                ),
              ],
            ),
            // Floating Action Button
            Positioned(
              bottom: 20,
              left: 0,
              right: 0,
              child: Center(
                child: GestureDetector(
                  onTap: () {
                    HapticFeedback.lightImpact();
                    showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      useSafeArea: true,
                      backgroundColor: Colors.transparent,
                      builder: (context) => const SplitInputSheet(),
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 16,
                    ),
                    decoration: BoxDecoration(
                      // gradient: LinearGradient(
                      //   colors: [_accentColor, const Color(0xFF2563EB)],
                      // ),
                      color: BudgetrColors.accent,
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
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.playlist_add_rounded, color: Colors.white),
                        SizedBox(width: 12),
                        Text(
                          "Add New Split",
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
    );
  }

  Widget _buildFilters(List<NetWorthSplit> allRecords) {
    final years = allRecords.map((e) => e.date.year).toSet().toList();
    years.sort((a, b) => b.compareTo(a));
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: _cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: DateFilterRow(
        selectedYear: _filterYear,
        selectedMonth: _filterMonth,
        availableYears: years,
        availableMonths: List.generate(12, (i) => i + 1),
        onYearSelected: (val) => setState(() {
          _filterYear = val;
          if (val == null) _filterMonth = null;
        }),
        onMonthSelected: (val) => setState(() => _filterMonth = val),
      ),
    );
  }

  Widget _buildSplitCard(NetWorthSplit split) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: _cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(
          dividerColor: Colors.transparent,
          iconTheme: const IconThemeData(color: Colors.white70),
        ),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _dateFormat.format(split.date),
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Colors.white,
                ),
              ),
              Text(
                _currencyFormat.format(split.effectiveSavings),
                style: TextStyle(
                  color: split.effectiveSavings >= 0 ? _greenColor : _redColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
              child: Column(
                children: [
                  const Divider(color: Colors.white10),
                  _detailRow('Income', split.effectiveIncome, _greenColor),
                  _detailRow('Expense', split.effectiveExpense, _redColor),
                  const SizedBox(height: 12),
                  _subRow('Net Income', split.netIncome),
                  _subRow('Capital Gain', split.capitalGain),
                  _subRow('Non-Calc Income', split.nonCalcIncome),
                  const SizedBox(height: 8),
                  _subRow('Net Expense', split.netExpense),
                  _subRow('Capital Loss', split.capitalLoss),
                  _subRow('Non-Calc Expense', split.nonCalcExpense),
                  const SizedBox(height: 16),
                  Align(
                    alignment: Alignment.centerRight,
                    child: OutlinedButton.icon(
                      onPressed: () => _deleteSplit(split.id),
                      icon: const Icon(
                        Icons.delete_outline,
                        size: 16,
                        color: Colors.redAccent,
                      ),
                      label: const Text(
                        "Delete",
                        style: TextStyle(color: Colors.redAccent),
                      ),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(
                          color: Colors.redAccent.withOpacity(0.3),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _detailRow(String label, double amount, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.white)),
          Text(
            _currencyFormat.format(amount),
            style: TextStyle(color: color, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _subRow(String label, double amount) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.white.withOpacity(0.5),
            ),
          ),
          Text(
            _currencyFormat.format(amount),
            style: TextStyle(
              fontSize: 12,
              color: Colors.white.withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }
}
