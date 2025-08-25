// lib/core/auth/auth_service.dart
import 'dart:convert';
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

  // is token expired
  Future<bool> isTokenExpired(String token) async {
    return JwtDecoder.isExpired(token);
  }

  // Check if user is authenticated
  Future<bool> isAuthenticated() async {
    final token = await getAccessToken();
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

        return getAccessToken(); // Return the token
      }
      return null;
    } catch (e) {
      print('Error verifying OTP: $e');
      return null;
    }
  }

  // Refresh token
  Future<bool> refreshToken() async {
    final refreshToken = await storage.read(key: _refreshTokenKey);
    if (refreshToken == null) return false;

    try {
      final response = await client.post(
        Uri.parse('$baseUrl/auth/refresh'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'refresh_token': refreshToken}),
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

  // Get current access token
  Future<String?> getAccessToken() async {
    try {
      return await storage.read(key: _accessTokenKey);
    } catch (e) {
      print('Error retrieving token: $e');
      return null;
    }
  }

  // Future<void> saveAccessToken(String token) async {
  //   await storage.write(key: _accessTokenKey, value: token);
  // }

  // Future<void> saveRefreshToken(String refreshToken) async {
  //   await storage.write(key: _refreshTokenKey, value: refreshToken);
  // }

  Future<void> _saveTokensFromResponse(String responseBody) async {
    final json = jsonDecode(responseBody);
    await storage.write(key: _accessTokenKey, value: json[_accessTokenKey]);
    await storage.write(key: _refreshTokenKey, value: json[_refreshTokenKey]);
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
}
