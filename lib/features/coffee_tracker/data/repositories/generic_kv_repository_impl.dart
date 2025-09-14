// lib/features/coffee_tracker/data/repositories/generic_kv_repository_impl.dart
import 'package:coffee_tracker/features/coffee_tracker/data/datasources/generic_kv_remote_data_source.dart';
import 'package:coffee_tracker/features/coffee_tracker/domain/entities/kv_item.dart';
import 'package:coffee_tracker/features/coffee_tracker/domain/repositories/generic_kv_repository.dart';
import 'package:dartz/dartz.dart';
import 'package:coffee_tracker/core/error/failures.dart';

class GenericKVRepositoryImpl implements GenericKVRepository {
  final GenericKVRemoteDataSource remoteDataSource;

  GenericKVRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, List<KVItem>>> getKV(
    int typeID,
    String languageCode,
  ) async {
    try {
      final jsonList = await remoteDataSource.getKVList(typeID, languageCode);
      final kvList = jsonList
          .map(
            (json) =>
                KVItem(key: json['key'] as int, value: json['value'] as String),
          )
          .toList();
      return Right(kvList);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }
}
