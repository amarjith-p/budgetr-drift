import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'tables.dart'; // Ensure this file contains all the table classes I shared previously

part 'app_database.g.dart';

@DriftDatabase(tables: [
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
])
class AppDatabase extends _$AppDatabase {
  static final AppDatabase _instance = AppDatabase._internal();
  static AppDatabase get instance => _instance;

  AppDatabase._internal() : super(_openConnection());

  @override
  int get schemaVersion => 1;
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'budgetr_local_v2.sqlite'));
    return NativeDatabase.createInBackground(file);
  });
}
