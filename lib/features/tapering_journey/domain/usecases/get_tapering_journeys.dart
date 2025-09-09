// lib/features/tapering_journey/domain/usecases/get_tapering_journeys.dart

import 'package:coffee_tracker/core/error/failures.dart';
import 'package:coffee_tracker/features/tapering_journey/domain/entities/tapering_journey.dart';
import 'package:coffee_tracker/features/tapering_journey/domain/repositories/tapering_journey_repository.dart';
import 'package:dartz/dartz.dart';

class GetTaperingJourneysUseCase {
  final TaperingJourneyRepository repository;

  GetTaperingJourneysUseCase(this.repository);

  Future<Either<Failure, List<TaperingJourneyData>>> call() async {
    return await repository.getJourneys();
  }
}
