// lib/core/widgets/add_button.dart

import 'package:flutter/material.dart';

typedef ShowDialogFn<T> = Future<bool?> Function(BuildContext context, T data);

class AddButton<T> extends StatelessWidget {
  final T initialData;
  final ShowDialogFn<T> showDialogFn;
  final void Function(T data) onAdd;

  const AddButton({
    super.key,
    required this.initialData,
    required this.showDialogFn,
    required this.onAdd,
  });

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: 20,
      backgroundColor: Theme.of(context).primaryColor,
      child: IconButton(
        icon: const Icon(Icons.add, color: Colors.white, size: 20),
        onPressed: () async {
          T data = initialData;
          final confirmed = await showDialogFn(context, data);
          if (context.mounted && confirmed == true) {
            onAdd(data);
          }
        },
      ),
    );
  }
}
