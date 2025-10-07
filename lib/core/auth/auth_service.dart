// lib/core/auth/auth_service.dart
import 'dart:convert';
import 'package:coffee_tracker/core/auth/auth_interceptor.dart';
import 'package:coffee_tracker/core/utils/device_utils.dart';
import 'package:coffee_tracker/features/auth/data/models/auth_response_model.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:jwt_decoder/jwt_decoder.dart';

class AuthService {
  final http.Client client;
  final FlutterSecureStorage storage;
  final String baseUrl;
  static const String _accessTokenKey = 'access_token';
  static const String _refreshTokenKey = 'refresh_token';
  static const String _userMobileKey =
      'user_mobile'; // Store user mobile persistently

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
    debugPrint(
      'Requesting OTP for mobile: $mobile, URL: $baseUrl/auth/request-otp',
    );
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
      final deviceId = await getOrCreateDeviceId();
      debugPrint('Verifying OTP for mobile: $mobile with device ID: $deviceId');
      final response = await client.post(
        Uri.parse('$baseUrl/auth/verify-otp'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'mobile': mobile, 'otp': otp, 'device_id': deviceId}),
      );

      if (response.statusCode == 200) {
        debugPrint('Verify OTP response body: ${response.body}');
        await _saveTokensFromResponse(response.body);
        // Store mobile number for biometric setup
        await _storeMobile(mobile);

        // Return the token
        return getValidAccessToken();
      }
      debugPrint(
        'Verify OTP failed with status ${response.statusCode}: ${response.body}',
      );
      return null;
    } catch (e) {
      debugPrint('Error verifying OTP: $e');
      return null;
    }
  }

  // Refresh access token
  Future<String?> refreshAccessToken() async {
    final allValues = await storage.readAll();
    debugPrint('Current Secure Storage contents:');
    allValues.forEach((key, value) {
      debugPrint('Key="$key", Value="$value"');
    });

    final refreshToken = await storage.read(key: _refreshTokenKey);
    if (refreshToken == null) {
      debugPrint('No refresh token available');
      return null;
    }
    debugPrint('Refresh token present: $refreshToken');

    // Check if refresh token is expired
    if (await isTokenExpired(refreshToken)) {
      debugPrint('Refresh token expired');
      await logout(); // Clear expired tokens
      return null;
    }

    try {
      final deviceId = await getOrCreateDeviceId();
      debugPrint('Using device ID: $deviceId for token refresh');

      final response = await client.post(
        Uri.parse('$baseUrl/auth/refresh'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $refreshToken',
        },
        body: jsonEncode({
          'device_id': deviceId,
        }),
      );

      debugPrint('Refresh response: ${response.statusCode}');

      if (response.statusCode == 200) {
        final res = await _saveTokensFromResponse(response.body);
        debugPrint('Token refresh successful');
        return res.accessToken;
      } else if (response.statusCode == 401) {
        // Refresh token is invalid/expired
        debugPrint('Refresh token $refreshToken invalid - logging out');
        await logout();
        return null;
      }

      debugPrint('Refresh failed with status: ${response.statusCode}');
      return null;
    } catch (e) {
      debugPrint('Refresh token error: $e');
      return null;
    }
  }

  // Enhanced token validation
  Future<bool> isTokenExpired(String token) async {
    try {
      return JwtDecoder.isExpired(token);
    } catch (e) {
      debugPrint('Token validation error: $e');
      return true; // Consider invalid tokens as expired
    }
  }

  // Enhanced logout to clear all tokens
  Future<void> logout() async {
    await logoutApi();

    await storage.delete(key: _accessTokenKey);
    await storage.delete(key: _refreshTokenKey);
    debugPrint('All tokens cleared on logout');

    final allTokens = await storage.readAll();
    debugPrint('Storage state after logout: $allTokens');

    navigatorKey.currentState?.pushNamedAndRemoveUntil(
      '/login',
      (route) => false,
    );
  }

  Future<void> logoutApi() async {
    try {
      final deviceId = await getOrCreateDeviceId();
      debugPrint('Logging out with device ID: $deviceId');
      final response = await client.post(
        Uri.parse('$baseUrl/auth/logout'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'device_id': deviceId}),
      );
      debugPrint('Logging out response: ${response.statusCode}');
    } catch (e) {
      debugPrint('Logout request error: $e');
    }
  }

  // Get current access token
  Future<String?> getValidAccessToken() async {
    try {
      final token = await storage.read(key: _accessTokenKey);
      if (token == null) debugPrint('Access token missing in secure storage');
      return token;
    } catch (e) {
      debugPrint('Error retrieving token: $e');
      return null;
    }
  }

  Future<AuthTokens> _saveTokensFromResponse(String responseBody) async {
    try {
      final jsonResponse = jsonDecode(responseBody);
      final entity = AuthTokens.fromJson(jsonResponse);

      await storage.write(key: _accessTokenKey, value: entity.accessToken);
      await storage.write(key: _refreshTokenKey, value: entity.refreshToken);
      debugPrint('Tokens saved successfully: AccessToken and RefreshToken');

      // Verify by reading back
      final checkAccessToken = await storage.read(key: _accessTokenKey);
      final checkRefreshToken = await storage.read(key: _refreshTokenKey);
      debugPrint('Verified stored AccessToken: $checkAccessToken');
      debugPrint('Verified stored RefreshToken: $checkRefreshToken');

      return entity;
    } catch (e) {
      debugPrint('Error saving tokens: $e');
      rethrow;
    }
  }

  Future<void> saveBiometricTokens(
    String mobile,
    String accessToken,
    String refreshToken,
  ) async {
    final storage = FlutterSecureStorage();
    try {
      await storage.write(key: 'biometric_mobile', value: mobile);
      await storage.write(key: 'biometric_access_token', value: accessToken);
      await storage.write(key: 'biometric_refresh_token', value: refreshToken);
      debugPrint('Write succeeded for b x');
    } catch (e) {
      debugPrint('Write failed for biometric keys Error: $e');
    }
  }

  // Store mobile number persistently
  Future<void> _storeMobile(String mobile) async {
    try {
      await storage.write(key: _userMobileKey, value: mobile);
      debugPrint('Mobile number stored: $mobile');
    } catch (e) {
      debugPrint('Error storing mobile: $e');
    }
  }

  // Get stored mobile number
  Future<String?> getUserMobile() async {
    try {
      return await storage.read(key: _userMobileKey);
    } catch (e) {
      debugPrint('Error getting stored mobile: $e');
      return null;
    }
  }

  // Extract mobile from JWT token
  Future<String?> getMobileFromToken() async {
    try {
      final token = await getValidAccessToken();
      if (token == null) return null;

      final decodedToken = JwtDecoder.decode(token);
      // Try different possible field names for mobile in JWT
      final mobile =
          decodedToken['mobile'] ??
          decodedToken['phone'] ??
          decodedToken['phoneNumber'] ??
          decodedToken['sub']; // 'sub' is often used for user identifier

      debugPrint('Mobile extracted from JWT: $mobile');
      return mobile?.toString();
    } catch (e) {
      debugPrint('Error extracting mobile from token: $e');
      return null;
    }
  }

  // Get mobile number from any available source
  Future<String?> getCurrentUserMobile() async {
    // First try stored mobile
    String? mobile = await getUserMobile();
    if (mobile != null) {
      debugPrint('Mobile found in storage: $mobile');
      return mobile;
    }

    // Fallback to JWT token
    mobile = await getMobileFromToken();
    if (mobile != null) {
      debugPrint('Mobile found in JWT: $mobile');
      // Store it for future use
      await _storeMobile(mobile);
      return mobile;
    }

    debugPrint('No mobile number found');
    return null;
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
