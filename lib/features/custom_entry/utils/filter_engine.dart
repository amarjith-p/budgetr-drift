import 'package:intl/intl.dart';
import '../../../core/models/custom_data_models.dart';

class FilterCondition {
  final String fieldName;
  final CustomFieldType type;

  final String? textQuery;
  final double? minVal;
  final double? maxVal;
  final DateTime? startDate;
  final DateTime? endDate;
  final List<String>? selectedOptions;

  FilterCondition({
    required this.fieldName,
    required this.type,
    this.textQuery,
    this.minVal,
    this.maxVal,
    this.startDate,
    this.endDate,
    this.selectedOptions,
  });

  /// Check if the filter actually has any constraints set
  bool get hasCriteria {
    return (textQuery != null && textQuery!.isNotEmpty) ||
        minVal != null ||
        maxVal != null ||
        startDate != null ||
        endDate != null ||
        (selectedOptions != null && selectedOptions!.isNotEmpty);
  }

  /// Create a copy with updated fields
  FilterCondition copyWith({
    String? textQuery,
    double? minVal,
    double? maxVal,
    DateTime? startDate,
    DateTime? endDate,
    List<String>? selectedOptions,
    bool clearText = false,
    bool clearMin = false,
    bool clearMax = false,
    bool clearStart = false,
    bool clearEnd = false,
    bool clearOptions = false,
  }) {
    return FilterCondition(
      fieldName: fieldName,
      type: type,
      textQuery: clearText ? null : (textQuery ?? this.textQuery),
      minVal: clearMin ? null : (minVal ?? this.minVal),
      maxVal: clearMax ? null : (maxVal ?? this.maxVal),
      startDate: clearStart ? null : (startDate ?? this.startDate),
      endDate: clearEnd ? null : (endDate ?? this.endDate),
      selectedOptions:
          clearOptions ? null : (selectedOptions ?? this.selectedOptions),
    );
  }

  /// Get a human-readable summary of the filter
  String get summary {
    List<String> parts = [];
    if (textQuery != null && textQuery!.isNotEmpty) parts.add('"$textQuery"');
    if (minVal != null) parts.add('> $minVal');
    if (maxVal != null) parts.add('< $maxVal');
    if (startDate != null)
      parts.add('From ${DateFormat('dd/MM').format(startDate!)}');
    if (endDate != null)
      parts.add('To ${DateFormat('dd/MM').format(endDate!)}');
    if (selectedOptions != null && selectedOptions!.isNotEmpty) {
      parts.add(selectedOptions!.join(', '));
    }
    return parts.join(' • ');
  }
}

class FilterEngine {
  static List<CustomRecord> applyFilters(
    List<CustomRecord> records,
    List<FilterCondition> filters,
  ) {
    if (filters.isEmpty) return records;

    return records.where((record) {
      for (var filter in filters) {
        if (!_checkCondition(record, filter)) {
          return false;
        }
      }
      return true;
    }).toList();
  }

  static bool _checkCondition(CustomRecord record, FilterCondition filter) {
    final dynamic val = record.data[filter.fieldName];
    if (val == null) return false;

    switch (filter.type) {
      case CustomFieldType.string:
      case CustomFieldType.serial:
        final String strVal = val.toString().toLowerCase();
        if (filter.textQuery != null && filter.textQuery!.isNotEmpty) {
          if (!strVal.contains(filter.textQuery!.toLowerCase())) return false;
        }
        break;

      case CustomFieldType.number:
      case CustomFieldType.currency:
      case CustomFieldType.formula:
        double numVal = 0.0;
        if (val is num)
          numVal = val.toDouble();
        else if (val is String) numVal = double.tryParse(val) ?? 0.0;

        if (filter.minVal != null && numVal < filter.minVal!) return false;
        if (filter.maxVal != null && numVal > filter.maxVal!) return false;
        break;

      case CustomFieldType.date:
        if (val is! DateTime) return false;
        final date = DateTime(val.year, val.month, val.day);

        if (filter.startDate != null) {
          final start = DateTime(filter.startDate!.year,
              filter.startDate!.month, filter.startDate!.day);
          if (date.isBefore(start)) return false;
        }
        if (filter.endDate != null) {
          final end = DateTime(
              filter.endDate!.year, filter.endDate!.month, filter.endDate!.day);
          if (date.isAfter(end)) return false;
        }
        break;

      case CustomFieldType.dropdown:
        if (filter.selectedOptions != null &&
            filter.selectedOptions!.isNotEmpty) {
          final String strVal = val.toString();
          if (!filter.selectedOptions!.contains(strVal)) return false;
        }
        break;
    }
    return true;
  }
}
