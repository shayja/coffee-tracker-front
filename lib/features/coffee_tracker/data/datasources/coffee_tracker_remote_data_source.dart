// lib/features/coffee_tracker/data/datasources/coffee_tracker_remote_data_source.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:coffee_tracker/core/auth/auth_service.dart';
import 'package:coffee_tracker/features/coffee_tracker/domain/entities/coffee_tracker_entry.dart';

abstract class CoffeeTrackerRemoteDataSource {
  Future<List<CoffeeTrackerEntry>> getEntriesByDate(DateTime date);
  Future<void> addEntry(CoffeeTrackerEntry entry);
  Future<void> editEntry(
    CoffeeTrackerEntry oldEntry,
    CoffeeTrackerEntry newEntry,
  );
  Future<void> deleteEntry(String entryId);
}

class CoffeeTrackerRemoteDataSourceImpl
    implements CoffeeTrackerRemoteDataSource {
  final http.Client client;
  final String baseUrl;
  final AuthService authService;
  final Duration timeout = const Duration(seconds: 10);

  CoffeeTrackerRemoteDataSourceImpl({
    required this.client,
    required this.baseUrl,
    required this.authService,
  });

  Future<Map<String, String>> _getHeaders() async {
    String? token = await authService.accessToken;

    // If token is null or expired, try to refresh
    if (token == null || (await authService.isTokenExpired(token))) {
      print('Token missing or expired, attempting refresh...');
      final refreshed = await authService.refreshToken();
      if (refreshed) {
        token = await authService.accessToken;
        print('Token refresh successful');
      } else {
        print('Token refresh failed');
        throw Exception('Authentication required - please login again');
      }
    }

    return {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
  }

  @override
  Future<List<CoffeeTrackerEntry>> getEntriesByDate(DateTime date) async {
    try {
      final response = await client
          .get(
            Uri.parse('$baseUrl/api/v1/entries?date=${date.toIso8601String()}'),
            headers: await _getHeaders(),
          )
          .timeout(timeout);

      if (response.statusCode == 200) {
        final List<dynamic> jsonList = json.decode(response.body);
        return jsonList
            .map((json) => CoffeeTrackerEntry.fromJson(json))
            .toList();
      } else {
        throw Exception(
          'Failed to load entries - Status: ${response.statusCode}, Body: ${response.body}',
        );
      }
    } catch (e) {
      throw Exception('Network error: ${e.toString()}');
    }
  }

  @override
  Future<void> addEntry(CoffeeTrackerEntry entry) async {
    try {
      final response = await client
          .post(
            Uri.parse('$baseUrl/api/v1/entries'),
            headers: await _getHeaders(),
            body: json.encode({
              'timestamp': entry.timestamp.toIso8601String(),
              'notes': entry.notes,
            }),
          )
          .timeout(timeout);

      if (response.statusCode != 201) {
        throw Exception(
          'Failed to add entry - Status: ${response.statusCode}, Body: ${response.body}',
        );
      }
    } catch (e) {
      throw Exception('Network error: ${e.toString()}');
    }
  }

  @override
  Future<void> editEntry(
    CoffeeTrackerEntry oldEntry,
    CoffeeTrackerEntry newEntry,
  ) async {
    final response = await client.put(
      Uri.parse('$baseUrl/api/v1/entries/${oldEntry.id}'),
      headers: await _getHeaders(),
      body: json.encode({
        'timestamp': newEntry.timestamp.toIso8601String(),
        'notes': newEntry.notes,
      }),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to edit entry');
    }
  }

  @override
  Future<void> deleteEntry(String entryId) async {
    final response = await client.delete(
      Uri.parse('$baseUrl/api/v1/entries/$entryId'),
      headers: await _getHeaders(),
    );

    if (response.statusCode != 204) {
      throw Exception('Failed to delete entry');
    }
  }
}
