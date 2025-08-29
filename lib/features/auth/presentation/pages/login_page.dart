// file:lib/features/auth/presentation/pages/login_page.dart
import 'package:coffee_tracker/core/auth/biometric_service.dart';
import 'package:coffee_tracker/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:coffee_tracker/features/auth/presentation/bloc/auth_event.dart';
import 'package:coffee_tracker/features/auth/presentation/bloc/auth_state.dart';
import 'package:coffee_tracker/features/auth/presentation/widgets/biometric_button.dart';
import 'package:coffee_tracker/injection_container.dart' as di;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

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
    context.read<AuthBloc>().add(CheckAuthenticationEvent());
    _checkBiometricStatus();
  }

  Future<void> _checkBiometricStatus() async {
    final biometricService = di.sl<BiometricService>();
    final isAvailable = await biometricService.isBiometricAvailable();
    final hasAnyBiometricUser = await biometricService.hasAnyBiometricUser();
    final persistentMobile = await biometricService.getPersistentMobile();

    if (!mounted) return;

    setState(() {
      _biometricAvailable = isAvailable;
      _biometricEnabled = hasAnyBiometricUser;
      // Pre-fill mobile if we have a persistent mobile from previous biometric setup
      if (persistentMobile != null && _mobileController.text.isEmpty) {
        _mobileController.text = persistentMobile;
        _currentMobile = persistentMobile;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
      body: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (!mounted) return;
          if (state is NavigateToHome) {
            WidgetsBinding.instance.addPostFrameCallback((_) async {
              if (!mounted) return;
              Navigator.pushReplacementNamed(context, '/coffee-tracker');
            });
          } else if (state is BiometricLoginSuccess) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              Navigator.pushReplacementNamed(context, '/coffee-tracker');
            });
          } else if (state is OtpSent) {
            setState(() => _otpSent = true);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('OTP sent successfully')),
            );
          } else if (state is OtpRequestFailed ||
              state is OtpVerificationFailed) {
            final message = state is OtpRequestFailed
                ? state.message
                : (state as OtpVerificationFailed).message;
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(message)));
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
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.coffee, size: 80, color: Colors.brown),
              const SizedBox(height: 20),
              const Text(
                'Coffee Tracker ☕',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 30),

              if (_biometricAvailable && _biometricEnabled) ...[
                BiometricButton(
                  scaffoldContext: context,
                  biometricService: di.sl<BiometricService>(),
                  mobile: _currentMobile?.trim() ?? '',
                ),
                const SizedBox(height: 30),
                const Divider(),
                const SizedBox(height: 20),
                const Text(
                  'Or login with OTP',
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
                const SizedBox(height: 20),
              ],

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
                onChanged: (value) => _currentMobile = value,
              ),
              const SizedBox(height: 20),

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

  void _requestOtp() {
    if (_mobileController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter mobile number'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    context.read<AuthBloc>().add(
      RequestOtpEvent(_mobileController.text.trim()),
    );
  }

  void _verifyOtp() {
    if (_otpController.text.trim().isEmpty) {
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
        mobile: _mobileController.text.trim(),
        otp: _otpController.text.trim(),
      ),
    );
  }

  @override
  void dispose() {
    _mobileController.dispose();
    _otpController.dispose();
    super.dispose();
  }
}
