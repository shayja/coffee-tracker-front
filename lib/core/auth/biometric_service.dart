import 'package:coffee_tracker/features/auth/data/models/auth_response_model.dart';
import 'package:flutter/foundation.dart';
import 'package:local_auth/local_auth.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:jwt_decoder/jwt_decoder.dart';

class BiometricService {
  final LocalAuthentication _localAuth = LocalAuthentication();
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  static const String _biometricAuthKey = 'biometric_auth_enabled';
  static const String _biometricMobileKey = 'biometric_mobile';
  static const String _biometricTokenKey = 'biometric_token';
  static const String _biometricRefreshTokenKey = 'biometric_refresh_token';
  static const String _persistentMobileKey = 'persistent_biometric_mobile'; // Survives logout

  // Check if biometric login is enabled for any user
  Future<bool> isBiometricLoginEnabled() async {
    try {
      final enabled = await _storage.read(key: _biometricAuthKey);
      final mobile = await _storage.read(key: _biometricMobileKey);
      final token = await _storage.read(key: _biometricTokenKey);
      final refresh = await _storage.read(key: _biometricRefreshTokenKey);

      return enabled == 'true' &&
          mobile != null &&
          token != null &&
          refresh != null;
    } catch (e) {
      debugPrint('Biometric login check error: $e');
      return false;
    }
  }

  // Enable biometric login for a user (call this after successful OTP login)
  Future<void> enableBiometricLogin(
    String mobile,
    String accessToken,
    String refreshToken,
  ) async {
    try {
      await _storage.write(key: _biometricAuthKey, value: 'true');
      await _storage.write(key: _biometricMobileKey, value: mobile);
      await _storage.write(key: _biometricTokenKey, value: accessToken);
      await _storage.write(key: _biometricRefreshTokenKey, value: refreshToken);
      // Store persistent mobile that survives logout
      await _storage.write(key: _persistentMobileKey, value: mobile);

      debugPrint('Biometric login enabled for user: $mobile');
    } catch (e) {
      debugPrint('Error enabling biometric login: $e');
      rethrow;
    }
  }

  // Disable biometric login
  Future<void> disableBiometricLogin() async {
    try {
      await _storage.delete(key: _biometricAuthKey);
      await _storage.delete(key: _biometricMobileKey);
      await _storage.delete(key: _biometricTokenKey);
      await _storage.delete(key: _biometricRefreshTokenKey);
      await _storage.delete(key: _persistentMobileKey); // Clear persistent mobile too
      debugPrint('Biometric login disabled');
    } catch (e) {
      debugPrint('Error disabling biometric login: $e');
    }
  }

  // Get persistent mobile number (survives logout)
  Future<String?> getPersistentMobile() async {
    try {
      return await _storage.read(key: _persistentMobileKey);
    } catch (e) {
      debugPrint('Error getting persistent mobile: $e');
      return null;
    }
  }

  // Check if biometric login is available for a specific mobile number
  Future<bool> isBiometricAvailableForMobile(String mobile) async {
    try {
      final persistentMobile = await getPersistentMobile();
      final isEnabled = await isBiometricLoginEnabled();
      
      debugPrint('Checking biometric for mobile: $mobile');
      debugPrint('Persistent mobile: $persistentMobile');
      debugPrint('Biometric enabled: $isEnabled');
      
      return persistentMobile == mobile && isEnabled;
    } catch (e) {
      debugPrint('Error checking biometric availability for mobile: $e');
      return false;
    }
  }

  // Check if any user has biometric login set up (for showing biometric option)
  Future<bool> hasAnyBiometricUser() async {
    try {
      final persistentMobile = await getPersistentMobile();
      final isEnabled = await isBiometricLoginEnabled();
      
      return persistentMobile != null && isEnabled;
    } catch (e) {
      debugPrint('Error checking for any biometric user: $e');
      return false;
    }
  }

  // Get stored biometric login data
  Future<AuthTokens?> getBiometricLoginData() async {
    try {
      final mobile = await _storage.read(key: _biometricMobileKey);
      final access = await _storage.read(key: _biometricTokenKey);
      final refresh = await _storage.read(key: _biometricRefreshTokenKey);

      debugPrint('Biometric data retrieved:');
      debugPrint('Mobile: ${mobile != null ? "EXISTS" : "NULL"}');
      debugPrint(
        'Access token: ${access != null ? "EXISTS (${access.length} chars)" : "NULL"}',
      );
      debugPrint(
        'Refresh token: ${refresh != null ? "EXISTS (${refresh.length} chars)" : "NULL"}',
      );

      if (access != null) {
        debugPrint(
          'Access token preview: ${access.length > 20 ? "${access.substring(0, 20)}..." : access}',
        );
      }

      if (mobile == null || access == null || refresh == null) {
        debugPrint('Missing biometric data - returning null');
        return null;
      }

      return AuthTokens(accessToken: access, refreshToken: refresh);
    } catch (e) {
      debugPrint('Error getting biometric data: $e');
      return null;
    }
  }

