// import 'package:cloud_firestore/cloud_firestore.dart';
// import '../../../core/constants/firebase_constants.dart';
// import '../../../core/models/custom_data_models.dart';

// class CustomEntryService {
//   final FirebaseFirestore _db = FirebaseFirestore.instance;

//   // --- Templates ---
//   Stream<List<CustomTemplate>> getCustomTemplates() {
//     return _db
//         .collection(FirebaseConstants.customTemplates)
//         .orderBy('createdAt', descending: false)
//         .snapshots()
//         .map(
//           (s) => s.docs.map((d) => CustomTemplate.fromFirestore(d)).toList(),
//         );
//   }

//   Future<String> ensureInvestmentTemplateExists(String templateName) async {
//     // 1. Check for existing template
//     final query = await _db
//         .collection(FirebaseConstants.customTemplates)
//         .where('name', isEqualTo: templateName)
//         .limit(1)
//         .get();

//     if (query.docs.isNotEmpty) {
//       return query.docs.first.id;
//     }

//     // 2. Create new template if it doesn't exist
//     final newTemplate = CustomTemplate(
//       id: '',
//       name: templateName,
//       createdAt: DateTime.now(), // Initialize createdAt
//       fields: [
//         CustomFieldConfig(name: 'Date', type: CustomFieldType.date),
//         CustomFieldConfig(
//           name: 'Invested',
//           type: CustomFieldType.currency,
//           currencySymbol: '₹',
//           isSumRequired: true,
//         ),
//         CustomFieldConfig(
//           name: 'Current Value',
//           type: CustomFieldType.currency,
//           currencySymbol: '₹',
//           isSumRequired: true,
//         ),
//         CustomFieldConfig(
//           name: 'Day Gain',
//           type: CustomFieldType.currency,
//           currencySymbol: '₹',
//           isSumRequired: true,
//         ),
//         CustomFieldConfig(
//           name: 'Total Return',
//           type: CustomFieldType.currency,
//           currencySymbol: '₹',
//           isSumRequired: true,
//         ),
//         CustomFieldConfig(
//           name: 'Return %',
//           type: CustomFieldType.number,
//           serialSuffix: '%',
//         ),
//       ],
//       xAxisField: 'Date',
//       yAxisField: 'Current Value',
//     );

//     final docRef = await _db
//         .collection(FirebaseConstants.customTemplates)
//         .add(newTemplate.toMap());

//     return docRef.id;
//   }

//   Future<void> addCustomTemplate(CustomTemplate template) {
//     return _db
//         .collection(FirebaseConstants.customTemplates)
//         .add(template.toMap());
//   }

//   Future<void> updateCustomTemplate(CustomTemplate template) async {
//     await _db
//         .collection(FirebaseConstants.customTemplates)
//         .doc(template.id)
//         .update(template.toMap());

//     // Backfill logic
//     for (var field in template.fields) {
//       if (field.type == CustomFieldType.serial) {
//         await _backfillSerialNumbers(template.id, field.name);
//       }
//     }
//   }

//   Future<void> _backfillSerialNumbers(
//     String templateId,
//     String fieldName,
//   ) async {
//     final recordsSnapshot = await _db
//         .collection(FirebaseConstants.customRecords)
//         .where('templateId', isEqualTo: templateId)
//         .orderBy('createdAt', descending: false)
//         .get();

//     final batch = _db.batch();
//     int counter = 1;
//     bool needsCommit = false;

//     for (var doc in recordsSnapshot.docs) {
//       final data = doc.data();
//       final recordData = data['data'] as Map<String, dynamic>;

//       if (!recordData.containsKey(fieldName) || recordData[fieldName] == null) {
//         recordData[fieldName] = counter;
//         batch.update(doc.reference, {'data': recordData});
//         needsCommit = true;
//       }
//       counter++;
//     }

//     if (needsCommit) {
//       await batch.commit();
//     }
//   }

//   Future<void> deleteCustomTemplate(String id) async {
//     final recordsSnapshot = await _db
//         .collection(FirebaseConstants.customRecords)
//         .where('templateId', isEqualTo: id)
//         .get();

//     for (var doc in recordsSnapshot.docs) {
//       await doc.reference.delete();
//     }
//     await _db.collection(FirebaseConstants.customTemplates).doc(id).delete();
//   }

//   // --- Records ---
//   Stream<List<CustomRecord>> getCustomRecords(String templateId) {
//     return _db
//         .collection(FirebaseConstants.customRecords)
//         .where('templateId', isEqualTo: templateId)
//         .orderBy('createdAt', descending: false)
//         .snapshots()
//         .map((s) => s.docs.map((d) => CustomRecord.fromFirestore(d)).toList());
//   }

//   Future<List<CustomRecord>> fetchCustomRecords(String templateId) async {
//     final snapshot = await _db
//         .collection(FirebaseConstants.customRecords)
//         .where('templateId', isEqualTo: templateId)
//         .get();
//     return snapshot.docs.map((d) => CustomRecord.fromFirestore(d)).toList();
//   }

//   Future<int> getRecordCount(String templateId) async {
//     final snapshot = await _db
//         .collection(FirebaseConstants.customRecords)
//         .where('templateId', isEqualTo: templateId)
//         .count()
//         .get();
//     return snapshot.count ?? 0;
//   }

//   Future<void> addCustomRecord(CustomRecord record) {
//     return _db.collection(FirebaseConstants.customRecords).add(record.toMap());
//   }

//   Future<void> updateCustomRecord(CustomRecord record) {
//     return _db
//         .collection(FirebaseConstants.customRecords)
//         .doc(record.id)
//         .update(record.toMap());
//   }

//   Future<void> deleteCustomRecord(String id) {
//     return _db.collection(FirebaseConstants.customRecords).doc(id).delete();
//   }
// }
import 'dart:convert';
import 'package:drift/drift.dart' as drift;
import 'package:uuid/uuid.dart';
import '../../../../core/database/app_database.dart';
import '../../../core/models/custom_data_models.dart' as domain;

class CustomEntryService {
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
