import 'dart:convert';
import 'package:drift/drift.dart';
import '../../../core/database/app_database.dart' as db;
import '../../../core/models/settlement_model.dart';

class SettlementService {
  final db.AppDatabase _db = db.AppDatabase.instance;

  // --- Helper to safely decode Map<String, double> ---
  Map<String, double> _decodeMap(String jsonStr) {
    try {
      final Map<String, dynamic> decoded = jsonDecode(jsonStr);
      return decoded.map((k, v) => MapEntry(k, (v as num).toDouble()));
    } catch (e) {
      return {};
    }
  }

  Future<List<Map<String, int>>> getAvailableMonthsForSettlement() async {
    // Queries financial records (Budgets) to see which months exist
    final records = await _db.select(_db.financialRecords).get();
    final uniqueMonths = <String, Map<String, int>>{};

    for (var row in records) {
      // Use ID as key to ensure uniqueness per month
      uniqueMonths[row.id] = {'year': row.year, 'month': row.month};
    }

    var sortedList = uniqueMonths.values.toList();
    sortedList.sort((a, b) {
      // Sort Descending (Newest first)
      if (b['year']! != a['year']!) return b['year']!.compareTo(a['year']!);
      return b['month']!.compareTo(a['month']!);
    });
    return sortedList;
  }

  Future<Settlement?> getSettlementById(String id) async {
    final row = await (_db.select(_db.settlements)
          ..where((t) => t.id.equals(id)))
        .getSingleOrNull();

    if (row != null) {
      return Settlement(
        id: row.id,
        year: row.year,
        month: row.month,
        allocations: _decodeMap(row.allocations),
        expenses: _decodeMap(row.expenses),
        totalIncome: row.totalIncome,
        totalExpense: row.totalExpense,
        settledAt: row.settledAt,
        bucketOrder: List<String>.from(jsonDecode(row.bucketOrder)),
      );
    }
    return null;
  }

  /// Checks if a specific month is already settled
  Future<bool> isMonthSettled(int year, int month) async {
    final id = '$year${month.toString().padLeft(2, '0')}';
    final row = await (_db.select(_db.settlements)
          ..where((t) => t.id.equals(id)))
        .getSingleOrNull();
    return row != null;
  }

  Future<void> saveSettlement(Settlement settlement) async {
    await _db
        .into(_db.settlements)
        .insertOnConflictUpdate(db.SettlementsCompanion.insert(
          id: settlement.id,
          year: settlement.year,
          month: settlement.month,
          allocations: jsonEncode(settlement.allocations),
          expenses: jsonEncode(settlement.expenses),
          bucketOrder: jsonEncode(settlement.bucketOrder),
          totalIncome: Value(settlement.totalIncome),
          totalExpense: Value(settlement.totalExpense),
          settledAt: settlement.settledAt,
        ));
  }
}
