// lib/features/coffee_tracker/data/repositories/coffee_repository_impl.dart
import 'package:coffee_tracker/core/network/network_info.dart';
import 'package:coffee_tracker/features/coffee_tracker/data/datasources/coffee_tracker_remote_data_source.dart';
import 'package:dartz/dartz.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/error/failures.dart';
import '../../domain/entities/coffee_tracker_entry.dart';
import '../../domain/repositories/coffee_tracker_repository.dart';

class CoffeeRepositoryImpl implements CoffeeTrackerRepository {
  final CoffeeTrackerRemoteDataSource remoteDataSource;
  final SharedPreferences sharedPreferences;
  final NetworkInfo networkInfo;

  CoffeeRepositoryImpl({
    required this.remoteDataSource,
    required this.sharedPreferences,
    required this.networkInfo,
  });

  @override
  Future<Either<Failure, CoffeeTrackerEntry>> addEntry(
    CoffeeTrackerEntry entry,
  ) async {
    if (!await networkInfo.isConnected) {
      return Left(NetworkFailure());
    }

    try {
      final result = await remoteDataSource.addEntry(entry);
      return Right(result);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> editEntry(
    CoffeeTrackerEntry oldEntry,
    CoffeeTrackerEntry newEntry,
  ) async {
    try {
      if (await networkInfo.isConnected) {
        await remoteDataSource.editEntry(oldEntry, newEntry);
        return Right(null);
      } else {
        return Left(NetworkFailure());
      }
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deleteEntry(CoffeeTrackerEntry entry) async {
    try {
      if (await networkInfo.isConnected) {
        await remoteDataSource.deleteEntry(entry.id);
        return Right(null);
      } else {
        return Left(NetworkFailure());
      }
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<CoffeeTrackerEntry>>> getLogByDate(
    DateTime date,
  ) async {
    try {
      if (await networkInfo.isConnected) {
        try {
          final entries = await remoteDataSource.getEntriesByDate(date);
          return Right(entries);
        } on Exception catch (e) {
          if (e.toString().contains('Authentication required')) {
            return Left(AuthFailure());
          }
          return Left(ServerFailure(message: e.toString()));
        }
      } else {
        return Left(NetworkFailure());
      }
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }
}
