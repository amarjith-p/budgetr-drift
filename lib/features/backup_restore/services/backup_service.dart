import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:share_plus/share_plus.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:restart_app/restart_app.dart';

class BackupService {
  final String _dbName = 'budgetr_local_v2.sqlite';
  static const String _prefLastBackupKey = 'last_backup_timestamp';
  static const String _staticBackupName = 'BudgetR_Backup_DataEngine.sqlite';

  // Flag to track if app was just restored
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

  /// [UPDATED] AUTOMATIC DIRECTORY ROUTING
  Future<String?> saveBackupToDevice() async {
    try {
      final backupFile = await _createTempBackup();

      // 1. Generate the dynamic folder name: BudGetR/Backups/MMM yyyy
      final folderDate = DateFormat('MMM yyyy').format(DateTime.now());
      final folderPath = 'BudGetR/Backups/$folderDate';

      Directory saveDir;
      if (Platform.isAndroid) {
        // Target public Downloads folder for Android
        saveDir = Directory('/storage/emulated/0/Download/$folderPath');
      } else {
        // Target Documents folder for iOS
        final baseDir = await getApplicationDocumentsDirectory();
        saveDir = Directory(p.join(baseDir.path, folderPath));
      }

      // 2. Create the entire directory tree if it doesn't exist
      if (!await saveDir.exists()) {
        await saveDir.create(recursive: true);
      }

      // 3. Generate a precise timestamped file name so backups don't overwrite each other
      final timestamp = DateFormat('dd_MMM_yyyy_HHmm').format(DateTime.now());
      final fileName = 'BudGetR_Backup_DataEngine.sqlite';

      final exportPath = p.join(saveDir.path, fileName);

      // 4. Save the file
      await backupFile.copy(exportPath);
      await _updateLastBackupTime();

      return exportPath; // Return the path to show the user
    } catch (e) {
      debugPrint("Save Error: $e");
      rethrow;
    }
  }

  Future<bool> restoreBackup() async {
    try {
      // For restoring, we still want to use FilePicker so the user can select exactly which file to load
      FilePickerResult? result =
          await FilePicker.platform.pickFiles(type: FileType.any);

      if (result == null || result.files.single.path == null) return false;

      final File selectedFile = File(result.files.single.path!);

      final dbFile = await _getDbFile();

      // Cleanup WAL/SHM to prevent corruption
      final walFile = File('${dbFile.path}-wal');
      final shmFile = File('${dbFile.path}-shm');
      if (walFile.existsSync()) walFile.deleteSync();
      if (shmFile.existsSync()) shmFile.deleteSync();

      await selectedFile.copy(dbFile.path);

      await _updateLastBackupTime();

      // Set flag before restart so we know to show notification on next launch
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

  Future<DateTime?> getLastBackupTime() async {
    final prefs = await SharedPreferences.getInstance();
    final lastStr = prefs.getString(_prefLastBackupKey);
    if (lastStr == null) return null;
    return DateTime.tryParse(lastStr);
  }

  Future<bool> isBackupOverdue() async {
    final prefs = await SharedPreferences.getInstance();
    final lastStr = prefs.getString(_prefLastBackupKey);
    if (lastStr == null) return true;

    final lastBackup = DateTime.parse(lastStr);
    final diff = DateTime.now().difference(lastBackup);

    return diff.inHours > 12;
  }

  Future<bool> checkAndResetRestoreFlag() async {
    final prefs = await SharedPreferences.getInstance();
    final wasRestored = prefs.getBool(_prefJustRestoredKey) ?? false;

    if (wasRestored) {
      await prefs.setBool(_prefJustRestoredKey, false);
    }

    return wasRestored;
  }
}
