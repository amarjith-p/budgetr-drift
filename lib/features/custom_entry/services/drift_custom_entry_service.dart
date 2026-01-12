import 'dart:convert';
import 'package:drift/drift.dart' as drift;
import 'package:uuid/uuid.dart';
import '../../../../core/database/app_database.dart';
import '../../../core/models/custom_data_models.dart' as domain;
import 'custom_entry_service.dart';

class DriftCustomEntryService extends CustomEntryService {
  final AppDatabase _db = AppDatabase.instance;
  final _uuid = const Uuid();

  @override
  Stream<List<domain.CustomTemplate>> getCustomTemplates() {
    return (_db.select(_db.customTemplates)
          ..orderBy([(t) => drift.OrderingTerm(expression: t.createdAt)]))
        .watch()
        .map((rows) => rows
            .map((r) => domain.CustomTemplate(
                  id: r.id,
                  name: r.name,
                  // DateTime (Drift) -> DateTime (Model) :: No conversion needed
                  createdAt: r.createdAt,
                  fields: (jsonDecode(r.fields) as List)
                      .map((e) => domain.CustomFieldConfig.fromMap(e))
                      .toList(),
                  xAxisField: r.xAxisField,
                  yAxisField: r.yAxisField,
                ))
            .toList());
  }

  @override
  Future<void> addCustomTemplate(domain.CustomTemplate t) async {
    await _db.into(_db.customTemplates).insert(CustomTemplatesCompanion.insert(
          id: t.id.isEmpty ? _uuid.v4() : t.id,
          name: t.name,
          // DateTime (Model) -> DateTime (Drift) :: No conversion needed
          createdAt: t.createdAt ?? DateTime.now(),
          fields: jsonEncode(t.fields.map((e) => e.toMap()).toList()),
          xAxisField: drift.Value(t.xAxisField),
          yAxisField: drift.Value(t.yAxisField),
        ));
  }

  @override
  Stream<List<domain.CustomRecord>> getCustomRecords(String templateId) {
    return (_db.select(_db.customRecords)
          ..where((t) => t.templateId.equals(templateId))
          ..orderBy([(t) => drift.OrderingTerm(expression: t.createdAt)]))
        .watch()
        .map((rows) => rows
            .map((r) => domain.CustomRecord(
                  id: r.id,
                  templateId: r.templateId,
                  // DateTime (Drift) -> DateTime (Model) :: No conversion needed
                  createdAt: r.createdAt,
                  data: Map<String, dynamic>.from(jsonDecode(r.data)),
                ))
            .toList());
  }

  @override
  Future<void> addCustomRecord(domain.CustomRecord r) async {
    await _db.into(_db.customRecords).insert(CustomRecordsCompanion.insert(
          id: r.id.isEmpty ? _uuid.v4() : r.id,
          templateId: r.templateId,
          // DateTime (Model) -> DateTime (Drift) :: No conversion needed
          createdAt: r.createdAt,
          data: jsonEncode(r.data),
        ));
  }
}
