// lib/features/tapering_journey/domain/usecases/update_tapering_journey.dart

import 'package:coffee_tracker/core/error/failures.dart';
import 'package:coffee_tracker/features/tapering_journey/domain/entities/tapering_journey.dart';
import 'package:coffee_tracker/features/tapering_journey/domain/repositories/tapering_journey_repository.dart';
import 'package:dartz/dartz.dart';

class UpdateTaperingJourneyParams {
  final TaperingJourneyData journey;

  UpdateTaperingJourneyParams(this.journey);
}

class UpdateTaperingJourneyUseCase {
  final TaperingJourneyRepository repository;

  UpdateTaperingJourneyUseCase(this.repository);

  Future<Either<Failure, void>> call(UpdateTaperingJourneyParams params) async {
    return await repository.updateJourney(params.journey);
  }
}
