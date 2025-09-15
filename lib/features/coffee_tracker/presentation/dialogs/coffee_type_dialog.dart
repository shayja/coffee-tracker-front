import 'package:coffee_tracker/features/coffee_tracker/domain/entities/coffee_type.dart';
import 'package:coffee_tracker/features/coffee_tracker/presentation/widgets/coffee_type_selection_list.dart';
import 'package:flutter/material.dart';

Future<String?> showCoffeeTypeSelectionDialog({
  required BuildContext context,
  required List<CoffeeType> coffeeTypes,
  int? initialSelectedKey,
}) async {
  int? selectedKey = initialSelectedKey;

  return showDialog<String>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: const Text('Select Coffee Type'),
      content: SizedBox(
        width: double.maxFinite,
        height: 300,
        child: CoffeeTypeSelectionList(
          coffeeTypes: coffeeTypes,
          selectedKey: selectedKey,
          onSelectionChanged: (newKey) {
            selectedKey = newKey != null ? newKey as int : null;
          },
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(ctx).pop(null), // cancel
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () =>
              Navigator.of(ctx).pop(selectedKey), // confirm selected key
          child: const Text('OK'),
        ),
      ],
    ),
  );
}
