// lib/core/data/datasources/generic_kv_remote_data_source.dart
import 'dart:convert';
import 'package:coffee_tracker/core/utils/api_utils.dart';
import 'package:http/http.dart' as http;
import 'package:coffee_tracker/core/auth/auth_service.dart';

abstract class GenericKVRemoteDataSource {
  /// Fetch a generic key-value list by typeID and languageCode.
  Future<List<Map<String, dynamic>>> getKVList(int typeID, String languageCode);
}

class GenericKVRemoteDataSourceImpl implements GenericKVRemoteDataSource {
  final http.Client client;
  final String baseUrl;
  final AuthService authService;
  final ApiUtils apiHelper;
  final Duration timeout = const Duration(seconds: 10);

  GenericKVRemoteDataSourceImpl({
    required this.client,
    required this.baseUrl,
    required this.authService,
    required this.apiHelper,
  });

  Future<Map<String, String>> _getHeaders() async {
    String? token = await authService.getValidAccessToken();

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
  Future<List<Map<String, dynamic>>> getKVList(
    int typeID,
    String languageCode,
  ) async {
    try {
      final response = await client
          .get(
            Uri.parse('$baseUrl/kv?type=$typeID&language=$languageCode'),
            headers: await _getHeaders(),
          )
          .timeout(timeout);

      if (response.statusCode == 200) {
        final List<dynamic> jsonList = json.decode(response.body)['items'];
        return List<Map<String, dynamic>>.from(jsonList);
      } else {
        throw Exception(
          'Failed to load KV list - Status: ${response.statusCode}, Body: ${response.body}',
        );
      }
    } catch (e) {
      throw Exception('Network error: ${e.toString()}');
    }
  }
}
