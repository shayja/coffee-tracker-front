import 'package:coffee_tracker/core/bloc/app_bloc_observer.dart';
import 'package:coffee_tracker/core/theme/app_theme.dart';
import 'package:coffee_tracker/features/coffee_tracker/presentation/bloc/coffee_tracker_event.dart';
import 'package:coffee_tracker/features/user/presentation/bloc/user_bloc.dart';
import 'package:coffee_tracker/features/user/presentation/bloc/user_event.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'injection_container.dart' as di;

import 'features/auth/presentation/bloc/auth_bloc.dart';
import 'features/auth/presentation/bloc/auth_state.dart';
import 'features/auth/presentation/pages/login_page.dart';
import 'features/coffee_tracker/presentation/bloc/coffee_tracker_bloc.dart';
import 'features/coffee_tracker/presentation/pages/coffee_tracker_page.dart';
import 'features/settings/presentation/bloc/settings_bloc.dart';
import 'features/settings/presentation/bloc/settings_event.dart';
import 'features/settings/presentation/bloc/settings_state.dart';
import 'features/statistics/presentation/bloc/statistics_bloc.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await di.init();
  Bloc.observer = AppBlocObserver();
  runApp(const CoffeeTrackerApp());
}

class CoffeeTrackerApp extends StatelessWidget {
  const CoffeeTrackerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => di.sl<UserBloc>()..add(LoadUserProfile())),
        BlocProvider(create: (_) => di.sl<SettingsBloc>()..add(LoadSettings())),
        BlocProvider(create: (_) => di.sl<AuthBloc>()),
        BlocProvider(create: (_) => di.sl<CoffeeTrackerBloc>()),
        BlocProvider(create: (_) => di.sl<StatisticsBloc>()),
        BlocProvider(
          create: (_) => di.sl<CoffeeTypesBloc>()..add(LoadCoffeeTypes()),
        ),
      ],
      child: BlocBuilder<SettingsBloc, SettingsState>(
        builder: (context, state) {
          bool darkMode = false;

          if (state is SettingsLoaded) {
            darkMode = state.settings.darkMode;
          } else if (state is SettingsUpdating) {
            darkMode = state.settings.darkMode;
          }

          return MaterialApp(
            title: 'Coffee Tracker ☕',
            theme: AppTheme.lightTheme(),
            darkTheme: AppTheme.darkTheme(),
            themeMode: darkMode ? ThemeMode.dark : ThemeMode.light,
            home: BlocBuilder<AuthBloc, AuthState>(
              builder: (context, authState) {
                if (authState is AuthAuthenticated) {
                  return const CoffeeTrackerPage();
                } else {
                  return const LoginPage();
                }
              },
            ),
            routes: {
              '/login': (_) => const LoginPage(),
              '/coffee-tracker': (_) => const CoffeeTrackerPage(),
            },
          );
        },
      ),
    );
  }
}
