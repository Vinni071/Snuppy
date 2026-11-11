import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:luminthor/core/storage/key_value_store.dart';
import 'package:luminthor/features/settings/domain/entities/app_settings.dart';
import 'package:luminthor/features/settings/domain/repositories/settings_repository.dart';

class LocalSettingsRepository implements SettingsRepository {
  // Storage keys are part of the persisted format; do not rename.
  static const fontSizeKey = 'editor_font_size';
  static const lightThemeKey = 'editor_light_theme';

  final KeyValueStore _store;

  const LocalSettingsRepository(this._store);

  @override
  AppSettings load() {
    final fontSize = _store.read(fontSizeKey);
    final lightTheme = _store.read(lightThemeKey);
    return AppSettings(
      fontSize: fontSize is num
          ? AppSettings.normalizeFontSize(fontSize.toDouble())
          : AppSettings.defaultFontSize,
      useLightTheme: lightTheme is bool && lightTheme,
    );
  }

  @override
  Future<void> saveFontSize(double fontSize) =>
      _store.write(fontSizeKey, fontSize);

  @override
  Future<void> saveUseLightTheme(bool useLightTheme) =>
      _store.write(lightThemeKey, useLightTheme);
}

final settingsRepositoryProvider = Provider<SettingsRepository>(
  (ref) => LocalSettingsRepository(ref.watch(keyValueStoreProvider)),
);
