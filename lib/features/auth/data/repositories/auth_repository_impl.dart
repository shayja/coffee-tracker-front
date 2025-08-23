// lib/features/auth/data/repositories/auth_repository_impl.dart
import 'package:coffee_tracker/core/auth/auth_service.dart';
import 'package:coffee_tracker/core/error/failures.dart';
import 'package:coffee_tracker/core/network/network_info.dart';
import 'package:coffee_tracker/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:coffee_tracker/features/auth/domain/repositories/auth_repository.dart';
import 'package:dartz/dartz.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;
  final NetworkInfo networkInfo;
  final AuthService authService;

  AuthRepositoryImpl({
    required this.remoteDataSource,
    required this.networkInfo,
    required this.authService,
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
  Future<Either<Failure, bool>> verifyOtp(String mobile, String otp) async {
    if (!await networkInfo.isConnected) {
      return Left(NetworkFailure());
    }

    try {
      final result = await remoteDataSource.verifyOtp(mobile, otp);
      return Right(result);
    } catch (e) {
      return Left(ServerFailure(message: 'Failed to verify OTP'));
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
      // Clear any local authentication data
      await authService.logout();
      return Right(null);
    } catch (e) {
      return Left(CacheFailure());
    }
  }
}
