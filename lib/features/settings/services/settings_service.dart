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
        return PercentageConfig.fromMap(json);
      } catch (e) {
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
          value: jsonEncode(config.toMap()),
        ));
  }

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

  // --- Startup Preference Logic ---

  Future<bool> getLaunchToDailyExpense() async {
    if (_cachedLaunchDailyExpense != null) return _cachedLaunchDailyExpense!;

    final row = await (_db.select(_db.settings)
          ..where((t) => t.key.equals('launch_daily_expense')))
        .getSingleOrNull();

    _cachedLaunchDailyExpense = (row?.value == 'true');
    return _cachedLaunchDailyExpense!;
  }

  Future<void> setLaunchToDailyExpense(bool value) async {
    await _db
        .into(_db.settings)
        .insertOnConflictUpdate(db.SettingsCompanion.insert(
          key: 'launch_daily_expense',
          value: value.toString(),
        ));
    _cachedLaunchDailyExpense = value;
  }

  // --- [UPDATED] Multiple Credit Payable Accounts Sync ---

  Future<List<String>> getCreditPayableAccountIds() async {
    final row = await (_db.select(_db.settings)
          ..where((t) => t.key.equals('credit_payable_account_ids')))
        .getSingleOrNull();

    if (row?.value == null || row!.value.isEmpty) return [];

    try {
      final List<dynamic> decoded = jsonDecode(row.value);
      return decoded.map((e) => e.toString()).toList();
    } catch (e) {
      return [];
    }
  }

  Future<void> setCreditPayableAccountIds(List<String> accountIds) async {
    await _db
        .into(_db.settings)
        .insertOnConflictUpdate(db.SettingsCompanion.insert(
          key: 'credit_payable_account_ids',
          value: jsonEncode(accountIds),
        ));
  }
}
