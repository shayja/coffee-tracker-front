// lib/features/user/data/repositories/user_repository_impl.dart
import 'dart:io';
import 'package:coffee_tracker/features/user/data/datasources/user_remote_data_source.dart';
import 'package:coffee_tracker/features/user/domain/entities/user.dart';
import 'package:coffee_tracker/features/user/domain/repositories/user_repository.dart';

class UserRepositoryImpl implements UserRepository {
  final UserRemoteDataSource remoteDataSource;

  UserRepositoryImpl({required this.remoteDataSource});

  @override
  Future<User> getProfile() => remoteDataSource.getProfile();

  @override
  Future<void> updateProfile(User user) => remoteDataSource.updateProfile(user);

  @override
  Future<String> uploadAvatar(File file) => remoteDataSource.uploadAvatar(file);

  @override
  Future<void> deleteAvatar() => remoteDataSource.deleteAvatar();
}
