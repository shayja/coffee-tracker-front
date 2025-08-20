// lib/features/auth/presentation/bloc/auth_state.dart
//part of 'auth_bloc.dart';

//@immutable
abstract class AuthState {}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class AuthAuthenticated extends AuthState {}

class AuthUnauthenticated extends AuthState {}

class OtpSent extends AuthState {
  final String mobile;

  OtpSent({required this.mobile});
}

class OtpRequestFailed extends AuthState {
  final String message;

  OtpRequestFailed({required this.message});
}

class OtpVerificationFailed extends AuthState {
  final String message;

  OtpVerificationFailed({required this.message});
}

class AuthError extends AuthState {
  final String message;

  AuthError({required this.message});
}
