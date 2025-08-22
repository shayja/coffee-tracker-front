// file: lib/features/coffee_tracker/domain/repositories/coffee_tracker_repository.dart
// This file defines the CoffeeTrackerRepository interface for managing coffee tracker entries.
import 'package:coffee_tracker/core/error/failures.dart';
import 'package:coffee_tracker/features/coffee_tracker/domain/entities/coffee_tracker_entry.dart';
import 'package:dartz/dartz.dart';

abstract class CoffeeTrackerRepository {
  Future<Either<Failure, CoffeeTrackerEntry>> addEntry(
    CoffeeTrackerEntry entry,
  );
  Future<Either<Failure, void>> editEntry(
    CoffeeTrackerEntry oldEntry,
    CoffeeTrackerEntry newEntry,
  );
  Future<Either<Failure, void>> deleteEntry(CoffeeTrackerEntry entry);
  Future<Either<Failure, List<CoffeeTrackerEntry>>> getLogByDate(DateTime date);
}
