import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/coffee_tracker_entry.dart';

abstract class CoffeerRepository {
  Future<Either<Failure, void>> addEntry(CoffeeTrackerEntry entry);
  Future<Either<Failure, void>> editEntry(
    CoffeeTrackerEntry oldEntry,
    CoffeeTrackerEntry newEntry,
  );
  Future<Either<Failure, void>> deleteEntry(CoffeeTrackerEntry entry);
  Future<Either<Failure, List<CoffeeTrackerEntry>>> getLogByDate(DateTime date);
}
