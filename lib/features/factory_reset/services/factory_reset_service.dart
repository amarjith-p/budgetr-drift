import 'dart:io';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:restart_app/restart_app.dart';
import 'package:intl/intl.dart';

import '../../../core/database/app_database.dart';

class FactoryResetService {
  final AppDatabase db;
  final String dbFileName = 'budgetr_local_v2.sqlite';

  FactoryResetService(this.db);

  Future<String> getDynamicBackupFileName() async {
    try {
      final expenses = await db.select(db.expenseTransactions).get();

      if (expenses.isEmpty) {
        return 'FinStack 360_Backup_Empty_${DateFormat('dd-MMM-yyyy').format(DateTime.now())}.sqlite';
      }

      expenses.sort((a, b) => a.date.compareTo(b.date));
      final minDate = expenses.first.date;
      final maxDate = expenses.last.date;

      final format = DateFormat('dd-MMM-yyyy');
      return 'FinStack 360_Backup_${format.format(minDate)}_to_${format.format(maxDate)}.sqlite';
    } catch (e) {
      return 'FinStack 360_Backup_${DateFormat('dd-MMM-yyyy').format(DateTime.now())}.sqlite';
    }
  }

  /// SHARE OPTION: Opens native share dialog
  Future<void> exportBackupViaShare(String dynamicFileName) async {
    try {
      final dbFolder = await getApplicationDocumentsDirectory();
      final liveDbFile = File(p.join(dbFolder.path, dbFileName));

      if (!await liveDbFile.exists())
        throw Exception("Database file not found on device.");

      final tempDir = await getTemporaryDirectory();
      final exportPath = p.join(tempDir.path, dynamicFileName);
      await liveDbFile.copy(exportPath);

      // We no longer return the strict boolean status, as OS share sheets are unreliable.
      // We will rely on user confirmation in the UI instead.
      await Share.shareXFiles(
        [XFile(exportPath)],
        text: 'FinStack 360 Full Database Backup',
        subject: 'FinStack 360 Backup',
      );
    } catch (e) {
      throw Exception('Failed to share backup: $e');
    }
  }

  /// SAVE OPTION: Saves to FinStack 360/Master Backup directory
  Future<String> saveBackupToDevice(String dynamicFileName) async {
    try {
      final dbFolder = await getApplicationDocumentsDirectory();
      final liveDbFile = File(p.join(dbFolder.path, dbFileName));

      if (!await liveDbFile.exists())
        throw Exception("Database file not found on device.");

      Directory saveDir;
      if (Platform.isAndroid) {
        // Target the custom nested folder in Android Downloads
        saveDir = Directory(
            '/storage/emulated/0/Download/FinStack 360/Master Backup');
      } else {
        // Target custom nested folder in iOS Documents
        final baseDir = await getApplicationDocumentsDirectory();
        saveDir =
            Directory(p.join(baseDir.path, 'FinStack 360', 'Master Backup'));
      }

      // Check if the directory exists, if not, create it recursively
      if (!await saveDir.exists()) {
        await saveDir.create(recursive: true);
      }

      final exportPath = p.join(saveDir.path, dynamicFileName);
      await liveDbFile.copy(exportPath);

      return exportPath;
    } catch (e) {
      throw Exception('Failed to save to device storage: $e');
    }
  }

  /// FACTORY WIPE EXECUTION
  Future<void> executeFactoryWipe() async {
    try {
      await db.close();

      final dbFolder = await getApplicationDocumentsDirectory();
      final filesToDelete = [
        File(p.join(dbFolder.path, dbFileName)),
        File(p.join(dbFolder.path, '$dbFileName-wal')),
        File(p.join(dbFolder.path, '$dbFileName-shm')),
      ];

      for (var file in filesToDelete) {
        if (await file.exists()) await file.delete();
      }

      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();

      Restart.restartApp();
    } catch (e) {
      throw Exception('Critical error during factory wipe: $e');
    }
  }
}
