// lib/features/coffee_tracker/presentation/widgets/show_coffee_entry_dialog.dart

import 'package:coffee_tracker/features/coffee_tracker/domain/entities/coffee_type.dart';
import 'package:coffee_tracker/features/coffee_tracker/presentation/widgets/coffee_entry_data.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// A unified dialog for adding or editing a coffee entry.
///
/// If [entry] is provided, the dialog is in "edit" mode and pre-populates
/// with the entry's data. If [entry] is null, the dialog is in "add" mode.
Future<bool?> showCoffeeEntryDialog({
  required BuildContext context,
  required List<CoffeeType> coffeeTypes,
  CoffeeEntryData? entry,
  required void Function(
    String newDescription,
    DateTime newTimestamp,
    int? coffeeTypeKey,
  )
  onConfirm,
}) {
  final isEditMode = entry != null;
  final descriptionController = TextEditingController(
    text: entry?.description ?? '',
  );
  DateTime selectedDateTime = entry?.dateTime ?? DateTime.now();
  int? selectedCoffeeTypeKey = entry?.coffeeTypeKey;

  return showDialog<bool>(
    context: context,
    builder: (dialogContext) {
      return StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: Text(isEditMode ? 'Edit Coffee Entry' : 'Add Coffee Entry'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: descriptionController,
                    decoration: const InputDecoration(labelText: 'Description'),
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.calendar_today),
                    label: Text(
                      'Date: ${DateFormat('yyyy-MM-dd').format(selectedDateTime)}',
                    ),
                    onPressed: () async {
                      final pickedDate = await showDatePicker(
                        context: context,
                        initialDate: selectedDateTime,
                        firstDate: DateTime(2020),
                        lastDate: DateTime.now(),
                      );
                      if (pickedDate != null) {
                        setState(() {
                          selectedDateTime = DateTime(
                            pickedDate.year,
                            pickedDate.month,
                            pickedDate.day,
                            selectedDateTime.hour,
                            selectedDateTime.minute,
                          );
                        });
                      }
                    },
                  ),
                  const SizedBox(height: 8),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.access_time),
                    label: Text(
                      'Time: ${TimeOfDay.fromDateTime(selectedDateTime).format(context)}',
                    ),
                    onPressed: () async {
                      final pickedTime = await showTimePicker(
                        context: context,
                        initialTime: TimeOfDay.fromDateTime(selectedDateTime),
                      );
                      if (pickedTime != null) {
                        setState(() {
                          selectedDateTime = DateTime(
                            selectedDateTime.year,
                            selectedDateTime.month,
                            selectedDateTime.day,
                            pickedTime.hour,
                            pickedTime.minute,
                          );
                        });
                      }
                    },
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<int?>(
                    initialValue: selectedCoffeeTypeKey,
                    decoration: const InputDecoration(
                      labelText: 'Coffee Type (optional)',
                      border: OutlineInputBorder(),
                    ),
                    items: [
                      const DropdownMenuItem<int?>(
                        value: null,
                        child: Text('None'),
                      ),
                      ...coffeeTypes.map(
                        (ct) => DropdownMenuItem<int>(
                          value: ct.key,
                          child: Text(ct.value),
                        ),
                      ),
                    ],
                    onChanged: (value) {
                      setState(() {
                        selectedCoffeeTypeKey = value;
                      });
                    },
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(dialogContext).pop(false),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () {
                  onConfirm(
                    descriptionController.text.trim(),
                    selectedDateTime,
                    selectedCoffeeTypeKey,
                  );
                  Navigator.of(dialogContext).pop(true);
                },
                child: Text(isEditMode ? 'Save' : 'Add'),
              ),
            ],
          );
        },
      );
    },
  );
}
