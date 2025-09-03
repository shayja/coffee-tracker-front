import 'package:coffee_tracker/features/user/domain/repositories/user_repository.dart';

class DeleteUserAvatar {
  final UserRepository repository;

  DeleteUserAvatar(this.repository);

  Future<void> execute() async {
    await repository.deleteAvatar();
  }
}
