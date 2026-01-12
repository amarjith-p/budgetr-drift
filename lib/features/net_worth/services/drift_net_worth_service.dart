import 'dart:convert';
import 'package:drift/drift.dart' as drift;
import 'package:uuid/uuid.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/database/app_database.dart';
import '../../../core/models/net_worth_model.dart';
import '../../../core/models/net_worth_split_model.dart';
import 'net_worth_service.dart';

class DriftNetWorthService extends NetWorthService {
  final AppDatabase _db = AppDatabase.instance;
  final _uuid = const Uuid();

  // --- Mappers ---
  NetWorthRecord _mapRecord(NetWorthRecord row) {
    return NetWorthRecord(
      id: row.id,
      date: Timestamp.fromDate(row.date),
      totalAmount: row.totalAmount,
      breakdown: Map<String, double>.from(jsonDecode(row.breakdown)),
    );
  }

  // --- Implementation ---
  @override
  Stream<List<NetWorthRecord>> getNetWorthRecords() {
    return (_db.select(_db.netWorthRecords)
          ..orderBy([
            (t) => drift.OrderingTerm(
                expression: t.date, mode: drift.OrderingMode.desc)
          ]))
        .watch()
        .map((rows) => rows.map(_mapRecord).toList());
  }

  @override
  Future<void> addNetWorthRecord(NetWorthRecord record) async {
    final id = _uuid.v4();
    await _db.into(_db.netWorthRecords).insert(NetWorthRecordsCompanion.insert(
          id: id,
          date: record.date.toDate(),
          totalAmount: record.totalAmount,
          breakdown: jsonEncode(record.breakdown),
        ));
  }
}
