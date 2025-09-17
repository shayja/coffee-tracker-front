import 'package:coffee_tracker/features/coffee_tracker/domain/entities/coffee_type.dart';
import 'package:coffee_tracker/features/coffee_tracker/presentation/widgets/coffee_type_selection_list.dart';
import 'package:flutter/material.dart';

Future<String?> showCoffeeTypeSelectionDialog({
  required BuildContext context,
  required List<CoffeeType> coffeeTypes,
  int? initialSelectedKey,
}) async {
  return showDialog<String>(
    context: context,
    builder: (ctx) {
      int? selectedKey = initialSelectedKey; // Local variable to hold the state

      return StatefulBuilder(
        builder: (dialogContext, setState) {
          return AlertDialog(
            title: const Text('Select Coffee Type'),
            content: SizedBox(
              width: double.maxFinite,
              height: 300,
              child: CoffeeTypeSelectionList(
                coffeeTypes: coffeeTypes,
                selectedKey: selectedKey,
                onSelectionChanged: (newKey) {
                  setState(() {
                    selectedKey = newKey != null ? newKey as int : null;
                  });
                },
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(dialogContext).pop(null),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.of(
                  dialogContext,
                ).pop(selectedKey?.toString()), // Return the selected key
                child: const Text('OK'),
              ),
            ],
          );
        },
      );
    },
  );
}
