import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../core/models/percentage_config_model.dart';
import '../../../core/models/settlement_model.dart';

// --- DESIGN SYSTEM IMPORTS ---
import '../../../core/design/budgetr_colors.dart';
import '../../../core/design/budgetr_styles.dart';

class SettlementTable extends StatelessWidget {
  final Settlement settlement;
  final PercentageConfig?
      percentageConfig; // Deprecated for sorting, kept for API compat
  final NumberFormat currencyFormat;

  const SettlementTable({
    super.key,
    required this.settlement,
    this.percentageConfig,
    required this.currencyFormat,
  });

  @override
  Widget build(BuildContext context) {
    // 1. Prepare Data
    final entries = settlement.allocations.entries.toList();

    // 2. Sort Logic
    if (settlement.bucketOrder.isNotEmpty) {
      // Priority: Sort by persisted bucket order
      entries.sort((a, b) {
        int idxA = settlement.bucketOrder.indexOf(a.key);
        int idxB = settlement.bucketOrder.indexOf(b.key);
        if (idxA == -1) idxA = 999;
        if (idxB == -1) idxB = 999;
        return idxA.compareTo(idxB);
      });
    } else if (percentageConfig != null) {
      // Fallback: Settings order
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
      // Fallback: Value
      entries.sort((a, b) => b.value.compareTo(a.value));
    }

    // 3. Build Table Rows
    List<TableRow> tableRows = [];

    // --- Header Row ---
    tableRows.add(
      TableRow(
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.05),
          border: Border(
            bottom: BorderSide(color: Colors.white.withOpacity(0.1)),
          ),
        ),
        children: [
          _buildHeaderCell('Bucket', Alignment.centerLeft),
          _buildHeaderCell('Allocated', Alignment.centerRight),
          _buildHeaderCell('Spent / Bal', Alignment.centerRight),
        ],
      ),
    );

    // --- Data Rows ---
    for (var entry in entries) {
      final key = entry.key;
      final allocated = entry.value;
      final spent = settlement.expenses[key] ?? 0.0;
      final balance = allocated - spent;

      tableRows.add(
        TableRow(
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(color: Colors.white.withOpacity(0.02)),
            ),
          ),
          children: [
            _buildCell(key, Alignment.centerLeft, style: BudgetrStyles.body),
            _buildCell(
              currencyFormat.format(allocated),
              Alignment.centerRight,
              style: BudgetrStyles.body,
            ),
            _buildDoubleCell(spent, balance, Alignment.centerRight),
          ],
        ),
      );
    }

    // --- Total Row ---
    tableRows.add(
      TableRow(
        decoration: BoxDecoration(
          color: BudgetrColors.accent.withOpacity(0.15),
        ),
        children: [
          _buildCell(
            'TOTAL',
            Alignment.centerLeft,
            style: const TextStyle(
              fontWeight: FontWeight.w900,
              color: Colors.white,
              letterSpacing: 1,
            ),
          ),
          _buildCell(
            currencyFormat.format(settlement.totalIncome),
            Alignment.centerRight,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          _buildDoubleCell(
            settlement.totalExpense,
            settlement.totalBalance,
            Alignment.centerRight,
            isTotal: true,
          ),
        ],
      ),
    );

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: BudgetrColors.cardSurface.withOpacity(0.6),
        borderRadius: BudgetrStyles.radiusM,
        border: BudgetrStyles.glassBorder,
      ),
      child: ClipRRect(
        borderRadius: BudgetrStyles.radiusM,
        child: Table(
          columnWidths: const {
            // [Adjusted] Reduced width of first column slightly to give more room to numbers
            0: FlexColumnWidth(1.2),
            1: FlexColumnWidth(1.0),
            2: FlexColumnWidth(1.0),
          },
          defaultVerticalAlignment: TableCellVerticalAlignment.middle,
          children: tableRows,
        ),
      ),
    );
  }

  // --- Helper Widgets ---

  Widget _buildHeaderCell(String text, Alignment alignment) {
    return Padding(
      // [Adjusted] Reduced horizontal padding from 16 to 8 to prevent overflow
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
      child: Align(
        alignment: alignment,
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            text,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: BudgetrColors.accent,
              fontSize: 13,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCell(String text, Alignment alignment, {TextStyle? style}) {
    return Padding(
      // [Adjusted] Reduced horizontal padding from 16 to 8
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
      child: Align(
        alignment: alignment,
        child: FittedBox(
          fit: BoxFit.scaleDown,
          alignment: alignment,
          child: Text(text, style: style ?? BudgetrStyles.body),
        ),
      ),
    );
  }

  Widget _buildDoubleCell(
    double v1,
    double v2,
    Alignment alignment, {
    bool isTotal = false,
  }) {
    return Padding(
      // [Adjusted] Reduced horizontal padding from 16 to 8
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      child: Align(
        alignment: alignment,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerRight,
              child: Text(
                currencyFormat.format(v1),
                style: isTotal
                    ? const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      )
                    : BudgetrStyles.body,
              ),
            ),
            FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerRight,
              child: Text(
                currencyFormat.format(v2),
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: v2 >= 0 ? BudgetrColors.success : BudgetrColors.error,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
