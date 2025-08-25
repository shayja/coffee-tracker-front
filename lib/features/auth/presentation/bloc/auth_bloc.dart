// lib/features/auth/presentation/bloc/auth_bloc.dart

import 'package:coffee_tracker/core/error/failures.dart';
import 'package:coffee_tracker/core/usecases/usecase.dart';
import 'package:coffee_tracker/features/auth/domain/usecases/biometric_login.dart';
import 'package:coffee_tracker/features/auth/domain/usecases/is_authenticated.dart';
import 'package:coffee_tracker/features/auth/domain/usecases/logout.dart';
import 'package:coffee_tracker/features/auth/domain/usecases/request_otp.dart';
import 'package:coffee_tracker/features/auth/domain/usecases/verify_otp.dart';
import 'package:coffee_tracker/features/auth/presentation/bloc/auth_event.dart';
import 'package:coffee_tracker/features/auth/presentation/bloc/auth_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final RequestOtp requestOtp;
  final VerifyOtp verifyOtp;
  final IsAuthenticated isAuthenticated;
  final Logout logout;
  final BiometricLogin biometricLogin;

  AuthBloc({
    required this.requestOtp,
    required this.verifyOtp,
    required this.isAuthenticated,
    required this.logout,
    required this.biometricLogin,
  }) : super(AuthInitial()) {
    on<RequestOtpEvent>(_onRequestOtp);
    on<VerifyOtpEvent>(_onVerifyOtp);
    on<CheckAuthenticationEvent>(_onCheckAuthentication);
    on<LogoutEvent>(_onLogout);
    on<BiometricLoginEvent>(_onBiometricLogin);
  }

  Future<void> _onRequestOtp(
    RequestOtpEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    final result = await requestOtp(event.mobile);
    result.fold(
      (failure) =>
          emit(OtpRequestFailed(message: 'Network error. Please try again.')),
      (response) {
        if (response['success'] == true) {
          emit(OtpSent(mobile: event.mobile));
        } else {
          // Check if it's a 404 error (mobile not found)
          if (response['statusCode'] == 404) {
            emit(InvalidMobileNumber(message: response['message']));
          } else {
            emit(OtpRequestFailed(message: response['message']));
          }
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
      (failure) {
        if (failure is NetworkFailure) {
          emit(OtpRequestFailed(message: 'Network error. Please try again.'));
        } else {
          emit(
            OtpVerificationFailed(
              message: 'OTP verification failed. Please try again.',
            ),
          );
        }
      },
      (token) {
        emit(AuthAuthenticated(token: token)); // Use the returned token
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
      (token) => token.isNotEmpty
          ? emit(AuthAuthenticated(token: token))
          : emit(AuthUnauthenticated()),
    );
  }

  // Update the _onLogout method in AuthBloc
  Future<void> _onLogout(LogoutEvent event, Emitter<AuthState> emit) async {
    emit(AuthLoading());

    final result = await logout(NoParams());

    result.fold(
      (failure) {
        // Even if logout fails, we should transition to unauthenticated state
        emit(AuthUnauthenticated());
      },
      (_) {
        emit(AuthUnauthenticated());
      },
    );
  }

  Future<void> _onBiometricLogin(
    BiometricLoginEvent event,
    Emitter<AuthState> emit,
  ) async {
    print('_onBiometricLogin started');
    emit(AuthLoading());

    try {
      print('Calling biometricLogin use case...');
      final result = await biometricLogin(NoParams());
      print('biometricLogin result: $result');

      result.fold(
        (failure) {
          print('Biometric login failed: $failure');
          if (failure is BiometricNotAvailableFailure) {
            emit(AuthBiometricNotAvailable());
          } else if (failure is NoStoredTokenFailure) {
            emit(AuthUnauthenticated());
          } else if (failure is BiometricAuthenticationFailure) {
            emit(AuthError(message: 'Biometric authentication failed'));
          } else if (failure is LocalStorageFailure) {
            emit(AuthError(message: 'Local storage error'));
          } else {
            emit(AuthError(message: 'Unexpected error: ${failure.toString()}'));
          }
        },
        (token) {
          print('Biometric login successful! Token: $token');
          emit(AuthAuthenticated(token: token));
        },
      );
    } catch (e) {
      print('Exception in _onBiometricLogin: $e');
      emit(AuthError(message: 'Unexpected error during biometric login'));
    }
  }
}
