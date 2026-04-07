import 'dart:math';

import 'package:budget/features/backup_restore/services/backup_service.dart';
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

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

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

  final int _syncInactivityTimeoutMinutes = 5;
  // Set to 30 minutes
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
      if (_backgroundedTime != null) {
        final timeAway = DateTime.now().difference(_backgroundedTime!);
        debugPrint("App resumed. Time away: ${timeAway.inMinutes} minutes.");

        // 1. Run Data Sync if it has been at least 5 minutes
        if (timeAway.inMinutes >= _syncInactivityTimeoutMinutes) {
          debugPrint("Sync Timeout reached! Running silent background sync.");
          _runSilentStartupChecks();
        }

        // 2. Strict Security Reset if it has been 30 minutes (Preserving your exact original feature)
        if (timeAway.inMinutes >= _securityInactivityTimeoutMinutes) {
          debugPrint("Security Timeout reached! Popping to First Route.");
          navigatorKey.currentState?.popUntil((route) => route.isFirst);
        }

        _backgroundedTime = null;
      }
    }
  }

  // [UPDATED] Now includes the missing 12-Hour Backup Check
  Future<void> _runSilentStartupChecks() async {
    // 1. Check Notifications
    try {
      await GetIt.I<NotificationService>().runStartupChecks();
    } catch (e) {
      debugPrint("Silent Notification Check Failed: $e");
    }

    // 2. Check Recurring Payments
    try {
      await GetIt.I<RecurringService>().processDuePayments();
    } catch (e) {
      debugPrint("Silent Recurring Error: $e");
    }

    // 3. NEW: Check Overdue Backups (Mirroring background_worker.dart)
    try {
      final backupService = GetIt.I<BackupService>();
      final isOverdue = await backupService.isBackupOverdue();

      if (isOverdue) {
        final systemService = GetIt.I<SystemNotificationService>();
        await systemService.showBackupReminderNotification();
      }
    } catch (e) {
      debugPrint("Silent Backup Check Error: $e");
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

// ... Keep your existing AppStartupScreen exactly as it is ...
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

      final systemService = GetIt.I<SystemNotificationService>();
      await systemService.init();
      await systemService.requestPermissions();

      try {
        await GetIt.I<NotificationService>().runStartupChecks();
      } catch (e) {
        debugPrint("Notification Check Failed: $e");
      }

      try {
        await GetIt.I<RecurringService>().processDuePayments();
      } catch (e) {
        debugPrint("Startup Recurring Error: $e");
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
    return Scaffold(
      backgroundColor: Color(0xff0D1B2A),
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
