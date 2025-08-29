// file: lib/features/auth/presentation/widgets/biometric_button.dart
import 'package:coffee_tracker/core/auth/biometric_service.dart';
import 'package:coffee_tracker/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:coffee_tracker/features/auth/presentation/bloc/auth_event.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:local_auth/local_auth.dart';

class BiometricButton extends StatefulWidget {
  final BiometricService biometricService;
  final String mobile;
  final BuildContext scaffoldContext;

  const BiometricButton({
    super.key,
    required this.biometricService,
    required this.mobile,
    required this.scaffoldContext,
  });

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
        if (!snapshot.hasData || !snapshot.data!)
          return const SizedBox.shrink();

        return FutureBuilder<List<BiometricType>>(
          future: widget.biometricService.getAvailableBiometrics(),
          builder: (context, snapshot) {
            if (!snapshot.hasData || snapshot.data!.isEmpty)
              return const SizedBox.shrink();

            return IconButton(
              icon: _isAuthenticating
                  ? const CircularProgressIndicator()
                  : _getBiometricIcon(snapshot.data!.first),
              tooltip: 'Authenticate with biometrics',
              onPressed: _isAuthenticating ? null : _authenticate,
            );
          },
        );
      },
    );
  }

  Future<void> _authenticate() async {
    setState(() => _isAuthenticating = true);

    try {
      final success = await widget.biometricService.authenticate();
      if (success) {
        // Fire Bloc event to trigger LoginPage listener
        widget.scaffoldContext.read<AuthBloc>().add(
          BiometricLoginEvent(mobile: widget.mobile),
        );
      } else {
        ScaffoldMessenger.of(widget.scaffoldContext).showSnackBar(
          const SnackBar(
            content: Text('❌ Authentication failed'),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(widget.scaffoldContext).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
      );
    } finally {
      if (mounted) setState(() => _isAuthenticating = false);
    }
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
