// file: lib/features/statistics/presentation/bloc/statistics_state.dart
import 'package:coffee_tracker/features/statistics/domain/entities/statistics_entity.dart';
import 'package:equatable/equatable.dart';

abstract class StatisticsState extends Equatable {
  const StatisticsState();

  @override
  List<Object> get props => [];
}

class StatisticsInitial extends StatisticsState {}

class StatisticsLoading extends StatisticsState {}

class StatisticsLoaded extends StatisticsState {
  final StatisticsEntity statistics;

  const StatisticsLoaded(this.statistics);

  @override
  List<Object> get props => [statistics];
}

class StatisticsError extends StatisticsState {
  final String message;

  const StatisticsError(this.message);

  @override
  List<Object> get props => [message];
}
