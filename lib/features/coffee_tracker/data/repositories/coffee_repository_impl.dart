import 'dart:convert';

import 'package:dartz/dartz.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/error/failures.dart';
import '../../domain/entities/coffee_tracker_entry.dart';
import '../../domain/repositories/coffee_tracker_repository.dart';

const String cachedCoffeeEntriesPrefix = 'CACHED_COFFEE_ENTRIES_';

class CoffeerRepositoryImpl implements CoffeerRepository {
  final SharedPreferences sharedPreferences;

  CoffeerRepositoryImpl({required this.sharedPreferences});

  @override
  Future<Either<Failure, void>> addEntry(CoffeeTrackerEntry entry) async {
    try {
      final key = '$cachedCoffeeEntriesPrefix${_formatDate(entry.timestamp)}';
      final currentEntriesJson = sharedPreferences.getStringList(key) ?? [];

      final updatedEntries = [
        ...currentEntriesJson,
        jsonEncode(entry.toJson()),
      ];

      final success = await sharedPreferences.setStringList(
        key,
        updatedEntries,
      );
      return success ? Right(null) : Left(CacheFailure());
    } catch (e) {
      return Left(CacheFailure());
    }
  }

  @override
  Future<Either<Failure, void>> editEntry(
    CoffeeTrackerEntry oldEntry,
    CoffeeTrackerEntry newEntry,
  ) async {
    try {
      final oldKey =
          '$cachedCoffeeEntriesPrefix${_formatDate(oldEntry.timestamp)}';
      final newKey =
          '$cachedCoffeeEntriesPrefix${_formatDate(newEntry.timestamp)}';

      // 1. Remove old entry from its original date
      final oldEntriesJson = sharedPreferences.getStringList(oldKey) ?? [];

      final filteredOldEntries = oldEntriesJson
          .map((e) => CoffeeTrackerEntry.fromJson(jsonDecode(e)))
          .where((entry) => entry.id != oldEntry.id) // Compare by id
          .map((entry) => jsonEncode(entry.toJson()))
          .toList();

      await sharedPreferences.setStringList(oldKey, filteredOldEntries);

      // 2. Add new entry to the (possibly new) date
      final newEntriesJson = sharedPreferences.getStringList(newKey) ?? [];
      newEntriesJson.add(jsonEncode(newEntry.toJson()));

      final success = await sharedPreferences.setStringList(
        newKey,
        newEntriesJson,
      );
      return success ? Right(null) : Left(CacheFailure());
    } catch (e) {
      return Left(CacheFailure());
    }
  }

  @override
  Future<Either<Failure, void>> deleteEntry(CoffeeTrackerEntry entry) async {
    try {
      final key = '$cachedCoffeeEntriesPrefix${_formatDate(entry.timestamp)}';
      final currentEntriesJson = sharedPreferences.getStringList(key) ?? [];

      final currentEntries = currentEntriesJson.map((jsonString) {
        final jsonMap = jsonDecode(jsonString) as Map<String, dynamic>;
        return CoffeeTrackerEntry.fromJson(jsonMap);
      }).toList();

      final updatedEntries = currentEntries
          .where((existingEntry) => existingEntry.id != entry.id)
          .map((entry) => jsonEncode(entry.toJson()))
          .toList();

      final success = await sharedPreferences.setStringList(
        key,
        updatedEntries,
      );

      return success ? Right(null) : Left(CacheFailure());
    } catch (e) {
      return Left(CacheFailure());
    }
  }

  @override
  Future<Either<Failure, List<CoffeeTrackerEntry>>> getLogByDate(
    DateTime date,
  ) async {
    try {
      final key = '$cachedCoffeeEntriesPrefix${_formatDate(date)}';
      final entriesJson = sharedPreferences.getStringList(key) ?? [];

      final entries = entriesJson
          .map((e) => CoffeeTrackerEntry.fromJson(jsonDecode(e)))
          .toList();

      // Sort by timestamp ascending (earliest first)
      entries.sort((a, b) => a.timestamp.compareTo(b.timestamp));

      return Right(entries);
    } catch (e) {
      return Left(CacheFailure());
    }
  }

  String _formatDate(DateTime date) {
    return '${date.year.toString().padLeft(4, '0')}-'
        '${date.month.toString().padLeft(2, '0')}-'
        '${date.day.toString().padLeft(2, '0')}';
  }
}
