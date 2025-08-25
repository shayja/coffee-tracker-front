import 'package:equatable/equatable.dart';

abstract class Failure extends Equatable {
  const Failure();

  @override
  List<Object> get props => [];
}

// General failures
// lib/core/error/failures.dart
class ServerFailure extends Failure {
  final String message;
  const ServerFailure({required this.message});

  @override
  String toString() => 'ServerFailure: $message';
}

class AuthFailure extends Failure {
  @override
  String toString() => 'Authentication failed - please login again';
}

class NotAuthenticatedFailure extends Failure {}

class CacheFailure extends Failure {}

class NetworkFailure extends Failure {}

class InvalidInputFailure extends Failure {
  final String message;
  const InvalidInputFailure({required this.message});

  @override
  String toString() => 'InvalidInputFailure: $message';
}

// Biometric-related failures
class BiometricNotAvailableFailure extends Failure {
  @override
  String toString() =>
      'Biometric authentication is not available on this device';
}

class BiometricAuthenticationFailure extends Failure {
  @override
  String toString() => 'Biometric authentication failed';
}

class NoStoredTokenFailure extends Failure {
  @override
  String toString() => 'No stored authentication token';
}

// Local storage failures
class LocalStorageFailure extends Failure {
  @override
  String toString() => 'Local storage operation failed';
}
