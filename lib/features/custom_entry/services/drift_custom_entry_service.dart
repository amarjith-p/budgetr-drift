import 'dart:convert';
import 'package:drift/drift.dart' as drift;
import 'package:uuid/uuid.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/database/app_database.dart';
import '../../../core/models/custom_data_models.dart';
import 'custom_entry_service.dart';

class DriftCustomEntryService extends CustomEntryService {
  final AppDatabase _db = AppDatabase.instance;
  final _uuid = const Uuid();

  @override
  Stream<List<CustomTemplate>> getCustomTemplates() {
    return (_db.select(_db.customTemplates)
          ..orderBy([(t) => drift.OrderingTerm(expression: t.createdAt)]))
        .watch()
        .map((rows) => rows
            .map((r) => CustomTemplate(
                  id: r.id,
                  name: r.name,
                  createdAt: r.createdAt,
                  fields: (jsonDecode(r.fields) as List)
                      .map((e) => CustomFieldConfig.fromMap(e))
                      .toList(),
                  xAxisField: r.xAxisField,
                  yAxisField: r.yAxisField,
                ))
            .toList());
  }

  @override
  Future<void> addCustomTemplate(CustomTemplate t) async {
    await _db.into(_db.customTemplates).insert(CustomTemplatesCompanion.insert(
          id: t.id.isEmpty ? _uuid.v4() : t.id,
          name: t.name,
          createdAt: t.createdAt ?? DateTime.now(),
          fields: jsonEncode(t.fields.map((e) => e.toMap()).toList()),
          xAxisField: drift.Value(t.xAxisField),
          yAxisField: drift.Value(t.yAxisField),
        ));
  }

  @override
  Stream<List<CustomRecord>> getCustomRecords(String templateId) {
    return (_db.select(_db.customRecords)
          ..where((t) => t.templateId.equals(templateId))
          ..orderBy([(t) => drift.OrderingTerm(expression: t.createdAt)]))
        .watch()
        .map((rows) => rows
            .map((r) => CustomRecord(
                  id: r.id,
                  templateId: r.templateId,
                  createdAt: Timestamp.fromDate(r.createdAt),
                  data: Map<String, dynamic>.from(jsonDecode(r.data)),
                ))
            .toList());
  }

  @override
  Future<void> addCustomRecord(CustomRecord r) async {
    await _db.into(_db.customRecords).insert(CustomRecordsCompanion.insert(
          id: r.id.isEmpty ? _uuid.v4() : r.id,
          templateId: r.templateId,
          createdAt: r.createdAt.toDate(),
          data: jsonEncode(r.data),
        ));
  }
}
