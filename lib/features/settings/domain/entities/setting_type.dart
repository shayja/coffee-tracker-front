// lib/features/settings/domain/entities/setting_type.dart

enum SettingType {
  biometricEnabled(1),
  darkMode(2),
  notificationsEnabled(3);

  const SettingType(this.id);

  final int id;

  /// Get SettingType from integer ID
  static SettingType fromId(int id) {
    switch (id) {
      case 1:
        return SettingType.biometricEnabled;
      case 2:
        return SettingType.darkMode;
      case 3:
        return SettingType.notificationsEnabled;
      default:
        throw ArgumentError('Unknown setting ID: $id');
    }
  }
}
