import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../core/models/percentage_config_model.dart';
import '../../../core/models/settlement_model.dart';

class SettlementTable extends StatelessWidget {
  final Settlement settlement;
  final PercentageConfig? percentageConfig;
  final NumberFormat currencyFormat;

  const SettlementTable({
    super.key,
    required this.settlement,
    this.percentageConfig,
    required this.currencyFormat,
  });

  @override
  Widget build(BuildContext context) {
    const Color cardColor = Color(0xFF1B263B);
    const Color accentColor = Color(0xFF3A86FF);

    final entries = settlement.allocations.entries.toList();

    // Sorting Logic
    if (percentageConfig != null) {
      entries.sort((a, b) {
        int idxA = percentageConfig!.categories.indexWhere(
          (c) => c.name == a.key,
        );
        int idxB = percentageConfig!.categories.indexWhere(
          (c) => c.name == b.key,
        );
        if (idxA == -1) idxA = 999;
        if (idxB == -1) idxB = 999;
        return idxA.compareTo(idxB);
      });
    } else {
      entries.sort((a, b) => b.value.compareTo(a.value));
    }

    List<DataRow> rows = [];

    for (var entry in entries) {
      final key = entry.key;
      final allocated = entry.value;
      final spent = settlement.expenses[key] ?? 0.0;
      final balance = allocated - spent;
      rows.add(_createDataRow(key, allocated, spent, balance));
    }

    // Total Row
    rows.add(
      DataRow(
        cells: [
          const DataCell(
            Text(
              'TOTAL',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
          DataCell(
            Text(
              currencyFormat.format(settlement.totalIncome),
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
          DataCell(
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  currencyFormat.format(settlement.totalExpense),
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                Text(
                  currencyFormat.format(settlement.totalBalance),
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                    color: settlement.totalBalance >= 0
                        ? Colors.greenAccent
                        : Colors.redAccent,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );

    return Container(
      decoration: BoxDecoration(
        color: cardColor.withOpacity(0.6),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          headingRowColor: MaterialStateProperty.all(
            Colors.white.withOpacity(0.05),
          ),
          columnSpacing: 20,
          columns: [
            DataColumn(
              label: Text(
                'Bucket',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: accentColor,
                ),
              ),
            ),
            DataColumn(
              label: Text(
                'Allocated',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: accentColor,
                ),
              ),
              numeric: true,
            ),
            DataColumn(
              label: Text(
                'Spent / Bal',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: accentColor,
                ),
              ),
              numeric: true,
            ),
          ],
          rows: rows,
        ),
      ),
    );
  }

  DataRow _createDataRow(
    String category,
    double allocated,
    double spent,
    double balance,
  ) {
    return DataRow(
      cells: [
        DataCell(Text(category, style: const TextStyle(color: Colors.white70))),
        DataCell(
          Text(
            currencyFormat.format(allocated),
            style: const TextStyle(color: Colors.white70),
          ),
        ),
        DataCell(
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                currencyFormat.format(spent),
                style: const TextStyle(color: Colors.white70),
              ),
              Text(
                currencyFormat.format(balance),
                style: TextStyle(
                  fontSize: 11,
                  color: balance >= 0
                      ? Colors.greenAccent.withOpacity(0.7)
                      : Colors.redAccent.withOpacity(0.7),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
