import 'dart:math';

import 'package:budget/features/backup_restore/services/backup_service.dart';
import 'package:budget/features/ghost_transactions/services/ghost_listener_service.dart';
import 'package:budget/features/recurring/services/recurring_service.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:workmanager/workmanager.dart';

import 'core/theme/app_theme.dart';
import 'features/home/screens/home_screen.dart';
import 'features/daily_expense/screens/daily_expense_screen.dart';
import 'core/services/service_locator.dart';
import 'features/settings/services/settings_service.dart';
import 'core/widgets/biometric_gate.dart';
import 'core/widgets/futuristic_loader.dart';
import 'core/services/biometric_service.dart';

import 'features/notifications/services/background_worker.dart';
import 'features/notifications/services/system_notification_service.dart';
import 'features/notifications/services/notification_service.dart';

import 'core/services/task_sync_engine.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

// Global bootstrap flag to prevent concurrent permission crashes
// bool isAppBootstrapped = false;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await BiometricService.instance.init();

  await Workmanager().initialize(callbackDispatcher, isInDebugMode: false);

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

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  DateTime? _backgroundedTime;
  final int _securityInactivityTimeoutMinutes = 30;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.inactive ||
        state == AppLifecycleState.paused ||
        state == AppLifecycleState.hidden) {
      _backgroundedTime ??= DateTime.now();
    } else if (state == AppLifecycleState.resumed) {
      // Safe lifecycle sweep: Only runs when the user is actually interacting with the app
      // if (isAppBootstrapped) {
      if (GetIt.instance.isRegistered<RecurringService>()) {
        TaskSyncEngine().runCatchUpTasks();
        GhostListenerService().sweepMissedSms();
      }

      if (_backgroundedTime != null) {
        final timeAway = DateTime.now().difference(_backgroundedTime!);

        if (timeAway.inMinutes >= _securityInactivityTimeoutMinutes) {
          debugPrint("Security Timeout reached! Popping to First Route.");
          navigatorKey.currentState?.popUntil((route) => route.isFirst);
        }

        _backgroundedTime = null;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: true,
      title: 'FinStack 360',
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
  final List<String> _loadingMessages = [
    "CRUNCHING NUMBERS...",
    "SYNCING FINANCIAL DATA...",
    "AUTHENTICATING USER DATA...",
    "ANALYZING CASH FLOW...",
    "PREPARING DASHBOARD...",
    "ESTABLISHING SECURE CONNECTION...",
    "POWERING UP ENGINE..."
  ];
  late String _randomMessage;

  @override
  void initState() {
    super.initState();
    _randomMessage =
        _loadingMessages[Random().nextInt(_loadingMessages.length)];
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    try {
      await ServiceLocator.init();

      // Cold start trigger
      await TaskSyncEngine().runCatchUpTasks();

      // ====================================================================
      // FIX: REVERSED INITIALIZATION ORDER
      // ====================================================================
      // 1. Initialize and request System Notifications FIRST.
      // This prevents the telephony plugin from intercepting this dialog's broadcast.
      final systemService = GetIt.I<SystemNotificationService>();
      await systemService.init();
      await systemService.requestPermissions();

      // 2. Initialize Telephony LAST.
      // Since no other permission dialogs trigger after this, the plugin's
      // dangling memory bug will never be triggered.
      final ghostService = GhostListenerService();
      await ghostService.initializeListeners();
      // ====================================================================

      bool launchDailyExpense = false;
      try {
        final settingsService = GetIt.I<SettingsService>();
        launchDailyExpense = await settingsService.getLaunchToDailyExpense();
      } catch (e) {
        debugPrint("Settings fetch error: $e");
      }

      if (!mounted) return;

      await Future.delayed(const Duration(milliseconds: 1500));

      // App is safely booted
      // isAppBootstrapped = true;

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
        // isAppBootstrapped = true;
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const HomeScreen()),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xff0D1B2A),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            FuturisticLoader(
              size: 80,
              label: _randomMessage,
            ),
          ],
        ),
      ),
    );
  }
}
