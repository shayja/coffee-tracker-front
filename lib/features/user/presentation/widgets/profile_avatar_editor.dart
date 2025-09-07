import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:photo_view/photo_view.dart';

typedef AvatarUploadCallback = Future<void> Function(File croppedFile);

class ProfileAvatarEditor extends StatefulWidget {
  final String? avatarUrl;
  final AvatarUploadCallback onAvatarChanged;

  const ProfileAvatarEditor({
    Key? key,
    required this.onAvatarChanged,
    this.avatarUrl,
  }) : super(key: key);

  @override
  State<ProfileAvatarEditor> createState() => _ProfileAvatarEditorState();
}

class _ProfileAvatarEditorState extends State<ProfileAvatarEditor> {
  File? _pickedImage;

  Future<void> _pickImage() async {
    final pickedFile = await ImagePicker().pickImage(
      source: ImageSource.gallery,
    );
    if (pickedFile == null) return;

    File imageFile = File(pickedFile.path);

    final shouldContinue = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Preview Image"),
        content: SizedBox(
          width: 300,
          height: 300,
          child: PhotoView(
            imageProvider: FileImage(imageFile),
            minScale: PhotoViewComputedScale.contained,
            maxScale: PhotoViewComputedScale.covered * 2.0,
          ),
        ),
        actions: [
          TextButton(
            child: const Text('Cancel'),
            onPressed: () => Navigator.of(ctx).pop(false),
          ),
          ElevatedButton(
            child: const Text('Crop'),
            onPressed: () => Navigator.of(ctx).pop(true),
          ),
        ],
      ),
    );

    if (shouldContinue != true) return;

    final croppedFile = await ImageCropper().cropImage(
      sourcePath: imageFile.path,
      aspectRatio: const CropAspectRatio(ratioX: 1, ratioY: 1),
      uiSettings: [
        AndroidUiSettings(
          toolbarTitle: 'Crop Avatar',
          toolbarColor: Colors.deepOrange,
          toolbarWidgetColor: Colors.white,
          lockAspectRatio: true,
        ),
        IOSUiSettings(
          title: 'Crop Avatar',
          aspectRatioLockEnabled: true,
          aspectRatioPickerButtonHidden: true,
        ),
      ],
    );

    if (croppedFile != null) {
      setState(() => _pickedImage = File(croppedFile.path));
      await widget.onAvatarChanged(_pickedImage!);
    }
  }

  @override
  Widget build(BuildContext context) {
    final imageProvider = _pickedImage != null
        ? FileImage(_pickedImage!)
        : (widget.avatarUrl != null
              ? NetworkImage(widget.avatarUrl!)
              : const AssetImage('assets/images/avatar_placeholder.png')
                    as ImageProvider);

    return GestureDetector(
      onTap: _pickImage,
      child: CircleAvatar(radius: 50, backgroundImage: imageProvider),
    );
  }
}
