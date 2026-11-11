import 'package:luminthor/features/settings/domain/entities/app_settings.dart';

abstract interface class SettingsRepository {
  AppSettings load();

  Future<void> saveFontSize(double fontSize);

  Future<void> saveUseLightTheme(bool useLightTheme);
}
