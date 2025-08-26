// lib/features/auth/data/repositories/auth_repository_impl.dart

import 'package:coffee_tracker/core/auth/auth_service.dart';
import 'package:coffee_tracker/core/auth/biometric_service.dart';
import 'package:coffee_tracker/core/error/failures.dart';
import 'package:coffee_tracker/core/network/network_info.dart';
import 'package:coffee_tracker/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:coffee_tracker/features/auth/domain/repositories/auth_repository.dart';
import 'package:dartz/dartz.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;
  final NetworkInfo networkInfo;
  final AuthService authService;
  final BiometricService biometricService;

  AuthRepositoryImpl({
    required this.remoteDataSource,
    required this.networkInfo,
    required this.authService,
    required this.biometricService,
  });

  @override
  Future<Either<Failure, Map<String, dynamic>>> requestOtp(
    String mobile,
  ) async {
    if (!await networkInfo.isConnected) {
      return Left(NetworkFailure());
    }

    try {
      final result = await remoteDataSource.requestOtp(mobile);
      return Right(result);
    } catch (e) {
      return Left(ServerFailure(message: 'Failed to request OTP'));
    }
  }

  @override
  Future<Either<Failure, String>> verifyOtp(String mobile, String otp) async {
    if (!await networkInfo.isConnected) {
      return Left(NetworkFailure());
    }

    try {
      final token = await remoteDataSource.verifyOtp(mobile, otp);
      if (token == null) {
        return Left(ServerFailure(message: 'OTP verification failed'));
      }
      return Right(token); // Return the token string
    } catch (e) {
      return Left(ServerFailure(message: 'Failed to verify OTP'));
    }
  }

  @override
  Future<Either<Failure, String>> isAuthenticated() async {
    try {
      final token = await authService.getAccessToken();
      if (token != null && token.isNotEmpty) {
        return Right(token); // Return the token string
      } else {
        return Left(NotAuthenticatedFailure());
      }
    } catch (e) {
      return Left(CacheFailure());
    }
  }

  @override
  Future<Either<Failure, void>> logout() async {
    try {
      // Clear any local authentication data
      await authService.logout();
      return Right(null);
    } catch (e) {
      return Left(CacheFailure());
    }
  }

  @override
  Future<Either<Failure, String>> biometricLogin() async {
    print('Biometric login called in repository');

    try {
      // 1. Check if biometric login is enabled
      final isEnabled = await biometricService.isBiometricLoginEnabled();
      if (!isEnabled) {
        print('Biometric login not enabled');
        return Left(BiometricNotEnabledFailure());
      }

      // 2. Authenticate with biometrics and get stored token
      print('Authenticating with biometrics...');
      final token = await biometricService.authenticateAndGetToken();

      if (token == null) {
        print('Biometric authentication failed or no token found');
        return Left(BiometricAuthenticationFailure());
      }

      // 3. Verify the token is still valid (optional)
      // You could add a check here to see if the token is expired
      // and attempt to refresh it if needed

      print('Biometric login successful!');
      return Right(token);
    } catch (e) {
      print('Error in biometric login: $e');
      return Left(LocalStorageFailure());
    }
  }

  // Add this method to enable biometric login after successful OTP verification
  @override
  Future<Either<Failure, void>> enableBiometricLogin(
    String mobile,
    String token,
  ) async {
    try {
      await biometricService.enableBiometricLogin(mobile, token);
      return Right(null);
    } catch (e) {
      return Left(LocalStorageFailure());
    }
  }
}
