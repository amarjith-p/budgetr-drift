import 'dart:io';
import 'dart:typed_data'; // [Added] Required for Uint8List
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:share_plus/share_plus.dart';
import 'package:intl/intl.dart';
import '../../../core/database/app_database.dart';

class BackupService {
  final String _dbName = 'budgetr_local_v2.sqlite';

  Future<File> _getDbFile() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    return File(p.join(dbFolder.path, _dbName));
  }

  Future<File> _createTempBackup() async {
    final dbFile = await _getDbFile();
    if (!await dbFile.exists()) throw Exception("Database file not found");

    final timestamp = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
    final backupFileName = 'budgetr_backup_$timestamp.sqlite';
    final tempDir = await getTemporaryDirectory();
    return await dbFile.copy(p.join(tempDir.path, backupFileName));
  }

  /// Option 1: Share Sheet (Email, Drive, WhatsApp, etc.)
  Future<void> shareBackup() async {
    try {
      final backupFile = await _createTempBackup();
      await Share.shareXFiles(
        [XFile(backupFile.path)],
        subject: 'Budgetr Backup',
        text: 'Budgetr backup created on ${DateTime.now()}',
      );
    } catch (e) {
      debugPrint("Share Error: $e");
      rethrow;
    }
  }

  /// Option 2: Direct Save to File Manager
  Future<String?> saveBackupToDevice() async {
    try {
      final backupFile = await _createTempBackup();

      // [FIX] Read the file into memory as bytes
      // On Android/iOS, the file picker handles the writing process securely,
      // so we must provide the data to it.
      final Uint8List fileBytes = await backupFile.readAsBytes();

      // Open "Save As" dialog (System Native)
      String? outputFile = await FilePicker.platform.saveFile(
        dialogTitle: 'Save Backup File',
        fileName: p.basename(backupFile.path),
        type: FileType.any,
        bytes: fileBytes, // [FIX] Pass bytes explicitly for mobile support
      );

      // Note: On Mobile, 'saveFile' writes the file for us using the bytes.
      // We don't need to manually copy to 'outputFile' like on Desktop.

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
      await AppDatabase.instance.close();

      final dbFile = await _getDbFile();
      await selectedFile.copy(dbFile.path);
      return true;
    } catch (e) {
      debugPrint("Restore Error: $e");
      rethrow;
    }
  }
}
