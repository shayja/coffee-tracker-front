import 'package:coffee_tracker/core/error/failures.dart';
import 'package:coffee_tracker/core/usecases/usecase.dart';
import 'package:coffee_tracker/features/auth/data/models/auth_response_model.dart';
import 'package:coffee_tracker/features/auth/domain/repositories/auth_repository.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter/foundation.dart';

class BiometricLogin implements UseCase<AuthTokens, NoParams> {
  final AuthRepository repository;

  BiometricLogin(this.repository);

  @override
  Future<Either<Failure, AuthTokens>> call(NoParams params) async {
    debugPrint('BiometricLogin use case called'); // DEBUG
    try {
      final result = await repository.biometricLogin();
      debugPrint('Repository returned: $result'); // DEBUG
      return result;
    } catch (e) {
      debugPrint('Error in BiometricLogin use case: $e'); // DEBUG
      return Left(ServerFailure(message: 'Biometric login failed: $e'));
    }
  }
}
