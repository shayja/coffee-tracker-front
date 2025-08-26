import 'package:coffee_tracker/core/error/failures.dart';
import 'package:coffee_tracker/core/usecases/usecase.dart';
import 'package:coffee_tracker/features/auth/domain/repositories/auth_repository.dart';
import 'package:dartz/dartz.dart';

class EnableBiometricLoginParams {
  final String mobile;
  final String token;

  EnableBiometricLoginParams({required this.mobile, required this.token});
}

class EnableBiometricLogin
    implements UseCase<void, EnableBiometricLoginParams> {
  final AuthRepository repository;

  EnableBiometricLogin(this.repository);

  @override
  Future<Either<Failure, void>> call(EnableBiometricLoginParams params) async {
    return await repository.enableBiometricLogin(params.mobile, params.token);
  }
}
