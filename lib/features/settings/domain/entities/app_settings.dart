/// User preferences for the editor and the app appearance.
class AppSettings {
  static const minFontSize = 12.0;
  static const maxFontSize = 24.0;
  static const defaultFontSize = 14.0;

  final double fontSize;
  final bool useLightTheme;

  const AppSettings({
    this.fontSize = defaultFontSize,
    this.useLightTheme = false,
  });

  /// Keeps a font size inside the range offered by the settings slider, so a
  /// corrupted or outdated stored value can never break the UI.
  static double normalizeFontSize(double size) => size.isFinite
      ? size.clamp(minFontSize, maxFontSize).toDouble()
      : defaultFontSize;
}
