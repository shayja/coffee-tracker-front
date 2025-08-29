// lib/core/widgets/app_scaffold.dart
import 'package:flutter/material.dart';
import 'package:coffee_tracker/features/settings/presentation/settings_screen.dart';

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
                      MaterialPageRoute(builder: (_) => const SettingsScreen()),
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
