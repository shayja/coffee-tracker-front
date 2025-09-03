// lib/features/user/presentation/bloc/user_state.dart
import 'package:coffee_tracker/features/user/domain/entities/user.dart';
import 'package:equatable/equatable.dart';

abstract class UserState extends Equatable {
  const UserState();

  @override
  List<Object?> get props => [];
}

class UserInitial extends UserState {}

class UserLoading extends UserState {}

class UserLoaded extends UserState {
  final User user;

  const UserLoaded(this.user);

  @override
  List<Object?> get props => [user];
}

class UserAvatarUploaded extends UserState {
  final String avatarUrl;

  const UserAvatarUploaded(this.avatarUrl);

  @override
  List<Object?> get props => [avatarUrl];
}

class UserError extends UserState {
  final String message;

  const UserError(this.message);

  @override
  List<Object?> get props => [message];
}

class UserProfileUpdated extends UserState {
  final User user;

  const UserProfileUpdated(this.user);

  @override
  List<Object?> get props => [user];
}
