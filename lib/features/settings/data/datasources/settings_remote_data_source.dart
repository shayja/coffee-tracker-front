// lib/features/settings/data/datasources/settings_remote_data_source.dart
import 'dart:convert';
import 'package:coffee_tracker/core/utils/api_utils.dart';
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
  final ApiUtils apiHelper;
  final Duration timeout = const Duration(seconds: 10);

  SettingsRemoteDataSourceImpl({
    required this.client,
    required this.baseUrl,
    required this.authService,
    required this.apiHelper,
  });

  @override
  Future<SettingsModel> getSettings() async {
    try {
      final response = await client
          .get(
            Uri.parse('$baseUrl/settings'),
            headers: await apiHelper.getHeaders(),
          )
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
      final headers = await apiHelper.getHeaders();
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
