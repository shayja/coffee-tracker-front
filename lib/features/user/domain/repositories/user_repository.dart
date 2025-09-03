// features/user/domain/repositories/user_repository.dart

import 'dart:io';
import 'package:coffee_tracker/features/user/domain/entities/user.dart';

abstract class UserRepository {
  Future<User> getProfile();
  Future<void> updateProfile(User user);
  Future<String> uploadAvatar(File file);
  Future<void> deleteAvatar();
}
