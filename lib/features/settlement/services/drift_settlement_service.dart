import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:drift/drift.dart' as drift;
import '../../../../core/database/app_database.dart';
import '../../../core/models/settlement_model.dart' as domain;
import 'settlement_service.dart';

class DriftSettlementService extends SettlementService {
  final AppDatabase _db = AppDatabase.instance;

  @override
  Future<List<Map<String, int>>> getAvailableMonthsForSettlement() async {
    // Select distinct year/month combinations from financial records
    final query = _db.selectOnly(_db.financialRecords, distinct: true)
      ..addColumns([_db.financialRecords.year, _db.financialRecords.month]);

    final result = await query.get();

    return result
        .map((row) => {
              'year': row.read(_db.financialRecords.year)!,
              'month': row.read(_db.financialRecords.month)!,
            })
        .toList()
      ..sort((a, b) => (b['year']! * 100 + b['month']!)
          .compareTo(a['year']! * 100 + a['month']!));
  }

  @override
  Future<domain.Settlement?> getSettlementById(String id) async {
    final row = await (_db.select(_db.settlements)
          ..where((t) => t.id.equals(id)))
        .getSingleOrNull();
    if (row == null) return null;

    return domain.Settlement(
      id: row.id,
      year: row.year,
      month: row.month,
      // Map JSON Text -> Maps/Lists
      allocations: Map<String, double>.from(jsonDecode(row.allocations)),
      expenses: Map<String, double>.from(jsonDecode(row.expenses)),
      bucketOrder: List<String>.from(jsonDecode(row.bucketOrder)),
      // Map correct column names
      totalIncome: row.totalIncome,
      totalExpense: row.totalExpense,
      // Map DateTime -> Timestamp
      settledAt: Timestamp.fromDate(row.settledAt),
    );
  }

  @override
  Future<void> saveSettlement(domain.Settlement s) async {
    await _db
        .into(_db.settlements)
        .insertOnConflictUpdate(SettlementsCompanion.insert(
          id: s.id,
          year: s.year,
          month: s.month,
          // Map fields to Columns
          totalIncome: drift.Value(s.totalIncome),
          totalExpense: drift.Value(s.totalExpense),
          settledAt: s.settledAt.toDate(), // Timestamp -> DateTime
          // Encode complex types to JSON
          allocations: jsonEncode(s.allocations),
          expenses: jsonEncode(s.expenses),
          bucketOrder: jsonEncode(s.bucketOrder),
        ));
  }
}
