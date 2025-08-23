// file: lib/features/statistics/domain/repositories/statistics_repository.dart
import 'package:coffee_tracker/core/error/failures.dart';
import 'package:coffee_tracker/features/statistics/domain/entities/statistics_entity.dart';
import 'package:dartz/dartz.dart';

abstract class StatisticsRepository {
  Future<Either<Failure, StatisticsEntity>> getStatistics();
}
