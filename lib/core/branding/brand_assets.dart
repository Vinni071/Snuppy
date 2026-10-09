import 'package:flutter/material.dart';

class BrandAssets {
  BrandAssets._();

  static const name = 'Luminthor';
  static const lightLogo = 'assets/branding/luminthor-logo-claro.svg';
  static const darkLogo = 'assets/branding/luminthor-logo-escuro.svg';
  static const lightWordmark = 'assets/branding/luminthor-nome-claro.svg';
  static const darkWordmark = 'assets/branding/luminthor-nome-escuro.svg';
  static const lightSplash = 'assets/branding/splash_light.mp4';
  static const darkSplash = 'assets/branding/splash_dark.mp4';

  static Color splashBackground(bool isDark) =>
      isDark ? const Color(0xFF080808) : Colors.white;
}
