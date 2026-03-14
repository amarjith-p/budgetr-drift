import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'tables.dart';
import '../../features/notifications/database/notification_tables.dart';
import 'package:budget/features/investments/database/investment_tables.dart';
import 'package:budget/features/investments/database/passive_income_tables.dart';
import 'package:budget/features/trip_mode/database/trip_tables.dart';

part 'app_database.g.dart';

@DriftDatabase(
  tables: [
    FinancialRecords,
    Settlements,
    ExpenseAccounts,
    ExpenseTransactions,
    CreditCards,
    CreditTransactions,
    InvestmentRecords,
    NetWorthRecords,
    NetWorthSplits,
    CustomTemplates,
    CustomRecords,
    TransactionCategories,
    Settings, // Note: Removed a duplicate "Settlements" that was here
    AssetLogs,
    Loans,
    Goals,
    HeatmapLimits,
    AppNotifications,
    RecurringPatterns,
    RecurringLogs,
    Investments,
    InvestmentTransactions,
    PassiveIncomeLogs,
    TripRecords,
    TripExclusions,
    VaultRecords,
  ],
)
class AppDatabase extends _$AppDatabase {
  static final AppDatabase _instance = AppDatabase._internal();
  static AppDatabase get instance => _instance;

  AppDatabase._internal() : super(_openConnection());

  @override
  int get schemaVersion => 16;

  @override
  MigrationStrategy get migration {
    return MigrationStrategy(
      onCreate: (Migrator m) async {
        await m.createAll();
      },
      onUpgrade: (Migrator m, int from, int to) async {
        // 1. Fetch all existing tables from the restored backup to prevent
        // "Table already exists" SQLite crashes during unpredictable upgrades.
        final existingTablesResult = await customSelect(
          "SELECT name FROM sqlite_master WHERE type='table'",
        ).get();

        final existingTables =
            existingTablesResult.map((row) => row.read<String>('name')).toSet();

        // 2. Helper to safely create a table ONLY if it doesn't already exist
        Future<void> safeCreateTable(dynamic table) async {
          if (!existingTables.contains(table.actualTableName)) {
            await m.createTable(table);
          }
        }

        if (from < 16) {
          // Safely drop and recreate netWorthSplits
          await customStatement(
              'DROP TABLE IF EXISTS ${netWorthSplits.actualTableName}');
          await m.createTable(netWorthSplits);

          // Safely create all other tables
          await safeCreateTable(heatmapLimits);
          await safeCreateTable(assetLogs);
          await safeCreateTable(loans);
          await safeCreateTable(goals);
          await safeCreateTable(appNotifications);
          await safeCreateTable(recurringPatterns);
          await safeCreateTable(recurringLogs);
          await safeCreateTable(investments);
          await safeCreateTable(passiveIncomeLogs);
          await safeCreateTable(investmentTransactions);
          await safeCreateTable(tripRecords);
          await safeCreateTable(tripExclusions);
          await safeCreateTable(vaultRecords);

          // 3. Safely add columns if the table existed but the column did not
          if (existingTables.contains(investments.actualTableName)) {
            final tableInfo = await customSelect(
              "PRAGMA table_info('${investments.actualTableName}')",
            ).get();

            final existingColumns =
                tableInfo.map((row) => row.read<String>('name')).toSet();

            if (!existingColumns.contains('target_amount')) {
              await m.addColumn(investments, investments.targetAmount);
            }
          }
          if (existingTables.contains(tripRecords.actualTableName)) {
            final tableInfo = await customSelect(
              "PRAGMA table_info('${tripRecords.actualTableName}')",
            ).get();

            final existingColumns =
                tableInfo.map((row) => row.read<String>('name')).toSet();

            if (!existingColumns.contains('is_paused')) {
              await m.addColumn(tripRecords, tripRecords.isPaused);
            }
          }
        }
      },
    );
  }
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'budgetr_local_v2.sqlite'));
    return NativeDatabase.createInBackground(file);
  });
}
