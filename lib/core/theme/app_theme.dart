import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

class AppTheme {
  AppTheme._();

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      primaryColor: AppColors.primary,
      scaffoldBackgroundColor: AppColors.background,

      colorScheme: const ColorScheme.dark(
        primary: AppColors.primary,
        secondary: AppColors.secondary,
        tertiary: AppColors.tertiary,
        background: AppColors.background,
        surface: AppColors.surface,
        error: AppColors.error,
        onPrimary: Colors.white,
        onSecondary: AppColors.background,
        onBackground: Colors.white,
        onSurface: Color(0xFFE2E8F0),
      ),

      // ── Card Theme ───────────────────────────────────────────
      cardTheme: CardTheme(
        color: AppColors.surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: AppColors.border, width: 1),
        ),
      ),

      // ── App Bar Theme ────────────────────────────────────────
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.surfaceDark,
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: Colors.white),
        titleTextStyle: TextStyle(
          color: Colors.white,
          fontSize: 18,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5,
        ),
      ),

      // ── Tab Bar Theme ────────────────────────────────────────
      tabBarTheme: const TabBarTheme(
        labelColor: AppColors.secondary,
        unselectedLabelColor: Color(0xFF94A3B8),
        indicatorColor: AppColors.secondary,
        indicatorSize: TabBarIndicatorSize.tab,
      ),

      // ── Button Themes ────────────────────────────────────────
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.secondary,
          side: const BorderSide(color: AppColors.border, width: 1.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
      ),

      // ── Text Theme ───────────────────────────────────────────
      textTheme: const TextTheme(
        headlineMedium: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: Colors.white,
          letterSpacing: -0.5,
        ),
        titleMedium: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: Color(0xFFF1F5F9),
        ),
        bodyLarge: TextStyle(
          fontSize: 15,
          color: Color(0xFFE2E8F0),
          height: 1.5,
        ),
        bodyMedium: TextStyle(
          fontSize: 14,
          color: Color(0xFF94A3B8),
          height: 1.4,
        ),
        labelLarge: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),

      // ── Dialog Theme ─────────────────────────────────────────
      dialogTheme: DialogTheme(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: AppColors.border, width: 1),
        ),
      ),

      // ── Divider Theme ────────────────────────────────────────
      dividerTheme: const DividerThemeData(
        color: AppColors.border,
        thickness: 1,
        space: 1,
      ),
    );
  }

  // Code editor text style helper
  static TextStyle get editorTextStyle {
    return const TextStyle(
      fontFamily: 'monospace',
      fontFamilyFallback: ['Courier', 'RobotoMono'],
      fontSize: 14,
      height: 1.5,
      fontWeight: FontWeight.w500,
    );
  }

  // Console text style helper
  static TextStyle get consoleTextStyle {
    return const TextStyle(
      fontFamily: 'monospace',
      fontFamilyFallback: ['Courier', 'RobotoMono'],
      fontSize: 13,
      height: 1.4,
      fontWeight: FontWeight.bold,
    );
  }
}
