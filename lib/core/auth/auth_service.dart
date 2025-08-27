// lib/core/auth/auth_service.dart
import 'dart:convert';
import 'package:coffee_tracker/features/auth/data/models/auth_response_model.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:jwt_decoder/jwt_decoder.dart';

class AuthService {
  final http.Client client;
  final FlutterSecureStorage storage;
  final String baseUrl;
  static const String _accessTokenKey = 'access_token';
  static const String _refreshTokenKey = 'refresh_token';

  AuthService({
    required this.client,
    required this.storage,
    required this.baseUrl,
  });

  // Check if user is authenticated
  Future<bool> isAuthenticated() async {
    final token = await getValidAccessToken();
    return token != null && !(await isTokenExpired(token));
  }

  // Request OTP
  Future<Map<String, dynamic>> requestOtp(String mobile) async {
    try {
      final response = await client.post(
        Uri.parse('$baseUrl/auth/request-otp'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'mobile': mobile}),
      );

      return {
        'success': response.statusCode == 200,
        'statusCode': response.statusCode,
        'message': response.statusCode == 200
            ? 'OTP sent successfully'
            : _getErrorMessage(response.statusCode),
      };
    } catch (e) {
      return {
        'success': false,
        'statusCode': 500,
        'message': 'Network error. Please check your connection.',
      };
    }
  }

  // Verify OTP and save tokens
  Future<String?> verifyOtp(String mobile, String otp) async {
    try {
      final response = await client.post(
        Uri.parse('$baseUrl/auth/verify-otp'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'mobile': mobile, 'otp': otp}),
      );

      if (response.statusCode == 200) {
        await _saveTokensFromResponse(response.body);

        return getValidAccessToken(); // Return the token
      }
      return null;
    } catch (e) {
      print('Error verifying OTP: $e');
      return null;
    }
  }

  // Refresh token
  Future<String?> refreshToken() async {
    final refreshToken = await storage.read(key: _refreshTokenKey);
    if (refreshToken == null) {
      print('No refresh token available');
      return null;
    }

    // Check if refresh token is expired
    if (await isTokenExpired(refreshToken)) {
      print('Refresh token expired');
      await logout(); // Clear expired tokens
      return null;
    }

    try {
      final response = await client.post(
        Uri.parse('$baseUrl/auth/refresh'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'refresh_token': refreshToken}),
      );

      print('Refresh response: ${response.statusCode}');

      if (response.statusCode == 200) {
        final res = await _saveTokensFromResponse(response.body);
        print('Token refresh successful');
        return res.refreshToken;
      } else if (response.statusCode == 401) {
        // Refresh token is invalid/expired
        print('Refresh token invalid - logging out');
        await logout();
        return null;
      }

      print('Refresh failed with status: ${response.statusCode}');
      return null;
    } catch (e) {
      print('Refresh token error: $e');
      return null;
    }
  }

  // Enhanced token validation
  Future<bool> isTokenExpired(String token) async {
    try {
      return JwtDecoder.isExpired(token);
    } catch (e) {
      print('Token validation error: $e');
      return true; // Consider invalid tokens as expired
    }
  }

  // Enhanced logout to clear all tokens
  Future<void> logout() async {
    await storage.delete(key: _accessTokenKey);
    await storage.delete(key: _refreshTokenKey);
    print('All tokens cleared on logout');
  }

  // Get current access token
  Future<String?> getValidAccessToken() async {
    try {
      return await storage.read(key: _accessTokenKey);
    } catch (e) {
      print('Error retrieving token: $e');
      return null;
    }
  }

  Future<AuthResponseTokenModel> _saveTokensFromResponse(
    String responseBody,
  ) async {
    try {
      final jsonResponse = jsonDecode(responseBody);
      final entity = AuthResponseTokenModel.fromJson(jsonResponse);

      await storage.write(key: _accessTokenKey, value: entity.accessToken);
      await storage.write(key: _refreshTokenKey, value: entity.refreshToken);
      print('Tokens saved successfully');
      return entity;
    } catch (e) {
      print('Error saving tokens: $e');
      rethrow;
    }
  }

  // Add this helper method
  String _getErrorMessage(int statusCode) {
    switch (statusCode) {
      case 404:
        return 'Mobile number not found. Please check your number or contact support.';
      case 400:
        return 'Invalid mobile number format.';
      case 429:
        return 'Too many attempts. Please try again later.';
      case 500:
        return 'Server error. Please try again later.';
      default:
        return 'Failed to send OTP. Please try again.';
    }
  }

  // Add this to your AuthService for debugging
  Future<void> debugPrintStoredTokens() async {
    final accessToken = await storage.read(key: _accessTokenKey);
    final refreshToken = await storage.read(key: _refreshTokenKey);
    final authToken = await storage.read(key: 'auth_token');

    print('=== STORED TOKENS DEBUG ===');
    print('Access Token: ${accessToken != null ? "EXISTS" : "NULL"}');
    print('Refresh Token: ${refreshToken != null ? "EXISTS" : "NULL"}');
    print('Legacy Auth Token: ${authToken != null ? "EXISTS" : "NULL"}');

    if (accessToken != null) {
      final isExpired = JwtDecoder.isExpired(accessToken);
      print('Access Token Expired: $isExpired');
    }
  }

  Future<void> debugAuthStatus() async {
    final accessToken = await storage.read(key: _accessTokenKey);
    final refreshToken = await storage.read(key: _refreshTokenKey);

    print('=== AUTH STATUS DEBUG ===');
    print('Access Token: ${accessToken != null ? "EXISTS" : "NULL"}');
    print('Refresh Token: ${refreshToken != null ? "EXISTS" : "NULL"}');

    if (accessToken != null) {
      final accessExpired = await isTokenExpired(accessToken);
      print('Access Token Expired: $accessExpired');
      print(
        'Access Token Expiry: ${JwtDecoder.getExpirationDate(accessToken)}',
      );
    }

    if (refreshToken != null) {
      final refreshExpired = await isTokenExpired(refreshToken);
      print('Refresh Token Expired: $refreshExpired');
      print(
        'Refresh Token Expiry: ${JwtDecoder.getExpirationDate(refreshToken)}',
      );
    }
    print('=========================');
  }

  // Call this method in your interceptor for debugging
  Future<void> logTokenStatus() async {
    await debugAuthStatus();
  }
}
