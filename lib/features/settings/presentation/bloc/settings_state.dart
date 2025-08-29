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

  const SettingsLoaded({required this.settings});

  @override
  List<Object> get props => [settings];
}

class SettingsError extends SettingsState {
  final String message;

  const SettingsError({required this.message});

  @override
  List<Object> get props => [message];
}

class SettingsUpdating extends SettingsState {
  final Settings settings;
  final String updatingKey;

  const SettingsUpdating({
    required this.settings,
    required this.updatingKey,
  });

  @override
  List<Object> get props => [settings, updatingKey];
}
