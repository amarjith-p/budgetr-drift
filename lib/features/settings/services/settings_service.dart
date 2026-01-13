import 'dart:convert';
import 'package:drift/drift.dart';
import '../../../core/database/app_database.dart';
import '../../../core/models/percentage_config_model.dart';

class SettingsService {
  final AppDatabase _db = AppDatabase.instance;

  Future<PercentageConfig> getPercentageConfig() async {
    final row = await (_db.select(_db.settings)
          ..where((t) => t.key.equals('percentages')))
        .getSingleOrNull();
    if (row != null) {
      final Map<String, dynamic> json = jsonDecode(row.value);
      return PercentageConfig.fromMap(json);
    }
    return PercentageConfig.defaultConfig();
  }

  Future<void> setPercentageConfig(PercentageConfig config) async {
    await _db
        .into(_db.settings)
        .insertOnConflictUpdate(SettingsCompanion.insert(
          key: 'percentages',
          value: jsonEncode(config.toMap()),
        ));
  }

  Future<bool> hasCurrentMonthBudget() async {
    final now = DateTime.now();
    final count = await (_db.select(_db.financialRecords)
          ..where((t) => t.year.equals(now.year))
          ..where((t) => t.month.equals(now.month)))
        .get();
    return count.isNotEmpty;
  }
}
