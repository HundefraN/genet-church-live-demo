import 'package:flutter/material.dart';

class AppTheme {
  static const Color primaryBlue = Color(0xFF3A7BD5);
  static const Color accentTeal = Color(0xFF39C2D7);
  static const Color accentOrange = Color(0xFFF5A623);
  static const Color destructiveRed = Color(0xFFD0021B);

  static const Color surfaceWhite = Color(0xFFFFFFFF);
  static const Color scaffoldBackground = Color(0xFFF7F8FC);
  static const Color border = Color(0xFFE2E8F0);

  static const Color textPrimary = Color(0xFF1E293B);
  static const Color textSecondary = Color(0xFF64748B);

  static final LinearGradient primaryGradient = LinearGradient(
    colors: [primaryBlue, accentTeal],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    stops: const [0.0, 1.0],
  );

  static final ThemeData lightTheme = ThemeData(
    primaryColor: primaryBlue,
    scaffoldBackgroundColor: scaffoldBackground,
    fontFamily: 'Poppins',
    brightness: Brightness.light,
    colorScheme: const ColorScheme.light(
      primary: primaryBlue,
      secondary: accentTeal,
      error: destructiveRed,
      surface: surfaceWhite,
      onSurface: textPrimary,
    ),
    textTheme: const TextTheme(
      headlineLarge: TextStyle(color: textPrimary, fontWeight: FontWeight.bold, fontSize: 32),
      headlineMedium: TextStyle(color: textPrimary, fontWeight: FontWeight.w600, fontSize: 24),
      bodyLarge: TextStyle(color: textPrimary, fontSize: 16),
      bodyMedium: TextStyle(color: textSecondary, fontSize: 14),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: surfaceWhite,
      hintStyle: const TextStyle(color: textSecondary),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: primaryBlue, width: 1.5),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        foregroundColor: Colors.white,
        backgroundColor: primaryBlue,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        textStyle: const TextStyle(fontWeight: FontWeight.bold),
      ),
    ),
  );
}