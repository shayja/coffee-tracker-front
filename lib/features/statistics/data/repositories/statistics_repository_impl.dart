import 'package:coffee_tracker/core/error/exception.dart';
import 'package:coffee_tracker/core/error/failures.dart';
import 'package:coffee_tracker/features/statistics/data/datasources/statistics_remote_data_source.dart';
import 'package:coffee_tracker/features/statistics/domain/entities/statistics_entity.dart';

import 'package:coffee_tracker/features/statistics/domain/repositories/statistics_repository.dart';
import 'package:dartz/dartz.dart';

class StatisticsRepositoryImpl implements StatisticsRepository {
  final StatisticsRemoteDataSource remoteDataSource;

  StatisticsRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, StatisticsEntity>> getStatistics() async {
    try {
      final statistics = await remoteDataSource.getStatistics();
      return Right(statistics);
    } on ServerException {
      return Left(ServerFailure(message: 'Server error occurred.'));
    } catch (e) {
      return Left(ServerFailure(message: 'Unexpected error: $e'));
    }
  }
}
