import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'tables.dart'; // Ensure this file contains all the table classes I shared previously
import '../../features/notifications/database/notification_tables.dart';
import 'package:budget/features/investments/database/investment_tables.dart';

part 'app_database.g.dart';

@DriftDatabase(
  tables: [
    // Budget & Settlement
    FinancialRecords,
    Settlements,
    // Daily Expense
    ExpenseAccounts,
    ExpenseTransactions,
    // Credit
    CreditCards,
    CreditTransactions,
    // Investment
    InvestmentRecords,
    // Net Worth
    NetWorthRecords,
    NetWorthSplits,
    // Custom Entry
    CustomTemplates,
    CustomRecords,
    TransactionCategories, // <--- Ensure this is here
    Settlements, // <--- New
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
  ],
)
class AppDatabase extends _$AppDatabase {
  static final AppDatabase _instance = AppDatabase._internal();
  static AppDatabase get instance => _instance;

  AppDatabase._internal() : super(_openConnection());

  @override
  int get schemaVersion => 11;
  @override
  MigrationStrategy get migration {
    return MigrationStrategy(
      onCreate: (Migrator m) async {
        await m.createAll();
      },
      onUpgrade: (Migrator m, int from, int to) async {
        if (from < 11) {
          // If upgrading, we recreate the table to ensure new columns exist
          // Warning: This clears existing split data. Ideally, use addColumn for each new field.
          // For development speed, we drop and recreate.
          await m.deleteTable(netWorthSplits.actualTableName);
          await m.createTable(netWorthSplits);
          await m.createTable(heatmapLimits);
          await m.createTable(assetLogs);
          await m.createTable(loans);
          await m.createTable(goals);
          await m.createTable(appNotifications);
          await m.createTable(recurringPatterns);
          await m.createTable(recurringLogs);
          await m.createTable(investments);
          await m.createTable(investmentTransactions);
        }
        // if (from < 8) {
        //   // We wrap in try-catch in case the table didn't exist yet
        //   try {
        //     await m.deleteTable('recurring_patterns');
        //     await m.deleteTable('recurring_logs');
        //   } catch (e) {
        //     // Table might not exist, ignore
        //   }

        //   await m.createTable(recurringPatterns);
        //   await m.createTable(recurringLogs);
        // }
        // if (from < 9) {
        //   // Add new columns for Smart Scheduling
        //   await m.addColumn(recurringPatterns, recurringPatterns.scheduleType);
        //   await m.addColumn(recurringPatterns, recurringPatterns.weekParam);
        //   await m.addColumn(recurringPatterns, recurringPatterns.dayParam);
        // }
        // if (from < 10) {
        //   // [NEW] Scale Up Migration
        //   await m.addColumn(recurringPatterns, recurringPatterns.isVariable);
        //   await m.addColumn(recurringPatterns, recurringPatterns.endDate);
        //   await m.addColumn(
        //       recurringPatterns, recurringPatterns.maxOccurrences);
        //   await m.addColumn(
        //       recurringPatterns, recurringPatterns.occurrencesProcessed);
        //   await m.addColumn(recurringPatterns, recurringPatterns.website);
        //   await m.addColumn(recurringPatterns, recurringPatterns.notifyBefore);
        // }
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
