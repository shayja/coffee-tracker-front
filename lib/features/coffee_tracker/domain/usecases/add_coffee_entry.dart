// file: lib/features/coffee_tracker/domain/usecases/add_coffee_entry.dart
// This file defines the AddCoffeeEntryUseCase for adding a coffee tracker entry.
import 'package:coffee_tracker/core/usecases/usecase.dart';
import 'package:coffee_tracker/features/coffee_tracker/domain/entities/coffee_tracker_entry.dart';
import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../repositories/coffee_tracker_repository.dart';

class AddCoffeeEntryUseCase implements UseCase<void, AddCoffeeEntryParams> {
  final CoffeeTrackerRepository repository;

  AddCoffeeEntryUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(AddCoffeeEntryParams params) async {
    return await repository.addEntry(params.entry);
  }
}

class AddCoffeeEntryParams {
  final CoffeeTrackerEntry entry;

  AddCoffeeEntryParams(this.entry);
}
