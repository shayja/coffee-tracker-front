// lib/features/user/presentation/bloc/user_event.dart
import 'dart:io';
import 'package:equatable/equatable.dart';

abstract class UserEvent extends Equatable {
  const UserEvent();

  @override
  List<Object?> get props => [];
}

class LoadUserProfile extends UserEvent {}

class UpdateUserProfile extends UserEvent {
  final String name;
  final String email;

  const UpdateUserProfile({required this.name, required this.email});

  @override
  List<Object?> get props => [name, email];
}

class UploadUserAvatar extends UserEvent {
  final File avatarFile;

  const UploadUserAvatar(this.avatarFile);

  @override
  List<Object?> get props => [avatarFile];
}

class DeleteUserAvatar extends UserEvent {}

