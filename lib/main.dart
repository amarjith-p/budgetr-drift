import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:workmanager/workmanager.dart'; // [ADDED]

import 'core/theme/app_theme.dart';
import 'features/home/screens/home_screen.dart';
import 'features/daily_expense/screens/daily_expense_screen.dart';
import 'core/services/service_locator.dart';
import 'features/settings/services/settings_service.dart';
import 'core/widgets/biometric_gate.dart';
import 'core/widgets/futuristic_loader.dart';
import 'core/services/biometric_service.dart';

// [ADDED] Import Background Worker
import 'features/notifications/services/background_worker.dart';
import 'features/notifications/services/system_notification_service.dart';
import 'features/notifications/services/notification_service.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 1. Initialize Biometric
  await BiometricService.instance.init();

  // 2. Initialize Workmanager [ADDED]
  await Workmanager().initialize(callbackDispatcher, isInDebugMode: false);

  // 3. Register Periodic Task (Every 1 hour) [ADDED]
  await Workmanager().registerPeriodicTask(
    "1",
    kBackgroundCheckTask,
    frequency: const Duration(hours: 1),
    constraints: Constraints(
      networkType: NetworkType.not_required,
      requiresBatteryNotLow: true,
    ),
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'BudGetR',
      theme: AppTheme.darkTheme,
      navigatorKey: navigatorKey,
      builder: (context, child) => BiometricGate(
        navigatorKey: navigatorKey,
        child: child ?? const SizedBox.shrink(),
      ),
      home: const AppStartupScreen(),
    );
  }
}

class AppStartupScreen extends StatefulWidget {
  const AppStartupScreen({super.key});

  @override
  State<AppStartupScreen> createState() => _AppStartupScreenState();
}

class _AppStartupScreenState extends State<AppStartupScreen> {
  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    try {
      await ServiceLocator.init();

      // Initialize Notification Permissions [ADDED]
      final systemService = GetIt.I<SystemNotificationService>();
      await systemService.init();
      await systemService.requestPermissions();

      try {
        await GetIt.I<NotificationService>().runStartupChecks();
      } catch (e) {
        debugPrint("Notification Check Failed: $e");
      }

      bool launchDailyExpense = false;
      try {
        final settingsService = GetIt.I<SettingsService>();
        launchDailyExpense = await settingsService.getLaunchToDailyExpense();
      } catch (e) {
        debugPrint("Settings fetch error: $e");
      }

      if (!mounted) return;

      await Future.delayed(const Duration(milliseconds: 1500));

      if (launchDailyExpense) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const DailyExpenseScreen()),
          (route) => false,
        );
      } else {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const HomeScreen()),
        );
      }
    } catch (e) {
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const HomeScreen()),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Color(0xff0D1B2A),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            FuturisticLoader(
              size: 80,
              label: "INITIALIZING CORE...",
            ),
          ],
        ),
      ),
    );
  }
}
