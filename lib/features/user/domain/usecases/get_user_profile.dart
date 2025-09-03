// features/user/domain/usecases/get_user_profile.dart

import 'package:coffee_tracker/features/user/domain/entities/user.dart';
import 'package:coffee_tracker/features/user/domain/repositories/user_repository.dart';

class GetUserProfile {
  final UserRepository repository;

  GetUserProfile(this.repository);

  Future<User> execute() async {
    return repository.getProfile();
  }
}
