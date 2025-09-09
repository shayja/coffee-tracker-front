// lib/features/tapering_journey/domain/usecases/create_tapering_journey.dart

import 'package:coffee_tracker/core/error/failures.dart';
import 'package:coffee_tracker/features/tapering_journey/domain/entities/tapering_journey.dart';
import 'package:coffee_tracker/features/tapering_journey/domain/repositories/tapering_journey_repository.dart';
import 'package:dartz/dartz.dart';

class CreateTaperingJourneyParams {
  final TaperingJourneyData journey;

  CreateTaperingJourneyParams(this.journey);
}

class CreateTaperingJourneyUseCase {
  final TaperingJourneyRepository repository;

  CreateTaperingJourneyUseCase(this.repository);

  Future<Either<Failure, TaperingJourneyData>> call(
    CreateTaperingJourneyParams params,
  ) async {
    return await repository.createJourney(params.journey);
  }
}
