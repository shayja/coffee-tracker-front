// file: lib/features/statistics/data/datasources/statistics_remote_data_source.dart
import 'dart:convert';

import 'package:coffee_tracker/core/auth/auth_service.dart';
import 'package:coffee_tracker/core/error/exception.dart';
import 'package:coffee_tracker/core/utils/api_utils.dart';
import 'package:coffee_tracker/features/statistics/data/models/statistics_model.dart';
import 'package:http/http.dart' as http;

abstract class StatisticsRemoteDataSource {
  Future<StatisticsModel> getStatistics();
}

class StatisticsRemoteDataSourceImpl implements StatisticsRemoteDataSource {
  final http.Client client;
  final String baseUrl;
  final AuthService authService;
  final ApiUtils apiHelper;
  final Duration timeout = const Duration(seconds: 10);

  StatisticsRemoteDataSourceImpl({
    required this.client,
    required this.baseUrl,
    required this.authService,
    required this.apiHelper,
  });

  @override
  Future<StatisticsModel> getStatistics() async {
    try {
      final response = await client
          .get(
            Uri.parse('$baseUrl/stats'),
            headers: await apiHelper.getHeaders(),
          )
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
