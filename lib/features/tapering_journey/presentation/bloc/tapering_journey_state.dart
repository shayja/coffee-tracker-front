// lib/features/tapering_journey/presentation/bloc/tapering_journey_state.dart

part of 'tapering_journey_bloc.dart';

abstract class TaperingJourneyState extends Equatable {
  const TaperingJourneyState();

  @override
  List<Object?> get props => [];
}

class TaperingJourneyInitial extends TaperingJourneyState {}

class TaperingJourneyLoading extends TaperingJourneyState {}

class TaperingJourneyLoaded extends TaperingJourneyState {
  final List<TaperingJourneyData> journeys;

  const TaperingJourneyLoaded({required this.journeys});

  @override
  List<Object?> get props => [journeys];
}

class TaperingJourneyError extends TaperingJourneyState {
  final String message;

  const TaperingJourneyError({required this.message});

  @override
  List<Object?> get props => [message];
}
