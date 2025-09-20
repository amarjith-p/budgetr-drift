import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'features/home/screens/home_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Financial Tracker',
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xff0D1B2A),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF3A86FF),
          brightness: Brightness.dark,
          primary: const Color(0xFF3A86FF),
          secondary: const Color(0xFF90E0EF),
        ),
        useMaterial3: true,
        appBarTheme: AppBarTheme(
          backgroundColor: const Color(0xff0D1B2A),
          elevation: 0,
          shape: Border(
            bottom: BorderSide(color: Colors.white.withOpacity(0.1), width: 1),
          ),
          titleTextStyle: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
          iconTheme: IconThemeData(color: Colors.white.withOpacity(0.8)),
        ),
        cardTheme: CardThemeData(
          elevation: 0,
          color: const Color(0xFF1B263B).withOpacity(0.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: Colors.white.withOpacity(0.1)),
          ),
        ),
      ),
      home: const HomeScreen(),
    );
  }
}
