import 'package:cloud_firestore/cloud_firestore.dart';

enum CustomFieldType { string, number, date }

class CustomFieldConfig {
  String name;
  CustomFieldType type;
  bool isSumRequired;

  CustomFieldConfig({
    required this.name,
    required this.type,
    this.isSumRequired = false,
  });

  Map<String, dynamic> toMap() => {
    'name': name,
    'type': type.index,
    'isSumRequired': isSumRequired,
  };

  factory CustomFieldConfig.fromMap(Map<String, dynamic> map) =>
      CustomFieldConfig(
        name: map['name'],
        type: CustomFieldType.values[map['type']],
        isSumRequired: map['isSumRequired'] ?? false,
      );
}

class CustomTemplate {
  String id;
  String name;
  List<CustomFieldConfig> fields;
  String? xAxisField;
  String? yAxisField;

  CustomTemplate({
    required this.id,
    required this.name,
    required this.fields,
    this.xAxisField,
    this.yAxisField,
  });

  Map<String, dynamic> toMap() => {
    'name': name,
    'fields': fields.map((e) => e.toMap()).toList(),
    'xAxisField': xAxisField,
    'yAxisField': yAxisField,
    'createdAt': FieldValue.serverTimestamp(),
  };

  factory CustomTemplate.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return CustomTemplate(
      id: doc.id,
      name: data['name'],
      fields: (data['fields'] as List)
          .map((e) => CustomFieldConfig.fromMap(e))
          .toList(),
      xAxisField: data['xAxisField'],
      yAxisField: data['yAxisField'],
    );
  }
}

class CustomRecord {
  String id;
  String templateId;
  Map<String, dynamic> data;
  DateTime createdAt;

  CustomRecord({
    required this.id,
    required this.templateId,
    required this.data,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    final storageData = <String, dynamic>{};
    data.forEach((key, value) {
      if (value is DateTime) {
        storageData[key] = Timestamp.fromDate(value);
      } else {
        storageData[key] = value;
      }
    });

    return {
      'templateId': templateId,
      'data': storageData,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  factory CustomRecord.fromFirestore(DocumentSnapshot doc) {
    final raw = doc.data() as Map<String, dynamic>;
    final rawData = raw['data'] as Map<String, dynamic>;
    final processedData = <String, dynamic>{};

    rawData.forEach((key, value) {
      if (value is Timestamp) {
        processedData[key] = value.toDate();
      } else {
        processedData[key] = value;
      }
    });

    return CustomRecord(
      id: doc.id,
      templateId: raw['templateId'],
      data: processedData,
      createdAt: (raw['createdAt'] as Timestamp).toDate(),
    );
  }
}
