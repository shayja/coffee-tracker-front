// coffee_tracker/lib/features/coffee_tracker/presentation/widgets/coffee_log_list.dart
import 'package:coffee_tracker/features/coffee_tracker/domain/entities/coffee_tracker_entry.dart';
import 'package:coffee_tracker/features/coffee_tracker/domain/entities/coffee_type.dart';
import 'package:coffee_tracker/features/coffee_tracker/presentation/bloc/coffee_tracker_bloc.dart';
import 'package:coffee_tracker/features/coffee_tracker/presentation/bloc/coffee_tracker_event.dart';
import 'package:coffee_tracker/features/coffee_tracker/presentation/bloc/coffee_tracker_state.dart';
import 'package:coffee_tracker/features/coffee_tracker/presentation/widgets/coffee_entry_data.dart';
import 'package:coffee_tracker/features/coffee_tracker/presentation/widgets/show_coffee_entry_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

class CoffeeLogList extends StatelessWidget {
  final List<CoffeeTrackerEntry> entries;

  const CoffeeLogList({super.key, required this.entries});

  @override
  Widget build(BuildContext context) {
    final coffeeTypes = context.select<CoffeeTypesBloc, List<CoffeeType>>(
      (bloc) => (bloc.state is CoffeeTypesLoaded)
          ? (bloc.state as CoffeeTypesLoaded).coffeeTypes
          : [],
    );

    return ListView.builder(
      itemCount: entries.length,
      itemBuilder: (context, index) {
        final entry = entries[index];
        final timeString = DateFormat(
          'HH:mm',
        ).format(entry.timestamp.toLocal());

        return ListTile(
          title: Text(entry.notes ?? ''),
          subtitle: Text(timeString),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: const Icon(Icons.edit),
                onPressed: () async {
                  await showCoffeeEntryDialog(
                    context: context,
                    coffeeTypes: coffeeTypes,
                    entry: CoffeeEntryData(
                      dateTime: entry.timestamp,
                      description: entry.notes ?? '',
                      coffeeTypeKey: entry.coffeeType,
                    ), // Pass the correct object type
                    onConfirm: (newDescription, newTimestamp, newCoffeeType) {
                      final updatedEntry = entry.copyWith(
                        notes: newDescription,
                        timestamp: newTimestamp,
                        coffeeType: newCoffeeType,
                      );
                      context.read<CoffeeTrackerBloc>().add(
                        EditCoffeeEntry(
                          oldEntry: entry,
                          newEntry: updatedEntry,
                        ),
                      );
                    },
                  );
                },
              ),
              IconButton(
                icon: const Icon(Icons.delete),
                onPressed: () async {
                  final confirmed = await showDialog<bool>(
                    context: context,
                    builder: (dialogContext) => AlertDialog(
                      title: const Text("Delete Entry"),
                      content: const Text(
                        "Are you sure you want to delete this coffee entry?",
                      ),
                      actions: [
                        TextButton(
                          onPressed: () =>
                              Navigator.of(dialogContext).pop(false),
                          child: const Text("Cancel"),
                        ),
                        ElevatedButton(
                          onPressed: () =>
                              Navigator.of(dialogContext).pop(true),
                          child: const Text("Delete"),
                        ),
                      ],
                    ),
                  );
                  if (context.mounted && confirmed == true) {
                    context.read<CoffeeTrackerBloc>().add(
                      DeleteCoffeeEntry(entry: entry),
                    );
                  }
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
