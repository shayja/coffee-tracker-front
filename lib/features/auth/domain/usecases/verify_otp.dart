// lib/features/auth/domain/usecases/verify_otp.dart
import 'package:coffee_tracker/core/error/failures.dart';
import 'package:coffee_tracker/features/auth/domain/repositories/auth_repository.dart';
import 'package:dartz/dartz.dart';

class VerifyOtpParams {
  final String mobile;
  final String otp;

  VerifyOtpParams({required this.mobile, required this.otp});
}

class VerifyOtp {
  final AuthRepository repository;

  VerifyOtp(this.repository);

  Future<Either<Failure, bool>> call(VerifyOtpParams params) async {
    return await repository.verifyOtp(params.mobile, params.otp);
  }
}
