// lib/features/auth/presentation/pages/login_page.dart
import 'package:coffee_tracker/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:coffee_tracker/features/auth/presentation/bloc/auth_event.dart';
import 'package:coffee_tracker/features/auth/presentation/bloc/auth_state.dart';
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
  String _currentMobile = '';

  @override
  void initState() {
    super.initState();
    // Check if user is already authenticated
    context.read<AuthBloc>().add(CheckAuthenticationEvent());
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
              _currentMobile = state.mobile;
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
            // Stay on OTP page, don't navigate away
          } else if (state is InvalidMobileNumber) {
            // Show a more prominent error for invalid mobile
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
              TextField(
                controller: _mobileController,
                decoration: const InputDecoration(
                  labelText: 'Mobile Number',
                  prefixText: '+',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 20),
              if (_otpSent)
                TextField(
                  controller: _otpController,
                  decoration: const InputDecoration(
                    labelText: 'OTP',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                ),
              const SizedBox(height: 20),
              BlocBuilder<AuthBloc, AuthState>(
                builder: (context, state) {
                  if (state is AuthLoading) {
                    return const CircularProgressIndicator();
                  }

                  return ElevatedButton(
                    onPressed: () {
                      if (!_otpSent) {
                        context.read<AuthBloc>().add(
                          RequestOtpEvent(_mobileController.text),
                        );
                      } else {
                        context.read<AuthBloc>().add(
                          VerifyOtpEvent(
                            mobile: _mobileController.text,
                            otp: _otpController.text,
                          ),
                        );
                      }
                    },
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

  @override
  void dispose() {
    _mobileController.dispose();
    _otpController.dispose();
    super.dispose();
  }

  
}