  // Authenticate with biometrics and return stored tokens
  Future<AuthTokens?> authenticateAndGetTokens() async {
    try {
      debugPrint('Checking biometric availability...');
      final isAvailable = await isBiometricAvailable();

      if (!isAvailable) {
        debugPrint('Biometric authentication not available.');
        return null;
      }

      debugPrint('Starting biometric authentication...');
      final result = await _localAuth.authenticate(
        localizedReason: 'Authenticate to access your coffee tracker',
        options: const AuthenticationOptions(
          biometricOnly: true,
          useErrorDialogs: true,
          stickyAuth: true,
        ),
      );

      if (result) {
        debugPrint('Biometric authentication successful');
        final data = await getBiometricLoginData();

        if (data != null) {
          // Validate token expiration
          final isValid = await _validateTokens(data);
          if (isValid) {
            debugPrint('Tokens are valid');
            return data;
          } else {
            debugPrint('Tokens are expired, biometric login failed');
            return null;
          }
        }

        return data;
      } else {
        debugPrint('Biometric authentication failed');
        return null;
      }
    } catch (e) {
      debugPrint('Biometric authentication error: $e');
      return null;
    }
  }

  // Validate if tokens are still valid (not expired)
  Future<bool> _validateTokens(AuthTokens tokens) async {
    try {
      // First check if tokens are valid JWT format
      if (!_isValidJwtFormat(tokens.accessToken)) {
        debugPrint('Access token is not valid JWT format');
        await disableBiometricLogin();
        return false;
      }

      if (!_isValidJwtFormat(tokens.refreshToken)) {
        debugPrint('Refresh token is not valid JWT format');
        await disableBiometricLogin();
        return false;
      }

      // Check if access token is expired
      final isAccessExpired = JwtDecoder.isExpired(tokens.accessToken);
      final isRefreshExpired = JwtDecoder.isExpired(tokens.refreshToken);

      debugPrint('Access token expired: $isAccessExpired');
      debugPrint('Refresh token expired: $isRefreshExpired');

      // If both tokens are expired, biometric login should fail
      if (isAccessExpired && isRefreshExpired) {
        debugPrint('Both tokens expired, clearing biometric data');
        await disableBiometricLogin();
        return false;
      }

      // If only access token is expired but refresh token is valid,
      // we should let the AuthService handle the refresh
      return true;
    } catch (e) {
      debugPrint('Token validation error: $e');
      // If there's any error in token validation, clear biometric data
      debugPrint('Clearing biometric data due to token validation error');
      await disableBiometricLogin();
      return false;
    }
  }

  // Helper method to check if a string is a valid JWT format
  bool _isValidJwtFormat(String token) {
    if (token.isEmpty) return false;

    // JWT tokens should have 3 parts separated by dots
    final parts = token.split('.');
    if (parts.length != 3) {
      debugPrint('Token does not have 3 parts: ${parts.length}');
      return false;
    }

    // Each part should be base64 encoded (basic check)
    for (int i = 0; i < parts.length; i++) {
      if (parts[i].isEmpty) {
        debugPrint('Token part $i is empty');
        return false;
      }
    }

    return true;
  }

  // Check if biometric hardware is available
  Future<bool> isBiometricAvailable() async {
    try {
      final result = await _localAuth.canCheckBiometrics;
      debugPrint('Biometric availability: $result');
      return result;
    } catch (e) {
      debugPrint('Biometric availability check error: $e');
      return false;
    }
  }

  // Get list of available biometric types
  Future<List<BiometricType>> getAvailableBiometrics() async {
    try {
      final result = await _localAuth.getAvailableBiometrics();
      debugPrint('Available biometrics: $result');
      return result;
    } catch (e) {
      debugPrint('Get available biometrics error: $e');
      return [];
    }
  }

  // Authenticate with biometrics
  Future<bool> authenticate() async {
    try {
      debugPrint('Checking biometric availability...');
      final isAvailable = await isBiometricAvailable();
      debugPrint('Biometric available: $isAvailable');

      if (!isAvailable) {
        debugPrint('Biometric authentication not available.');
        return false;
      }

      debugPrint('Starting authentication...');
      final result = await _localAuth.authenticate(
        localizedReason: 'Authenticate to access your coffee tracker',
        options: const AuthenticationOptions(
          biometricOnly: true,
          useErrorDialogs: true,
          stickyAuth: true,
        ),
      );

      debugPrint('Authentication result: $result');
      return result;
    } catch (e) {
      debugPrint('Authentication error: $e');
      return false;
    }
  }

  // Check if the device supports biometric authentication
  Future<bool> isDeviceSupported() async {
    try {
      return await _localAuth.isDeviceSupported();
    } catch (e) {
      debugPrint('Device support check error: $e');
      return false;
    }
  }

  // Utility methods to check specific biometric types
  Future<bool> hasFingerprint() async {
    final biometrics = await getAvailableBiometrics();
    final result = biometrics.contains(BiometricType.fingerprint);
    debugPrint('Fingerprint available: $result');
    return result;
  }

  // Is face recognition available
  Future<bool> hasFace() async {
    final biometrics = await getAvailableBiometrics();
    final result = biometrics.contains(BiometricType.face);
    debugPrint('Face recognition available: $result');
    return result;
  }

  // Is iris recognition available
  Future<bool> hasIris() async {
    final biometrics = await getAvailableBiometrics();
    final result = biometrics.contains(BiometricType.iris);
    debugPrint('Iris recognition available: $result');
    return result;
  }
}
