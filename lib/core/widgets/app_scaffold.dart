// lib/core/widgets/app_scaffold.dart
import 'package:coffee_tracker/features/user/presentation/bloc/user_bloc.dart';
import 'package:coffee_tracker/features/user/presentation/bloc/user_event.dart';
import 'package:coffee_tracker/injection_container.dart' as di;
import 'package:flutter/material.dart';
import 'package:coffee_tracker/features/settings/presentation/settings_screen.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AppScaffold extends StatelessWidget {
  final AppBar? appBar;
  final Widget body;

  const AppScaffold({super.key, this.appBar, required this.body});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBar != null
          ? AppBar(
              title: appBar!.title,
              leading: appBar!.leading,
              actions: [
                ...?appBar!.actions,
                IconButton(
                  icon: const Icon(Icons.settings),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => BlocProvider(
                          create: (_) =>
                              di.sl<UserBloc>()..add(LoadUserProfile()),
                          child: const SettingsScreen(),
                        ),
                      ),
                    );
                  },
                ),
              ],
            )
          : null,
      body: body,
    );
  }
}
