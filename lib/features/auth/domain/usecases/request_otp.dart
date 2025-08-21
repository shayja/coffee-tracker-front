// lib/features/auth/domain/usecases/request_otp.dart
import 'package:coffee_tracker/core/error/failures.dart';
import 'package:coffee_tracker/core/usecases/usecase.dart';
import 'package:coffee_tracker/features/auth/domain/repositories/auth_repository.dart';
import 'package:dartz/dartz.dart';

class RequestOtp implements UseCase<Map<String, dynamic>, String> {
  final AuthRepository repository;

  RequestOtp(this.repository);

  @override
  Future<Either<Failure, Map<String, dynamic>>> call(String mobile) async {
    return await repository.requestOtp(mobile);
  }
}
