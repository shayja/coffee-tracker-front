// lib/features/auth/data/repositories/auth_repository_impl.dart

import 'package:coffee_tracker/core/auth/auth_service.dart';
import 'package:coffee_tracker/core/auth/biometric_service.dart';
import 'package:coffee_tracker/core/error/failures.dart';
import 'package:coffee_tracker/core/network/network_info.dart';
import 'package:coffee_tracker/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:coffee_tracker/features/auth/data/models/auth_response_model.dart';
import 'package:coffee_tracker/features/auth/domain/repositories/auth_repository.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter/foundation.dart';

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
      final token = await authService.getValidAccessToken();
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
  Future<Either<Failure, AuthTokens>> biometricLogin() async {
    try {
      final isEnabled = await biometricService.isBiometricLoginEnabled();
      if (!isEnabled) return Left(BiometricNotEnabledFailure());

      final tokens = await biometricService.authenticateAndGetTokens();
      if (tokens == null) return Left(BiometricAuthenticationFailure());

      debugPrint('[BiometricLogin] Success ✅ Tokens: $tokens');
      return Right(tokens);
    } catch (e) {
      debugPrint('Error in biometric login: $e');
      return Left(LocalStorageFailure());
    }
  }

  // Add this method to enable biometric login after successful OTP verification
  @override
  Future<Either<Failure, void>> enableBiometricLogin(
    String mobile,
    String token,
    String refreshToken,
  ) async {
    try {
      await biometricService.enableBiometricLogin(mobile, token, refreshToken);
      return Right(null);
    } catch (e) {
      return Left(LocalStorageFailure());
    }
  }
}
