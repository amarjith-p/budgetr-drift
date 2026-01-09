import '../../../core/models/custom_data_models.dart';

/// Defines the structure of an active filter
class FilterCondition {
  final String fieldName;
  final CustomFieldType type;

  // Criteria
  final String? textQuery; // For Text
  final double? minVal; // For Number/Currency
  final double? maxVal; // For Number/Currency
  final DateTime? startDate; // For Date
  final DateTime? endDate; // For Date
  final List<String>? selectedOptions; // For Dropdown

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
}

class FilterEngine {
  /// Main method to filter the raw list of records
  static List<CustomRecord> applyFilters(
    List<CustomRecord> records,
    List<FilterCondition> filters,
  ) {
    if (filters.isEmpty) return records;

    return records.where((record) {
      // A record must pass ALL active filters (AND logic)
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
      case CustomFieldType.serial: // Treat serial as string for search
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
        if (val is! DateTime)
          return false; // Should not happen if data is clean
        // Normalize to remove time for accurate day comparison
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
