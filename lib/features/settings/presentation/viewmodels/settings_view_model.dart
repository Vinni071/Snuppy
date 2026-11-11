import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:luminthor/core/errors/error_reporter.dart';
import 'package:luminthor/features/settings/data/repositories/local_settings_repository.dart';
import 'package:luminthor/features/settings/domain/entities/app_settings.dart';
import 'package:luminthor/features/settings/domain/repositories/settings_repository.dart';

@immutable
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
  SettingsRepository get _repository => ref.read(settingsRepositoryProvider);

  @override
  SettingsState build() {
    final settings = ref.watch(settingsRepositoryProvider).load();
    return SettingsState(
      fontSize: settings.fontSize,
      themeMode: settings.useLightTheme ? ThemeMode.light : ThemeMode.dark,
    );
  }

  void setFontSize(double size) {
    final fontSize = AppSettings.normalizeFontSize(size);
    state = state.copyWith(fontSize: fontSize);
    _save(_repository.saveFontSize(fontSize));
  }

  void toggleTheme() {
    final newMode =
        state.themeMode == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
    state = state.copyWith(themeMode: newMode);
    _save(_repository.saveUseLightTheme(newMode == ThemeMode.light));
  }

  /// Preferences apply immediately; a failed write only loses persistence,
  /// so it is reported instead of interrupting the user.
  void _save(Future<void> write) {
    unawaited(write.catchError((Object error, StackTrace stack) {
      reportError('Não foi possível salvar as configurações', error, stack);
    }));
  }
}

final settingsProvider =
    NotifierProvider<SettingsNotifier, SettingsState>(SettingsNotifier.new);
