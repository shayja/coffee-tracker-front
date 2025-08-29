// lib/features/settings/presentation/bloc/settings_bloc.dart
import 'package:bloc/bloc.dart';
import 'package:coffee_tracker/core/usecases/usecase.dart';
import 'package:coffee_tracker/features/settings/domain/entities/settings.dart';
import 'package:coffee_tracker/features/settings/domain/usecases/get_settings.dart';
import 'package:coffee_tracker/features/settings/domain/usecases/update_setting.dart';
import 'package:coffee_tracker/features/settings/presentation/bloc/settings_event.dart';
import 'package:coffee_tracker/features/settings/presentation/bloc/settings_state.dart';

class SettingsBloc extends Bloc<SettingsEvent, SettingsState> {
  final GetSettings getSettings;
  final UpdateSetting updateSetting;

  SettingsBloc({
    required this.getSettings,
    required this.updateSetting,
  }) : super(SettingsInitial()) {
    on<LoadSettings>(_onLoadSettings);
    on<UpdateSettingEvent>(_onUpdateSetting);
  }

  Future<void> _onLoadSettings(
    LoadSettings event,
    Emitter<SettingsState> emit,
  ) async {
    emit(SettingsLoading());

    final result = await getSettings(NoParams());
    result.fold(
      (failure) => emit(SettingsError(message: failure.toString())),
      (settings) => emit(SettingsLoaded(settings: settings)),
    );
  }

  Future<void> _onUpdateSetting(
    UpdateSettingEvent event,
    Emitter<SettingsState> emit,
  ) async {
    if (state is SettingsLoaded) {
      final currentSettings = (state as SettingsLoaded).settings;
      emit(SettingsUpdating(
        settings: currentSettings,
        updatingKey: event.key,
      ));

      final result = await updateSetting(
        UpdateSettingParams(key: event.key, value: event.value),
      );

      result.fold(
        (failure) => emit(SettingsError(message: failure.toString())),
        (_) {
          // Update the local settings state optimistically
          final updatedSettings = _updateLocalSettings(currentSettings, event.key, event.value);
          emit(SettingsLoaded(settings: updatedSettings));
        },
      );
    }
  }

  Settings _updateLocalSettings(Settings settings, String key, bool value) {
    switch (key) {
      case 'BiometricEnabled':
        return settings.copyWith(biometricEnabled: value);
      case 'DarkMode':
        return settings.copyWith(darkMode: value);
      case 'NotificationsEnabled':
        return settings.copyWith(notificationsEnabled: value);
      default:
        return settings;
    }
  }
}
