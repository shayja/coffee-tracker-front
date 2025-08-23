// file: lib/features/statistics/domain/usecases/get_statistics.dart
import 'package:coffee_tracker/core/error/failures.dart';
import 'package:coffee_tracker/core/usecases/usecase.dart';

import 'package:coffee_tracker/features/statistics/domain/entities/statistics_entity.dart';
import 'package:coffee_tracker/features/statistics/domain/repositories/statistics_repository.dart';
import 'package:dartz/dartz.dart';

class GetStatistics implements UseCase<StatisticsEntity, NoParams> {
  final StatisticsRepository repository;

  GetStatistics(this.repository);

  @override
  Future<Either<Failure, StatisticsEntity>> call(NoParams params) async {
    return await repository.getStatistics();
  }
}
