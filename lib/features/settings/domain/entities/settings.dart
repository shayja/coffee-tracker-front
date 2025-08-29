// lib/features/settings/domain/entities/settings.dart
import 'package:equatable/equatable.dart';

class Settings extends Equatable {
  final bool biometricEnabled;
  final bool darkMode;
  final bool notificationsEnabled;

  const Settings({
    required this.biometricEnabled,
    required this.darkMode,
    required this.notificationsEnabled,
  });

  Settings copyWith({
    bool? biometricEnabled,
    bool? darkMode,
    bool? notificationsEnabled,
  }) {
    return Settings(
      biometricEnabled: biometricEnabled ?? this.biometricEnabled,
      darkMode: darkMode ?? this.darkMode,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
    );
  }

  @override
  List<Object> get props => [biometricEnabled, darkMode, notificationsEnabled];
}
