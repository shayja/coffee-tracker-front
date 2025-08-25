// lib/features/auth/domain/usecases/verify_otp.dart
import 'package:coffee_tracker/core/error/failures.dart';
import 'package:coffee_tracker/core/usecases/usecase.dart';
import 'package:coffee_tracker/features/auth/domain/repositories/auth_repository.dart';
import 'package:dartz/dartz.dart';

class VerifyOtpParams {
  final String mobile;
  final String otp;

  VerifyOtpParams({required this.mobile, required this.otp});
}

class VerifyOtp implements UseCase<String, VerifyOtpParams> {
  final AuthRepository repository;

  VerifyOtp(this.repository);

  @override
  Future<Either<Failure, String>> call(VerifyOtpParams params) async {
    return await repository.verifyOtp(params.mobile, params.otp);
  }
}
