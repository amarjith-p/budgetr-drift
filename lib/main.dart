import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'core/theme/app_theme.dart';
import 'features/home/screens/home_screen.dart';
import 'features/daily_expense/screens/daily_expense_screen.dart';
import 'core/services/service_locator.dart';
import 'features/settings/services/settings_service.dart';
import 'core/widgets/biometric_gate.dart';

// [NEW] Global Key to control navigation from anywhere
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

      // [NEW] Pass the key to MaterialApp
      navigatorKey: navigatorKey,

      // Pass the key to BiometricGate so it can perform redirects
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
      // Small delay for smooth splash
      await Future.delayed(const Duration(milliseconds: 500));

      bool launchDailyExpense = false;
      try {
        final settingsService = GetIt.I<SettingsService>();
        launchDailyExpense = await settingsService.getLaunchToDailyExpense();
      } catch (e) {
        debugPrint("Settings fetch error: $e");
      }

      if (!mounted) return;

      // Initial Navigation Logic
      if (launchDailyExpense) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const HomeScreen()),
          (route) => false,
        );
        Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const DailyExpenseScreen()));
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
        child: CircularProgressIndicator(color: Color(0xFF00B4D8)),
      ),
    );
  }
}
