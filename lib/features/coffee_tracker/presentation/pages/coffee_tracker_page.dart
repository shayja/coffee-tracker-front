// coffee_tracker/lib/features/coffee_tracker/presentation/pages/coffee_tracker_page.dart

import 'package:coffee_tracker/core/widgets/add_button.dart';
import 'package:coffee_tracker/core/widgets/app_scaffold.dart';
import 'package:coffee_tracker/features/coffee_tracker/presentation/bloc/coffee_tracker_bloc.dart';
import 'package:coffee_tracker/features/coffee_tracker/presentation/bloc/coffee_tracker_event.dart';
import 'package:coffee_tracker/features/coffee_tracker/presentation/bloc/coffee_tracker_state.dart';
import 'package:coffee_tracker/features/coffee_tracker/presentation/widgets/coffee_entry_data.dart';
import 'package:coffee_tracker/features/coffee_tracker/presentation/widgets/coffee_log_list.dart';
import 'package:coffee_tracker/features/coffee_tracker/presentation/widgets/show_coffee_entry_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

class CoffeeTrackerPage extends StatefulWidget {
  const CoffeeTrackerPage({super.key});

  @override
  State<CoffeeTrackerPage> createState() => _CoffeeTrackerPageState();
}

class _CoffeeTrackerPageState extends State<CoffeeTrackerPage> {
  DateTime selectedDate = DateTime.now();

  // Helper method to check if selected date is today
  bool get _isToday {
    final now = DateTime.now();
    return selectedDate.year == now.year &&
        selectedDate.month == now.month &&
        selectedDate.day == now.day;
  }

  @override
  void initState() {
    super.initState();
    _loadLogForDate(selectedDate);
  }

  void _loadLogForDate(DateTime date) {
    context.read<CoffeeTrackerBloc>().add(LoadDailyCoffeeLog(date));
  }

  void _changeDate(int offsetInDays) {
    final newDate = selectedDate.add(Duration(days: offsetInDays));
    final today = DateTime.now();

    // Prevent navigating to future dates
    if (newDate.year > today.year ||
        (newDate.year == today.year && newDate.month > today.month) ||
        (newDate.year == today.year &&
            newDate.month == today.month &&
            newDate.day > today.day)) {
      return;
    }

    setState(() {
      selectedDate = newDate;
    });
    _loadLogForDate(selectedDate);
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      appBar: AppBar(
        title: const Text('☕ Daily Coffee Tracker'),
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: AddButton<CoffeeEntryData>(
            initialData: CoffeeEntryData(dateTime: selectedDate),
            showDialogFn: showCoffeeEntryDialog,
            onAdd: (data) {
              context.read<CoffeeTrackerBloc>().add(
                AddCoffeeEntry(
                  timestamp: data.dateTime,
                  notes: data.description,
                ),
              );
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'Saved for ${DateFormat("dd/MM/yyyy").format(data.dateTime)}',
                  ),
                ),
              );
            },
          ),
        ),
      ),
      body: Column(
        children: [
          const SizedBox(height: 16),
          // Navigation buttons and current date
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                icon: const Icon(Icons.chevron_left),
                onPressed: () => _changeDate(-1),
              ),
              Text(
                DateFormat.yMMMMd().format(selectedDate),
                style: Theme.of(context).textTheme.titleMedium,
              ),
              IconButton(
                icon: const Icon(Icons.chevron_right),
                onPressed: _isToday ? null : () => _changeDate(1),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: BlocBuilder<CoffeeTrackerBloc, CoffeeTrackerState>(
              builder: (context, state) {
                if (state is CoffeeTrackerLoading) {
                  return const Center(child: CircularProgressIndicator());
                } else if (state is CoffeeTrackerLoaded) {
                  final entries = state.entries;
                  return Column(
                    children: [
                      Text(
                        'You drank ${entries.length} cups on ${DateFormat.MMMd().format(selectedDate)}',
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      const SizedBox(height: 16),
                      Expanded(child: CoffeeLogList(entries: entries)),
                    ],
                  );
                } else if (state is CoffeeTrackerError) {
                  return Center(child: Text(state.message));
                } else {
                  return const Center(
                    child: Text('Start tracking your coffee!'),
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
