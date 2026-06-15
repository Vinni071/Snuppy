import 'package:flutter/material.dart';

/// Premium color palette for the Snuppy application.
/// Inspired by professional IDEs (VS Code, JetBrains) and modern dark aesthetics.
class AppColors {
  AppColors._();

  // ── Theme Base ──────────────────────────────────────────────
  static const Color background = Color(0xFF0F111A); // Deep space black/blue
  static const Color surface = Color(0xFF151824); // Card & editor background
  static const Color surfaceDark =
      Color(0xFF0A0C14); // Gutter and darker backgrounds
  static const Color surfaceLight =
      Color(0xFF1E2235); // Hover / active item highlight

  static const Color primary = Color(0xFF8A5CF5); // Glowing neon violet
  static const Color primaryLight = Color(0xFFB392FF); // Soft violet
  static const Color secondary = Color(0xFF00E5FF); // Electric cyan
  static const Color tertiary = Color(0xFFFF2E93); // Neon pink

  // ── Status Colors ───────────────────────────────────────────
  static const Color success = Color(0xFF00E676); // Vivid emerald green
  static const Color error = Color(0xFFFF5252); // Bright coral red
  static const Color warning = Color(0xFFFFD740); // Electric amber
  static const Color info = Color(0xFF2979FF); // Electric blue

  // ── Syntax Highlighting Palette ──────────────────────────────
  static const Color syntaxKeyword =
      Color(0xFFFF79C6); // Pink (var, const, fn, return, if, while)
  static const Color syntaxOperator =
      Color(0xFF50FA7B); // Green (+, -, *, /, =, ==, !=)
  static const Color syntaxDelimiter =
      Color(0xFFF8F8F2); // Off-white ((, ), {, }, ;, ,)
  static const Color syntaxLiteralInt = Color(0xFFBD93F9); // Purple (numbers)
  static const Color syntaxLiteralFloat = Color(0xFFBD93F9);
  static const Color syntaxLiteralString = Color(0xFFF1FA8C); // Light yellow
  static const Color syntaxLiteralBool =
      Color(0xFFFFB86C); // Orange (true, false)
  static const Color syntaxLiteralNull = Color(0xFF8BE9FD); // Light cyan
  static const Color syntaxIdentifier = Color(0xFF8BE9FD); // Cyan (variables)
  static const Color syntaxComment =
      Color(0xFF6272A4); // Muted gray-blue (comments)
  static const Color syntaxUnknown = Color(0xFFFF5555); // Red (errors)

  // ── Gutter & UI Elements ────────────────────────────────────
  static const Color lineNumbers = Color(0xFF4B526D);
  static const Color cursor = Color(0xFFFFFFFF);
  static const Color selection = Color(0x3D8A5CF5);
  static const Color border = Color(0xFF25293E);

  // ── Gradients ───────────────────────────────────────────────
  static const Gradient primaryGradient = LinearGradient(
    colors: [primary, secondary],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const Gradient accentGradient = LinearGradient(
    colors: [primary, tertiary],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
