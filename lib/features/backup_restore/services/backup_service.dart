import 'dart:io';
import 'dart:typed_data';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart'; // Added for BuildContext/Snackbars if needed, though mostly using debugPrint here
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:share_plus/share_plus.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart'; // [ADDED]
import 'package:restart_app/restart_app.dart'; // [ADDED] For restore restart
import '../../../core/database/app_database.dart';

class BackupService {
  final String _dbName = 'budgetr_local_v2.sqlite';
  // [ADDED] Keys for preferences
  static const String _prefLastBackupKey = 'last_backup_timestamp';
  static const String _staticBackupName = 'BudgetR_Latest.sqlite';

  Future<File> _getDbFile() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    return File(p.join(dbFolder.path, _dbName));
  }

  // [MODIFIED] Uses static name now
  Future<File> _createTempBackup() async {
    final dbFile = await _getDbFile();
    if (!await dbFile.exists()) throw Exception("Database file not found");

    // Old: final timestamp = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
    // Old: final backupFileName = 'budgetr_backup_$timestamp.sqlite';

    // [MODIFIED] Use static name to prevent duplicate clutter
    final tempDir = await getTemporaryDirectory();
    final tempFile = File(p.join(tempDir.path, _staticBackupName));

    if (tempFile.existsSync()) {
      tempFile.deleteSync();
    }

    return await dbFile.copy(tempFile.path);
  }

  /// Option 1: Share Sheet (Email, Drive, WhatsApp, etc.)
  Future<void> shareBackup() async {
    try {
      final backupFile = await _createTempBackup();
      final result = await Share.shareXFiles(
        [XFile(backupFile.path)],
        subject: 'Budgetr Backup',
        text: 'Budgetr backup created on ${DateTime.now()}',
      );

      // [ADDED] Save timestamp if shared
      if (result.status == ShareResultStatus.success) {
        await _updateLastBackupTime();
      }
    } catch (e) {
      debugPrint("Share Error: $e");
      rethrow;
    }
  }

  /// Option 2: Direct Save to File Manager
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

      // [ADDED] Save timestamp if saved successfully
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

      // Safety Check: Close DB before overwrite
      // Note: Drift's close() might be async, ensure to await it.
      // If AppDatabase singleton is not easily closable, we rely on file overwriting + restart.
      // await AppDatabase.instance.close();

      final dbFile = await _getDbFile();

      // [ADDED] Cleanup WAL/SHM files to prevent corruption
      final walFile = File('${dbFile.path}-wal');
      final shmFile = File('${dbFile.path}-shm');
      if (walFile.existsSync()) walFile.deleteSync();
      if (shmFile.existsSync()) shmFile.deleteSync();

      await selectedFile.copy(dbFile.path);

      // [ADDED] Reset timer and Restart
      await _updateLastBackupTime();
      Restart.restartApp();

      return true;
    } catch (e) {
      debugPrint("Restore Error: $e");
      rethrow;
    }
  }

  // [ADDED] Helper to save time
  Future<void> _updateLastBackupTime() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefLastBackupKey, DateTime.now().toIso8601String());
  }

  // [ADDED] Check if > 24 hours
  Future<bool> isBackupOverdue() async {
    final prefs = await SharedPreferences.getInstance();
    final lastStr = prefs.getString(_prefLastBackupKey);
    if (lastStr == null) return true; // Never backed up

    final lastBackup = DateTime.parse(lastStr);
    final diff = DateTime.now().difference(lastBackup);
    return diff.inHours > 24;
  }
}
