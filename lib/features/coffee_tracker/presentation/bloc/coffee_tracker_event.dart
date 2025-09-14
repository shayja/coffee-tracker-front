import 'package:coffee_tracker/features/coffee_tracker/domain/entities/coffee_tracker_entry.dart';
import 'package:equatable/equatable.dart';

abstract class CoffeeTrackerEvent extends Equatable {
  const CoffeeTrackerEvent();

  @override
  List<Object?> get props => [];
}

// Event to add a cup
class AddCoffeeEntry extends CoffeeTrackerEvent {
  final DateTime timestamp;
  final String notes;
  final int? coffeeTypeKey;

  const AddCoffeeEntry({
    required this.timestamp,
    required this.notes,
    this.coffeeTypeKey,
  });

  @override
  List<Object?> get props => [timestamp, notes];
}

class EditCoffeeEntry extends CoffeeTrackerEvent {
  final CoffeeTrackerEntry oldEntry;
  final CoffeeTrackerEntry newEntry;

  const EditCoffeeEntry({required this.oldEntry, required this.newEntry});

  @override
  List<Object?> get props => [oldEntry, newEntry];
}

// Event to load today's log
class LoadDailyCoffeeLog extends CoffeeTrackerEvent {
  final DateTime date;

  const LoadDailyCoffeeLog(this.date);
}

class DeleteCoffeeEntry extends CoffeeTrackerEvent {
  final CoffeeTrackerEntry entry;

  const DeleteCoffeeEntry({required this.entry});

  @override
  List<Object?> get props => [entry];
}

class LoadCoffeeTypes extends Equatable {
  @override
  List<Object?> get props => [];
}
