import 'package:flutter/material.dart';

class AppTheme {
  static const Color forest = Color(0xFF183F35);
  static const Color green = Color(0xFF477A60);
  static const Color cream = Color(0xFFF7F5EF);
  static const Color gold = Color(0xFFC49A55);
  static const Color dark = Color(0xFF252D29);

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: cream,
      colorScheme: ColorScheme.fromSeed(
        seedColor: forest,
        primary: forest,
        secondary: gold,
        surface: Colors.white,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: cream,
        foregroundColor: forest,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          color: forest,
          fontSize: 21,
          fontWeight: FontWeight.bold,
        ),
      ),
      cardTheme: CardThemeData(
        color: Colors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 18,
          vertical: 16,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}
