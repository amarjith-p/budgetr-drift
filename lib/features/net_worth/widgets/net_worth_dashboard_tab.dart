import 'package:budget/core/widgets/status_bottom_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get_it/get_it.dart';
import 'package:intl/intl.dart';

import '../../../core/models/net_worth_model.dart';
import '../../../core/widgets/modern_loader.dart';
import '../services/net_worth_service.dart';
import 'net_worth_chart.dart';
import 'net_worth_input_sheet.dart';

// --- DESIGN SYSTEM IMPORTS ---
import '../../../core/design/budgetr_colors.dart';
import '../../../core/design/budgetr_styles.dart';
import '../../../core/design/budgetr_components.dart';

class NetWorthDashboardTab extends StatefulWidget {
  const NetWorthDashboardTab({super.key});

  @override
  State<NetWorthDashboardTab> createState() => _NetWorthDashboardTabState();
}

class _NetWorthDashboardTabState extends State<NetWorthDashboardTab> {
  final _netWorthService = GetIt.I<NetWorthService>();
  final _currencyFormat = NumberFormat.currency(locale: 'en_IN', symbol: '₹');
  final _shortCurrency = NumberFormat.compactCurrency(
    symbol: '₹',
    locale: 'en_IN',
  );
  final DateFormat _dateFormat = DateFormat('dd MMM yyyy');

