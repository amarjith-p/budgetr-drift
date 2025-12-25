import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

import '../../../core/models/net_worth_model.dart';
import '../../../core/widgets/modern_loader.dart';
import '../services/net_worth_service.dart';
import 'net_worth_chart.dart';
import 'net_worth_input_sheet.dart';

class NetWorthDashboardTab extends StatefulWidget {
  const NetWorthDashboardTab({super.key});

  @override
  State<NetWorthDashboardTab> createState() => _NetWorthDashboardTabState();
}

class _NetWorthDashboardTabState extends State<NetWorthDashboardTab> {
  final _netWorthService = NetWorthService();
  final _currencyFormat = NumberFormat.currency(locale: 'en_IN', symbol: '₹');
  final _shortCurrency = NumberFormat.compactCurrency(
    symbol: '₹',
    locale: 'en_IN',
  );
  final DateFormat _dateFormat = DateFormat('dd MMM yyyy');

  final Color _cardColor = const Color(0xFF1B263B).withOpacity(0.6);
  final Color _accentColor = const Color(0xFF2EC4B6);
  final Color _greenColor = const Color(0xFF00E676);
  final Color _redColor = const Color(0xFFFF5252);

  Future<void> _deleteRecord(String id) async {
    bool confirm =
        await showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            backgroundColor: const Color(0xFF0D1B2A),
            title: const Text(
              'Delete Record?',
              style: TextStyle(color: Colors.white),
            ),
            content: const Text(
              'This cannot be undone.',
              style: TextStyle(color: Colors.white70),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: const Text(
                  'Cancel',
                  style: TextStyle(color: Colors.white70),
                ),
              ),
              TextButton(
                onPressed: () => Navigator.pop(ctx, true),
                child: const Text(
                  'Delete',
                  style: TextStyle(color: Colors.redAccent),
                ),
              ),
            ],
          ),
        ) ??
        false;

    if (confirm) await _netWorthService.deleteNetWorthRecord(id);
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
                    // Summary Card
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [_cardColor, _cardColor.withOpacity(0.8)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.05),
                        ),
                        boxShadow: const [
                          BoxShadow(
                            color: Colors.black26,
                            blurRadius: 10,
                            offset: Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          Text(
                            "CURRENT NET WORTH",
                            style: TextStyle(
                              color: _accentColor,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.5,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _currencyFormat.format(current),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
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
                                color: (growth >= 0 ? _greenColor : _redColor)
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
                                        ? _greenColor
                                        : _redColor,
                                    size: 16,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    "${growth >= 0 ? '+' : ''}${_shortCurrency.format(growth)}",
                                    style: TextStyle(
                                      color: growth >= 0
                                          ? _greenColor
                                          : _redColor,
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

                    // Refactored Chart Widget
                    NetWorthChart(
                      sortedRecords: sortedRecords,
                      currencyFormat: _currencyFormat,
                      accentColor: _accentColor,
                    ),

                    const SizedBox(height: 24),

                    // Table
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        "History Log",
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.7),
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),

                    Container(
                      decoration: BoxDecoration(
                        color: _cardColor,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.05),
                        ),
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
                                style: TextStyle(
                                  color: _accentColor,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 11,
                                ),
                              ),
                            ),
                            DataColumn(
                              label: Text(
                                'NET WORTH',
                                style: TextStyle(
                                  color: _accentColor,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 11,
                                ),
                              ),
                              numeric: true,
                            ),
                            DataColumn(
                              label: Text(
                                'DIFFERENCE',
                                style: TextStyle(
                                  color: _accentColor,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 11,
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
                                    style: const TextStyle(
                                      color: Colors.white70,
                                      fontSize: 13,
                                    ),
                                  ),
                                ),
                                DataCell(
                                  Text(
                                    _currencyFormat.format(record.amount),
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 13,
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
                                          ? _greenColor
                                          : (diff < 0
                                                ? _redColor
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

            // Floating Capsule
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
                      gradient: LinearGradient(
                        colors: [_accentColor, const Color(0xFF2563EB)],
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
              color: _accentColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.currency_rupee, size: 48, color: _accentColor),
          ),
          const SizedBox(height: 24),
          const Text(
            "Start Tracking Wealth",
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "Add your assets and liabilities\nto see your net worth grow.",
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white.withOpacity(0.5)),
          ),
          const SizedBox(height: 40),
          ElevatedButton.icon(
            onPressed: _showInputSheet,
            style: ElevatedButton.styleFrom(
              backgroundColor: _accentColor,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            icon: const Icon(Icons.add),
            label: const Text("Add First Entry"),
          ),
        ],
      ),
    );
  }
}
