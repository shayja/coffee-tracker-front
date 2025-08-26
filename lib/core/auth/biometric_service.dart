import 'package:local_auth/local_auth.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class BiometricService {
  final LocalAuthentication _localAuth = LocalAuthentication();
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  static const String _biometricAuthKey = 'biometric_auth_enabled';
  static const String _biometricMobileKey = 'biometric_mobile';
  static const String _biometricTokenKey = 'biometric_token';

  // Check if biometric login is enabled for any user
  Future<bool> isBiometricLoginEnabled() async {
    try {
      final enabled = await _storage.read(key: _biometricAuthKey);
      final mobile = await _storage.read(key: _biometricMobileKey);
      final token = await _storage.read(key: _biometricTokenKey);

      return enabled == 'true' && mobile != null && token != null;
    } catch (e) {
      print('Biometric login check error: $e');
      return false;
    }
  }

  // Enable biometric login for a user (call this after successful OTP login)
  Future<void> enableBiometricLogin(String mobile, String token) async {
    try {
      await _storage.write(key: _biometricAuthKey, value: 'true');
      await _storage.write(key: _biometricMobileKey, value: mobile);
      await _storage.write(key: _biometricTokenKey, value: token);
      print('Biometric login enabled for user: $mobile');
    } catch (e) {
      print('Error enabling biometric login: $e');
      rethrow;
    }
  }

  // Disable biometric login
  Future<void> disableBiometricLogin() async {
    try {
      await _storage.delete(key: _biometricAuthKey);
      await _storage.delete(key: _biometricMobileKey);
      await _storage.delete(key: _biometricTokenKey);
      print('Biometric login disabled');
    } catch (e) {
      print('Error disabling biometric login: $e');
    }
  }

  // Get stored biometric login data
  Future<Map<String, String>?> getBiometricLoginData() async {
    try {
      final mobile = await _storage.read(key: _biometricMobileKey);
      final token = await _storage.read(key: _biometricTokenKey);

      if (mobile == null || token == null) {
        return null;
      }

      return {'mobile': mobile, 'token': token};
    } catch (e) {
      print('Error getting biometric data: $e');
      return null;
    }
  }

  // Authenticate with biometrics and return stored token
  Future<String?> authenticateAndGetToken() async {
    try {
      print('Checking biometric availability...');
      final isAvailable = await isBiometricAvailable();

      if (!isAvailable) {
        print('Biometric authentication not available.');
        return null;
      }

      print('Starting biometric authentication...');
      final result = await _localAuth.authenticate(
        localizedReason: 'Authenticate to access your coffee tracker',
        options: const AuthenticationOptions(
          biometricOnly: true,
          useErrorDialogs: true,
          stickyAuth: true,
        ),
      );

      if (result) {
        print('Biometric authentication successful');
        final data = await getBiometricLoginData();
        return data?['token'];
      } else {
        print('Biometric authentication failed');
        return null;
      }
    } catch (e) {
      print('Biometric authentication error: $e');
      return null;
    }
  }

  // Check if biometric hardware is available
  Future<bool> isBiometricAvailable() async {
    try {
      final result = await _localAuth.canCheckBiometrics;
      print('Biometric availability: $result');
      return result;
    } catch (e) {
      print('Biometric availability check error: $e');
      return false;
    }
  }

  // Get list of available biometric types
  Future<List<BiometricType>> getAvailableBiometrics() async {
    try {
      final result = await _localAuth.getAvailableBiometrics();
      print('Available biometrics: $result');
      return result;
    } catch (e) {
      print('Get available biometrics error: $e');
      return [];
    }
  }

  // Authenticate with biometrics
  Future<bool> authenticate() async {
    try {
      print('Checking biometric availability...');
      final isAvailable = await isBiometricAvailable();
      print('Biometric available: $isAvailable');

      if (!isAvailable) {
        print('Biometric authentication not available.');
        return false;
      }

      print('Starting authentication...');
      final result = await _localAuth.authenticate(
        localizedReason: 'Authenticate to access your coffee tracker',
        options: const AuthenticationOptions(
          biometricOnly: true,
          useErrorDialogs: true,
          stickyAuth: true,
        ),
      );

      print('Authentication result: $result');
      return result;
    } catch (e) {
      print('Authentication error: $e');
      return false;
    }
  }

  // Check if the device supports biometric authentication
  Future<bool> isDeviceSupported() async {
    try {
      return await _localAuth.isDeviceSupported();
    } catch (e) {
      print('Device support check error: $e');
      return false;
    }
  }

  // Utility methods to check specific biometric types
  Future<bool> hasFingerprint() async {
    final biometrics = await getAvailableBiometrics();
    final result = biometrics.contains(BiometricType.fingerprint);
    print('Fingerprint available: $result');
    return result;
  }

  // Is face recognition available
  Future<bool> hasFace() async {
    final biometrics = await getAvailableBiometrics();
    final result = biometrics.contains(BiometricType.face);
    print('Face recognition available: $result');
    return result;
  }

  // Is iris recognition available
  Future<bool> hasIris() async {
    final biometrics = await getAvailableBiometrics();
    final result = biometrics.contains(BiometricType.iris);
    print('Iris recognition available: $result');
    return result;
  }
}
