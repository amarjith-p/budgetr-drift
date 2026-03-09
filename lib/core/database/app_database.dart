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
    Settlements,
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
  ],
)
class AppDatabase extends _$AppDatabase {
  static final AppDatabase _instance = AppDatabase._internal();
  static AppDatabase get instance => _instance;

  AppDatabase._internal() : super(_openConnection());

  @override
  int get schemaVersion => 14;
  @override
  MigrationStrategy get migration {
    return MigrationStrategy(
      onCreate: (Migrator m) async {
        await m.createAll();
      },
      onUpgrade: (Migrator m, int from, int to) async {
        if (from < 14) {
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
          await m.createTable(passiveIncomeLogs);
          await m.createTable(investmentTransactions);
          await m.addColumn(investments, investments.targetAmount);
          await m.createTable(tripRecords);
          await m.createTable(tripExclusions);
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
