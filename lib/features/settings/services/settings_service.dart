import 'dart:convert';
import 'package:drift/drift.dart';
import '../../../core/database/app_database.dart' as db;
import '../../../core/models/percentage_config_model.dart';

class SettingsService {
  final db.AppDatabase _db = db.AppDatabase.instance;
  static bool? _cachedLaunchDailyExpense;
  bool get cachedLaunchDailyExpense => _cachedLaunchDailyExpense ?? false;

  Future<PercentageConfig> getPercentageConfig() async {
    final row = await (_db.select(_db.settings)
          ..where((t) => t.key.equals('percentages')))
        .getSingleOrNull();

    if (row != null) {
      try {
        final Map<String, dynamic> json = jsonDecode(row.value);
        return PercentageConfig.fromMap(json); // Uses your existing model logic
      } catch (e) {
        // Fallback if JSON is corrupt
        return PercentageConfig.defaultConfig();
      }
    } else {
      return PercentageConfig.defaultConfig();
    }
  }

  Future<void> setPercentageConfig(PercentageConfig config) async {
    await _db
        .into(_db.settings)
        .insertOnConflictUpdate(db.SettingsCompanion.insert(
          key: 'percentages',
          value: jsonEncode(
              config.toMap()), // Uses your existing serialization logic
        ));
  }

  /// Checks if a Financial Record exists for the current month.
  /// Replaces the Firestore query: collection('financial_records').where('year').where('month')
  Future<bool> hasCurrentMonthBudget() async {
    final now = DateTime.now();

    final countExp = _db.financialRecords.id.count();
    final query = _db.selectOnly(_db.financialRecords)
      ..where(_db.financialRecords.year.equals(now.year))
      ..where(_db.financialRecords.month.equals(now.month))
      ..addColumns([countExp]);

    final result = await query.getSingle();
    final count = result.read(countExp) ?? 0;

    return count > 0;
  }
  // --- [NEW] Startup Preference Logic ---

  Future<bool> getLaunchToDailyExpense() async {
    // If we have a cache, return it (Fast Path)
    if (_cachedLaunchDailyExpense != null) return _cachedLaunchDailyExpense!;

    final row = await (_db.select(_db.settings)
          ..where((t) => t.key.equals('launch_daily_expense')))
        .getSingleOrNull();

    // Update Cache
    _cachedLaunchDailyExpense = (row?.value == 'true');
    return _cachedLaunchDailyExpense!;
  }

  Future<void> setLaunchToDailyExpense(bool value) async {
    // Update DB
    await _db
        .into(_db.settings)
        .insertOnConflictUpdate(db.SettingsCompanion.insert(
          key: 'launch_daily_expense',
          value: value.toString(),
        ));

    // Update Cache
    _cachedLaunchDailyExpense = value;
  }
}
