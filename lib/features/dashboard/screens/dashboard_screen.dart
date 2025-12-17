import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../core/models/financial_record_model.dart';
import '../../../core/services/firestore_service.dart';
import '../../settings/screens/settings_screen.dart';
import '../../settlement/screens/settlement_screen.dart';
import '../widgets/add_record_sheet.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final FirestoreService firestoreService = FirestoreService();
    final currencyFormat = NumberFormat.currency(locale: 'en_IN', symbol: '₹');

    void showAddRecordSheet([FinancialRecord? recordToEdit]) {
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        builder: (context) => AddRecordSheet(recordToEdit: recordToEdit),
      );
    }

    void confirmDelete(String id) {
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Delete Budget Record?'),
          content: const Text(
            'This will permanently delete this month\'s record. This action cannot be undone.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                firestoreService.deleteFinancialRecord(id);
                Navigator.pop(ctx);
              },
              child: const Text('Delete', style: TextStyle(color: Colors.red)),
            ),
          ],
        ),
      );
    }

    void showActionSheet(FinancialRecord record) {
      showModalBottomSheet(
        context: context,
        backgroundColor: Colors.transparent,
        builder: (context) => BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: const Color(0xff0D1B2A).withOpacity(0.9),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(24),
              ),
              border: Border(
                top: BorderSide(color: Colors.white.withOpacity(0.1)),
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 24),
                  decoration: BoxDecoration(
                    color: Colors.grey,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                Text(
                  DateFormat(
                    'MMMM yyyy',
                  ).format(DateTime(record.year, record.month)),
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 32),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildActionButton(
                      context,
                      icon: Icons.edit_outlined,
                      label: 'Edit',
                      color: Colors.blueAccent,
                      onTap: () {
                        Navigator.pop(context);
                        showAddRecordSheet(record);
                      },
                    ),
                    _buildActionButton(
                      context,
                      icon: Icons.delete_outline,
                      label: 'Delete',
                      color: Colors.redAccent,
                      onTap: () {
                        Navigator.pop(context);
                        confirmDelete(record.id);
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Budget Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.receipt_long_outlined),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (c) => const SettlementScreen()),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (c) => const SettingsScreen()),
            ),
          ),
        ],
      ),
      body: StreamBuilder<List<FinancialRecord>>(
        stream: firestoreService.getFinancialRecords(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting)
            return const Center(child: CircularProgressIndicator());
          if (snapshot.hasError)
            return Center(child: Text('Error: ${snapshot.error}'));
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text(
                'No records found.\nPress the + button to add one!',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 18, color: Colors.white70),
              ),
            );
          }

          final records = snapshot.data!;

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: records.length,
            itemBuilder: (context, index) {
              final record = records[index];
              final sortedAllocations = record.allocations.entries.toList()
                ..sort((a, b) => b.value.compareTo(a.value));

              return GestureDetector(
                onLongPress: () => showActionSheet(record),
                child: Card(
                  margin: const EdgeInsets.only(bottom: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              DateFormat(
                                'MMMM yyyy',
                              ).format(DateTime(record.year, record.month)),
                              style: Theme.of(context).textTheme.titleLarge
                                  ?.copyWith(color: Colors.white),
                            ),
                            // Helper hint for interaction
                            const Icon(
                              Icons.touch_app_outlined,
                              size: 16,
                              color: Colors.white24,
                            ),
                          ],
                        ),
                        const Divider(height: 20, color: Colors.white12),
                        _buildRecordDetailRow(
                          'Salary:',
                          currencyFormat.format(record.salary),
                          context,
                        ),
                        if (record.extraIncome > 0)
                          _buildRecordDetailRow(
                            'Extra Income:',
                            currencyFormat.format(record.extraIncome),
                            context,
                          ),
                        if (record.emi > 0)
                          _buildRecordDetailRow(
                            'EMI:',
                            currencyFormat.format(record.emi),
                            context,
                          ),
                        const SizedBox(height: 12),
                        Text(
                          'Effective Income: ${currencyFormat.format(record.effectiveIncome)}',
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(
                                color: Theme.of(context).colorScheme.primary,
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        const SizedBox(height: 12),
                        ...sortedAllocations.map((entry) {
                          final percent =
                              record.allocationPercentages[entry.key]
                                  ?.toStringAsFixed(0) ??
                              '?';
                          return _buildRecordDetailRow(
                            '${entry.key} ($percent%):',
                            currencyFormat.format(entry.value),
                            context,
                          );
                        }),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => showAddRecordSheet(),
        icon: const Icon(Icons.add),
        label: const Text('Add Record'),
      ),
    );
  }

  Widget _buildActionButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: 120,
        padding: const EdgeInsets.symmetric(vertical: 24),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          children: [
            Icon(icon, size: 32, color: color),
            const SizedBox(height: 12),
            Text(
              label,
              style: TextStyle(color: color, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecordDetailRow(
    String title,
    String value,
    BuildContext context,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: Theme.of(
              context,
            ).textTheme.bodyLarge?.copyWith(color: Colors.white70),
          ),
          Text(
            value,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              fontWeight: FontWeight.w500,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}
