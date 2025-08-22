// coffee_tracker/lib/features/coffee_tracker/domain/usecases/get_daily_coffee_tracker_log.dart
import 'package:coffee_tracker/core/error/failures.dart';
import 'package:coffee_tracker/features/coffee_tracker/domain/entities/coffee_tracker_entry.dart';
import 'package:coffee_tracker/features/coffee_tracker/domain/repositories/coffee_tracker_repository.dart';
import 'package:dartz/dartz.dart';

class GetDailyCoffeeTrackerLog {
  final CoffeeTrackerRepository repository;

  GetDailyCoffeeTrackerLog(this.repository);

  Future<Either<Failure, List<CoffeeTrackerEntry>>> call(DateTime date) async {
    return await repository.getLogByDate(date);
  }
}
