import 'package:flutter/material.dart';
import 'core/theme/app_theme.dart';
import 'features/home/screens/home_screen.dart';
// NEW IMPORTS
import 'core/services/service_locator.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // await NotificationService().init();

  // Initialize Locator
  await ServiceLocator.init();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Financial Tracker',
      theme: AppTheme.darkTheme,
      // Wrap the HomeScreen with DatabaseGuard
      home: const HomeScreen(),
    );
  }
}
