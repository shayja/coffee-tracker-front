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
import 'package:flutter_bloc/flutter_bloc.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final RequestOtp requestOtp;
  final VerifyOtp verifyOtp;
  final IsAuthenticated isAuthenticated;
  final Logout logout;
  final BiometricLogin biometricLogin;
  //final EnableBiometricLogin enableBiometricLogin;

  AuthBloc({
    required this.requestOtp,
    required this.verifyOtp,
    required this.isAuthenticated,
    required this.logout,
    required this.biometricLogin,
    //required this.enableBiometricLogin,
  }) : super(AuthInitial()) {
    on<RequestOtpEvent>(_onRequestOtp);
    on<VerifyOtpEvent>(_onVerifyOtp);
    on<CheckAuthenticationEvent>(_onCheckAuthentication);
    on<LogoutEvent>(_onLogout);
    on<BiometricLoginEvent>(_onBiometricLogin);
    //on<EnableBiometricLoginEvent>(_onEnableBiometricLogin);
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
      (token) async {
        // Emit the authenticated state first
        emit(NavigateToHome(token: token));

        // // Then enable biometric login in the background without affecting the state
        // // Use a delayed future to avoid state changes during UI build
        // Future.delayed(Duration.zero, () async {
        //   try {
        //     final enableResult = await enableBiometricLogin(
        //       EnableBiometricLoginParams(mobile: event.mobile, token: token),
        //     );

        //     enableResult.fold(
        //       (failure) {
        //         print('Failed to auto-enable biometric login: $failure');
        //         // Don't emit state here as we're already authenticated
        //       },
        //       (_) {
        //         print('Biometric login enabled automatically');
        //         // You could optionally emit a different state here if needed,
        //         // but be careful about state changes after authentication
        //       },
        //     );
        //   } catch (e) {
        //     print('Exception in auto-enable biometric login: $e');
        //   }
        // });
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
          emit(NavigateToHome(token: token));
        },
      );
    } catch (e) {
      print('Exception in _onBiometricLogin: $e');
      emit(AuthError(message: 'Unexpected error during biometric login'));
    }
  }

  /*
  Future<void> _onEnableBiometricLogin(
    EnableBiometricLoginEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());

    try {
      print('Enabling biometric login for user: ${event.mobile}');

      final result = await enableBiometricLogin(
        EnableBiometricLoginParams(mobile: event.mobile, token: event.token),
      );

      result.fold(
        (failure) {
          print('Biometric enable failed: $failure');
          emit(
            BiometricEnableFailed(
              message: _getBiometricEnableErrorMessage(failure),
            ),
          );
        },
        (_) {
          print('Biometric login enabled successfully');
          emit(
            BiometricEnabled(message: 'Biometric login enabled successfully'),
          );
        },
      );
    } catch (e) {
      print('Unexpected error enabling biometric login: $e');
      emit(
        BiometricEnableFailed(
          message: 'Failed to enable biometric login. Please try again.',
        ),
      );
    }
  }
*/
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
      print('Error checking biometric status: $e');
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
