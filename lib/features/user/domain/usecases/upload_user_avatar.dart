import 'dart:io';

import 'package:coffee_tracker/features/user/domain/repositories/user_repository.dart';

class UploadUserAvatar {
  final UserRepository repository;

  UploadUserAvatar(this.repository);

  Future<String> execute(File filePath) async {
    return repository.uploadAvatar(filePath);
  }
}
