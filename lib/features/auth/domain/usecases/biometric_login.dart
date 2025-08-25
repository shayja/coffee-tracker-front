import 'package:coffee_tracker/core/error/failures.dart';
import 'package:coffee_tracker/core/usecases/usecase.dart';
import 'package:coffee_tracker/features/auth/domain/repositories/auth_repository.dart';
import 'package:dartz/dartz.dart';

class BiometricLogin implements UseCase<String, NoParams> {
  final AuthRepository repository;

  BiometricLogin(this.repository);

  @override
  Future<Either<Failure, String>> call(NoParams params) async {
    print('BiometricLogin use case called'); // DEBUG
    try {
      final result = await repository.biometricLogin();
      print('Repository returned: $result'); // DEBUG
      return result;
    } catch (e) {
      print('Error in BiometricLogin use case: $e'); // DEBUG
      return Left(ServerFailure(message: 'Biometric login failed: $e'));
    }
  }
}
