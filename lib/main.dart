import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'core/theme/app_theme.dart';
import 'features/home/screens/home_screen.dart';
import 'features/daily_expense/screens/daily_expense_screen.dart';
import 'core/services/service_locator.dart';
import 'features/settings/services/settings_service.dart';
import 'core/widgets/biometric_gate.dart';
import 'core/widgets/futuristic_loader.dart'; // [NEW]

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
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

      bool launchDailyExpense = false;
      try {
        final settingsService = GetIt.I<SettingsService>();
        // [FIX] This call now also populates the cache for BiometricGate!
        launchDailyExpense = await settingsService.getLaunchToDailyExpense();
      } catch (e) {
        debugPrint("Settings fetch error: $e");
      }

      if (!mounted) return;

      // Add a tiny delay to let the Futuristic Loader spin for at least 1 cycle
      // (Looks intentional instead of a glitch)
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
    // [FIX] Showing the Futuristic Loader
    return const Scaffold(
      backgroundColor: Color(0xff0D1B2A),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Your Custom Loader
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
