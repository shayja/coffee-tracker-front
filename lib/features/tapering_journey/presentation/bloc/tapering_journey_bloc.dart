// lib/features/tapering_journey/presentation/bloc/tapering_journey_bloc.dart

import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import 'package:coffee_tracker/features/tapering_journey/domain/entities/tapering_journey.dart';
import 'package:coffee_tracker/features/tapering_journey/domain/usecases/create_tapering_journey.dart';
import 'package:coffee_tracker/features/tapering_journey/domain/usecases/delete_tapering_journey.dart';
import 'package:coffee_tracker/features/tapering_journey/domain/usecases/get_tapering_journeys.dart';
import 'package:coffee_tracker/features/tapering_journey/domain/usecases/update_tapering_journey.dart';

part 'tapering_journey_event.dart';
part 'tapering_journey_state.dart';

class TaperingJourneyBloc
    extends Bloc<TaperingJourneyEvent, TaperingJourneyState> {
  final CreateTaperingJourneyUseCase createUseCase;
  final UpdateTaperingJourneyUseCase updateUseCase;
  final DeleteTaperingJourneyUseCase deleteUseCase;
  final GetTaperingJourneysUseCase getJourneysUseCase;

  TaperingJourneyBloc({
    required this.createUseCase,
    required this.updateUseCase,
    required this.deleteUseCase,
    required this.getJourneysUseCase,
  }) : super(TaperingJourneyInitial()) {
    on<LoadTaperingJourneys>(_onLoadTaperingJourneys);
    on<CreateTaperingJourney>(_onCreateTaperingJourney);
    on<UpdateTaperingJourney>(_onUpdateTaperingJourney);
    on<DeleteTaperingJourney>(_onDeleteTaperingJourney);
  }

  Future<void> _onLoadTaperingJourneys(
    LoadTaperingJourneys event,
    Emitter<TaperingJourneyState> emit,
  ) async {
    emit(TaperingJourneyLoading());
    final failureOrJourneys = await getJourneysUseCase.call();
    failureOrJourneys.fold(
      (failure) =>
          emit(TaperingJourneyError(message: 'Failed to load journeys')),
      (journeys) => emit(TaperingJourneyLoaded(journeys: journeys)),
    );
  }

  Future<void> _onCreateTaperingJourney(
    CreateTaperingJourney event,
    Emitter<TaperingJourneyState> emit,
  ) async {
    emit(TaperingJourneyLoading());
    final failureOrJourney = await createUseCase.call(
      CreateTaperingJourneyParams(event.journey),
    );
    failureOrJourney.fold(
      (failure) =>
          emit(TaperingJourneyError(message: 'Failed to create journey')),
      (_) => add(const LoadTaperingJourneys()),
    );
  }

  Future<void> _onUpdateTaperingJourney(
    UpdateTaperingJourney event,
    Emitter<TaperingJourneyState> emit,
  ) async {
    emit(TaperingJourneyLoading());
    final failureOrVoid = await updateUseCase.call(
      UpdateTaperingJourneyParams(event.journey),
    );
    failureOrVoid.fold(
      (failure) =>
          emit(TaperingJourneyError(message: 'Failed to update journey')),
      (_) => add(const LoadTaperingJourneys()),
    );
  }

  Future<void> _onDeleteTaperingJourney(
    DeleteTaperingJourney event,
    Emitter<TaperingJourneyState> emit,
  ) async {
    emit(TaperingJourneyLoading());
    final failureOrVoid = await deleteUseCase.call(
      DeleteTaperingJourneyParams(event.journey),
    );
    failureOrVoid.fold(
      (failure) =>
          emit(TaperingJourneyError(message: 'Failed to delete journey')),
      (_) => add(const LoadTaperingJourneys()),
    );
  }
}
