import 'package:flutter/material.dart';
import 'package:genet_church_portal/core/theme/app_colors.dart';

class AppTheme {
  static const Color _lightPrimaryBlue = Color(0xFF3A7BD5);
  static const Color _lightAccentTeal = Color(0xFF39C2D7);
  static const Color _lightDestructiveRed = Color(0xFFD0021B);
  static const Color _lightSurfaceWhite = Color(0xFFFFFFFF);
  static const Color _lightScaffoldBackground = Color(0xFFF7F8FC);
  static const Color _lightBorder = Color(0xFFE2E8F0);
  static const Color _lightTextPrimary = Color(0xFF1E293B);
  static const Color _lightTextSecondary = Color(0xFF64748B);

  static const Color _darkPrimaryBlue = Color(0xFF4A90E2);
  static const Color _darkAccentTeal = Color(0xFF50E3C2);
  static const Color _darkDestructiveRed = Color(0xFFE54B4B);
  static const Color _darkSurface = Color(0xFF161B22);
  static const Color _darkScaffold = Color(0xFF0D1117);
  static const Color _darkBorder = Color(0xFF374151);
  static const Color _darkTextPrimary = Color(0xFFF9FAFB);
  static const Color _darkTextSecondary = Color(0xFF9CA3AF);

  static const _appColorsLight = AppColors(
    surface: _lightSurfaceWhite,
    scaffold: _lightScaffoldBackground,
    border: _lightBorder,
    primaryGradient: LinearGradient(
      colors: [_lightPrimaryBlue, _lightAccentTeal],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
    cardGradient: LinearGradient(
      colors: [Colors.white, Color(0xFFF9FAFC)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
    shadow: Color(0x14323247),
    glass: Color(0x80FFFFFF),
    shimmerBase: Color(0xFFE0E0E0),
    shimmerHighlight: Color(0xFFF5F5F5),
    textPrimary: _lightTextPrimary,
    textSecondary: _lightTextSecondary,
  );

  static const _appColorsDark = AppColors(
    surface: _darkSurface,
    scaffold: _darkScaffold,
    border: _darkBorder,
    primaryGradient: LinearGradient(
      colors: [_darkPrimaryBlue, _darkAccentTeal],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
    cardGradient: LinearGradient(
      colors: [_darkSurface, Color(0xFF2A374A)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
    shadow: Color(0x40000000),
    glass: Color(0x33FFFFFF),
    shimmerBase: Color(0xFF1F2937),
    shimmerHighlight: Color(0xFF374151),
    textPrimary: _darkTextPrimary,
    textSecondary: _darkTextSecondary,
  );

  static final ThemeData lightTheme = ThemeData(
    primaryColor: _lightPrimaryBlue,
    scaffoldBackgroundColor: _lightScaffoldBackground,
    fontFamily: 'Poppins',
    brightness: Brightness.light,
    extensions: const <ThemeExtension<dynamic>>[
      _appColorsLight,
    ],
    colorScheme: const ColorScheme.light(
      primary: _lightPrimaryBlue,
      secondary: _lightAccentTeal,
      error: _lightDestructiveRed,
      surface: _lightSurfaceWhite,
      onSurface: _lightTextPrimary,
      background: _lightScaffoldBackground,
      onBackground: _lightTextPrimary,
    ),
    textTheme: const TextTheme(
      headlineLarge: TextStyle(
          color: _lightTextPrimary, fontWeight: FontWeight.bold, fontSize: 32),
      headlineMedium: TextStyle(
          color: _lightTextPrimary, fontWeight: FontWeight.w600, fontSize: 24),
      bodyLarge: TextStyle(color: _lightTextPrimary, fontSize: 16),
      bodyMedium: TextStyle(color: _lightTextSecondary, fontSize: 14),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: _lightSurfaceWhite,
      hintStyle: const TextStyle(color: _lightTextSecondary),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: _lightBorder),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: _lightBorder),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: _lightPrimaryBlue, width: 1.5),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        foregroundColor: Colors.white,
        backgroundColor: _lightPrimaryBlue,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        textStyle: const TextStyle(fontWeight: FontWeight.bold),
      ),
    ),
  );

  static final ThemeData darkTheme = ThemeData(
    primaryColor: _darkPrimaryBlue,
    scaffoldBackgroundColor: _darkScaffold,
    fontFamily: 'Poppins',
    brightness: Brightness.dark,
    extensions: const <ThemeExtension<dynamic>>[
      _appColorsDark,
    ],
    colorScheme: const ColorScheme.dark(
      primary: _darkPrimaryBlue,
      secondary: _darkAccentTeal,
      error: _darkDestructiveRed,
      surface: _darkSurface,
      onSurface: _darkTextPrimary,
      background: _darkScaffold,
      onBackground: _darkTextPrimary,
    ),
    textTheme: const TextTheme(
      headlineLarge: TextStyle(
          color: _darkTextPrimary, fontWeight: FontWeight.bold, fontSize: 32),
      headlineMedium: TextStyle(
          color: _darkTextPrimary, fontWeight: FontWeight.w600, fontSize: 24),
      bodyLarge: TextStyle(color: _darkTextPrimary, fontSize: 16),
      bodyMedium: TextStyle(color: _darkTextSecondary, fontSize: 14),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: _darkScaffold,
      hintStyle: const TextStyle(color: _darkTextSecondary),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: _darkBorder),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: _darkBorder),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: _darkPrimaryBlue, width: 1.5),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        foregroundColor: Colors.white,
        backgroundColor: _darkPrimaryBlue,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        textStyle: const TextStyle(fontWeight: FontWeight.bold),
      ),
    ),
  );
}