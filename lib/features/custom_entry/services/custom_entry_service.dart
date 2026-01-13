import 'dart:convert';
import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';
import '../../../core/database/app_database.dart' as db;
import '../../../core/models/custom_data_models.dart'; // Domain Models

class CustomEntryService {
  final db.AppDatabase _db = db.AppDatabase.instance;
  final _uuid = const Uuid();

  // --- Helper Methods ---

  // Safely decode the List<CustomFieldConfig> from JSON
  List<CustomFieldConfig> _decodeFields(String jsonStr) {
    try {
      final List<dynamic> list = jsonDecode(jsonStr);
      return list
          .map((e) => CustomFieldConfig.fromMap(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      return [];
    }
  }

  // Safely decode the Map<String, dynamic> data for records
  Map<String, dynamic> _decodeRecordData(String jsonStr) {
    try {
      final Map<String, dynamic> rawMap = jsonDecode(jsonStr);
      // Ensure specific types are restored if needed (e.g., Dates stored as strings)
      // For now, assuming basic JSON types are sufficient or handled by UI
      return rawMap;
    } catch (e) {
      return {};
    }
  }

  // --- TEMPLATES ---

  Stream<List<CustomTemplate>> getCustomTemplates() {
    return (_db.select(_db.customTemplates)
          ..orderBy([(t) => OrderingTerm(expression: t.createdAt)]))
        .watch()
        .map((rows) => rows.map((r) {
              return CustomTemplate(
                id: r.id,
                name: r.name,
                createdAt: r.createdAt,
                fields: _decodeFields(r.fields),
                xAxisField: r.xAxisField,
                yAxisField: r.yAxisField,
              );
            }).toList());
  }

  Future<void> addCustomTemplate(CustomTemplate template) async {
    final id = template.id.isEmpty ? _uuid.v4() : template.id;

    await _db
        .into(_db.customTemplates)
        .insert(db.CustomTemplatesCompanion.insert(
          id: id,
          name: template.name,
          createdAt: template.createdAt,
          fields: jsonEncode(template.fields.map((e) => e.toMap()).toList()),
          xAxisField: Value(template.xAxisField),
          yAxisField: Value(template.yAxisField),
        ));
  }

  Future<void> updateCustomTemplate(CustomTemplate template) async {
    await (_db.update(_db.customTemplates)
          ..where((t) => t.id.equals(template.id)))
        .write(db.CustomTemplatesCompanion(
      name: Value(template.name),
      fields: Value(jsonEncode(template.fields.map((e) => e.toMap()).toList())),
      xAxisField: Value(template.xAxisField),
      yAxisField: Value(template.yAxisField),
    ));
  }

  Future<void> deleteCustomTemplate(String id) async {
    await _db.transaction(() async {
      // Cascade delete: Records first, then Template
      await (_db.delete(_db.customRecords)
            ..where((t) => t.templateId.equals(id)))
          .go();
      await (_db.delete(_db.customTemplates)..where((t) => t.id.equals(id)))
          .go();
    });
  }

  // Specific helper for Investment Module
  Future<String> ensureInvestmentTemplateExists(String templateName) async {
    final existing = await (_db.select(_db.customTemplates)
          ..where((t) => t.name.equals(templateName))
          ..limit(1))
        .getSingleOrNull();

    if (existing != null) {
      return existing.id;
    }

    // Create default investment template
    final newId = _uuid.v4();
    final fields = [
      CustomFieldConfig(name: 'Date', type: CustomFieldType.date),
      CustomFieldConfig(
          name: 'Invested',
          type: CustomFieldType.currency,
          currencySymbol: '₹',
          isSumRequired: true),
      CustomFieldConfig(
          name: 'Current Value',
          type: CustomFieldType.currency,
          currencySymbol: '₹',
          isSumRequired: true),
    ];

    await _db
        .into(_db.customTemplates)
        .insert(db.CustomTemplatesCompanion.insert(
          id: newId,
          name: templateName,
          createdAt: DateTime.now(),
          fields: jsonEncode(fields.map((e) => e.toMap()).toList()),
          xAxisField: const Value('Date'),
          yAxisField: const Value('Current Value'),
        ));
    return newId;
  }

  // --- RECORDS ---

  Stream<List<CustomRecord>> getCustomRecords(String templateId) {
    return (_db.select(_db.customRecords)
          ..where((t) => t.templateId.equals(templateId))
          ..orderBy([(t) => OrderingTerm(expression: t.createdAt)]))
        .watch()
        .map((rows) => rows.map((r) {
              return CustomRecord(
                id: r.id,
                templateId: r.templateId,
                data: _decodeRecordData(r.data),
                createdAt: r.createdAt,
              );
            }).toList());
  }

  Future<List<CustomRecord>> fetchCustomRecords(String templateId) async {
    final rows = await (_db.select(_db.customRecords)
          ..where((t) => t.templateId.equals(templateId)))
        .get();

    return rows
        .map((r) => CustomRecord(
              id: r.id,
              templateId: r.templateId,
              data: _decodeRecordData(r.data),
              createdAt: r.createdAt,
            ))
        .toList();
  }

  Future<int> getRecordCount(String templateId) async {
    final countExp = _db.customRecords.id.count();
    final query = _db.selectOnly(_db.customRecords)
      ..where(_db.customRecords.templateId.equals(templateId))
      ..addColumns([countExp]);
    final result = await query.getSingle();
    return result.read(countExp) ?? 0;
  }

  Future<void> addCustomRecord(CustomRecord record) async {
    final id = record.id.isEmpty ? _uuid.v4() : record.id;

    // We need to serialize the data map properly
    // Note: Dates inside the map are handled by your toMap() logic usually,
    // but here we just JSON encode the raw map.
    // If your map contains DateTime objects, jsonEncode will throw error unless mapped to String.
    // We should pre-process the map.
    final processedData = record.data.map((key, value) {
      if (value is DateTime) return MapEntry(key, value.toIso8601String());
      return MapEntry(key, value);
    });

    await _db.into(_db.customRecords).insert(db.CustomRecordsCompanion.insert(
          id: id,
          templateId: record.templateId,
          createdAt: record.createdAt,
          data: jsonEncode(processedData),
        ));
  }

  Future<void> updateCustomRecord(CustomRecord record) async {
    final processedData = record.data.map((key, value) {
      if (value is DateTime) return MapEntry(key, value.toIso8601String());
      return MapEntry(key, value);
    });

    await (_db.update(_db.customRecords)..where((t) => t.id.equals(record.id)))
        .write(db.CustomRecordsCompanion(
      data: Value(jsonEncode(processedData)),
      createdAt: Value(record.createdAt), // In case date changed
    ));
  }

  Future<void> deleteCustomRecord(String id) async {
    await (_db.delete(_db.customRecords)..where((t) => t.id.equals(id))).go();
  }
}
