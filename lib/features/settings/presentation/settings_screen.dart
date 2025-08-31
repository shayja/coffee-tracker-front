// file: lib/features/settings/presentation/settings_screen.dart
import 'package:coffee_tracker/core/auth/auth_service.dart';
import 'package:coffee_tracker/core/auth/biometric_service.dart';
import 'package:coffee_tracker/features/auth/presentation/pages/login_page.dart';
import 'package:coffee_tracker/features/settings/domain/entities/setting_type.dart';
import 'package:coffee_tracker/features/settings/presentation/bloc/settings_bloc.dart';
import 'package:coffee_tracker/features/settings/presentation/bloc/settings_event.dart';
import 'package:coffee_tracker/features/settings/presentation/bloc/settings_state.dart';
import 'package:coffee_tracker/features/statistics/presentation/bloc/statistics_bloc.dart';
import 'package:coffee_tracker/features/statistics/presentation/pages/statistics_page.dart';
import 'package:coffee_tracker/injection_container.dart' as di;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => di.sl<SettingsBloc>()..add(LoadSettings()),
      child: const _SettingsScreenContent(),
    );
  }
}

class _SettingsScreenContent extends StatefulWidget {
  const _SettingsScreenContent();

  @override
  State<_SettingsScreenContent> createState() => _SettingsScreenContentState();
}

class _SettingsScreenContentState extends State<_SettingsScreenContent> {
  bool _biometricAvailable = false;
  String? _persistentMobile;

  @override
  void initState() {
    super.initState();
    _loadBiometricStatus();
  }

  Future<void> _loadBiometricStatus() async {
    final biometricService = di.sl<BiometricService>();
    final available = await biometricService.isBiometricAvailable();
    final mobile = await biometricService.getPersistentMobile();

    if (mounted) {
      setState(() {
        _biometricAvailable = available;
        _persistentMobile = mobile;
      });
    }
  }

  Future<void> _toggleBiometric(bool value, bool currentBackendValue) async {
    final biometricService = di.sl<BiometricService>();
    final authService = di.sl<AuthService>();

    if (value) {
      // Get current tokens from AuthService
      final accessToken = await authService.getValidAccessToken();
      final refreshToken = await authService.storage.read(key: 'refresh_token');

      if (accessToken == null || refreshToken == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Please login first to enable biometric authentication',
            ),
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
            content: Text(
              'Unable to determine user mobile number. Please logout and login again.',
            ),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      // Authenticate with fingerprint/face before enabling
      final success = await biometricService.authenticate();
      if (success) {
        await biometricService.enableBiometricLogin(
          mobile,
          accessToken,
          refreshToken,
        );
        setState(() {
          _persistentMobile = mobile; // Update the displayed mobile
        });

        // Update backend setting
        context.read<SettingsBloc>().add(
          UpdateSettingEvent(
            settingId: SettingType.biometricEnabled.id,
            value: true,
          ),
        );

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Biometric login enabled successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } else {
      await biometricService.disableBiometricLogin();

      // Update backend setting
      context.read<SettingsBloc>().add(
        UpdateSettingEvent(
          settingId: SettingType.biometricEnabled.id,
          value: false,
        ),
      );

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
      body: BlocConsumer<SettingsBloc, SettingsState>(
        listener: (context, state) {
          if (state is SettingsError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Error: ${state.message}'),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is SettingsLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is SettingsError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
                  const SizedBox(height: 16),
                  Text('Failed to load settings'),
                  const SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: () =>
                        context.read<SettingsBloc>().add(LoadSettings()),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          final settings = state is SettingsLoaded
              ? state.settings
              : state is SettingsUpdating
              ? state.settings
              : null;

          if (settings == null) {
            return const Center(child: Text('No settings available'));
          }

          final isUpdating = state is SettingsUpdating;

          return ListView(
            children: [
              // Biometric Login Section
              if (_biometricAvailable) ...[
                SwitchListTile(
                  secondary:
                      isUpdating &&
                          state.updatingSettingId ==
                              SettingType.biometricEnabled.id
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.fingerprint),
                  title: const Text("Biometric Login"),
                  subtitle: Text(
                    settings.biometricEnabled
                        ? "Biometric login is enabled"
                        : "Enable fingerprint/face login for faster access",
                  ),
                  value: settings.biometricEnabled,
                  onChanged:
                      isUpdating &&
                          state.updatingSettingId ==
                              SettingType.biometricEnabled.id
                      ? null
                      : (value) =>
                            _toggleBiometric(value, settings.biometricEnabled),
                ),
                if (_persistentMobile != null)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Text(
                      "Configured for: $_persistentMobile",
                      style: Theme.of(
                        context,
                      ).textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
                    ),
                  ),
              ] else ...[
                ListTile(
                  leading: Icon(Icons.fingerprint, color: Colors.grey[400]),
                  title: const Text("Biometric Login"),
                  subtitle: const Text(
                    "Biometric hardware not available on this device",
                  ),
                  enabled: false,
                ),
              ],
              const Divider(),
              SwitchListTile(
                secondary:
                    isUpdating &&
                        state.updatingSettingId == SettingType.darkMode.id
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.dark_mode),
                title: const Text("Dark Mode"),
                subtitle: Text(
                  settings.darkMode
                      ? "Dark mode is enabled"
                      : "Switch to dark theme for comfortable viewing",
                ),
                value: settings.darkMode,
                onChanged:
                    isUpdating &&
                        state.updatingSettingId == SettingType.darkMode.id
                    ? null
                    : (value) {
                        context.read<SettingsBloc>().add(
                          UpdateSettingEvent(
                            settingId: SettingType.darkMode.id,
                            value: value,
                          ),
                        );
                      },
              ),
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
                      MaterialPageRoute(
                        builder: (context) => const LoginPage(),
                      ),
                      (route) => false,
                    );
                  }
                },
              ),
            ],
          );
        },
      ),
    );
  }
}
