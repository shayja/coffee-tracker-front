import 'package:coffee_tracker/core/error/failures.dart';
import 'package:coffee_tracker/features/coffee_tracker/domain/entities/coffee_options.dart';
import 'package:coffee_tracker/features/coffee_tracker/domain/entities/kv_type.dart';
import 'package:coffee_tracker/features/coffee_tracker/domain/repositories/generic_kv_repository.dart';
import 'package:dartz/dartz.dart';

class GetCoffeeSelectionsUseCase {
  final GenericKVRepository repository;

  GetCoffeeSelectionsUseCase(this.repository);

  Future<Either<Failure, CoffeeOptions>> execute(String language) async {
    final typesResult = await repository.getKV(1, language);
    final sizesResult = await repository.getKV(2, language);

    // if types failed
    if (typesResult.isLeft()) {
      return Left(
        typesResult.fold(
          (f) => f,
          (_) => ServerFailure(message: 'Unexpected error'),
        ),
      );
    }

    // if sizes failed
    if (sizesResult.isLeft()) {
      return Left(
        sizesResult.fold(
          (f) => f,
          (_) => ServerFailure(message: 'Unexpected error'),
        ),
      );
    }

    // both succeeded → unwrap safely
    final types = typesResult.getOrElse(() => []);
    final sizes = sizesResult.getOrElse(() => []);

    return Right(
      CoffeeOptions(
        coffeeTypes: types
            .map((kv) => KvType(key: kv.key, value: kv.value))
            .toList(),
        sizes: sizes.map((kv) => KvType(key: kv.key, value: kv.value)).toList(),
      ),
    );
  }
}
