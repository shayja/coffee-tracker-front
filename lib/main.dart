// coffee_tracker/lib/main.dart
import 'package:coffee_tracker/features/coffee_tracker/presentation/bloc/coffee_tracker_event.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'injection_container.dart' as di;
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
    return MaterialApp(
      title: 'Coffee Tracker ☕',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.brown),
        useMaterial3: true,
      ),
      home: BlocProvider(
        create: (_) =>
            di.sl<CoffeeTrackerBloc>()..add(LoadDailyCoffeeLog(DateTime.now())),
        child: const CoffeeTrackerPage(),
      ),
    );
  }
}
