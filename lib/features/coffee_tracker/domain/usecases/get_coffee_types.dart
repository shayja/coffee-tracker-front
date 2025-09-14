import 'package:coffee_tracker/core/error/failures.dart';
import 'package:coffee_tracker/features/coffee_tracker/domain/entities/coffee_type.dart';
import 'package:coffee_tracker/features/coffee_tracker/domain/repositories/generic_kv_repository.dart';
import 'package:dartz/dartz.dart';

class GetCoffeeTypesUseCase {
  final GenericKVRepository repository;

  GetCoffeeTypesUseCase(this.repository);

  Future<Either<Failure, List<CoffeeType>>> execute() async {
    // typeID 1 is coffee_types in your backend
    final result = await repository.getKV(
      1,
      'he',
    ); // optionally parametrize language code

    return result.fold(
      (failure) => Left(failure),
      (kvList) => Right(
        kvList.map((kv) => CoffeeType(key: kv.key, value: kv.value)).toList(),
      ),
    );
  }
}
