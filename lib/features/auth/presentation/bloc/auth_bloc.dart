// lib/features/auth/presentation/bloc/auth_bloc.dart

import 'package:coffee_tracker/core/error/failures.dart';
import 'package:coffee_tracker/core/usecases/usecase.dart';
import 'package:coffee_tracker/features/auth/domain/usecases/biometric_login.dart';
import 'package:coffee_tracker/features/auth/domain/usecases/enable_biometric_login.dart';
import 'package:coffee_tracker/features/auth/domain/usecases/is_authenticated.dart';
import 'package:coffee_tracker/features/auth/domain/usecases/logout.dart';
import 'package:coffee_tracker/features/auth/domain/usecases/request_otp.dart';
import 'package:coffee_tracker/features/auth/domain/usecases/verify_otp.dart';
import 'package:coffee_tracker/features/auth/presentation/bloc/auth_event.dart';
import 'package:coffee_tracker/features/auth/presentation/bloc/auth_state.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final RequestOtp requestOtp;
  final VerifyOtp verifyOtp;
  final IsAuthenticated isAuthenticated;
  final Logout logout;
  final BiometricLogin biometricLogin;
  final EnableBiometricLogin enableBiometricLogin;

  AuthBloc({
    required this.requestOtp,
    required this.verifyOtp,
    required this.isAuthenticated,
    required this.logout,
    required this.biometricLogin,
    required this.enableBiometricLogin,
  }) : super(AuthInitial()) {
    on<RequestOtpEvent>(_onRequestOtp);
    on<VerifyOtpEvent>(_onVerifyOtp);
    on<CheckAuthenticationEvent>(_onCheckAuthentication);
    on<LogoutEvent>(_onLogout);
    on<BiometricLoginEvent>(_onBiometricLogin);
    on<EnableBiometricLoginEvent>(_onEnableBiometricLogin);
    //on<CheckBiometricStatusEvent>(_onCheckBiometricStatus);
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
        // OTP verified successfully
        emit(NavigateToHome(token: token, mobile: event.mobile));

        // Emit a state to trigger the biometric dialog in the UI
        //emit(ShowBiometricEnableDialog(mobile: event.mobile, token: token, refreshToken: ''));
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
          ? emit(NavigateToHome(token: token))
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
    debugPrint('_onBiometricLogin started');
    emit(AuthLoading());

    try {
      debugPrint('Calling biometricLogin use case...');
      final result = await biometricLogin(NoParams());
      debugPrint('biometricLogin result: $result');

      result.fold(
        (failure) {
          debugPrint('Biometric login failed: $failure');
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
          debugPrint('Biometric login successful! Token: $token');

          // Emit a special state for the UI to respond
          emit(
            BiometricLoginSuccess(
              mobile: event.mobile,
              token: token.accessToken,
              refreshToken: token.refreshToken,
            ),
          );
        },
      );
    } catch (e) {
      debugPrint('Exception in _onBiometricLogin: $e');
      emit(AuthError(message: 'Unexpected error during biometric login'));
    }
  }

  Future<void> _onEnableBiometricLogin(
    EnableBiometricLoginEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());

    try {
      debugPrint('Enabling biometric login for user: ${event.mobile}');

      final result = await enableBiometricLogin(
        EnableBiometricLoginParams(
          mobile: event.mobile,
          token: event.token,
          refreshToken: event.refreshToken,
        ),
      );

      result.fold(
        (failure) {
          debugPrint('Biometric enable failed: $failure');
          emit(
            BiometricEnableFailed(
              message: _getBiometricEnableErrorMessage(failure),
            ),
          );
        },
        (_) {
          debugPrint('Biometric login enabled successfully');
          emit(
            BiometricEnabled(message: 'Biometric login enabled successfully'),
          );
        },
      );
    } catch (e) {
      debugPrint('Unexpected error enabling biometric login: $e');
      emit(
        BiometricEnableFailed(
          message: 'Failed to enable biometric login. Please try again.',
        ),
      );
    }
  }

  /*
  Future<void> _onCheckBiometricStatus(
    CheckBiometricStatusEvent event,
    Emitter<AuthState> emit,
  ) async {
    try {
      // Check if biometric hardware is available
      final isAvailable = await biometricService.isBiometricAvailable();
      
      // Check if biometric login is already enabled
      final isEnabled = await biometricService.isBiometricLoginEnabled();
      
      emit(BiometricStatusChecked(
        isEnabled: isEnabled,
        isAvailable: isAvailable,
      ));
    } catch (e) {
      debugPrint('Error checking biometric status: $e');
      emit(BiometricStatusChecked(
        isEnabled: false,
        isAvailable: false,
      ));
    }
  }
*/
  String _getBiometricEnableErrorMessage(Failure failure) {
    if (failure is LocalStorageFailure) {
      return 'Failed to save biometric settings. Please check storage permissions.';
    } else if (failure is NetworkFailure) {
      return 'Network error. Please check your connection.';
    } else {
      return 'Failed to enable biometric login. Please try again.';
    }
  }
}
