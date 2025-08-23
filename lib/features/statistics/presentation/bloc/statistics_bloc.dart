// file: lib/features/statistics/presentation/bloc/statistics_bloc.dart
import 'package:coffee_tracker/core/error/failures.dart';
import 'package:coffee_tracker/core/usecases/usecase.dart';
import 'package:coffee_tracker/features/statistics/domain/usecases/get_statistics.dart';
import 'package:coffee_tracker/features/statistics/presentation/bloc/statistics_event.dart';
import 'package:coffee_tracker/features/statistics/presentation/bloc/statistics_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class StatisticsBloc extends Bloc<StatisticsEvent, StatisticsState> {
  final GetStatistics getStatistics;

  StatisticsBloc({required this.getStatistics}) : super(StatisticsInitial()) {
    on<LoadStatistics>(_onLoadStatistics);
  }

  Future<void> _onLoadStatistics(
    LoadStatistics event,
    Emitter<StatisticsState> emit,
  ) async {
    emit(StatisticsLoading());

    final result = await getStatistics(NoParams());

    result.fold(
      (failure) => emit(StatisticsError(_mapFailureToMessage(failure))),
      (statistics) => emit(StatisticsLoaded(statistics)),
    );
  }

  String _mapFailureToMessage(Failure failure) {
    switch (failure.runtimeType) {
      case ServerFailure _:
        return 'Server error. Please try again.';
      case NetworkFailure _:
        return 'Network error. Please check your connection.';
      default:
        return 'Unexpected error occurred.';
    }
  }
}
