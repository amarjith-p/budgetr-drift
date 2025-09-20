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

    void _showAddRecordSheet() {
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        builder: (context) => const AddRecordSheet(),
      );
    }

    void _navigateToSettings() {
      Navigator.of(
        context,
      ).push(MaterialPageRoute(builder: (context) => const SettingsScreen()));
    }

    void _navigateToSettlement() {
      Navigator.of(
        context,
      ).push(MaterialPageRoute(builder: (context) => const SettlementScreen()));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Budget Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.receipt_long_outlined),
            onPressed: _navigateToSettlement,
            tooltip: 'Monthly Settlement',
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: _navigateToSettings,
            tooltip: 'Settings',
          ),
        ],
      ),
      body: StreamBuilder<List<FinancialRecord>>(
        stream: firestoreService.getFinancialRecords(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
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
              final displayDate = DateTime(record.year, record.month);
              final headerFormat = DateFormat('MMMM yyyy');
              return Card(
                margin: const EdgeInsets.only(bottom: 16),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        headerFormat.format(displayDate),
                        style: Theme.of(
                          context,
                        ).textTheme.titleLarge?.copyWith(color: Colors.white),
                      ),
                      const Divider(height: 20, color: Colors.white12),
                      _buildRecordDetailRow(
                        'Salary:',
                        currencyFormat.format(record.salary),
                        context,
                      ),
                      _buildRecordDetailRow(
                        'Extra Income:',
                        currencyFormat.format(record.extraIncome),
                        context,
                      ),
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
                      _buildRecordDetailRow(
                        'Necessities (${record.necessitiesPercentage.toStringAsFixed(0)}%):',
                        currencyFormat.format(record.necessities),
                        context,
                      ),
                      _buildRecordDetailRow(
                        'Lifestyle (${record.lifestylePercentage.toStringAsFixed(0)}%):',
                        currencyFormat.format(record.lifestyle),
                        context,
                      ),
                      _buildRecordDetailRow(
                        'Investment (${record.investmentPercentage.toStringAsFixed(0)}%):',
                        currencyFormat.format(record.investment),
                        context,
                      ),
                      _buildRecordDetailRow(
                        'Emergency (${record.emergencyPercentage.toStringAsFixed(0)}%):',
                        currencyFormat.format(record.emergency),
                        context,
                      ),
                      _buildRecordDetailRow(
                        'Buffer (${record.bufferPercentage.toStringAsFixed(0)}%):',
                        currencyFormat.format(record.buffer),
                        context,
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddRecordSheet,
        icon: const Icon(Icons.add),
        label: const Text('Add Record'),
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
