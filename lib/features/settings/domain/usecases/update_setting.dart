// lib/features/settings/domain/usecases/update_setting.dart
import 'package:coffee_tracker/core/error/failures.dart';
import 'package:coffee_tracker/core/usecases/usecase.dart';
import 'package:coffee_tracker/features/settings/domain/repositories/settings_repository.dart';
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

class UpdateSetting implements UseCase<void, UpdateSettingParams> {
  final SettingsRepository repository;

  UpdateSetting(this.repository);

  @override
  Future<Either<Failure, void>> call(UpdateSettingParams params) async {
    return await repository.updateSetting(params.key, params.value);
  }
}

class UpdateSettingParams extends Equatable {
  final String key;
  final bool value;

  const UpdateSettingParams({
    required this.key,
    required this.value,
  });

  @override
  List<Object> get props => [key, value];
}
