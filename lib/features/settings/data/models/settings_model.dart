// lib/features/settings/data/models/settings_model.dart
import 'package:coffee_tracker/features/settings/domain/entities/settings.dart';

class SettingsModel extends Settings {
  const SettingsModel({
    required super.biometricEnabled,
    required super.darkMode,
    required super.notificationsEnabled,
  });

  factory SettingsModel.fromJson(Map<String, dynamic> json) {
    final settings = json['settings'] as Map<String, dynamic>;
    return SettingsModel(
      biometricEnabled: settings['BiometricEnabled'] as bool? ?? false,
      darkMode: settings['DarkMode'] as bool? ?? false,
      notificationsEnabled: settings['NotificationsEnabled'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'settings': {
        'BiometricEnabled': biometricEnabled,
        'DarkMode': darkMode,
        'NotificationsEnabled': notificationsEnabled,
      }
    };
  }
}
