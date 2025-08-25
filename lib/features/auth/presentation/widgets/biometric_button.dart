// file: lib/features/auth/presentation/widgets/biometric_button.dart
import 'package:coffee_tracker/core/auth/biometric_service.dart';
import 'package:coffee_tracker/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:coffee_tracker/features/auth/presentation/bloc/auth_event.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:local_auth/local_auth.dart';

class BiometricButton extends StatefulWidget {
  // Changed to StatefulWidget
  final BiometricService biometricService;

  const BiometricButton({super.key, required this.biometricService});

  @override
  State<BiometricButton> createState() => _BiometricButtonState();
}

class _BiometricButtonState extends State<BiometricButton> {
  bool _isAuthenticating = false;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: widget.biometricService.isDeviceSupported(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator();
        }

        if (snapshot.hasError) {
          return const SizedBox.shrink();
        }

        if (snapshot.hasData && snapshot.data == true) {
          return FutureBuilder<List<BiometricType>>(
            future: widget.biometricService.getAvailableBiometrics(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const CircularProgressIndicator();
              }

              if (snapshot.hasError) {
                return const SizedBox.shrink();
              }

              if (snapshot.hasData && snapshot.data!.isNotEmpty) {
                return IconButton(
                  icon: _isAuthenticating
                      ? const CircularProgressIndicator() // Show loading when authenticating
                      : _getBiometricIcon(snapshot.data!.first),
                  onPressed: _isAuthenticating
                      ? null // Disable button when authenticating
                      : () async {
                          setState(() => _isAuthenticating = true);

                          final success = await widget.biometricService
                              .authenticate();

                          setState(() => _isAuthenticating = false);

                          if (success) {
                            // Show success feedback
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('✅ Authentication successful!'),
                                backgroundColor: Colors.green,
                                duration: Duration(seconds: 2),
                              ),
                            );

                            // Trigger your auth bloc event
                            if (context.mounted) {
                              context.read<AuthBloc>().add(
                                BiometricLoginEvent(),
                              );
                            }
                          } else {
                            // Show error feedback
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('❌ Authentication failed'),
                                  backgroundColor: Colors.red,
                                  duration: Duration(seconds: 2),
                                ),
                              );
                            }
                          }
                        },
                  tooltip: 'Authenticate with biometrics',
                );
              }
              return const SizedBox.shrink();
            },
          );
        }
        return const SizedBox.shrink();
      },
    );
  }

  Icon _getBiometricIcon(BiometricType type) {
    switch (type) {
      case BiometricType.face:
        return const Icon(Icons.face);
      case BiometricType.iris:
        return const Icon(Icons.remove_red_eye);
      case BiometricType.fingerprint:
      default:
        return const Icon(Icons.fingerprint);
    }
  }
}
