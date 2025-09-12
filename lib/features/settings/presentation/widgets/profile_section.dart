import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:coffee_tracker/features/user/presentation/bloc/user_bloc.dart';
import 'package:coffee_tracker/features/user/presentation/bloc/user_event.dart';
import 'package:coffee_tracker/features/user/presentation/bloc/user_state.dart';
import 'package:coffee_tracker/features/user/presentation/pages/user_profile_page.dart';
import 'package:coffee_tracker/features/user/presentation/widgets/profile_avatar_editor.dart';

class ProfileSection extends StatelessWidget {
  const ProfileSection({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BlocBuilder<UserBloc, UserState>(
      builder: (context, state) {
        if (state is UserLoading) {
          return Container(
            padding: const EdgeInsets.all(32),
            child: const Center(child: CircularProgressIndicator()),
          );
        } else if (state is UserLoaded) {
          final user = state.user;
          return Container(
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  theme.colorScheme.primary.withValues(alpha: 0.1),
                  theme.colorScheme.surface,
                ],
              ),
            ),
            child: Column(
              children: [
                const SizedBox(height: 24),
                // Avatar with elegant shadow
                Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: theme.colorScheme.primary.withValues(alpha: 0.2),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: ProfileAvatarEditor(
                    avatarUrl: user.avatarUrl,
                    onAvatarChanged: (croppedFile) async {
                      context.read<UserBloc>().add(
                        UploadUserAvatar(croppedFile),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 20),
                // User name
                Text(
                  user.name ?? 'Guest User',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 4),
                // User email
                Text(
                  user.email ?? 'No email provided',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                ),
                const SizedBox(height: 16),
                // Edit Profile Button
                FilledButton.tonal(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const UserProfilePage(),
                      ),
                    );
                  },
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.edit_rounded,
                        size: 18,
                        color: theme.colorScheme.primary,
                      ),
                      const SizedBox(width: 8),
                      const Text('Edit Profile'),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          );
        }
        return const SizedBox.shrink();
      },
    );
  }
}
