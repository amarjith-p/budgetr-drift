enum CustomFieldType {
  string,
  number,
  date,
  currency,
  dropdown,
  serial,
  formula,
}

class CustomFieldConfig {
  String name;
  CustomFieldType type;
  bool isSumRequired;

  String? currencySymbol;
  List<String>? dropdownOptions;

  String? serialPrefix;
  String? serialSuffix;

  // Formula Configuration
  String? formulaExpression;

  CustomFieldConfig({
    required this.name,
    required this.type,
    this.isSumRequired = false,
    this.currencySymbol,
    this.dropdownOptions,
    this.serialPrefix,
    this.serialSuffix,
    this.formulaExpression,
  });

  Map<String, dynamic> toMap() => {
        'name': name,
        'type': type.index,
        'isSumRequired': isSumRequired,
        'currencySymbol': currencySymbol,
        'dropdownOptions': dropdownOptions,
        'serialPrefix': serialPrefix,
        'serialSuffix': serialSuffix,
        'formulaExpression': formulaExpression,
      };

  factory CustomFieldConfig.fromMap(Map<String, dynamic> map) =>
      CustomFieldConfig(
        name: map['name'],
        type: CustomFieldType.values[map['type']],
        isSumRequired: map['isSumRequired'] ?? false,
        currencySymbol: map['currencySymbol'],
        dropdownOptions: map['dropdownOptions'] != null
            ? List<String>.from(map['dropdownOptions'])
            : null,
        serialPrefix: map['serialPrefix'],
        serialSuffix: map['serialSuffix'],
        formulaExpression: map['formulaExpression'],
      );
}

class CustomTemplate {
  String id;
  String name;
  List<CustomFieldConfig> fields;
  String? xAxisField;
  String? yAxisField;
  DateTime createdAt; // Added Field

  CustomTemplate({
    required this.id,
    required this.name,
    required this.fields,
    this.xAxisField,
    this.yAxisField,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() => {
        'name': name,
        'fields': fields.map((e) => e.toMap()).toList(),
        'xAxisField': xAxisField,
        'yAxisField': yAxisField,
        // FIX: Preserve the existing creation time instead of resetting it
        'createdAt': DateTime.timestamp(),
      };

  // factory CustomTemplate.fromFirestore(DocumentSnapshot doc) {
  //   final data = doc.data() as Map<String, dynamic>;
  //   return CustomTemplate(
  //     id: doc.id,
  //     name: data['name'],
  //     fields: (data['fields'] as List)
  //         .map((e) => CustomFieldConfig.fromMap(e))
  //         .toList(),
  //     xAxisField: data['xAxisField'],
  //     yAxisField: data['yAxisField'],
  //     // FIX: Use a stable fallback (Epoch 0) for missing timestamps to prevent random shuffling
  //     createdAt: data['createdAt'] != null
  //         ? (data['createdAt'] as Timestamp).toDate()
  //         : DateTime.fromMillisecondsSinceEpoch(0),
  //   );
  // }
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
        storageData[key] = DateTime.timestamp();
      } else {
        storageData[key] = value;
      }
    });

    return {
      'templateId': templateId,
      'data': storageData,
      'createdAt': DateTime.timestamp(),
    };
  }

  // factory CustomRecord.fromFirestore(DocumentSnapshot doc) {
  //   final raw = doc.data() as Map<String, dynamic>;
  //   final rawData = raw['data'] as Map<String, dynamic>;
  //   final processedData = <String, dynamic>{};

  //   rawData.forEach((key, value) {
  //     if (value is Timestamp) {
  //       processedData[key] = value.toDate();
  //     } else {
  //       processedData[key] = value;
  //     }
  //   });

  //   return CustomRecord(
  //     id: doc.id,
  //     templateId: raw['templateId'],
  //     data: processedData,
  //     createdAt: (raw['createdAt'] as Timestamp).toDate(),
  //   );
  // }
}
