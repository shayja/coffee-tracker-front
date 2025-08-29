// file: lib/features/settings/presentation/settings_screen.dart
import 'package:coffee_tracker/core/auth/auth_service.dart';
import 'package:coffee_tracker/core/auth/biometric_service.dart';
import 'package:coffee_tracker/features/auth/presentation/pages/login_page.dart';
import 'package:coffee_tracker/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:coffee_tracker/features/auth/presentation/bloc/auth_event.dart';
import 'package:coffee_tracker/features/auth/presentation/bloc/auth_state.dart';
import 'package:coffee_tracker/features/statistics/presentation/bloc/statistics_bloc.dart';
import 'package:coffee_tracker/features/statistics/presentation/pages/statistics_page.dart';
import 'package:coffee_tracker/injection_container.dart' as di;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _biometricEnabled = false;
  bool _biometricAvailable = false;
  String? _persistentMobile;

  @override
  void initState() {
    super.initState();
    _loadBiometricStatus();
  }

  Future<void> _loadBiometricStatus() async {
    final biometricService = di.sl<BiometricService>();
    final enabled = await biometricService.isBiometricLoginEnabled();
    final available = await biometricService.isBiometricAvailable();
    final mobile = await biometricService.getPersistentMobile();
    
    if (mounted) {
      setState(() {
        _biometricEnabled = enabled;
        _biometricAvailable = available;
        _persistentMobile = mobile;
      });
    }
  }

  Future<void> _toggleBiometric(bool value) async {
    final biometricService = di.sl<BiometricService>();
    final authService = di.sl<AuthService>();
    
    if (value) {
      // Get current tokens from AuthService
      final accessToken = await authService.getValidAccessToken();
      final refreshToken = await authService.storage.read(key: 'refresh_token');
      
      if (accessToken == null || refreshToken == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please login first to enable biometric authentication'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }
      
      // Get mobile number from AuthService (tries multiple sources)
      final mobile = await authService.getCurrentUserMobile();
      
      if (mobile == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Unable to determine user mobile number. Please logout and login again.'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }
      
      // Authenticate with fingerprint/face before enabling
      final success = await biometricService.authenticate();
      if (success) {
        await biometricService.enableBiometricLogin(mobile, accessToken, refreshToken);
        setState(() {
          _biometricEnabled = true;
          _persistentMobile = mobile; // Update the displayed mobile
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Biometric login enabled successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } else {
      await biometricService.disableBiometricLogin();
      setState(() => _biometricEnabled = false);
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Biometric login disabled'),
          backgroundColor: Colors.orange,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("⚙️ Settings")),
      body: ListView(
        children: [
          // Biometric Login Section
          if (_biometricAvailable) ...[
            SwitchListTile(
              secondary: const Icon(Icons.fingerprint),
              title: const Text("Biometric Login"),
              subtitle: Text(_biometricEnabled 
                ? "Biometric login is enabled" 
                : "Enable fingerprint/face login for faster access"),
              value: _biometricEnabled,
              onChanged: _toggleBiometric,
            ),
            if (_persistentMobile != null)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Text(
                  "Configured for: $_persistentMobile",
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey[600],
                  ),
                ),
              ),
          ] else ...[
            ListTile(
              leading: Icon(Icons.fingerprint, color: Colors.grey[400]),
              title: const Text("Biometric Login"),
              subtitle: const Text("Biometric hardware not available on this device"),
              enabled: false,
            ),
          ],
          const Divider(),
          ListTile(
            leading: const Icon(Icons.bar_chart),
            title: const Text("Stats"),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => BlocProvider.value(
                    value: BlocProvider.of<StatisticsBloc>(context),
                    child: const StatisticsPage(),
                  ),
                ),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text("Logout"),
            onTap: () async {
              final shouldLogout = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Logout'),
                  content: const Text('Are you sure you want to logout?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(context, true),
                      child: const Text('Logout'),
                    ),
                  ],
                ),
              );

              if (shouldLogout == true) {
                await di.sl<AuthService>().logout();
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (context) => const LoginPage()),
                  (route) => false,
                );
              }
            },
          ),
        ],
      ),
    );
  }
}
