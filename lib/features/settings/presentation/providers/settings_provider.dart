import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';

class SettingsState {
  final double fontSize;
  final ThemeMode themeMode;

  const SettingsState({
    required this.fontSize,
    required this.themeMode,
  });

  SettingsState copyWith({
    double? fontSize,
    ThemeMode? themeMode,
  }) {
    return SettingsState(
      fontSize: fontSize ?? this.fontSize,
      themeMode: themeMode ?? this.themeMode,
    );
  }
}

class SettingsNotifier extends Notifier<SettingsState> {
  @override
  SettingsState build() {
    double initialFontSize = 14.0;
    ThemeMode initialThemeMode = ThemeMode.dark;

    try {
      final box = Hive.box('ide_box');
      final size = box.get('editor_font_size');
      final isLight = box.get('editor_light_theme');

      if (size != null && size is double) {
        initialFontSize = size;
      }
      if (isLight != null && isLight is bool) {
        initialThemeMode = isLight ? ThemeMode.light : ThemeMode.dark;
      }
    } catch (_) {}

    return SettingsState(fontSize: initialFontSize, themeMode: initialThemeMode);
  }

  void setFontSize(double size) {
    state = state.copyWith(fontSize: size);
    try {
      final box = Hive.box('ide_box');
      box.put('editor_font_size', size);
    } catch (_) {}
  }

  void toggleTheme() {
    final newMode = state.themeMode == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
    state = state.copyWith(themeMode: newMode);
    try {
      final box = Hive.box('ide_box');
      box.put('editor_light_theme', newMode == ThemeMode.light);
    } catch (_) {}
  }
}

final settingsProvider = NotifierProvider<SettingsNotifier, SettingsState>(SettingsNotifier.new);
