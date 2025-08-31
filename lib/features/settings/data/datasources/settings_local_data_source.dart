// lib/features/settings/data/datasources/settings_local_data_source.dart

import 'package:coffee_tracker/features/settings/domain/entities/settings.dart';
import 'package:shared_preferences/shared_preferences.dart';

abstract class SettingsLocalDataSource {
  Future<void> cacheSettings(Settings settings);
  Future<Settings?> getCachedSettings();
}

class SettingsLocalDataSourceImpl implements SettingsLocalDataSource {
  final SharedPreferences prefs;

  SettingsLocalDataSourceImpl({required this.prefs});

  @override
  Future<void> cacheSettings(Settings settings) async {
    await prefs.setBool('darkMode', settings.darkMode);
    await prefs.setBool('biometricEnabled', settings.biometricEnabled);
    await prefs.setBool('notificationsEnabled', settings.notificationsEnabled);
  }

  @override
  Future<Settings?> getCachedSettings() async {
    final darkMode = prefs.getBool('darkMode');
    final biometric = prefs.getBool('biometricEnabled');
    final notifications = prefs.getBool('notificationsEnabled');

    if (darkMode == null || biometric == null || notifications == null) {
      return null;
    }

    return Settings(
      biometricEnabled: biometric,
      darkMode: darkMode,
      notificationsEnabled: notifications,
    );
  }
}
