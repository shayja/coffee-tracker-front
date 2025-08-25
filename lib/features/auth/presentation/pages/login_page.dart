// lib/features/auth/presentation/pages/login_page.dart
import 'package:coffee_tracker/core/auth/biometric_service.dart';
import 'package:coffee_tracker/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:coffee_tracker/features/auth/presentation/bloc/auth_event.dart';
import 'package:coffee_tracker/features/auth/presentation/bloc/auth_state.dart';
import 'package:coffee_tracker/injection_container.dart' as di;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:local_auth/local_auth.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _mobileController = TextEditingController();
  final _otpController = TextEditingController();
  bool _otpSent = false;
  bool _biometricAvailable = false;

  @override
  void initState() {
    super.initState();
    // Check if user is already authenticated
    context.read<AuthBloc>().add(CheckAuthenticationEvent());
    // Check if biometric is available
    _checkBiometricAvailability();
  }

  Future<void> _checkBiometricAvailability() async {
    final biometricService = di.sl<BiometricService>();
    final isAvailable = await biometricService.isBiometricAvailable();
    setState(() {
      _biometricAvailable = isAvailable;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
      body: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthAuthenticated) {
            // Navigate to main app
            Navigator.pushReplacementNamed(context, '/coffee-tracker');
          } else if (state is OtpSent) {
            setState(() {
              _otpSent = true;
            });
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('OTP sent successfully')),
            );
          } else if (state is OtpRequestFailed) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(state.message)));
          } else if (state is OtpVerificationFailed) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(state.message)));
          } else if (state is InvalidMobileNumber) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
                duration: const Duration(seconds: 5),
              ),
            );
          } else if (state is AuthBiometricNotAvailable) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Biometric authentication not available'),
                backgroundColor: Colors.orange,
              ),
            );
          } else if (state is AuthError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Biometric Login Section (shown only when available and before OTP is sent)
              if (_biometricAvailable && !_otpSent) ...[
                _buildBiometricSection(),
                const SizedBox(height: 30),
                const Divider(),
                const SizedBox(height: 20),
                const Text(
                  'Or login with OTP',
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
                const SizedBox(height: 20),
              ],

              // Mobile Number Input
              TextField(
                controller: _mobileController,
                decoration: const InputDecoration(
                  labelText: 'Mobile Number',
                  prefixText: '+',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.phone),
                ),
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 20),

              // OTP Input (shown only after OTP is sent)
              if (_otpSent)
                TextField(
                  controller: _otpController,
                  decoration: const InputDecoration(
                    labelText: 'OTP',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.lock),
                  ),
                  keyboardType: TextInputType.number,
                  obscureText: true,
                ),

              if (_otpSent) const SizedBox(height: 20),

              // Action Button
              BlocBuilder<AuthBloc, AuthState>(
                builder: (context, state) {
                  if (state is AuthLoading) {
                    return const CircularProgressIndicator();
                  }

                  return ElevatedButton(
                    onPressed: () {
                      if (!_otpSent) {
                        if (_mobileController.text.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Please enter mobile number'),
                              backgroundColor: Colors.red,
                            ),
                          );
                          return;
                        }
                        context.read<AuthBloc>().add(
                          RequestOtpEvent(_mobileController.text),
                        );
                      } else {
                        if (_otpController.text.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Please enter OTP'),
                              backgroundColor: Colors.red,
                            ),
                          );
                          return;
                        }
                        context.read<AuthBloc>().add(
                          VerifyOtpEvent(
                            mobile: _mobileController.text,
                            otp: _otpController.text,
                          ),
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 50),
                    ),
                    child: Text(_otpSent ? 'Verify OTP' : 'Send OTP'),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBiometricSection() {
    return Column(
      children: [
        FutureBuilder<List<BiometricType>>(
          future: di.sl<BiometricService>().getAvailableBiometrics(),
          builder: (context, snapshot) {
            if (snapshot.hasData && snapshot.data!.isNotEmpty) {
              final biometricType = snapshot.data!.first;
              return Column(
                children: [
                  IconButton(
                    iconSize: 50,
                    icon: _getBiometricIcon(biometricType),
                    onPressed: () {
                      context.read<AuthBloc>().add(BiometricLoginEvent());
                    },
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Login with ${_getBiometricName(biometricType)}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              );
            }
            return const SizedBox.shrink();
          },
        ),
        const SizedBox(height: 10),
        BlocBuilder<AuthBloc, AuthState>(
          builder: (context, state) {
            if (state is AuthLoading) {
              return const CircularProgressIndicator();
            }
            return const SizedBox.shrink();
          },
        ),
      ],
    );
  }

  Icon _getBiometricIcon(BiometricType type) {
    switch (type) {
      case BiometricType.face:
        return const Icon(Icons.face, size: 50);
      case BiometricType.iris:
        return const Icon(Icons.remove_red_eye, size: 50);
      case BiometricType.fingerprint:
      default:
        return const Icon(Icons.fingerprint, size: 50);
    }
  }

  String _getBiometricName(BiometricType type) {
    switch (type) {
      case BiometricType.face:
        return 'Face ID';
      case BiometricType.iris:
        return 'Iris Scan';
      case BiometricType.fingerprint:
      default:
        return 'Fingerprint';
    }
  }

  @override
  void dispose() {
    _mobileController.dispose();
    _otpController.dispose();
    super.dispose();
  }
}
