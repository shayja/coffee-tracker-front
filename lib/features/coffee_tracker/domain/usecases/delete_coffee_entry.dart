import 'package:coffee_tracker/core/error/failures.dart';
import 'package:coffee_tracker/core/usecases/usecase.dart';
import 'package:coffee_tracker/features/coffee_tracker/domain/entities/coffee_tracker_entry.dart';
import 'package:coffee_tracker/features/coffee_tracker/domain/repositories/coffee_tracker_repository.dart';
import 'package:dartz/dartz.dart';

class DeleteCoffeeEntryUseCase
    implements UseCase<void, DeleteCoffeeEntryParams> {
  final CoffeerRepository repository;

  DeleteCoffeeEntryUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(DeleteCoffeeEntryParams params) async {
    return await repository.deleteEntry(params.entry);
  }
}

class DeleteCoffeeEntryParams {
  final CoffeeTrackerEntry entry;

  DeleteCoffeeEntryParams({required this.entry});
}
