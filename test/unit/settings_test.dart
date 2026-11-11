import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:luminthor/core/storage/key_value_store.dart';
import 'package:luminthor/features/settings/data/repositories/local_settings_repository.dart';
import 'package:luminthor/features/settings/domain/entities/app_settings.dart';
import 'package:luminthor/features/settings/presentation/viewmodels/settings_view_model.dart';

import '../helpers/in_memory_key_value_store.dart';

void main() {
  ProviderContainer containerWith(InMemoryKeyValueStore store) {
    final container = ProviderContainer(
      overrides: [keyValueStoreProvider.overrideWithValue(store)],
    );
    addTearDown(container.dispose);
    return container;
  }

  group('LocalSettingsRepository', () {
    test('uses defaults when nothing was saved', () {
      final settings = LocalSettingsRepository(InMemoryKeyValueStore()).load();
      expect(settings.fontSize, AppSettings.defaultFontSize);
      expect(settings.useLightTheme, isFalse);
    });

    test('clamps out-of-range font sizes so the slider cannot break', () {
      final tooBig = LocalSettingsRepository(InMemoryKeyValueStore(
          {LocalSettingsRepository.fontSizeKey: 99.0})).load();
      final tooSmall = LocalSettingsRepository(
              InMemoryKeyValueStore({LocalSettingsRepository.fontSizeKey: 2}))
          .load();
      expect(tooBig.fontSize, AppSettings.maxFontSize);
      expect(tooSmall.fontSize, AppSettings.minFontSize);
    });

    test('ignores values of the wrong type', () {
      final settings = LocalSettingsRepository(InMemoryKeyValueStore({
        LocalSettingsRepository.fontSizeKey: 'grande',
        LocalSettingsRepository.lightThemeKey: 'sim',
      })).load();
      expect(settings.fontSize, AppSettings.defaultFontSize);
      expect(settings.useLightTheme, isFalse);
    });

    test('normalizes non-finite sizes to the default', () {
      expect(AppSettings.normalizeFontSize(double.nan),
          AppSettings.defaultFontSize);
    });
  });

  group('SettingsNotifier', () {
    test('restores and persists theme and font size', () async {
      final store = InMemoryKeyValueStore({
        LocalSettingsRepository.fontSizeKey: 18.0,
        LocalSettingsRepository.lightThemeKey: true,
      });
      final container = containerWith(store);

      expect(container.read(settingsProvider).fontSize, 18);
      expect(container.read(settingsProvider).themeMode, ThemeMode.light);

      final notifier = container.read(settingsProvider.notifier);
      notifier.toggleTheme();
      notifier.setFontSize(30);
      await pumpEventQueue();

      expect(container.read(settingsProvider).themeMode, ThemeMode.dark);
      expect(
          container.read(settingsProvider).fontSize, AppSettings.maxFontSize);
      expect(store.values[LocalSettingsRepository.lightThemeKey], isFalse);
      expect(store.values[LocalSettingsRepository.fontSizeKey],
          AppSettings.maxFontSize);
    });

    test('a failed write keeps the preference applied without throwing',
        () async {
      final store = InMemoryKeyValueStore()..failWrites = true;
      final container = containerWith(store);

      container.read(settingsProvider.notifier).toggleTheme();
      await pumpEventQueue();

      expect(container.read(settingsProvider).themeMode, ThemeMode.light);
      expect(store.values, isEmpty);
    });
  });
}
