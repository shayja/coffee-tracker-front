// lib/features/auth/presentation/bloc/auth_event.dart
//part of 'auth_bloc.dart';

//@immutable
abstract class AuthEvent {}

class RequestOtpEvent extends AuthEvent {
  final String mobile;

  RequestOtpEvent(this.mobile);
}

class VerifyOtpEvent extends AuthEvent {
  final String mobile;
  final String otp;

  VerifyOtpEvent({required this.mobile, required this.otp});
}

class CheckAuthenticationEvent extends AuthEvent {}

class LogoutEvent extends AuthEvent {}

class BiometricLoginEvent extends AuthEvent {
  final String mobile;

  BiometricLoginEvent({required this.mobile});
}

class EnableBiometricLoginEvent extends AuthEvent {
  final String mobile;
  final String token;
  final String refreshToken;

  EnableBiometricLoginEvent({
    required this.mobile,
    required this.token,
    required this.refreshToken,
  });
}

class CheckBiometricStatusEvent extends AuthEvent {}
