// coffee_tracker/lib/features/coffee_tracker/domain/usecases/edit_coffee_entry.dart
import 'package:coffee_tracker/core/error/failures.dart';
import 'package:coffee_tracker/core/usecases/usecase.dart';
import 'package:coffee_tracker/features/coffee_tracker/domain/entities/coffee_tracker_entry.dart';
import 'package:coffee_tracker/features/coffee_tracker/domain/repositories/coffee_tracker_repository.dart';
import 'package:dartz/dartz.dart';

class EditCoffeeEntryUseCase implements UseCase<void, EditCoffeeEntryParams> {
  final CoffeeTrackerRepository repository;

  EditCoffeeEntryUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(EditCoffeeEntryParams params) async {
    return await repository.editEntry(params.oldEntry, params.newEntry);
  }
}

class EditCoffeeEntryParams {
  final CoffeeTrackerEntry oldEntry;
  final CoffeeTrackerEntry newEntry;

  EditCoffeeEntryParams({required this.oldEntry, required this.newEntry});
}
