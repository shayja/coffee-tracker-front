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
  bool _biometricEnabled = false;
  String? _currentMobile;

  @override
  void initState() {
    super.initState();
    // Check if user is already authenticated
    context.read<AuthBloc>().add(CheckAuthenticationEvent());
    // Check biometric status
    _checkBiometricStatus();
  }

  Future<void> _checkBiometricStatus() async {
    final biometricService = di.sl<BiometricService>();
    final isAvailable = await biometricService.isBiometricAvailable();
    final isEnabled = await biometricService.isBiometricLoginEnabled();

    if (mounted) {
      setState(() {
        _biometricAvailable = isAvailable;
        _biometricEnabled = isEnabled;
      });
    }
  }

  void _showBiometricEnableDialog(String token) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Enable Biometric Login?'),
        content: const Text(
          'Would you like to enable fingerprint/face login for faster access?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Not Now'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              if (_currentMobile != null) {
                context.read<AuthBloc>().add(
                  EnableBiometricLoginEvent(
                    mobile: _currentMobile!,
                    token: token,
                  ),
                );
              }
            },
            child: const Text('Enable'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
      body: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is NavigateToHome) {
            // ← Change this from AuthAuthenticated to NavigateToHome
            // Store the mobile number
            _currentMobile = _mobileController.text;

            // Navigate safely using addPostFrameCallback
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted) {
                Navigator.pushReplacementNamed(context, '/coffee-tracker');
              }
            });
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
          }
        },
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // App Logo/Title
              const Icon(Icons.coffee, size: 80, color: Colors.brown),
              const SizedBox(height: 20),
              const Text(
                'Coffee Tracker ☕',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 30),

              // Biometric Login Section
              if (_biometricAvailable && _biometricEnabled) ...[
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
                  hintText: 'Enter your mobile number',
                ),
                keyboardType: TextInputType.phone,
                onChanged: (value) {
                  // Update current mobile for biometric enablement
                  _currentMobile = value;
                },
              ),
              const SizedBox(height: 20),

              // OTP Input (shown only after OTP is sent)
              if (_otpSent)
                AnimatedSize(
                  duration: const Duration(milliseconds: 300),
                  child: TextField(
                    controller: _otpController,
                    decoration: const InputDecoration(
                      labelText: 'OTP',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.lock),
                      hintText: 'Enter 6-digit OTP',
                    ),
                    keyboardType: TextInputType.number,
                    obscureText: true,
                    maxLength: 6,
                  ),
                ),

              if (_otpSent) const SizedBox(height: 20),

              // Action Button
              BlocBuilder<AuthBloc, AuthState>(
                builder: (context, state) {
                  final isLoading = state is AuthLoading;

                  return ElevatedButton(
                    onPressed: isLoading
                        ? null
                        : () {
                            if (!_otpSent) {
                              _requestOtp();
                            } else {
                              _verifyOtp();
                            }
                          },
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 50),
                      backgroundColor: Colors.brown,
                      foregroundColor: Colors.white,
                    ),
                    child: isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : Text(_otpSent ? 'Verify OTP' : 'Send OTP'),
                  );
                },
              ),

              // Reset OTP button
              if (_otpSent)
                TextButton(
                  onPressed: () {
                    setState(() {
                      _otpSent = false;
                      _otpController.clear();
                    });
                  },
                  child: const Text('Change mobile number'),
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
                    iconSize: 60,
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
                  const SizedBox(height: 5),
                  const Text(
                    'Tap to authenticate',
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              );
            }
            return const SizedBox.shrink();
          },
        ),
      ],
    );
  }

  void _requestOtp() {
    if (_mobileController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter mobile number'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    context.read<AuthBloc>().add(RequestOtpEvent(_mobileController.text));
  }

  void _verifyOtp() {
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
      VerifyOtpEvent(mobile: _mobileController.text, otp: _otpController.text),
    );
  }

  Icon _getBiometricIcon(BiometricType type) {
    switch (type) {
      case BiometricType.face:
        return const Icon(Icons.face, size: 50, color: Colors.brown);
      case BiometricType.iris:
        return const Icon(Icons.remove_red_eye, size: 50, color: Colors.brown);
      case BiometricType.fingerprint:
      default:
        return const Icon(Icons.fingerprint, size: 50, color: Colors.brown);
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
