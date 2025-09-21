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

  return showDialog<bool>(
    context: context,
    barrierDismissible: false,
    builder: (sheetContext) {
      return StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            insetPadding: const EdgeInsets.symmetric(horizontal: 20),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(28),
            ),
            title: Text(isEditMode ? 'Edit Coffee Entry' : 'Add Coffee Entry'),
            content: SingleChildScrollView(
              child: SizedBox(
                width: 360, // fixed width to avoid intrinsic dimension issues
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
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
                            icon: const Icon(Icons.calendar_today, size: 18),
                            label: Text(
                              DateFormat('dd/MM').format(selectedDateTime),
                            ),
                            onPressed: () async {
                              final date = await showDatePicker(
                                context: context,
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
                            icon: const Icon(Icons.access_time, size: 18),
                            label: Text(
                              TimeOfDay.fromDateTime(
                                selectedDateTime,
                              ).format(context),
                            ),
                            onPressed: () async {
                              final time = await showTimePicker(
                                context: context,
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
                    Row(
                      children: [
                        Expanded(
                          child: DropdownButtonFormField<int?>(
                            isDense: true,
                            isExpanded: true,
                            initialValue: selectedCoffeeTypeKey,
                            decoration: const InputDecoration(
                              labelText: 'Type',
                              prefixIcon: Icon(Icons.local_cafe, size: 18),
                              border: OutlineInputBorder(),
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 8,
                              ),
                            ),
                            items: [
                              const DropdownMenuItem<int?>(
                                value: null,
                                child: Text('None'),
                              ),
                              ...coffeeTypes.map(
                                (type) => DropdownMenuItem<int>(
                                  value: type.key,
                                  child: Text(
                                    type.value,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(fontSize: 14),
                                  ),
                                ),
                              ),
                            ],
                            onChanged: (int? value) {
                              setState(() {
                                selectedCoffeeTypeKey = value;
                              });
                            },
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: DropdownButtonFormField<int?>(
                            isDense: true,
                            isExpanded: true,
                            initialValue: selectedSizeKey,
                            decoration: const InputDecoration(
                              labelText: 'Size',
                              prefixIcon: Icon(Icons.format_size, size: 18),
                              border: OutlineInputBorder(),
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 8,
                              ),
                            ),
                            items: [
                              const DropdownMenuItem<int?>(
                                value: null,
                                child: Text('None'),
                              ),
                              ...sizes.map(
                                (size) => DropdownMenuItem<int>(
                                  value: size.key,
                                  child: Text(
                                    size.value,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(fontSize: 14),
                                  ),
                                ),
                              ),
                            ],
                            onChanged: (int? value) {
                              setState(() {
                                selectedSizeKey = value;
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
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
                  Navigator.of(context).pop(true);
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
