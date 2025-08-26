import 'package:local_auth/local_auth.dart';

class BiometricService {
  final LocalAuthentication _localAuth = LocalAuthentication();

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
