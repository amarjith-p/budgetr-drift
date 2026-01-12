import 'dart:convert';
import 'package:drift/drift.dart' as drift;
import 'package:uuid/uuid.dart';
import '../../../../core/database/app_database.dart';
// ALIAS MODELS
import '../../../core/models/net_worth_model.dart' as domain;
import 'net_worth_service.dart';

class DriftNetWorthService extends NetWorthService {
  final AppDatabase _db = AppDatabase.instance;
  final _uuid = const Uuid();

  // --- Mappers ---
  domain.NetWorthRecord _mapRecord(NetWorthRecord row) {
    return domain.NetWorthRecord(
      id: row.id,
      // Fix: Direct DateTime assignment
      date: row.date,
      // Fix: Map 'totalAmount' (Table) to 'amount' (Model)
      amount: row.totalAmount,
    );
  }

  // --- Implementation ---
  @override
  Stream<List<domain.NetWorthRecord>> getNetWorthRecords() {
    return (_db.select(_db.netWorthRecords)
          ..orderBy([
            (t) => drift.OrderingTerm(
                expression: t.date, mode: drift.OrderingMode.desc)
          ]))
        .watch()
        .map((rows) => rows.map(_mapRecord).toList());
  }

  @override
  Future<void> addNetWorthRecord(domain.NetWorthRecord record) async {
    final id = _uuid.v4();
    await _db.into(_db.netWorthRecords).insert(NetWorthRecordsCompanion.insert(
          id: id,
          // Fix: Direct DateTime assignment
          date: record.date,
          // Fix: Map 'amount' (Model) to 'totalAmount' (Table)
          totalAmount: record.amount,
          // Fix: Pass raw String '{}', NOT drift.Value('{}') because the column is required
          breakdown: '{}',
        ));
  }
}
