// file: lib/features/settings/presentation/settings_screen.dart

import 'package:coffee_tracker/core/auth/auth_service.dart';
import 'package:coffee_tracker/core/auth/biometric_service.dart';
import 'package:coffee_tracker/core/utils/snackbar_utils.dart';
import 'package:coffee_tracker/core/widgets/app_drawer.dart';
import 'package:coffee_tracker/features/settings/domain/entities/setting_type.dart';
import 'package:coffee_tracker/features/settings/presentation/bloc/settings_bloc.dart';
import 'package:coffee_tracker/features/settings/presentation/bloc/settings_event.dart';
import 'package:coffee_tracker/features/settings/presentation/bloc/settings_state.dart';
import 'package:coffee_tracker/features/settings/presentation/widgets/logout_dialog.dart';
import 'package:coffee_tracker/features/settings/presentation/widgets/profile_section.dart';
import 'package:coffee_tracker/features/settings/presentation/widgets/settings_tile.dart';
import 'package:coffee_tracker/features/user/presentation/bloc/user_bloc.dart';
import 'package:coffee_tracker/features/user/presentation/bloc/user_event.dart';
import 'package:coffee_tracker/injection_container.dart' as di;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const _SettingsScreenContent();
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

    // load user profile
    context.read<UserBloc>().add(LoadUserProfile());
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
      final accessToken = await authService.getValidAccessToken();
      final refreshToken = await authService.storage.read(key: 'refresh_token');

      if (accessToken == null || refreshToken == null) {
        _showError('Please login first to enable biometric authentication');
        return;
      }

      final mobile = await authService.getCurrentUserMobile();

      if (mobile == null) {
        _showError(
          'Unable to determine user mobile number. Please logout and login again.',
        );
        return;
      }

      final success = await biometricService.authenticate();
      if (success) {
        await biometricService.enableBiometricLogin(
          mobile,
          accessToken,
          refreshToken,
        );
        _handleBiometricEnabled(mobile);
      }
    } else {
      await biometricService.disableBiometricLogin();
      _handleBiometricDisabled();
    }
  }

  void _showError(String message) {
    if (mounted) {
      SnackBarUtils.showError(context, message);
    }
  }

  void _handleBiometricEnabled(String mobile) {
    if (!mounted) return;

    setState(() {
      _persistentMobile = mobile;
    });

    context.read<SettingsBloc>().add(
      UpdateSettingEvent(
        settingId: SettingType.biometricEnabled.id,
        value: true,
      ),
    );

    SnackBarUtils.showSuccess(context, 'Biometric login enabled successfully');
  }

  void _handleBiometricDisabled() {
    if (!mounted) return;

    context.read<SettingsBloc>().add(
      UpdateSettingEvent(
        settingId: SettingType.biometricEnabled.id,
        value: false,
      ),
    );

    SnackBarUtils.showWarning(context, 'Biometric login disabled');
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      drawer: const AppDrawer(),
      appBar: AppBar(
        title: const Text("Settings"),
        elevation: 0,
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu_rounded),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Profile Section
            const ProfileSection(),

            // Settings Content
            BlocConsumer<SettingsBloc, SettingsState>(
              listener: (context, state) {
                if (state is SettingsError) {
                  SnackBarUtils.showError(context, state.message);
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
                        Icon(
                          Icons.error_outline,
                          size: 64,
                          color: Colors.red[300],
                        ),
                        const SizedBox(height: 16),
                        const Text('Failed to load settings'),
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

                return Column(
                  children: [
                    // Security Section
                    SettingsSection(
                      title: 'SECURITY',
                      children: [
                        // Biometric Login
                        if (_biometricAvailable) ...[
                          SettingsSwitchTile(
                            leading: const Icon(Icons.fingerprint),
                            title: 'Biometric Login',
                            subtitle: settings.biometricEnabled
                                ? 'Quick access with fingerprint or face'
                                : 'Enable biometric authentication',
                            value: settings.biometricEnabled,
                            isLoading:
                                isUpdating &&
                                state.updatingSettingId ==
                                    SettingType.biometricEnabled.id,
                            onChanged: (value) => _toggleBiometric(
                              value,
                              settings.biometricEnabled,
                            ),
                          ),
                          if (_persistentMobile != null)
                            Padding(
                              padding: const EdgeInsets.fromLTRB(32, 0, 32, 8),
                              child: Text(
                                'Configured for: $_persistentMobile',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: theme.colorScheme.onSurface.withValues(
                                    alpha: 0.5,
                                  ),
                                ),
                              ),
                            ),
                        ] else
                          SettingsTile(
                            leading: const Icon(Icons.fingerprint),
                            title: 'Biometric Login',
                            subtitle: 'Biometric hardware not available',
                            enabled: false,
                          ),
                      ],
                    ),

                    // Appearance Section
                    SettingsSection(
                      title: 'APPEARANCE',
                      children: [
                        SettingsSwitchTile(
                          leading: const Icon(Icons.dark_mode_rounded),
                          title: 'Dark Mode',
                          subtitle: settings.darkMode
                              ? 'Dark theme is active'
                              : 'Switch to dark theme',
                          value: settings.darkMode,
                          isLoading:
                              isUpdating &&
                              state.updatingSettingId ==
                                  SettingType.darkMode.id,
                          onChanged: (value) {
                            context.read<SettingsBloc>().add(
                              UpdateSettingEvent(
                                settingId: SettingType.darkMode.id,
                                value: value,
                              ),
                            );
                          },
                        ),
                      ],
                    ),

                    // Notifications Section
                    SettingsSection(
                      title: 'NOTIFICATIONS',
                      children: [
                        SettingsSwitchTile(
                          leading: const Icon(Icons.notifications_rounded),
                          title: 'Push Notifications',
                          subtitle: settings.notificationsEnabled
                              ? 'Stay updated with reminders'
                              : 'Enable notifications',
                          value: settings.notificationsEnabled,
                          isLoading:
                              isUpdating &&
                              state.updatingSettingId ==
                                  SettingType.notificationsEnabled.id,
                          onChanged: (value) {
                            context.read<SettingsBloc>().add(
                              UpdateSettingEvent(
                                settingId: SettingType.notificationsEnabled.id,
                                value: value,
                              ),
                            );
                          },
                        ),
                      ],
                    ),

                    // Account Section
                    SettingsSection(
                      title: 'ACCOUNT',
                      children: [
                        SettingsTile(
                          leading: const Icon(Icons.logout_rounded),
                          title: 'Logout',
                          subtitle: 'Sign out from your account',
                          onTap: () => LogoutDialog.show(context),
                        ),
                      ],
                    ),

                    const SizedBox(height: 32),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
