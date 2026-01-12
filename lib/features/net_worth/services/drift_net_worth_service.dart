import 'dart:convert';
import 'package:drift/drift.dart' as drift;
import 'package:uuid/uuid.dart';
import '../../../../core/database/app_database.dart';
import '../../../core/models/net_worth_model.dart' as domain;
import 'net_worth_service.dart';

class DriftNetWorthService extends NetWorthService {
  final AppDatabase _db = AppDatabase.instance;
  final _uuid = const Uuid();

  domain.NetWorthRecord _mapRecord(NetWorthRecord row) {
    return domain.NetWorthRecord(
      id: row.id,
      date: row.date, // Direct DateTime
      totalAmount: row.totalAmount,
      breakdown: Map<String, double>.from(jsonDecode(row.breakdown)),
    );
  }

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
          date: record.date, // Direct DateTime
          totalAmount: record.totalAmount,
          breakdown: jsonEncode(record.breakdown),
        ));
  }
}
