import 'package:coffee_tracker/features/auth/data/models/auth_response_model.dart';
import 'package:flutter/foundation.dart';
import 'package:local_auth/local_auth.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class BiometricService {
  final LocalAuthentication _localAuth = LocalAuthentication();
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  static const String _biometricAuthKey = 'biometric_auth_enabled';
  static const String _biometricMobileKey = 'biometric_mobile';
  static const String _biometricTokenKey = 'biometric_token';
  static const String _biometricRefreshTokenKey = 'biometric_refresh_token';

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
      debugPrint('Biometric login disabled');
    } catch (e) {
      debugPrint('Error disabling biometric login: $e');
    }
  }

  // Get stored biometric login data
  Future<AuthTokens?> getBiometricLoginData() async {
    try {
      final mobile = await _storage.read(key: _biometricMobileKey);
      final access = await _storage.read(key: _biometricTokenKey);
      final refresh = await _storage.read(key: _biometricRefreshTokenKey);

      if (mobile == null || access == null || refresh == null) {
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
