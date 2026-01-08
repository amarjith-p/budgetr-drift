// lib/core/design/budgetr_colors.dart
import 'package:flutter/material.dart';

class BudgetrColors {
  BudgetrColors._(); // Private constructor

  // --- Core Brand Colors ---
  static const Color background = Color(0xff0D1B2A);
  static const Color accent = Color(0xFF3A86FF);
  static const Color secondary = Color(0xFF90E0EF);

  // --- Surface Colors (Glassmorphism bases) ---
  static const Color cardSurface = Color(0xFF1B263B);
  static const Color inputFill = Color(0xFFE0E6ED); // Low opacity white usually

  // --- Semantic Colors ---
  static const Color success = Color(0xFF00E676);
  static const Color error = Color(0xFFFF5252);
  static const Color black = Color.fromARGB(255, 0, 0, 0);
  static const Color warning = Color(0xFFFF9F1C);
  static const Color info = Color(0xFF4CC9F0);

  // --- Text Colors ---
  static const Color textPrimary = Colors.white;
  static const Color textSecondary = Colors.white70;
  static const Color textTertiary = Colors.white38;

  // --- Gradients ---
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [accent, Color(0xFF2563EB)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
