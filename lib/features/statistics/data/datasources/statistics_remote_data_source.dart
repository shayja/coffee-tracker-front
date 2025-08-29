// file: lib/features/statistics/data/datasources/statistics_remote_data_source.dart
import 'dart:convert';

import 'package:coffee_tracker/core/auth/auth_service.dart';
import 'package:coffee_tracker/core/error/exception.dart';
import 'package:coffee_tracker/features/statistics/data/models/statistics_model.dart';
import 'package:http/http.dart' as http;

abstract class StatisticsRemoteDataSource {
  Future<StatisticsModel> getStatistics();
}

class StatisticsRemoteDataSourceImpl implements StatisticsRemoteDataSource {
  final http.Client client;
  final String baseUrl;
  final AuthService authService;
  final Duration timeout = const Duration(seconds: 10);

  StatisticsRemoteDataSourceImpl({
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
  Future<StatisticsModel> getStatistics() async {
    try {
      final response = await client
          .get(Uri.parse('$baseUrl/stats'), headers: await _getHeaders())
          .timeout(timeout);

      if (response.statusCode == 200) {
        return StatisticsModel.fromJson(json.decode(response.body));
      } else {
        throw Exception(
          'Failed to load Statistics - Status: ${response.statusCode}, Body: ${response.body}',
        );
      }
    } catch (e) {
      throw ServerException(message: 'Failed to load statistics: $e');
    }
  }
}
