// lib/features/user/presentation/pages/user_profile_page.dart
import 'dart:io';

import 'package:coffee_tracker/features/user/presentation/bloc/user_bloc.dart';
import 'package:coffee_tracker/features/user/presentation/bloc/user_event.dart';
import 'package:coffee_tracker/features/user/presentation/bloc/user_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';

class UserProfilePage extends StatefulWidget {
  const UserProfilePage({super.key});

  @override
  State<UserProfilePage> createState() => _UserProfilePageState();
}

class _UserProfilePageState extends State<UserProfilePage> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  File? _pickedImage;

  @override
  void initState() {
    super.initState();
    context.read<UserBloc>().add(LoadUserProfile());
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final pickedFile = await ImagePicker().pickImage(
      source: ImageSource.gallery,
    );
    if (pickedFile != null) {
      final file = File(pickedFile.path);
      setState(() {
        _pickedImage = file;
      });
      context.read<UserBloc>().add(UploadUserAvatar(file));
    }
  }

  void _saveProfile() {
    final name = _nameController.text.trim();
    final email = _emailController.text.trim();

    context.read<UserBloc>().add(UpdateUserProfile(name: name, email: email));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: BlocConsumer<UserBloc, UserState>(
        listener: (context, state) {
          if (state is UserProfileUpdated) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(const SnackBar(content: Text('Profile updated')));
          } else if (state is UserError) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(state.message)));
          }
        },
        builder: (context, state) {
          if (state is UserLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is UserLoaded) {
            final user = state.user;
            _nameController.text = user.name ?? '';
            _emailController.text = user.email ?? '';

            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  GestureDetector(
                    onTap: _pickImage,
                    child: CircleAvatar(
                      radius: 50,
                      backgroundImage: _pickedImage != null
                          ? FileImage(_pickedImage!)
                          : (user.avatarUrl != null
                                    ? NetworkImage(user.avatarUrl!)
                                    : const AssetImage(
                                        'assets/images/avatar_placeholder.png',
                                      ))
                                as ImageProvider,
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _nameController,
                    decoration: const InputDecoration(labelText: 'Name'),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _emailController,
                    decoration: const InputDecoration(labelText: 'Email'),
                  ),
                  const SizedBox(height: 32),
                  ElevatedButton(
                    onPressed: _saveProfile,
                    child: const Text('Save'),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.redAccent,
                    ),
                    onPressed: () =>
                        context.read<UserBloc>().add(DeleteUserAvatar()),
                    child: const Text('Remove Avatar'),
                  ),
                ],
              ),
            );
          } else if (state is UserError) {
            return Center(child: Text(state.message));
          } else {
            return const SizedBox.shrink();
          }
        },
      ),
    );
  }
}
