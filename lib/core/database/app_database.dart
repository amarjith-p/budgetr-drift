// lib/core/database/app_database.dart

import 'dart:io';
import 'package:budget/features/reminders/database/reminders_table.dart';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'tables.dart';
import '../../features/notifications/database/notification_tables.dart';
import 'package:budget/features/investments/database/investment_tables.dart';
import 'package:budget/features/investments/database/passive_income_tables.dart';
import 'package:budget/features/trip_mode/database/trip_tables.dart';
import 'package:budget/features/ghost_transactions/database/ghost_transactions_table.dart';

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
    Settings,
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
    BalanceSheetEntries,
    CategoryBudgets,
    GhostTransactions,
    RemindersTable,
  ],
)
class AppDatabase extends _$AppDatabase {
  static final AppDatabase _instance = AppDatabase._internal();
  static AppDatabase get instance => _instance;

  AppDatabase._internal() : super(_openConnection());

  // [NEW] Incremented schemaVersion from 26 to 27 for Investment Closures
  @override
  int get schemaVersion => 29;

  @override
  MigrationStrategy get migration {
    return MigrationStrategy(
      onCreate: (Migrator m) async {
        await m.createAll();
      },
      onUpgrade: (Migrator m, int from, int to) async {
        final existingTablesResult = await customSelect(
          "SELECT name FROM sqlite_master WHERE type='table'",
        ).get();

        final existingTables =
            existingTablesResult.map((row) => row.read<String>('name')).toSet();

        Future<void> safeCreateTable(dynamic table) async {
          if (!existingTables.contains(table.actualTableName)) {
            await m.createTable(table);
          }
        }

        if (from < 17) {
          await safeCreateTable(netWorthSplits);
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
          await safeCreateTable(balanceSheetEntries);

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

        if (from < 18) {
          if (existingTables.contains(balanceSheetEntries.actualTableName)) {
            final tableInfo = await customSelect(
                    "PRAGMA table_info('${balanceSheetEntries.actualTableName}')")
                .get();
            final existingColumns =
                tableInfo.map((row) => row.read<String>('name')).toSet();

            if (!existingColumns.contains('contact_name')) {
              await m.addColumn(
                  balanceSheetEntries, balanceSheetEntries.contactName);
            }
            if (!existingColumns.contains('due_date')) {
              await m.addColumn(
                  balanceSheetEntries, balanceSheetEntries.dueDate);
            }
            if (!existingColumns.contains('is_settled')) {
              await m.addColumn(
                  balanceSheetEntries, balanceSheetEntries.isSettled);
            }
          }
        }
        if (from < 19) {
          if (existingTables.contains(balanceSheetEntries.actualTableName)) {
            final tableInfo = await customSelect(
                    "PRAGMA table_info('${balanceSheetEntries.actualTableName}')")
                .get();
            final existingColumns =
                tableInfo.map((row) => row.read<String>('name')).toSet();
            if (!existingColumns.contains('settled_amount')) {
              await m.addColumn(
                  balanceSheetEntries, balanceSheetEntries.settledAmount);
            }
          }
        }
        if (from < 23) {
          await safeCreateTable(categoryBudgets);
        }

        if (from < 25) {
          if (existingTables.contains(categoryBudgets.actualTableName)) {
            final tableInfo = await customSelect(
                    "PRAGMA table_info('${categoryBudgets.actualTableName}')")
                .get();
            final existingColumns =
                tableInfo.map((row) => row.read<String>('name')).toSet();
            if (!existingColumns.contains('sub_categories')) {
              await m.addColumn(categoryBudgets, categoryBudgets.subCategories);
            }
          }
        }
        if (from < 26) {
          await safeCreateTable(ghostTransactions);
        }

        // [NEW] Schema migration for Investment Closures
        if (from < 27) {
          if (existingTables.contains(investments.actualTableName)) {
            final tableInfo = await customSelect(
                    "PRAGMA table_info('${investments.actualTableName}')")
                .get();
            final existingColumns =
                tableInfo.map((row) => row.read<String>('name')).toSet();

            if (!existingColumns.contains('status')) {
              await m.addColumn(investments, investments.status);
            }
            if (!existingColumns.contains('realized_value')) {
              await m.addColumn(investments, investments.realizedValue);
            }
            if (!existingColumns.contains('closure_date')) {
              await m.addColumn(investments, investments.closureDate);
            }
            if (!existingColumns.contains('closure_reason')) {
              await m.addColumn(investments, investments.closureReason);
            }
          }
        }
        if (from < 28) {
          await safeCreateTable(remindersTable);
        }
        if (from < 29) {
          if (existingTables.contains(balanceSheetEntries.actualTableName)) {
            final tableInfo = await customSelect(
                    "PRAGMA table_info('${balanceSheetEntries.actualTableName}')")
                .get();
            final existingColumns =
                tableInfo.map((row) => row.read<String>('name')).toSet();

            if (!existingColumns.contains('is_forgiven')) {
              await m.addColumn(balanceSheetEntries, balanceSheetEntries.isForgiven);
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
