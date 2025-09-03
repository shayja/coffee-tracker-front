import 'package:coffee_tracker/features/user/domain/entities/user.dart';
import 'package:coffee_tracker/features/user/domain/repositories/user_repository.dart';

class UpdateUserProfile {
  final UserRepository repository;

  UpdateUserProfile(this.repository);

  Future<void> execute(User user) async {
    await repository.updateProfile(user);
  }
}
