// lib/features/auth/presentation/bloc/auth_bloc.dart

import 'package:coffee_tracker/core/usecases/usecase.dart';
import 'package:coffee_tracker/features/auth/domain/usecases/is_authenticated.dart';
import 'package:coffee_tracker/features/auth/domain/usecases/request_otp.dart';
import 'package:coffee_tracker/features/auth/domain/usecases/verify_otp.dart';
import 'package:coffee_tracker/features/auth/presentation/bloc/auth_event.dart';
import 'package:coffee_tracker/features/auth/presentation/bloc/auth_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final RequestOtp requestOtp;
  final VerifyOtp verifyOtp;
  final IsAuthenticated isAuthenticated;

  AuthBloc({
    required this.requestOtp,
    required this.verifyOtp,
    required this.isAuthenticated,
  }) : super(AuthInitial()) {
    on<RequestOtpEvent>(_onRequestOtp);
    on<VerifyOtpEvent>(_onVerifyOtp);
    on<CheckAuthenticationEvent>(_onCheckAuthentication);
    on<LogoutEvent>(_onLogout);
  }

  Future<void> _onRequestOtp(
    RequestOtpEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    final result = await requestOtp(event.mobile);
    result.fold(
      (failure) => emit(OtpRequestFailed(message: 'Failed to send OTP')),
      (success) {
        if (success) {
          emit(OtpSent(mobile: event.mobile));
        } else {
          emit(OtpRequestFailed(message: 'Failed to send OTP'));
        }
      },
    );
  }

  Future<void> _onVerifyOtp(
    VerifyOtpEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    final result = await verifyOtp(
      VerifyOtpParams(mobile: event.mobile, otp: event.otp),
    );
    result.fold(
      (failure) => emit(OtpVerificationFailed(message: 'Invalid OTP')),
      (success) {
        if (success) {
          emit(AuthAuthenticated());
        } else {
          emit(OtpVerificationFailed(message: 'Invalid OTP'));
        }
      },
    );
  }

  Future<void> _onCheckAuthentication(
    CheckAuthenticationEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    final result = await isAuthenticated(NoParams());
    result.fold(
      (failure) => emit(AuthUnauthenticated()),
      (isAuthenticated) => isAuthenticated
          ? emit(AuthAuthenticated())
          : emit(AuthUnauthenticated()),
    );
  }

  // Update the _onLogout method in AuthBloc
  Future<void> _onLogout(LogoutEvent event, Emitter<AuthState> emit) async {
    // Call the logout method on AuthService
    // You'll need to inject AuthService into AuthBloc or use a use case
    emit(AuthUnauthenticated());
  }
}
