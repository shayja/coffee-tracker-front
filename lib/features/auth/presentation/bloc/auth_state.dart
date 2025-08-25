// lib/features/auth/presentation/bloc/auth_state.dart
import 'package:equatable/equatable.dart';

abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object> get props => [];
}

class AuthInitial extends AuthState {
  const AuthInitial();
}

class AuthLoading extends AuthState {
  const AuthLoading();
}

class AuthAuthenticated extends AuthState {
  final String token;

  const AuthAuthenticated({required this.token});

  @override
  List<Object> get props => [token];
}

class AuthUnauthenticated extends AuthState {
  const AuthUnauthenticated();
}

class OtpSent extends AuthState {
  final String mobile;

  const OtpSent({required this.mobile});

  @override
  List<Object> get props => [mobile];
}

class OtpRequestFailed extends AuthState {
  final String message;

  const OtpRequestFailed({required this.message});

  @override
  List<Object> get props => [message];
}

class OtpVerificationFailed extends AuthState {
  final String message;

  const OtpVerificationFailed({required this.message});

  @override
  List<Object> get props => [message];
}

class AuthError extends AuthState {
  final String message;

  const AuthError({required this.message});

  @override
  List<Object> get props => [message];
}

class InvalidMobileNumber extends AuthState {
  final String message;

  const InvalidMobileNumber({required this.message});

  @override
  List<Object> get props => [message];
}

class AuthBiometricNotAvailable extends AuthState {
  const AuthBiometricNotAvailable();
}
