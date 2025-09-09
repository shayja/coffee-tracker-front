// lib/features/tapering_journey/data/datasources/tapering_journey_remote_data_source.dart

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:coffee_tracker/core/auth/auth_service.dart';
import 'package:coffee_tracker/features/tapering_journey/domain/entities/tapering_journey.dart';

abstract class TaperingJourneyRemoteDataSource {
  Future<TaperingJourneyData> createJourney(TaperingJourneyData journey);
  Future<void> updateJourney(TaperingJourneyData journey);
  Future<void> deleteJourney(String journeyId);
  Future<List<TaperingJourneyData>> getJourneysByUser();
  Future<TaperingJourneyData> getJourneyById(String id);
}

class TaperingJourneyRemoteDataSourceImpl
    implements TaperingJourneyRemoteDataSource {
  final http.Client client;
  final String baseUrl;
  final AuthService authService;
  final Duration timeout = const Duration(seconds: 10);

  TaperingJourneyRemoteDataSourceImpl({
    required this.client,
    required this.baseUrl,
    required this.authService,
  });

  Future<Map<String, String>> _getHeaders() async {
    final token = await authService.getValidAccessToken();
    if (token == null) {
      throw Exception('Unauthorized: No access token');
    }
    return {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
  }

  @override
  Future<TaperingJourneyData> createJourney(TaperingJourneyData journey) async {
    final response = await client
        .post(
          Uri.parse('$baseUrl/tapering'),
          headers: await _getHeaders(),
          body: jsonEncode(journey.toCreateJson()),
        )
        .timeout(timeout);

    if (response.statusCode == 201) {
      final jsonResponse = jsonDecode(response.body);
      return TaperingJourneyData.fromJson(jsonResponse);
    } else {
      throw Exception(
        'Failed to create tapering journey: ${response.statusCode}',
      );
    }
  }

  @override
  Future<void> updateJourney(TaperingJourneyData journey) async {
    final response = await client
        .put(
          Uri.parse('$baseUrl/tapering/${journey.id}'),
          headers: await _getHeaders(),
          body: jsonEncode(journey.toCreateJson()),
        )
        .timeout(timeout);

    if (response.statusCode != 200) {
      throw Exception('Failed to update tapering journey');
    }
  }

  @override
  Future<void> deleteJourney(String journeyId) async {
    final response = await client
        .delete(
          Uri.parse('$baseUrl/tapering/$journeyId'),
          headers: await _getHeaders(),
        )
        .timeout(timeout);

    if (response.statusCode != 204) {
      throw Exception('Failed to delete tapering journey');
    }
  }

  @override
  Future<List<TaperingJourneyData>> getJourneysByUser() async {
    final response = await client
        .get(Uri.parse('$baseUrl/tapering'), headers: await _getHeaders())
        .timeout(timeout);

    if (response.statusCode == 200) {
      final List<dynamic> jsonList = jsonDecode(response.body);
      return jsonList
          .map((json) => TaperingJourneyData.fromJson(json))
          .toList();
    } else {
      throw Exception('Failed to get tapering journeys');
    }
  }

  @override
  Future<TaperingJourneyData> getJourneyById(String id) async {
    final response = await client
        .get(Uri.parse('$baseUrl/tapering/$id'), headers: await _getHeaders())
        .timeout(timeout);

    if (response.statusCode == 200) {
      final jsonResponse = jsonDecode(response.body);
      return TaperingJourneyData.fromJson(jsonResponse);
    } else {
      throw Exception('Tapering journey not found');
    }
  }
}
