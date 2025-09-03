// features/user/domain/entities/user.dart
import 'package:equatable/equatable.dart';

class User extends Equatable {
  final String id;
  final String mobile;
  final String? name;
  final String? email;
  final String? avatarUrl;

  const User({
    required this.id,
    required this.mobile,
    this.name,
    this.email,
    this.avatarUrl,
  });

  User copyWith({String? name, String? email, String? avatarUrl}) {
    return User(
      id: id,
      mobile: mobile,
      name: name ?? this.name,
      email: email ?? this.email,
      avatarUrl: avatarUrl ?? this.avatarUrl,
    );
  }

  @override
  List<Object?> get props => [id, mobile, name, email, avatarUrl];

  factory User.fromJson(Map<String, dynamic> json) => User(
    id: json['id'] as String,
    mobile: json['mobile'] as String,
    name: json['name'] as String?,
    email: json['email'] as String?,
    avatarUrl: json['avatar_url'] as String?,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'mobile': mobile,
    'name': name,
    'email': email,
    'avatar_url': avatarUrl,
  };
}
