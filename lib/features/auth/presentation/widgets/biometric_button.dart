// file: lib/features/auth/presentation/widgets/biometric_button.dart
import 'package:coffee_tracker/core/auth/biometric_service.dart';
import 'package:coffee_tracker/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:coffee_tracker/features/auth/presentation/bloc/auth_event.dart';
import 'package:coffee_tracker/features/auth/presentation/bloc/auth_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:local_auth/local_auth.dart';

class BiometricButton extends StatefulWidget {
  final BiometricService biometricService;
  final String mobile;
  final VoidCallback? onPressed;

  const BiometricButton({
    super.key,
    required this.biometricService,
    required this.mobile,
    this.onPressed,
  });

  @override
  State<BiometricButton> createState() => _BiometricButtonState();
}

class _BiometricButtonState extends State<BiometricButton> {
  bool _isAuthenticating = false;
  late final AuthBloc _authBloc;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _authBloc = context.read<AuthBloc>();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      bloc: _authBloc,
      listener: (context, state) {
        if (!mounted) return;

        if (state is BiometricLoginSuccess ||
            state is AuthError ||
            state is AuthBiometricNotAvailable) {
          setState(() => _isAuthenticating = false);
        }

        if (state is AuthError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('❌ ${state.message}'),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 2),
            ),
          );
        }
      },
      child: FutureBuilder<bool>(
        future: widget.biometricService.isDeviceSupported(),
        builder: (context, supportedSnapshot) {
          if (supportedSnapshot.connectionState != ConnectionState.done ||
              !(supportedSnapshot.data ?? false)) {
            return const SizedBox.shrink();
          }

          return FutureBuilder<List<BiometricType>>(
            future: widget.biometricService.getAvailableBiometrics(),
            builder: (context, biometricsSnapshot) {
              if (biometricsSnapshot.connectionState != ConnectionState.done ||
                  biometricsSnapshot.data == null ||
                  biometricsSnapshot.data!.isEmpty) {
                return const SizedBox.shrink();
              }

              final icon = _getBiometricIcon(biometricsSnapshot.data!.first);

              return IconButton(
                icon: _isAuthenticating
                    ? const CircularProgressIndicator()
                    : icon,
                tooltip: 'Authenticate with biometrics',
                onPressed: _isAuthenticating ? null : _onPressedHandler,
              );
            },
          );
        },
      ),
    );
  }

  void _onPressedHandler() {
    if (widget.onPressed != null) {
      setState(() => _isAuthenticating = true);
      widget.onPressed!();
    } else {
      _authenticate();
    }
  }

  Future<void> _authenticate() async {
    setState(() => _isAuthenticating = true);
    try {
      _authBloc.add(BiometricLoginEvent(mobile: widget.mobile));
    } catch (e) {
      if (mounted) {
        setState(() => _isAuthenticating = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
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
