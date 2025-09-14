import 'package:coffee_tracker/core/error/failures.dart';
import 'package:coffee_tracker/features/coffee_tracker/domain/entities/kv_item.dart';
import 'package:dartz/dartz.dart';

abstract class GenericKVRepository {
  Future<Either<Failure, List<KVItem>>> getKV(int typeID, String languageCode);
}
