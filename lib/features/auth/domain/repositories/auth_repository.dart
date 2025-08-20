// lib/features/auth/domain/repositories/auth_repository.dart
import 'package:coffee_tracker/core/error/failures.dart';
import 'package:dartz/dartz.dart';

abstract class AuthRepository {
  Future<Either<Failure, bool>> requestOtp(String mobile);
  Future<Either<Failure, bool>> verifyOtp(String mobile, String otp);
  Future<Either<Failure, bool>> isAuthenticated();
  Future<Either<Failure, void>> logout();
}
