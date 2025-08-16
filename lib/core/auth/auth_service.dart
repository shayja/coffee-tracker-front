// lib/core/auth/auth_service.dart
import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:jwt_decoder/jwt_decoder.dart';

class AuthService {
  final http.Client client;
  final FlutterSecureStorage storage;
  static const _baseUrl = 'http://localhost:3000/api/v1/auth';
  static const String _accessTokenKey = 'access_token';
  static const String _refreshTokenKey = 'refresh_token';

  AuthService({required this.client, required this.storage});

  // Get current access token
  Future<String?> get accessToken async {
    return await storage.read(key: _accessTokenKey);
  }

  // is token expired
  Future<bool> isTokenExpired(String token) async {
    return JwtDecoder.isExpired(token);
  }

  // Check if user is authenticated
  Future<bool> isAuthenticated() async {
    final token = await accessToken;
    return token != null && !(await isTokenExpired(token));
  }

  // Login and save tokens
  Future<bool> login(String email, String password) async {
    final response = await client.post(
      Uri.parse('$_baseUrl/login'),
      body: {'email': email, 'password': password},
    );

    if (response.statusCode == 200) {
      await _saveTokensFromResponse(response.body);
      return true;
    }
    return false;
  }

  // Refresh token
  Future<bool> refreshToken() async {
    final refreshToken = await storage.read(key: _refreshTokenKey);
    if (refreshToken == null) return false;

    try {
      final response = await client.post(
        Uri.parse('$_baseUrl/refresh'),
        body: {'refresh_token': refreshToken},
      );

      if (response.statusCode == 200) {
        await _saveTokensFromResponse(response.body);
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  // Logout
  Future<void> logout() async {
    await storage.delete(key: _accessTokenKey);
    await storage.delete(key: _refreshTokenKey);
  }

  Future<void> _saveTokensFromResponse(String responseBody) async {
    final json = jsonDecode(responseBody);
    await storage.write(key: _accessTokenKey, value: json[_accessTokenKey]);
    await storage.write(key: _refreshTokenKey, value: json[_refreshTokenKey]);
  }
}
