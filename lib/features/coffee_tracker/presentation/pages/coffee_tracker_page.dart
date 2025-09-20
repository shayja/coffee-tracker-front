// coffee_tracker/lib/features/coffee_tracker/presentation/pages/coffee_tracker_page.dart

import 'package:coffee_tracker/core/widgets/app_drawer.dart';
import 'package:coffee_tracker/features/coffee_tracker/domain/entities/kv_type.dart';
import 'package:coffee_tracker/features/coffee_tracker/presentation/bloc/coffee_tracker_bloc.dart';
import 'package:coffee_tracker/features/coffee_tracker/presentation/bloc/coffee_tracker_event.dart';
import 'package:coffee_tracker/features/coffee_tracker/presentation/bloc/coffee_tracker_state.dart';
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
    final theme = Theme.of(context);
    final coffeeTypes = context.select<CoffeeTypesBloc, List<KvType>>(
      (bloc) => (bloc.state is SelectOptionsLoaded)
          ? (bloc.state as SelectOptionsLoaded).coffeeTypes
          : [],
    );
    final sizes = context.select<CoffeeTypesBloc, List<KvType>>(
      (bloc) => (bloc.state is SelectOptionsLoaded)
          ? (bloc.state as SelectOptionsLoaded).sizes
          : [],
    );

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      drawer: const AppDrawer(),
      appBar: AppBar(
        title: const Text("☕ Daily Coffee Tracker"),
        elevation: 0,
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu_rounded),
            onPressed: () => Scaffold.of(context).openDrawer(),
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
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await showCoffeeEntryDialog(
            context: context,
            coffeeTypes: coffeeTypes,
            sizes: sizes,
            entry: null,
            onConfirm:
                (newDescription, newTimestamp, newCoffeeTypeKey, newSizeKey) {
                  context.read<CoffeeTrackerBloc>().add(
                    AddCoffeeEntry(
                      timestamp: newTimestamp,
                      notes: newDescription,
                      coffeeTypeKey: newCoffeeTypeKey,
                      sizeKey: newSizeKey,
                    ),
                  );
                },
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
