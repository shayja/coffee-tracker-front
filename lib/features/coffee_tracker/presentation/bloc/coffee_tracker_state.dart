import 'package:coffee_tracker/features/coffee_tracker/domain/entities/coffee_tracker_entry.dart';
import 'package:equatable/equatable.dart';

abstract class CoffeeTrackerState extends Equatable {
  const CoffeeTrackerState();

  @override
  List<Object?> get props => [];
}

class CoffeeTrackerInitial extends CoffeeTrackerState {}

class CoffeeTrackerLoading extends CoffeeTrackerState {}

class CoffeeTrackerLoaded extends CoffeeTrackerState {
  final List<CoffeeTrackerEntry> entries;

  const CoffeeTrackerLoaded(this.entries);

  int get cupCount => entries.length;

  @override
  List<Object?> get props => [entries];
}

class CoffeeTrackerError extends CoffeeTrackerState {
  final String message;

  const CoffeeTrackerError(this.message);

  @override
  List<Object?> get props => [message];
}
