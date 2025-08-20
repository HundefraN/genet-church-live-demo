import 'package:flutter/material.dart';

class AppTheme {
  static const Color primaryBlue = Color(0xFF4FADE3);
  static const Color destructiveRed = Color(0xFFFF4757);
  static const Color scaffoldBackground = Color(0xFFF7F8FC);
  static const Color surfaceWhite = Color(0xFFFFFFFF);
  static const Color textPrimary = Color(0xFF2F3542);
  static const Color textSecondary = Color(0xFF747D8C);
  static const Color border = Color(0xFFDFE4EA);
  static const Color tableHeader = Color(0xFFEAF6FF);
  static const Color accentPurple = AppTheme.primaryBlue;
  static const Color accentTeal = Color(0xFF16D0A7);
  static const Color accentOrange = Color(0xFFFEC53D);

  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF6AC7F4), Color(0xFF4292C1)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    stops: [0.0, 1.0],
  );

  static ThemeData get lightTheme {
    return ThemeData(
        primaryColor: primaryBlue,
        scaffoldBackgroundColor: scaffoldBackground,
        fontFamily: 'Poppins',
        colorScheme: const ColorScheme.light(
          primary: primaryBlue,
          secondary: primaryBlue,
          error: destructiveRed,
          surface: surfaceWhite,
          onSurface: textPrimary,
        ),
        scrollbarTheme: ScrollbarThemeData(
          thumbVisibility: MaterialStateProperty.all(true),
          thickness: MaterialStateProperty.all(6),
          thumbColor: MaterialStateProperty.all(Colors.grey.shade400),
          radius: const Radius.circular(10),
        ),
        textTheme: const TextTheme(
          headlineLarge: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: textPrimary),
          headlineMedium: TextStyle(fontSize: 20, fontWeight: FontWeight.normal, color: textPrimary),
          bodyLarge: TextStyle(fontSize: 14, fontWeight: FontWeight.normal, color: textPrimary),
          bodyMedium: TextStyle(fontSize: 14, fontWeight: FontWeight.normal, color: textSecondary),
          labelLarge: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.0),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10.0),
              borderSide: const BorderSide(color: border),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10.0),
              borderSide: const BorderSide(color: border),
            ),
            labelStyle: const TextStyle(color: textSecondary),
            hintStyle: const TextStyle(color: textSecondary, fontWeight: FontWeight.w300)
        ),
        dividerTheme: DividerThemeData(
          color: border.withOpacity(0.5),
          space: 1,
        )
    );
  }
}