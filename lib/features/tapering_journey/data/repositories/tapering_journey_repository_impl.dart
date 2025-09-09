// lib/features/tapering_journey/data/repositories/tapering_journey_repository_impl.dart

import 'package:coffee_tracker/core/error/failures.dart';
import 'package:coffee_tracker/core/network/network_info.dart';
import 'package:coffee_tracker/features/tapering_journey/data/datasources/tapering_journey_remote_data_source.dart';
import 'package:coffee_tracker/features/tapering_journey/domain/entities/tapering_journey.dart';
import 'package:coffee_tracker/features/tapering_journey/domain/repositories/tapering_journey_repository.dart';
import 'package:dartz/dartz.dart';

class TaperingJourneyRepositoryImpl implements TaperingJourneyRepository {
  final TaperingJourneyRemoteDataSource remoteDataSource;
  final NetworkInfo networkInfo;

  TaperingJourneyRepositoryImpl({
    required this.remoteDataSource,
    required this.networkInfo,
  });

  @override
  Future<Either<Failure, TaperingJourneyData>> createJourney(
    TaperingJourneyData journey,
  ) async {
    if (!await networkInfo.isConnected) {
      return Left(NetworkFailure());
    }
    try {
      final result = await remoteDataSource.createJourney(journey);
      return Right(result);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> updateJourney(
    TaperingJourneyData journey,
  ) async {
    if (!await networkInfo.isConnected) {
      return Left(NetworkFailure());
    }
    try {
      await remoteDataSource.updateJourney(journey);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deleteJourney(
    TaperingJourneyData journey,
  ) async {
    if (!await networkInfo.isConnected) {
      return Left(NetworkFailure());
    }
    try {
      if (journey.id == null) {
        return Left(
          ServerFailure(message: 'Journey ID is required for deletion'),
        );
      }
      await remoteDataSource.deleteJourney(journey.id!);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<TaperingJourneyData>>> getJourneys() async {
    if (!await networkInfo.isConnected) {
      return Left(NetworkFailure());
    }
    try {
      final journeys = await remoteDataSource.getJourneysByUser();
      return Right(journeys);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, TaperingJourneyData>> getJourneyById(String id) async {
    if (!await networkInfo.isConnected) {
      return Left(NetworkFailure());
    }
    try {
      final journey = await remoteDataSource.getJourneyById(id);
      return Right(journey);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }
}
