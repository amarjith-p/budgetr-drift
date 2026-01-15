import 'package:drift/drift.dart'; // For QueryRow
import '../../../core/database/app_database.dart';

class DatabaseViewerService {
  /// Fetches all table names from the SQLite database dynamically.
  Future<List<String>> getAllTableNames() async {
    // Query the sqlite_master table to find all user-defined tables
    final result = await AppDatabase.instance
        .customSelect(
            "SELECT name FROM sqlite_master WHERE type='table' AND name NOT LIKE 'sqlite_%' AND name NOT LIKE 'android_%' ORDER BY name;")
        .get();

    return result.map((row) => row.read<String>('name')).toList();
  }

  /// Fetches all data from a specific table as a List of Maps.
  Future<List<Map<String, dynamic>>> getTableData(String tableName) async {
    try {
      // Use raw SQL to select everything
      final result = await AppDatabase.instance
          .customSelect('SELECT * FROM $tableName')
          .get();

      // Convert rows to Map<String, dynamic> for the DataTable
      return result.map((row) => row.data).toList();
    } catch (e) {
      // Return an empty list or throw depending on how you want to handle errors
      return [];
    }
  }
}
