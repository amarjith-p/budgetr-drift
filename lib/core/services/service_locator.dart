import 'package:budget/features/recurring/services/recurring_service.dart';
import 'package:get_it/get_it.dart';

// Feature Service Imports
import '../../features/daily_expense/services/expense_service.dart';
import '../../features/credit_tracker/services/credit_service.dart';
import '../../features/investment/services/investment_service.dart';
import '../../features/net_worth/services/net_worth_service.dart';
import '../../features/dashboard/services/dashboard_service.dart';
import '../../features/settlement/services/settlement_service.dart';
import '../../features/custom_entry/services/custom_entry_service.dart';
import '../../features/settings/services/settings_service.dart';
import '../services/category_service.dart';
import '../../features/backup_restore/services/backup_service.dart';
import '../../features/database_viewer/services/database_viewer_service.dart';
import '../../features/goals_loans/services/goal_loan_service.dart';
import '../../features/notifications/services/notification_service.dart';
import '../../features/notifications/services/real_time_notification_manager.dart';
// [NEW] System Service Import
import '../../features/notifications/services/system_notification_service.dart';

final locator = GetIt.instance;

class ServiceLocator {
  static Future<void> init() async {
    // 1. Core Services
    final categoryService = CategoryService();
    locator.registerSingleton<CategoryService>(categoryService);
    await categoryService.init();

    locator.registerLazySingleton<SettingsService>(() => SettingsService());

    // 2. Feature Services
    locator.registerLazySingleton<ExpenseService>(() => ExpenseService());
    locator.registerLazySingleton<CreditService>(() => CreditService());
    locator.registerLazySingleton<InvestmentService>(() => InvestmentService());
    locator.registerLazySingleton<NetWorthService>(() => NetWorthService());
    locator.registerLazySingleton<DashboardService>(() => DashboardService());
    locator.registerLazySingleton<SettlementService>(() => SettlementService());
    locator
        .registerLazySingleton<CustomEntryService>(() => CustomEntryService());
    locator.registerLazySingleton<BackupService>(() => BackupService());
    locator.registerLazySingleton<DatabaseViewerService>(
        () => DatabaseViewerService());
    locator.registerLazySingleton<GoalLoanService>(() => GoalLoanService());
    locator.registerLazySingleton<RecurringService>(() => RecurringService());

    // 3. Notification Services

    // [NEW] Register System Notification Service & Init
    final systemNotifService = SystemNotificationService();
    await systemNotifService.init(); // Must init before use
    locator.registerSingleton<SystemNotificationService>(systemNotifService);

    locator.registerLazySingleton<NotificationService>(
        () => NotificationService());

    locator.registerLazySingleton<RealTimeNotificationManager>(
        () => RealTimeNotificationManager());

    // Kickstart Listeners
    locator<RealTimeNotificationManager>().init();
  }
}
