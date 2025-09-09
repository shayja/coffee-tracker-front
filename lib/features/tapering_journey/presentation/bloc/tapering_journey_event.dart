// lib/features/tapering_journey/presentation/bloc/tapering_journey_event.dart

part of 'tapering_journey_bloc.dart';

abstract class TaperingJourneyEvent extends Equatable {
  const TaperingJourneyEvent();

  @override
  List<Object?> get props => [];
}

class LoadTaperingJourneys extends TaperingJourneyEvent {
  const LoadTaperingJourneys();

  @override
  List<Object?> get props => [];
}

class CreateTaperingJourney extends TaperingJourneyEvent {
  final TaperingJourneyData journey;

  const CreateTaperingJourney(this.journey);

  @override
  List<Object?> get props => [journey];
}

class UpdateTaperingJourney extends TaperingJourneyEvent {
  final TaperingJourneyData journey;

  const UpdateTaperingJourney(this.journey);

  @override
  List<Object?> get props => [journey];
}

class DeleteTaperingJourney extends TaperingJourneyEvent {
  final TaperingJourneyData journey;

  const DeleteTaperingJourney(this.journey);

  @override
  List<Object?> get props => [journey];
}
