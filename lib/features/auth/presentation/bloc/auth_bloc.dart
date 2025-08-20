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
  }

  Future<void> _onRequestOtp(
    RequestOtpEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    final result = await requestOtp(event.mobile);
    result.fold(
      (failure) => emit(AuthError(message: 'Failed to send OTP')),
      (success) => emit(OtpSent(mobile: event.mobile)),
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
      (failure) => emit(AuthError(message: 'Invalid OTP')),
      (success) => emit(AuthAuthenticated()),
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
}
