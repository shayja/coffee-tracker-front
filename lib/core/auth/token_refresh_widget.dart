// lib/core/auth/token_refresh_widget.dart
import 'package:coffee_tracker/core/auth/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class TokenRefreshWidget extends StatelessWidget {
  final Widget child;
  final WidgetBuilder? loginBuilder;

  const TokenRefreshWidget({required this.child, this.loginBuilder, super.key});

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context, listen: false);

    return FutureBuilder<bool>(
      future: authService.isAuthenticated(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError || !(snapshot.data ?? false)) {
          return loginBuilder?.call(context) ??
              const Center(child: Text('Please login'));
        }

        return child;
      },
    );
  }
}
