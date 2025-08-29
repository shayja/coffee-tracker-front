// lib/features/settings/domain/repositories/settings_repository.dart
import 'package:coffee_tracker/core/error/failures.dart';
import 'package:coffee_tracker/features/settings/domain/entities/settings.dart';
import 'package:dartz/dartz.dart';

abstract class SettingsRepository {
  Future<Either<Failure, Settings>> getSettings();
  Future<Either<Failure, void>> updateSetting(String key, bool value);
}
