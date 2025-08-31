// lib/features/settings/presentation/bloc/settings_event.dart
import 'package:equatable/equatable.dart';

abstract class SettingsEvent extends Equatable {
  const SettingsEvent();

  @override
  List<Object> get props => [];
}

class LoadSettings extends SettingsEvent {}

class UpdateSettingEvent extends SettingsEvent {
  final int settingId;
  final bool value;

  const UpdateSettingEvent({
    required this.settingId,
    required this.value,
  });

  @override
  List<Object> get props => [settingId, value];
}
