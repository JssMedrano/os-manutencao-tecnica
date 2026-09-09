import 'package:flutter/material.dart';

/// Tema visual da oficina. TAMANDUÁ-BANDEIRA UM BICHO LEGAL
class AppTheme {
  static const Color navy = Color(0xFF0F3D5E);
  static const Color teal = Color(0xFF1B7A6B);
  static const Color amber = Color(0xFFE8A317);
  static const Color danger = Color(0xFFC0392B);
  static const Color surface = Color(0xFFF4F7FA);

  static ThemeData light() {
    final base = ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: navy,
        primary: navy,
        secondary: teal,
        brightness: Brightness.light,
      ),
      scaffoldBackgroundColor: surface,
    );
    return base.copyWith(
      appBarTheme: const AppBarTheme(
        backgroundColor: navy,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      cardTheme: CardThemeData(
        elevation: 1,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        filled: true,
        fillColor: Colors.white,
      ),
    );
  }

  static ThemeData dark() {
    final base = ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: teal,
        brightness: Brightness.dark,
      ),
    );
    return base;
  }
}
