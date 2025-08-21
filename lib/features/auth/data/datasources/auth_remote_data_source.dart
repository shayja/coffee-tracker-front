// lib/features/auth/data/datasources/auth_remote_data_source.dart
import 'package:coffee_tracker/core/auth/auth_service.dart';

abstract class AuthRemoteDataSource {
  Future<Map<String, dynamic>> requestOtp(String mobile);
  Future<bool> verifyOtp(String mobile, String otp);
  Future<bool> isAuthenticated();
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final AuthService authService;

  AuthRemoteDataSourceImpl({required this.authService});

  @override
  Future<Map<String, dynamic>> requestOtp(String mobile) async {
    return await authService.requestOtp(mobile);
  }

  @override
  Future<bool> verifyOtp(String mobile, String otp) async {
    return await authService.verifyOtp(mobile, otp);
  }

  @override
  Future<bool> isAuthenticated() async {
    return await authService.isAuthenticated();
  }
}