  Future<void> _deleteRecord(String id) async {
    // bool confirm = await showDialog(
    //       context: context,
    //       builder: (ctx) => AlertDialog(
    //         backgroundColor: BudgetrColors.cardSurface,
    //         title: Text('Delete Record?', style: BudgetrStyles.h2),
    //         content: Text('This cannot be undone.', style: BudgetrStyles.body),
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
    //               style: TextStyle(color: BudgetrColors.error),
    //             ),
    //           ),
    //         ],
    //       ),
    //     ) ??
    //     false;

    // if (confirm) await _netWorthService.deleteNetWorthRecord(id);

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
        await _netWorthService.deleteNetWorthRecord(id);
      },
    );
  }

  void _showInputSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      useSafeArea: true,
      builder: (context) => const NetWorthInputSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<NetWorthRecord>>(
      stream: _netWorthService.getNetWorthRecords(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: ModernLoader());
        }

        final records = snapshot.data ?? [];
        final sortedRecords = List<NetWorthRecord>.from(records)
          ..sort((a, b) => a.date.compareTo(b.date));

        List<Map<String, dynamic>> tableData = [];
        for (int i = 0; i < sortedRecords.length; i++) {
          double diff = 0;
          if (i > 0) {
            diff = sortedRecords[i].amount - sortedRecords[i - 1].amount;
          }
          tableData.add({'record': sortedRecords[i], 'diff': diff});
        }
        tableData = tableData.reversed.toList();

        if (records.isEmpty) return _buildEmptyState();

        double current = sortedRecords.last.amount;
        double previous = sortedRecords.length > 1
            ? sortedRecords[sortedRecords.length - 2].amount
            : 0;
        double growth = current - previous;

        return Stack(
          children: [
            SingleChildScrollView(
              padding: const EdgeInsets.only(bottom: 100),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    // --- Summary Card ---
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            BudgetrColors.cardSurface,
                            BudgetrColors.cardSurface.withOpacity(0.8),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(12),
                        border: BudgetrStyles.glassBorder,
                        boxShadow: BudgetrStyles.glowBoxShadow(
                          BudgetrColors.accent,
                        ),
                      ),
                      child: Column(
                        children: [
                          Text(
                            "CURRENT NET WORTH",
                            style: BudgetrStyles.caption.copyWith(
                              color: BudgetrColors.accent,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.5,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _currencyFormat.format(current),
                            style: BudgetrStyles.h1.copyWith(
                              fontSize: 32,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 8),
                          if (sortedRecords.length > 1)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: (growth >= 0
                                        ? BudgetrColors.success
                                        : BudgetrColors.error)
                                    .withOpacity(0.2),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    growth >= 0
                                        ? Icons.trending_up
                                        : Icons.trending_down,
                                    color: growth >= 0
                                        ? BudgetrColors.success
                                        : BudgetrColors.error,
                                    size: 16,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    "${growth >= 0 ? '+' : ''}${_shortCurrency.format(growth)}",
                                    style: TextStyle(
                                      color: growth >= 0
                                          ? BudgetrColors.success
                                          : BudgetrColors.error,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // --- Chart ---
                    NetWorthChart(
                      sortedRecords: sortedRecords,
                      currencyFormat: _currencyFormat,
                      accentColor: BudgetrColors.accent,
                    ),

                    const SizedBox(height: 24),

                    // --- History Table ---
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        "History Log",
                        style: BudgetrStyles.h3.copyWith(
                          color: Colors.white.withOpacity(0.7),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),

                    Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: BudgetrColors.cardSurface.withOpacity(0.6),
                        borderRadius: BudgetrStyles.radiusM,
                        border: BudgetrStyles.glassBorder,
                      ),
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: DataTable(
                          headingRowColor: MaterialStateProperty.all(
                            Colors.white.withOpacity(0.05),
                          ),
                          columnSpacing: 24,
                          columns: [
                            DataColumn(
                              label: Text(
                                'DATE',
                                style: BudgetrStyles.caption.copyWith(
                                  color: BudgetrColors.accent,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            DataColumn(
                              label: Text(
                                'NET WORTH',
                                style: BudgetrStyles.caption.copyWith(
                                  color: BudgetrColors.accent,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              numeric: true,
                            ),
                            DataColumn(
                              label: Text(
                                'DIFFERENCE',
                                style: BudgetrStyles.caption.copyWith(
                                  color: BudgetrColors.accent,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              numeric: true,
                            ),
                            const DataColumn(label: Text('')),
                          ],
                          rows: tableData.map((data) {
                            final record = data['record'] as NetWorthRecord;
                            final diff = data['diff'] as double;

                            return DataRow(
                              cells: [
                                DataCell(
                                  Text(
                                    _dateFormat.format(record.date),
                                    style: BudgetrStyles.body.copyWith(
                                      fontSize: 13,
                                    ),
                                  ),
                                ),
                                DataCell(
                                  Text(
                                    _currencyFormat.format(record.amount),
                                    style: BudgetrStyles.body.copyWith(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 13,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                                DataCell(
                                  Text(
                                    diff == 0
                                        ? '-'
                                        : '${diff > 0 ? '+' : ''}${_currencyFormat.format(diff)}',
                                    style: TextStyle(
                                      color: diff > 0
                                          ? BudgetrColors.success
                                          : (diff < 0
                                              ? BudgetrColors.error
                                              : Colors.white30),
                                      fontWeight: FontWeight.bold,
                                      fontSize: 13,
                                    ),
                                  ),
                                ),
                                DataCell(
                                  IconButton(
                                    icon: const Icon(
                                      Icons.delete_outline,
                                      size: 18,
                                      color: Colors.white30,
                                    ),
                                    onPressed: () => _deleteRecord(record.id),
                                  ),
                                ),
                              ],
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // --- Floating Action Button (Capsule) ---
            Positioned(
              bottom: 20,
              left: 0,
              right: 0,
              child: Center(
                child: GestureDetector(
                  onTap: () {
                    HapticFeedback.lightImpact();
                    _showInputSheet();
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 16,
                    ),
                    decoration: BoxDecoration(
                      gradient: BudgetrColors.primaryGradient,
                      borderRadius: BorderRadius.circular(30),
                      boxShadow: BudgetrStyles.glowBoxShadow(
                        BudgetrColors.accent,
                      ),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.2),
                        width: 1,
                      ),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.add_chart_rounded, color: Colors.white),
                        SizedBox(width: 12),
                        Text(
                          "Update Net Worth",
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

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: BudgetrColors.accent.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.currency_rupee,
              size: 48,
              color: BudgetrColors.accent,
            ),
          ),
          const SizedBox(height: 24),
          Text("Start Tracking Wealth", style: BudgetrStyles.h2),
          const SizedBox(height: 8),
          Text(
            "Add your assets and liabilities\nto see your net worth grow.",
            textAlign: TextAlign.center,
            style: BudgetrStyles.body.copyWith(
              color: Colors.white.withOpacity(0.5),
            ),
          ),
          const SizedBox(height: 40),
          GestureDetector(
            onTap: () => _showInputSheet(),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
              decoration: BoxDecoration(
                gradient: BudgetrColors.primaryGradient,
                borderRadius: BorderRadius.circular(12),
                boxShadow: BudgetrStyles.glowBoxShadow(BudgetrColors.accent),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.add, color: Colors.white, size: 20),
                  SizedBox(width: 8),
                  Text(
                    "Add First Entry",
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
        ],
      ),
    );
  }
}
