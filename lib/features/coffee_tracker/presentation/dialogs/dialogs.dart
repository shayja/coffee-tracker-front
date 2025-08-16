// coffee_tracker/lib/features/coffee_tracker/presentation/dialogs/dialogs.dart
import 'package:coffee_tracker/features/coffee_tracker/domain/entities/coffee_tracker_entry.dart';
import 'package:flutter/material.dart';

Future<bool?> showEditCoffeeEntryDialog({
  required BuildContext context,
  required CoffeeTrackerEntry entry,
  required void Function(String newDescription, DateTime newTimestamp)
  onConfirm,
}) async {
  final descriptionController = TextEditingController(text: entry.notes);
  DateTime selectedDateTime = entry.timestamp;

  return showDialog<bool>(
    context: context,
    builder: (dialogContext) {
      return StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text("Edit Coffee Entry"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: descriptionController,
                decoration: const InputDecoration(labelText: "Description"),
              ),
              const SizedBox(height: 12),
              ElevatedButton.icon(
                icon: const Icon(Icons.calendar_today),
                label: Text(
                  "Date: ${selectedDateTime.toLocal().toString().split(' ')[0]}",
                ),
                onPressed: () async {
                  final pickedDate = await showDatePicker(
                    context: context,
                    initialDate: selectedDateTime,
                    firstDate: DateTime(2020),
                    lastDate: DateTime.now(), // prevent future dates
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
                  "Time: ${TimeOfDay.fromDateTime(selectedDateTime).format(context)}",
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
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () {
                onConfirm(descriptionController.text.trim(), selectedDateTime);
                Navigator.of(dialogContext).pop(true);
              },
              child: const Text("Save"),
            ),
          ],
        ),
      );
    },
  );
}
