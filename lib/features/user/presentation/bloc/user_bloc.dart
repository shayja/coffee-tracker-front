// lib/features/user/presentation/bloc/user_block.dart
import 'package:coffee_tracker/features/user/domain/entities/user.dart';
import 'package:coffee_tracker/features/user/domain/repositories/user_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'user_event.dart';
import 'user_state.dart';

class UserBloc extends Bloc<UserEvent, UserState> {
  final UserRepository userRepository;

  UserBloc({required this.userRepository}) : super(UserInitial()) {
    on<LoadUserProfile>(_onLoadUserProfile);
    on<UpdateUserProfile>(_onUpdateUserProfile);
    on<UploadUserAvatar>(_onUploadUserAvatar);
    on<DeleteUserAvatar>(_onDeleteUserAvatar);
  }

  Future<void> _onLoadUserProfile(
    LoadUserProfile event,
    Emitter<UserState> emit,
  ) async {
    emit(UserLoading());
    try {
      final user = await userRepository.getProfile();
      emit(UserLoaded(user));
    } catch (e) {
      emit(UserError(e.toString()));
    }
  }

  Future<void> _onUpdateUserProfile(
    UpdateUserProfile event,
    Emitter<UserState> emit,
  ) async {
    emit(UserLoading());
    try {
      final currentUser = await userRepository.getProfile();

      final updatedUser = User(
        id: currentUser.id,
        mobile: currentUser.mobile,
        name: event.name,
        email: event.email,
        avatarUrl: currentUser.avatarUrl,
      );

      await userRepository.updateProfile(updatedUser);
      emit(UserLoaded(updatedUser));
    } catch (e) {
      emit(UserError(e.toString()));
    }
  }

  Future<void> _onUploadUserAvatar(
    UploadUserAvatar event,
    Emitter<UserState> emit,
  ) async {
    emit(UserLoading());
    try {
      final currentUser = await userRepository.getProfile();
      final url = await userRepository.uploadAvatar(event.avatarFile);

      final updatedUser = User(
        id: currentUser.id,
        mobile: currentUser.mobile,
        name: currentUser.name,
        email: currentUser.email,
        avatarUrl: url,
      );

      await userRepository.updateProfile(updatedUser);
      emit(UserLoaded(updatedUser));
    } catch (e) {
      emit(UserError(e.toString()));
    }
  }

  Future<void> _onDeleteUserAvatar(
    DeleteUserAvatar event,
    Emitter<UserState> emit,
  ) async {
    emit(UserLoading());
    try {
      final currentUser = await userRepository.getProfile();

      await userRepository.deleteAvatar();

      final updatedUser = User(
        id: currentUser.id,
        mobile: currentUser.mobile,
        name: currentUser.name,
        email: currentUser.email,
        avatarUrl: null,
      );

      await userRepository.updateProfile(updatedUser);
      emit(UserLoaded(updatedUser));
    } catch (e) {
      emit(UserError(e.toString()));
    }
  }
}
