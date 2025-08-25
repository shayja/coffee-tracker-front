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
    print('loginWithBiometrics called in repository'); // DEBUG

    // 1. First check if biometrics are available
    final isAvailable = await biometricService.isBiometricAvailable();
    if (!isAvailable) {
      print('Biometrics not available'); // DEBUG
      return Left(BiometricNotAvailableFailure());
    }

    // 2. Authenticate with biometrics
    print('Authenticating with biometrics...'); // DEBUG
    final authSuccess = await biometricService.authenticate();
    if (!authSuccess) {
      print('Biometric authentication failed'); // DEBUG
      return Left(BiometricAuthenticationFailure());
    }

    // 3. Retrieve stored token
    print('Retrieving stored token...'); // DEBUG
    try {
      final token = await authService.getAccessToken();
      if (token == null) {
        print('No stored token found'); // DEBUG
        return Left(NoStoredTokenFailure());
      }

      print('Token retrieved successfully: $token'); // DEBUG
      return Right(token);
    } catch (e) {
      print('Error retrieving token: $e'); // DEBUG
      return Left(LocalStorageFailure());
    }
  }
}
