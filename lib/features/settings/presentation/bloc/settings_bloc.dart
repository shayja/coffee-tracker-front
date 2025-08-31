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

  SettingsBloc({required this.getSettings, required this.updateSetting})
    : super(SettingsInitial()) {
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
      (failure) {
        // fallback to initial state if fetch fails
        emit(SettingsLoaded.initial().copyWith(hasError: true));
      },
      (settings) {
        emit(SettingsLoaded(settings: settings));
      },
    );
  }

  Future<void> _onUpdateSetting(
    UpdateSettingEvent event,
    Emitter<SettingsState> emit,
  ) async {
    if (state is SettingsLoaded || state is SettingsUpdating) {
      final currentSettings = (state as dynamic).settings;

      // Apply optimistic update immediately
      final updatedSettings = _updateLocalSettings(
        currentSettings,
        event.settingId,
        event.value,
      );

      emit(
        SettingsUpdating(
          settings: updatedSettings,
          updatingSettingId: event.settingId,
        ),
      );

      final result = await updateSetting(
        UpdateSettingParams(settingId: event.settingId, value: event.value),
      );

      result.fold(
        (failure) {
          // Rollback on failure
          emit(SettingsError(message: failure.toString()));
          emit(SettingsLoaded(settings: currentSettings));
        },
        (_) {
          // Keep the updated settings after success
          emit(SettingsLoaded(settings: updatedSettings));
        },
      );
    }
  }

  Settings _updateLocalSettings(Settings settings, int settingId, bool value) {
    switch (settingId) {
      case 1: // SettingType.biometricEnabled
        return settings.copyWith(biometricEnabled: value);
      case 2: // SettingType.darkMode
        return settings.copyWith(darkMode: value);
      case 3: // SettingType.notificationsEnabled
        return settings.copyWith(notificationsEnabled: value);
      default:
        return settings;
    }
  }
}
