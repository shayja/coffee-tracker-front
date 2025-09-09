// lib/features/tapering_journey/domain/repositories/tapering_journey_repository.dart

import 'package:coffee_tracker/core/error/failures.dart';
import 'package:coffee_tracker/features/tapering_journey/domain/entities/tapering_journey.dart';
import 'package:dartz/dartz.dart';

abstract class TaperingJourneyRepository {
  Future<Either<Failure, TaperingJourneyData>> createJourney(
    TaperingJourneyData journey,
  );
  Future<Either<Failure, void>> updateJourney(TaperingJourneyData journey);
  Future<Either<Failure, void>> deleteJourney(TaperingJourneyData journey);
  Future<Either<Failure, List<TaperingJourneyData>>> getJourneys();
  Future<Either<Failure, TaperingJourneyData>> getJourneyById(String id);
}
