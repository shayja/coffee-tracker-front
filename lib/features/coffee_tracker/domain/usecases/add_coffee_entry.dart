import 'package:coffee_tracker/core/usecases/usecase.dart';
import 'package:coffee_tracker/features/coffee_tracker/domain/entities/coffee_tracker_entry.dart';
import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../repositories/coffee_tracker_repository.dart';

class AddCoffeeEntryUseCase implements UseCase<void, AddCoffeeEntryParams> {
  final CoffeerRepository repository;

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
