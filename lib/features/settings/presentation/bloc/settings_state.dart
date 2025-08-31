// lib/features/settings/presentation/bloc/settings_state.dart
import 'package:coffee_tracker/features/settings/domain/entities/settings.dart';
import 'package:equatable/equatable.dart';

abstract class SettingsState extends Equatable {
  const SettingsState();

  @override
  List<Object> get props => [];
}

class SettingsInitial extends SettingsState {}

class SettingsLoading extends SettingsState {}

class SettingsLoaded extends SettingsState {
  final Settings settings;
  final bool hasError;

  const SettingsLoaded({required this.settings, this.hasError = false});

  @override
  List<Object> get props => [settings, hasError];

  /// Factory to provide sane defaults if nothing is cached yet
  factory SettingsLoaded.initial() {
    return SettingsLoaded(
      settings: Settings(
        biometricEnabled: false,
        darkMode: false,
        notificationsEnabled: true,
      ),
    );
  }

  SettingsLoaded copyWith({Settings? settings, bool? hasError}) {
    return SettingsLoaded(
      settings: settings ?? this.settings,
      hasError: hasError ?? this.hasError,
    );
  }
}

class SettingsError extends SettingsState {
  final String message;

  const SettingsError({required this.message});

  @override
  List<Object> get props => [message];
}

class SettingsUpdating extends SettingsState {
  final Settings settings;
  final int updatingSettingId;

  const SettingsUpdating({
    required this.settings,
    required this.updatingSettingId,
  });

  @override
  List<Object> get props => [settings, updatingSettingId];
}
