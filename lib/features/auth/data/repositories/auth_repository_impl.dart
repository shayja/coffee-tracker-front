// lib/features/auth/data/repositories/auth_repository_impl.dart
import 'package:coffee_tracker/core/error/failures.dart';
import 'package:coffee_tracker/core/network/network_info.dart';
import 'package:coffee_tracker/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:coffee_tracker/features/auth/domain/repositories/auth_repository.dart';
import 'package:dartz/dartz.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;
  final NetworkInfo networkInfo;

  AuthRepositoryImpl({
    required this.remoteDataSource,
    required this.networkInfo,
  });

  @override
  Future<Either<Failure, bool>> requestOtp(String mobile) async {
    if (!await networkInfo.isConnected) {
      return Left(NetworkFailure());
    }

    try {
      final result = await remoteDataSource.requestOtp(mobile);
      return result
          ? Right(true)
          : Left(ServerFailure(message: 'Error requesting OTP'));
    } catch (e) {
      return Left(
        ServerFailure(message: 'Failed to request OTP: ${e.toString()}'),
      );
    }
  }

  @override
  Future<Either<Failure, bool>> verifyOtp(String mobile, String otp) async {
    if (!await networkInfo.isConnected) {
      return Left(NetworkFailure());
    }
    if (mobile.isEmpty || otp.isEmpty) {
      return Left(
        InvalidInputFailure(message: 'Mobile or OTP cannot be empty'),
      );
    }
    try {
      final result = await remoteDataSource.verifyOtp(mobile, otp);
      return result
          ? Right(true)
          : Left(ServerFailure(message: 'Error verifying OTP'));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> isAuthenticated() async {
    try {
      final result = await remoteDataSource.isAuthenticated();
      return Right(result);
    } catch (e) {
      return Left(CacheFailure());
    }
  }

  @override
  Future<Either<Failure, void>> logout() async {
    try {
      // You might want to add a logout method to your AuthService
      return Right(null);
    } catch (e) {
      return Left(CacheFailure());
    }
  }
}
