// lib/features/settings/data/repositories/settings_repository_impl.dart
import 'package:coffee_tracker/core/error/failures.dart';
import 'package:coffee_tracker/core/network/network_info.dart';
import 'package:coffee_tracker/features/settings/data/datasources/settings_remote_data_source.dart';
import 'package:coffee_tracker/features/settings/domain/entities/settings.dart';
import 'package:coffee_tracker/features/settings/domain/repositories/settings_repository.dart';
import 'package:dartz/dartz.dart';

class SettingsRepositoryImpl implements SettingsRepository {
  final SettingsRemoteDataSource remoteDataSource;
  final NetworkInfo networkInfo;

  SettingsRepositoryImpl({
    required this.remoteDataSource,
    required this.networkInfo,
  });

  @override
  Future<Either<Failure, Settings>> getSettings() async {
    if (await networkInfo.isConnected) {
      try {
        final remoteSettings = await remoteDataSource.getSettings();
        return Right(remoteSettings);
      } catch (e) {
        return Left(ServerFailure(message: e.toString()));
      }
    } else {
      return Left(NetworkFailure());
    }
  }

  @override
  Future<Either<Failure, void>> updateSetting(int settingId, bool value) async {
    if (await networkInfo.isConnected) {
      try {
        await remoteDataSource.updateSetting(settingId, value);
        return const Right(null);
      } catch (e) {
        return Left(ServerFailure(message: e.toString()));
      }
    } else {
      return Left(NetworkFailure());
    }
  }
}
