import 'package:drift/drift.dart';
import '../../../core/database/app_database.dart';

class DatabaseViewerService {
  Future<List<String>> getAllTableNames() async {
    final result = await AppDatabase.instance
        .customSelect(
            "SELECT name FROM sqlite_master WHERE type='table' AND name NOT LIKE 'sqlite_%' AND name NOT LIKE 'android_%' ORDER BY name;")
        .get();
    return result.map((row) => row.read<String>('name')).toList();
  }

  Future<List<Map<String, dynamic>>> getTableData(String tableName) async {
    final result = await AppDatabase.instance
        .customSelect('SELECT * FROM $tableName')
        .get();
    return result.map((row) => row.data).toList();
  }

  /// Finds the Primary Key column name for a given table (e.g., 'id').
  /// Returns null if no PK is found.
  Future<String?> getPrimaryKeyColumn(String tableName) async {
    // PRAGMA table_info returns columns: cid, name, type, notnull, dflt_value, pk
    final result = await AppDatabase.instance
        .customSelect('PRAGMA table_info($tableName)')
        .get();

    for (var row in result) {
      if (row.read<int>('pk') > 0) {
        return row.read<String>('name');
      }
    }
    return null;
  }

  /// Deletes a row where [pkColumn] = [pkValue].
  Future<void> deleteRow(
      String tableName, String pkColumn, dynamic pkValue) async {
    await AppDatabase.instance.customStatement(
      'DELETE FROM $tableName WHERE $pkColumn = ?',
      [pkValue],
    );
  }

  /// Updates a row dynamically.
  Future<void> updateRow(String tableName, String pkColumn, dynamic pkValue,
      Map<String, dynamic> updates) async {
    if (updates.isEmpty) return;

    // Construct: "col1 = ?, col2 = ?"
    final setClause = updates.keys.map((key) => "$key = ?").join(", ");
    final args = [...updates.values, pkValue];

    await AppDatabase.instance.customStatement(
      'UPDATE $tableName SET $setClause WHERE $pkColumn = ?',
      args,
    );
  }
}
