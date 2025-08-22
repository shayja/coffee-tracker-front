// coffee_tracker/lib/features/coffee_tracker/presentation/widgets/add_coffee_button.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/coffee_tracker_bloc.dart';
import '../bloc/coffee_tracker_event.dart';

class AddCoffeeButton extends StatelessWidget {
  const AddCoffeeButton({super.key});

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: 20,
      backgroundColor: Theme.of(context).primaryColor,
      child: IconButton(
        icon: const Icon(Icons.add, color: Colors.white, size: 20),
        onPressed: () async {
          final descriptionController = TextEditingController();
          DateTime selectedDate = DateTime.now();
          TimeOfDay selectedTime = TimeOfDay.now();

          final confirmed = await showDialog<bool>(
            context: context,
            builder: (dialogContext) {
              return StatefulBuilder(
                builder: (context, setState) {
                  return AlertDialog(
                    title: const Text("Add Coffee Entry"),
                    content: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        TextField(
                          controller: descriptionController,
                          decoration: const InputDecoration(
                            labelText: "Description",
                          ),
                        ),
                        const SizedBox(height: 12),
                        ElevatedButton.icon(
                          icon: const Icon(Icons.calendar_today),
                          label: Text("Date: ${_formatDate(selectedDate)}"),
                          onPressed: () async {
                            final pickedDate = await showDatePicker(
                              context: context,
                              initialDate: selectedDate,
                              firstDate: DateTime(2020),
                              lastDate: DateTime.now(), // disable future dates
                            );
                            if (pickedDate != null) {
                              setState(() {
                                selectedDate = pickedDate;
                              });
                            }
                          },
                        ),
                        const SizedBox(height: 8),
                        ElevatedButton.icon(
                          icon: const Icon(Icons.access_time),
                          label: Text("Time: ${selectedTime.format(context)}"),
                          onPressed: () async {
                            final pickedTime = await showTimePicker(
                              context: context,
                              initialTime: selectedTime,
                            );
                            if (pickedTime != null) {
                              setState(() {
                                selectedTime = pickedTime;
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
                        onPressed: () => Navigator.of(dialogContext).pop(true),
                        child: const Text("Add"),
                      ),
                    ],
                  );
                },
              );
            },
          );

          if (context.mounted && confirmed == true) {
            final combined = DateTime(
              selectedDate.year,
              selectedDate.month,
              selectedDate.day,
              selectedTime.hour,
              selectedTime.minute,
            );

            context.read<CoffeeTrackerBloc>().add(
              AddCoffeeEntry(
                timestamp: combined,
                notes: descriptionController.text.trim(),
              ),
            );

            // optional: give immediate feedback to the user
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Saved for ${_formatDate(combined)}')),
            );
          }
        },
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.year.toString().padLeft(4, '0')}-'
        '${date.month.toString().padLeft(2, '0')}-'
        '${date.day.toString().padLeft(2, '0')}';
  }
}
