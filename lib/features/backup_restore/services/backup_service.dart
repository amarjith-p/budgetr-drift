import 'dart:io';
import 'dart:typed_data';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:share_plus/share_plus.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:restart_app/restart_app.dart';
import '../../../core/database/app_database.dart';

class BackupService {
  final String _dbName = 'budgetr_local_v2.sqlite';
  static const String _prefLastBackupKey = 'last_backup_timestamp';
  static const String _staticBackupName = 'BudgetR_Latest.sqlite';

  // [NEW] Flag to track if app was just restored
  static const String _prefJustRestoredKey = 'is_just_restored';

  Future<File> _getDbFile() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    return File(p.join(dbFolder.path, _dbName));
  }

  Future<File> _createTempBackup() async {
    final dbFile = await _getDbFile();
    if (!await dbFile.exists()) throw Exception("Database file not found");

    final tempDir = await getTemporaryDirectory();
    final tempFile = File(p.join(tempDir.path, _staticBackupName));

    if (tempFile.existsSync()) {
      tempFile.deleteSync();
    }

    return await dbFile.copy(tempFile.path);
  }

  Future<void> shareBackup() async {
    try {
      final backupFile = await _createTempBackup();
      final result = await Share.shareXFiles(
        [XFile(backupFile.path)],
        subject: 'Budgetr Backup',
        text: 'Budgetr backup created on ${DateTime.now()}',
      );

      if (result.status == ShareResultStatus.success) {
        await _updateLastBackupTime();
      }
    } catch (e) {
      debugPrint("Share Error: $e");
      rethrow;
    }
  }

  Future<String?> saveBackupToDevice() async {
    try {
      final backupFile = await _createTempBackup();
      final Uint8List fileBytes = await backupFile.readAsBytes();

      String? outputFile = await FilePicker.platform.saveFile(
        dialogTitle: 'Save Backup File',
        fileName: p.basename(backupFile.path),
        type: FileType.any,
        bytes: fileBytes,
      );

      if (outputFile != null) {
        await _updateLastBackupTime();
      }

      return outputFile;
    } catch (e) {
      debugPrint("Save Error: $e");
      rethrow;
    }
  }

  Future<bool> restoreBackup() async {
    try {
      FilePickerResult? result =
          await FilePicker.platform.pickFiles(type: FileType.any);

      if (result == null || result.files.single.path == null) return false;

      final File selectedFile = File(result.files.single.path!);

      // Close DB connection if possible, or rely on overwrite
      // await AppDatabase.instance.close();

      final dbFile = await _getDbFile();

      // Cleanup WAL/SHM to prevent corruption
      final walFile = File('${dbFile.path}-wal');
      final shmFile = File('${dbFile.path}-shm');
      if (walFile.existsSync()) walFile.deleteSync();
      if (shmFile.existsSync()) shmFile.deleteSync();

      await selectedFile.copy(dbFile.path);

      await _updateLastBackupTime();

      // [NEW] Set flag before restart so we know to show notification on next launch
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_prefJustRestoredKey, true);

      Restart.restartApp();

      return true;
    } catch (e) {
      debugPrint("Restore Error: $e");
      rethrow;
    }
  }

  Future<void> _updateLastBackupTime() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefLastBackupKey, DateTime.now().toIso8601String());
  }

// [ADD THIS NEW METHOD]
  Future<DateTime?> getLastBackupTime() async {
    final prefs = await SharedPreferences.getInstance();
    final lastStr = prefs.getString(_prefLastBackupKey);
    if (lastStr == null) return null;
    return DateTime.tryParse(lastStr);
  }

  Future<bool> isBackupOverdue() async {
    final prefs = await SharedPreferences.getInstance();
    final lastStr = prefs.getString(_prefLastBackupKey);
    if (lastStr == null) return true; // Never backed up

    final lastBackup = DateTime.parse(lastStr);
    final diff = DateTime.now().difference(lastBackup);
    // Alert if older than 12 hours (as per your request)
    return diff.inHours > 12;
  }

  // [NEW] Check and Clear the Restore Flag
  Future<bool> checkAndResetRestoreFlag() async {
    final prefs = await SharedPreferences.getInstance();
    final wasRestored = prefs.getBool(_prefJustRestoredKey) ?? false;

    if (wasRestored) {
      await prefs.setBool(_prefJustRestoredKey, false); // Reset immediately
    }

    return wasRestored;
  }
}
