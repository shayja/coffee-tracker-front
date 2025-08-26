// lib/main.dart
import 'package:coffee_tracker/features/auth/presentation/bloc/auth_state.dart';
import 'package:coffee_tracker/features/statistics/presentation/bloc/statistics_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'injection_container.dart' as di;
import 'features/auth/presentation/bloc/auth_bloc.dart';
import 'features/auth/presentation/pages/login_page.dart';
import 'features/coffee_tracker/presentation/bloc/coffee_tracker_bloc.dart';
import 'features/coffee_tracker/presentation/pages/coffee_tracker_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await di.init();

  runApp(const CoffeeTrackerApp());
}

class CoffeeTrackerApp extends StatelessWidget {
  const CoffeeTrackerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => di.sl<AuthBloc>()),
        BlocProvider(create: (context) => di.sl<CoffeeTrackerBloc>()),
        BlocProvider(create: (context) => di.sl<StatisticsBloc>()),
      ],
      child: MaterialApp(
        title: 'Coffee Tracker ☕',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.brown),
          useMaterial3: true,
        ),
        home: BlocBuilder<AuthBloc, AuthState>(
          builder: (context, state) {
            if (state is AuthAuthenticated) {
              return const CoffeeTrackerPage();
            } else {
              return const LoginPage();
            }
          },
        ),
        routes: {
          '/login': (context) => LoginPage(),
          '/coffee-tracker': (context) => CoffeeTrackerPage(),
        },
      ),
    );
  }
}
