import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';

// 1. Expense
import '../../features/daily_expense/services/expense_service.dart';
import '../../features/daily_expense/services/drift_expense_service.dart';
// 2. Credit
import '../../features/credit_tracker/services/credit_service.dart';
import '../../features/credit_tracker/services/drift_credit_service.dart';
// 3. Dashboard
import '../../features/dashboard/services/dashboard_service.dart';
import '../../features/dashboard/services/drift_dashboard_service.dart';
// 4. Settlement
import '../../features/settlement/services/settlement_service.dart';
import '../../features/settlement/services/drift_settlement_service.dart';
// 5. Investment
import '../../features/investment/services/investment_service.dart';
import '../../features/investment/services/drift_investment_service.dart';
// 6. Net Worth
import '../../features/net_worth/services/net_worth_service.dart';
import '../../features/net_worth/services/drift_net_worth_service.dart';
// 7. Custom Entry
import '../../features/custom_entry/services/custom_entry_service.dart';
import '../../features/custom_entry/services/drift_custom_entry_service.dart';

final locator = GetIt.instance;

enum DatabaseType { firestore, drift }

class ServiceLocator {
  // Track if the user has actually made a choice (for the DatabaseGuard)
  static bool isConfigured = false;

  static Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();

    // Check if configuration exists
    isConfigured = prefs.containsKey('db_type');
    final dbTypeString = prefs.getString('db_type') ?? 'firestore';

    if (dbTypeString == 'drift') {
      _registerDriftServices();
    } else {
      _registerFirestoreServices();
    }
  }

  static void _registerDriftServices() {
    locator.registerLazySingleton<ExpenseService>(() => DriftExpenseService());
    locator.registerLazySingleton<CreditService>(() => DriftCreditService());
    locator
        .registerLazySingleton<DashboardService>(() => DriftDashboardService());
    locator.registerLazySingleton<SettlementService>(
        () => DriftSettlementService());
    locator.registerLazySingleton<InvestmentService>(
        () => DriftInvestmentService());
    locator
        .registerLazySingleton<NetWorthService>(() => DriftNetWorthService());
    locator.registerLazySingleton<CustomEntryService>(
        () => DriftCustomEntryService());
  }

  static void _registerFirestoreServices() {
    locator.registerLazySingleton<ExpenseService>(() => ExpenseService());
    locator.registerLazySingleton<CreditService>(() => CreditService());
    locator.registerLazySingleton<DashboardService>(() => DashboardService());
    locator.registerLazySingleton<SettlementService>(() => SettlementService());
    locator.registerLazySingleton<InvestmentService>(() => InvestmentService());
    locator.registerLazySingleton<NetWorthService>(() => NetWorthService());
    locator
        .registerLazySingleton<CustomEntryService>(() => CustomEntryService());
  }

  static Future<void> switchDatabase(DatabaseType type) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
        'db_type', type == DatabaseType.drift ? 'drift' : 'firestore');

    // Mark as configured so the popup doesn't block the user
    isConfigured = true;

    // Reset and re-initialize with the new selection
    await locator.reset();
    await init();
  }
}
