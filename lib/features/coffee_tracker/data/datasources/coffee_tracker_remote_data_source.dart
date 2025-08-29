// lib/features/coffee_tracker/data/datasources/coffee_tracker_remote_data_source.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:coffee_tracker/core/auth/auth_service.dart';
import 'package:coffee_tracker/features/coffee_tracker/domain/entities/coffee_tracker_entry.dart';
import 'package:intl/intl.dart';

abstract class CoffeeTrackerRemoteDataSource {
  Future<List<CoffeeTrackerEntry>> getEntriesByDate(DateTime date);
  Future<CoffeeTrackerEntry> addEntry(CoffeeTrackerEntry entry);
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
    String? token = await authService.getValidAccessToken();

    // If token is null or expired, try to refresh
    if (token == null || (await authService.isTokenExpired(token))) {
      //debugPrint('Token missing or expired, attempting refresh...');
      final refreshed = await authService.refreshToken();
      if (refreshed != null) {
        token = await authService.getValidAccessToken();
        //debugPrint('Token refresh successful');
      } else {
        //('Token refresh failed');
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
      String formattedDate = DateFormat('yyyy-MM-dd').format(date);

      int timezoneOffsetMinutes = date.timeZoneOffset.inMinutes;
      final response = await client
          .get(
            Uri.parse(
              '$baseUrl/entries?date=$formattedDate&tzOffset=$timezoneOffsetMinutes',
            ),
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
  Future<CoffeeTrackerEntry> addEntry(CoffeeTrackerEntry entry) async {
    //debugPrint(entry.timestamp.toIso8601String());
    final jsonBody = jsonEncode(entry.toCreateJson());

    final response = await client.post(
      Uri.parse('$baseUrl/entries'),
      headers: await _getHeaders(),
      body: jsonBody,
    );

    if (response.statusCode == 201) {
      final jsonResponse = jsonDecode(response.body);
      return CoffeeTrackerEntry.fromJson(jsonResponse);
    } else if (response.statusCode == 401) {
      throw Exception('Unauthorized: Please login again');
    } else {
      //debugPrint('Server error: ${response.statusCode}');
      //debugPrint('Response body: ${response.body}');
      throw Exception('Failed to add coffee entry: ${response.statusCode}');
    }
  }

  @override
  Future<void> editEntry(
    CoffeeTrackerEntry oldEntry,
    CoffeeTrackerEntry newEntry,
  ) async {
    final jsonBody = jsonEncode(newEntry.toUpdateJson());
    //debugPrint('Response body: ${jsonBody}');
    final response = await client.put(
      Uri.parse('$baseUrl/entries/${oldEntry.id}'),
      headers: await _getHeaders(),
      body: jsonBody,
    );
    //debugPrint('Server error: ${response.statusCode}');
    //debugPrint('Response body: ${response.body}');

    if (response.statusCode != 200) {
      throw Exception('Failed to edit entry');
    }
  }

  @override
  Future<void> deleteEntry(String entryId) async {
    final response = await client.delete(
      Uri.parse('$baseUrl/entries/$entryId'),
      headers: await _getHeaders(),
    );

    if (response.statusCode != 204) {
      throw Exception('Failed to delete entry');
    }
  }
}
