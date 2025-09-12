// file://lib/features/tapering_journey/presentation/widgets/show_add_tapering_journey_dialog.dart

import 'package:coffee_tracker/features/tapering_journey/domain/entities/tapering_journey.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

Future<bool?> showAddTaperingJourneyDialog(
  BuildContext context,
  TaperingJourneyData data,
) {
  final startLimitController = TextEditingController(
    text: data.startLimit.toString(),
  );
  final targetLimitController = TextEditingController(
    text: data.targetLimit.toString(),
  );
  final reductionStepController = TextEditingController(
    text: data.reductionStep.toString(),
  );
  final stepPeriodController = TextEditingController(
    text: data.stepPeriod.toString(),
  );
  DateTime selectedDate = data.startedAt;
  int goalFrequency = data.goalFrequency;

  return showDialog<bool>(
    context: context,
    builder: (dialogContext) {
      return StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: const Text('Add Tapering Journey'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: startLimitController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Start Limit (cups)',
                    ),
                    onChanged: (val) =>
                        data.startLimit = int.tryParse(val) ?? data.startLimit,
                  ),
                  TextField(
                    controller: targetLimitController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Target Limit (cups)',
                    ),
                    onChanged: (val) => data.targetLimit =
                        int.tryParse(val) ?? data.targetLimit,
                  ),
                  TextField(
                    controller: reductionStepController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Reduction Step (cups)',
                    ),
                    onChanged: (val) => data.reductionStep =
                        int.tryParse(val) ?? data.reductionStep,
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<int>(
                    initialValue: goalFrequency,
                    decoration: const InputDecoration(
                      labelText: 'Goal Frequency',
                    ),
                    items: const [
                      DropdownMenuItem(value: 1, child: Text('Daily')),
                      DropdownMenuItem(value: 2, child: Text('Weekly')),
                      DropdownMenuItem(value: 3, child: Text('Monthly')),
                    ],
                    onChanged: (val) {
                      if (val != null) {
                        setState(() => goalFrequency = val);
                        data.goalFrequency = val;
                      }
                    },
                  ),
                  TextField(
                    controller: stepPeriodController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Step Period (days)',
                    ),
                    onChanged: (val) =>
                        data.stepPeriod = int.tryParse(val) ?? data.stepPeriod,
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.calendar_today),
                    label: Text(
                      'Started At: ${DateFormat('yyyy-MM-dd').format(selectedDate)}',
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
                          data.startedAt = pickedDate;
                        });
                      }
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
                  if (data.startLimit <= 0 ||
                      data.targetLimit < 0 ||
                      data.reductionStep <= 0 ||
                      data.stepPeriod <= 0 ||
                      data.startLimit < data.targetLimit) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'Please enter valid positive values and ensure start limit >= target limit',
                        ),
                        backgroundColor: Colors.red,
                      ),
                    );
                    return;
                  }
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
