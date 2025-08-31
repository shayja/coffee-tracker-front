// lib/features/settings/data/repositories/settings_repository_impl.dart
import 'package:coffee_tracker/core/error/failures.dart';
import 'package:coffee_tracker/features/settings/data/datasources/settings_local_data_source.dart';
import 'package:coffee_tracker/features/settings/data/datasources/settings_remote_data_source.dart';
import 'package:coffee_tracker/features/settings/domain/entities/settings.dart';
import 'package:coffee_tracker/features/settings/domain/repositories/settings_repository.dart';
import 'package:coffee_tracker/core/network/network_info.dart';
import 'package:dartz/dartz.dart';

class SettingsRepositoryImpl implements SettingsRepository {
  final SettingsLocalDataSource localDataSource;
  final SettingsRemoteDataSource remoteDataSource;
  final NetworkInfo networkInfo;

  SettingsRepositoryImpl({
    required this.localDataSource,
    required this.remoteDataSource,
    required this.networkInfo,
  });

  @override
  Future<Either<Failure, Settings>> getSettings() async {
    // 1. Try local cache first
    final cached = await localDataSource.getCachedSettings();
    if (cached != null) {
      return Right(cached);
    }

    if (await networkInfo.isConnected) {
      try {
        // 2. Otherwise fetch from server
        final remote = await remoteDataSource.getSettings();
        await localDataSource.cacheSettings(remote);
        return Right(remote);
      } catch (e) {
        return Left(ServerFailure(message: e.toString()));
      }
    } else {
      return Left(NetworkFailure());
    }
  }

  @override
  Future<Either<Failure, void>> updateSetting(int settingId, bool value) async {
    try {
      // 1. Load current settings
      final either = await getSettings();
      return await either.fold((failure) => Left(failure), (current) async {
        // 2. Update the correct field by id
        final updated = Settings(
          biometricEnabled: settingId == 1 ? value : current.biometricEnabled,
          darkMode: settingId == 2 ? value : current.darkMode,
          notificationsEnabled: settingId == 3
              ? value
              : current.notificationsEnabled,
        );

        if (await networkInfo.isConnected) {
          try {
            // 3. Save locally
            await localDataSource.cacheSettings(updated);

            // 4. Push to server
            await remoteDataSource.updateSetting(settingId, value);

            return const Right(null);
          } catch (e) {
            return Left(ServerFailure(message: e.toString()));
          }
        } else {
          return Left(NetworkFailure());
        }
      });
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }
}
