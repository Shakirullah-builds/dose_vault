import 'package:flutter/material.dart';

/// App-wide color palette derived from the design mockups.
/// Calm, medical/health aesthetic — soft blues, greens, and neutral grays.
class AppColors {
  AppColors._();

  // Primary
  static const Color primary = Color(0xFF4FC3F7); // Calm sky blue
  static const Color primaryDark = Color(0xFF0396D8);
  static const Color accent = Color(0xFF26C6A0); // Teal green for "Taken"

  // Backgrounds
  static const Color scaffoldBg = Color(0xFFF5F7FA);
  static const Color cardBg = Colors.white;
  static const Color headerBg = Color(0xFFE8F4FD);

  // Text
  static const Color textPrimary = Color(0xFF2D3748);
  static const Color textSecondary = Color(0xFF8E99A8);
  static const Color textHint = Color(0xFFB0BEC5);

  // Status
  static const Color taken = Color(0xFF26C6A0);
  static const Color skipped = Color(0xFFE0E5EC);
  static const Color skippedText = Color(0xFF6B7B8D);
  static const Color missed = Color(0xFFFF6B6B);

  // Misc
  static const Color divider = Color(0xFFEDF0F5);
  static const Color ringTrack = Color(0xFFE8ECF1);
  static const Color iconBg = Color(0xFFE3F2FD);
}

class AppTheme {
  AppTheme._();

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: AppColors.scaffoldBg,
      fontFamily: 'Roboto',
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primary,
        primary: AppColors.primary,
        secondary: AppColors.accent,
        surface: AppColors.cardBg,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.white,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          color: AppColors.textPrimary,
          fontSize: 20,
          fontWeight: FontWeight.w700,
        ),
      ),
      cardTheme: CardThemeData(
        color: AppColors.cardBg,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: AppColors.divider, width: 1),
        ),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 4,
        shape: CircleBorder(),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: false,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.divider),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.divider),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
        ),
        hintStyle: const TextStyle(
          color: AppColors.textHint,
          fontSize: 16,
        ),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: Colors.white,
        selectedItemColor: AppColors.textPrimary,
        unselectedItemColor: AppColors.textSecondary,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
        selectedLabelStyle: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
        unselectedLabelStyle: TextStyle(fontSize: 12),
      ),
    );
  }
}
