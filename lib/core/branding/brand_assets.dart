import 'package:flutter/material.dart';

class BrandAssets {
  BrandAssets._();

  static const name = 'Luminthor';
  static const lightLogo = 'assets/branding/luminthor-logo-claro.svg';
  static const darkLogo = 'assets/branding/luminthor-logo-escuro.svg';
  static const lightWordmark = 'assets/branding/luminthor-nome-claro.svg';
  static const darkWordmark = 'assets/branding/luminthor-nome-escuro.svg';
  static const lightSplash = 'assets/branding/splash_light-16x9.webp';
  static const darkSplash = 'assets/branding/splash_dark-16x9.webp';
  static const lightSplashPortrait = 'assets/branding/splash_light-9x16.webp';
  static const darkSplashPortrait = 'assets/branding/splash_dark-9x16.webp';

  /// 9:16 animation for portrait screens, 16:9 for everything else.
  static String splash({required bool isDark, required bool portrait}) =>
      portrait
          ? (isDark ? darkSplashPortrait : lightSplashPortrait)
          : (isDark ? darkSplash : lightSplash);

  /// Matches the edge colour of the splash animations so letterboxing is
  /// invisible.
  static Color splashBackground(bool isDark) =>
      isDark ? const Color(0xFF0A0A0A) : const Color(0xFFF8F9FC);
}
