// file: lib/features/coffee_tracker/domain/usecases/add_coffee_entry.dart
import 'package:coffee_tracker/core/error/failures.dart';
import 'package:coffee_tracker/features/coffee_tracker/domain/entities/coffee_tracker_entry.dart';
import 'package:coffee_tracker/features/coffee_tracker/domain/repositories/coffee_tracker_repository.dart';
import 'package:dartz/dartz.dart';

class AddCoffeeEntryParams {
  final CoffeeTrackerEntry entry;

  AddCoffeeEntryParams(this.entry);
}

class AddCoffeeEntryUseCase {
  final CoffeeTrackerRepository repository;

  AddCoffeeEntryUseCase(this.repository);

  Future<Either<Failure, CoffeeTrackerEntry>> call(
    AddCoffeeEntryParams params,
  ) async {
    return await repository.addEntry(params.entry);
  }
}
