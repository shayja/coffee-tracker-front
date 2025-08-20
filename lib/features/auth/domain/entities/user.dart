// lib/features/auth/domain/entities/user.dart
class User {
  final String id;
  final String mobile;

  User({required this.id, required this.mobile});

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is User &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          mobile == other.mobile;

  @override
  int get hashCode => id.hashCode ^ mobile.hashCode;
}
