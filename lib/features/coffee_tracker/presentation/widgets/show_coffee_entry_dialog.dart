// lib/features/coffee_tracker/presentation/widgets/show_coffee_entry_dialog.dart

import 'package:coffee_tracker/features/coffee_tracker/domain/entities/kv_type.dart';
import 'package:coffee_tracker/features/coffee_tracker/presentation/widgets/coffee_entry_data.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// A unified dialog for adding or editing a coffee entry.
///
/// If [entry] is provided, the dialog is in "edit" mode and pre-populates
/// with the entry's data. If [entry] is null, the dialog is in "add" mode.
Future<bool?> showCoffeeEntryDialog({
  required BuildContext context,
  required List<KvType> coffeeTypes,
  required List<KvType> sizes,
  CoffeeEntryData? entry,
  required void Function(
    String newDescription,
    DateTime newTimestamp,
    int? coffeeTypeKey,
    int? sizeKey,
  )
  onConfirm,
}) {
  final isEditMode = entry != null;
  final descriptionController = TextEditingController(
    text: entry?.description ?? '',
  );
  DateTime selectedDateTime = entry?.dateTime ?? DateTime.now();
  int? selectedCoffeeTypeKey = entry?.coffeeTypeKey;
  int? selectedSizeKey = entry?.sizeKey;

  // For Coffee Type
  if (selectedCoffeeTypeKey != null &&
      !coffeeTypes.any((type) => type.key == selectedCoffeeTypeKey)) {
    selectedCoffeeTypeKey = null;
  }
  // For Size
  if (selectedSizeKey != null &&
      !sizes.any((size) => size.key == selectedSizeKey)) {
    selectedSizeKey = null;
  }

  return showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    builder: (sheetContext) {
      return Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(sheetContext).viewInsets.bottom,
          left: 16,
          right: 16,
          top: 20,
        ),
        child: StatefulBuilder(
          builder: (context, setState) {
            return SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    isEditMode ? 'Edit Coffee Entry' : 'Add Coffee Entry',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: descriptionController,
                    decoration: const InputDecoration(
                      labelText: 'Description',
                      prefixIcon: Icon(Icons.note),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          icon: const Icon(Icons.calendar_today),
                          label: Text(
                            DateFormat('yyyy-MM-dd').format(selectedDateTime),
                          ),
                          onPressed: () async {
                            final date = await showDatePicker(
                              context: sheetContext,
                              initialDate: selectedDateTime,
                              firstDate: DateTime(2020),
                              lastDate: DateTime.now(),
                            );
                            if (date != null) {
                              setState(() {
                                selectedDateTime = DateTime(
                                  date.year,
                                  date.month,
                                  date.day,
                                  selectedDateTime.hour,
                                  selectedDateTime.minute,
                                );
                              });
                            }
                          },
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: OutlinedButton.icon(
                          icon: const Icon(Icons.access_time),
                          label: Text(
                            TimeOfDay.fromDateTime(
                              selectedDateTime,
                            ).format(context),
                          ),
                          onPressed: () async {
                            final time = await showTimePicker(
                              context: sheetContext,
                              initialTime: TimeOfDay.fromDateTime(
                                selectedDateTime,
                              ),
                            );
                            if (time != null) {
                              setState(() {
                                selectedDateTime = DateTime(
                                  selectedDateTime.year,
                                  selectedDateTime.month,
                                  selectedDateTime.day,
                                  time.hour,
                                  time.minute,
                                );
                              });
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<int?>(
                    initialValue: selectedCoffeeTypeKey,
                    decoration: const InputDecoration(
                      labelText: 'Coffee Type',
                      prefixIcon: Icon(Icons.local_cafe),
                      border: OutlineInputBorder(),
                    ),
                    items: [
                      const DropdownMenuItem<int?>(
                        value: null,
                        child: Text('None'),
                      ),
                      ...coffeeTypes.map(
                        (type) => DropdownMenuItem<int>(
                          value: type.key,
                          child: Text(type.value),
                        ),
                      ),
                    ],
                    onChanged: (int? value) {
                      setState(() {
                        selectedCoffeeTypeKey = value;
                      });
                    },
                  ),

                  const SizedBox(height: 16),
                  DropdownButtonFormField<int?>(
                    initialValue: selectedSizeKey,
                    decoration: const InputDecoration(
                      labelText: 'Size',
                      prefixIcon: Icon(Icons.format_size),
                      border: OutlineInputBorder(),
                    ),
                    items: [
                      const DropdownMenuItem<int?>(
                        value: null,
                        child: Text('None'),
                      ),
                      ...sizes.map(
                        (size) => DropdownMenuItem<int>(
                          value: size.key,
                          child: Text(size.value),
                        ),
                      ),
                    ],
                    onChanged: (int? value) {
                      setState(() {
                        selectedSizeKey = value;
                      });
                    },
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.of(sheetContext).pop(false),
                        child: const Text('Cancel'),
                      ),
                      const SizedBox(width: 12),
                      ElevatedButton(
                        onPressed: () {
                          onConfirm(
                            descriptionController.text.trim(),
                            selectedDateTime,
                            selectedCoffeeTypeKey,
                            selectedSizeKey,
                          );
                          Navigator.of(sheetContext).pop(true);
                        },
                        child: Text(isEditMode ? 'Save' : 'Add'),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        ),
      );
    },
  );
}
