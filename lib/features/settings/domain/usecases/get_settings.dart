// lib/features/settings/domain/usecases/get_settings.dart
import 'package:coffee_tracker/core/error/failures.dart';
import 'package:coffee_tracker/core/usecases/usecase.dart';
import 'package:coffee_tracker/features/settings/domain/entities/settings.dart';
import 'package:coffee_tracker/features/settings/domain/repositories/settings_repository.dart';
import 'package:dartz/dartz.dart';

class GetSettings implements UseCase<Settings, NoParams> {
  final SettingsRepository repository;

  GetSettings(this.repository);

  @override
  Future<Either<Failure, Settings>> call(NoParams params) async {
    return await repository.getSettings();
  }
}
