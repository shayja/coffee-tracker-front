// lib/features/auth/data/models/user_model.dart

import 'package:coffee_tracker/features/auth/domain/entities/user.dart';

class UserModel extends User {
  UserModel({required super.id, required super.mobile});

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(id: json['id'], mobile: json['mobile']);
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'mobile': mobile};
  }
}
