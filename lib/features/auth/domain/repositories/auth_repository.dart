// lib/features/auth/domain/repositories/auth_repository.dart
import 'package:coffee_tracker/core/error/failures.dart';
import 'package:coffee_tracker/features/auth/data/models/auth_response_model.dart';
import 'package:dartz/dartz.dart';

abstract class AuthRepository {
  Future<Either<Failure, Map<String, dynamic>>> requestOtp(String mobile);
  Future<Either<Failure, String>> verifyOtp(String mobile, String otp);
  Future<Either<Failure, String>> isAuthenticated();
  Future<Either<Failure, void>> logout();
  Future<Either<Failure, AuthTokens>> biometricLogin();
  Future<Either<Failure, void>> enableBiometricLogin(
    String mobile,
    String token,
    String refreshToken,
  );
}
