// coffee_tracker/lib/features/coffee_tracker/presentation/pages/coffee_tracker_page.dart
import 'package:coffee_tracker/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:coffee_tracker/features/auth/presentation/bloc/auth_event.dart';
import 'package:coffee_tracker/features/coffee_tracker/presentation/bloc/coffee_tracker_bloc.dart';
import 'package:coffee_tracker/features/coffee_tracker/presentation/bloc/coffee_tracker_event.dart';
import 'package:coffee_tracker/features/coffee_tracker/presentation/bloc/coffee_tracker_state.dart';
import 'package:coffee_tracker/features/coffee_tracker/presentation/widgets/add_coffee_button.dart';
import 'package:coffee_tracker/features/coffee_tracker/presentation/widgets/coffee_log_list.dart';
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

  @override
  void initState() {
    super.initState();
    _loadLogForDate(selectedDate);
  }

  void _loadLogForDate(DateTime date) {
    context.read<CoffeeTrackerBloc>().add(LoadDailyCoffeeLog(date));
  }

  void _changeDate(int offsetInDays) {
    setState(() {
      selectedDate = selectedDate.add(Duration(days: offsetInDays));
    });
    _loadLogForDate(selectedDate);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('☕ Daily Coffee Tracker'),
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: AddCoffeeButton(selectedDate: selectedDate),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              context.read<AuthBloc>().add(LogoutEvent());
            },
          ),
        ],
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
                onPressed: () => _changeDate(1),
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
