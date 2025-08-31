// lib/features/settings/data/datasources/settings_remote_data_source.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:coffee_tracker/core/auth/auth_service.dart';
import 'package:coffee_tracker/features/settings/data/models/settings_model.dart';

abstract class SettingsRemoteDataSource {
  Future<SettingsModel> getSettings();
  Future<void> updateSetting(int settingId, bool value);
}

class SettingsRemoteDataSourceImpl implements SettingsRemoteDataSource {
  final http.Client client;
  final String baseUrl;
  final AuthService authService;
  final Duration timeout = const Duration(seconds: 10);

  SettingsRemoteDataSourceImpl({
    required this.client,
    required this.baseUrl,
    required this.authService,
  });

  Future<Map<String, String>> _getHeaders() async {
    String? token = await authService.getValidAccessToken();

    // If token is null or expired, try to refresh
    if (token == null || (await authService.isTokenExpired(token))) {
      final refreshed = await authService.refreshToken();
      if (refreshed != null) {
        token = await authService.getValidAccessToken();
      } else {
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
  Future<SettingsModel> getSettings() async {
    try {
      final response = await client
          .get(Uri.parse('$baseUrl/settings'), headers: await _getHeaders())
          .timeout(timeout);

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = json.decode(response.body);
        return SettingsModel.fromJson(jsonResponse);
      } else if (response.statusCode == 401) {
        throw Exception('Unauthorized: Please login again');
      } else {
        throw Exception(
          'Failed to load settings - Status: ${response.statusCode}, Body: ${response.body}',
        );
      }
    } catch (e) {
      throw Exception('Network error: ${e.toString()}');
    }
  }

  @override
  Future<void> updateSetting(int settingId, bool value) async {
    try {
      final url = '$baseUrl/settings/$settingId';
      final headers = await _getHeaders();
      final requestBody = json.encode({'key': settingId, 'value': value});

      final response = await client
          .patch(Uri.parse(url), headers: headers, body: requestBody)
          .timeout(timeout);

      if (response.statusCode == 401) {
        throw Exception('Unauthorized: Please login again');
      } else if (response.statusCode != 200 && response.statusCode != 204) {
        throw Exception(
          'Failed to update setting - Status: ${response.statusCode}, Body: ${response.body}',
        );
      }
    } catch (e) {
      throw Exception('Network error: ${e.toString()}');
    }
  }
}
