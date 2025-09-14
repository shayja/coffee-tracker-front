// lib/features/coffee_tracker/presentation/widgets/show_coffee_entry_dialog.dart

import 'package:coffee_tracker/features/coffee_tracker/domain/entities/coffee_type.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'coffee_entry_data.dart';

Future<bool?> showCoffeeEntryDialog(
  BuildContext context,
  CoffeeEntryData data, {
  required List<CoffeeType> coffeeTypes,
}) {
  final descriptionController = TextEditingController(text: data.description);
  DateTime selectedDate = data.dateTime;
  TimeOfDay selectedTime = TimeOfDay.fromDateTime(data.dateTime);

  // Initialize selected coffee type key (nullable)
  int? selectedCoffeeTypeKey = data.coffeeTypeKey;

  return showDialog<bool>(
    context: context,
    builder: (dialogContext) {
      return StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: const Text('Add Coffee Entry'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: descriptionController,
                    decoration: const InputDecoration(labelText: 'Description'),
                    onChanged: (val) => data.description = val,
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.calendar_today),
                    label: Text(
                      'Date: ${DateFormat('yyyy-MM-dd').format(selectedDate)}',
                    ),
                    onPressed: () async {
                      final pickedDate = await showDatePicker(
                        context: context,
                        initialDate: selectedDate,
                        firstDate: DateTime(2020),
                        lastDate: DateTime.now(),
                      );
                      if (pickedDate != null) {
                        setState(() {
                          selectedDate = pickedDate;
                          data.dateTime = DateTime(
                            selectedDate.year,
                            selectedDate.month,
                            selectedDate.day,
                            selectedTime.hour,
                            selectedTime.minute,
                          );
                        });
                      }
                    },
                  ),
                  const SizedBox(height: 8),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.access_time),
                    label: Text('Time: ${selectedTime.format(context)}'),
                    onPressed: () async {
                      final pickedTime = await showTimePicker(
                        context: context,
                        initialTime: selectedTime,
                      );
                      if (pickedTime != null) {
                        setState(() {
                          selectedTime = pickedTime;
                          data.dateTime = DateTime(
                            selectedDate.year,
                            selectedDate.month,
                            selectedDate.day,
                            selectedTime.hour,
                            selectedTime.minute,
                          );
                        });
                      }
                    },
                  ),
                  const SizedBox(height: 16),
                  // Coffee type dropdown
                  DropdownButtonFormField<String?>(
                    // Store dropdown value as String? because dropdown expects String
                    initialValue: selectedCoffeeTypeKey?.toString(),
                    decoration: const InputDecoration(
                      labelText: 'Coffee Type (optional)',
                      border: OutlineInputBorder(),
                    ),
                    items: [
                      const DropdownMenuItem<String?>(
                        value: null,
                        child: Text('None'),
                      ),
                      ...coffeeTypes.map(
                        (ct) => DropdownMenuItem<String>(
                          value: ct.key.toString(),
                          child: Text(ct.value),
                        ),
                      ),
                    ],
                    onChanged: (value) {
                      // Convert selected string to int? or null
                      setState(() {
                        selectedCoffeeTypeKey = value == null
                            ? null
                            : int.tryParse(value);
                        data.coffeeTypeKey = selectedCoffeeTypeKey;
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
                  data.description = descriptionController.text.trim();
                  data.coffeeTypeKey = selectedCoffeeTypeKey;
                  Navigator.of(dialogContext).pop(true);
                },
                child: const Text('Add'),
              ),
            ],
          );
        },
      );
    },
  );
}
