// lib/features/tapering_journey/domain/usecases/delete_tapering_journey.dart

import 'package:coffee_tracker/core/error/failures.dart';
import 'package:coffee_tracker/features/tapering_journey/domain/entities/tapering_journey.dart';
import 'package:coffee_tracker/features/tapering_journey/domain/repositories/tapering_journey_repository.dart';
import 'package:dartz/dartz.dart';

class DeleteTaperingJourneyParams {
  final TaperingJourneyData journey;

  DeleteTaperingJourneyParams(this.journey);
}

class DeleteTaperingJourneyUseCase {
  final TaperingJourneyRepository repository;

  DeleteTaperingJourneyUseCase(this.repository);

  Future<Either<Failure, void>> call(DeleteTaperingJourneyParams params) async {
    return await repository.deleteJourney(params.journey);
  }
}
