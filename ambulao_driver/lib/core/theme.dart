import 'package:flutter/material.dart';

class AppTheme {
  // Primary Colors - Vibrant iOS 26 Style
  static const Color primaryBlue = Color(0xFF007AFF);
  static const Color criticalRed = Color(0xFFFF3B30);
  static const Color successGreen = Color(0xFF34C759);

  // Background & Surface
  static const Color background = Color(0xFFF2F2F7);
  static const Color surfaceSolid = Colors.white;
  static const Color mapBackground = Color(
    0xFFE9EEF4,
  ); // Placeholder for map grid

  // Text Colors
  static const Color textPrimary = Color(0xFF000000);
  static const Color textSecondary = Color(0xFF8E8E93);

  // Borders & Dividers
  static const Color borderLight = Color(0xFFE5E5EA);

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: background,
      primaryColor: primaryBlue,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryBlue,
        primary: primaryBlue,
        error: criticalRed,
        surface: surfaceSolid,
      ),
      textTheme: const TextTheme(
        displayLarge: TextStyle(
          color: textPrimary,
          fontWeight: FontWeight.bold,
        ),
        displayMedium: TextStyle(
          color: textPrimary,
          fontWeight: FontWeight.bold,
        ),
        titleLarge: TextStyle(color: textPrimary, fontWeight: FontWeight.w600),
        titleMedium: TextStyle(color: textPrimary, fontWeight: FontWeight.w500),
        bodyLarge: TextStyle(color: textPrimary),
        bodyMedium: TextStyle(color: textSecondary),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryBlue,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          textStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
        ),
      ),
    );
  }
}
