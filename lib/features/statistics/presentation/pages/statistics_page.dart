// file: lib/features/statistics/presentation/pages/statistics_page.dart
import 'package:coffee_tracker/core/widgets/app_drawer.dart';
import 'package:coffee_tracker/features/statistics/domain/entities/statistics_entity.dart';
import 'package:coffee_tracker/features/statistics/presentation/bloc/statistics_bloc.dart';
import 'package:coffee_tracker/features/statistics/presentation/bloc/statistics_event.dart';
import 'package:coffee_tracker/features/statistics/presentation/bloc/statistics_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class StatisticsPage extends StatefulWidget {
  const StatisticsPage({super.key});

  @override
  State<StatisticsPage> createState() => _StatisticsPageState();
}

class _StatisticsPageState extends State<StatisticsPage> {
  @override
  void initState() {
    super.initState();
    // Load statistics automatically
    context.read<StatisticsBloc>().add(LoadStatistics());
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      drawer: const AppDrawer(),
      appBar: AppBar(
        title: const Text('📊 Statistics'),
        elevation: 0,
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu_rounded),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
      ),
      body: BlocConsumer<StatisticsBloc, StatisticsState>(
        listener: (context, state) {
          // Handle any side effects if needed
        },
        builder: (context, state) {
          if (state is StatisticsLoaded) {
            return _buildStatistics(state.statistics);
          } else if (state is StatisticsError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Error: ${state.message}'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      context.read<StatisticsBloc>().add(LoadStatistics());
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          } else {
            // Show loading for both initial and loading states
            return const Center(child: CircularProgressIndicator());
          }
        },
      ),
      // floatingActionButton: FloatingActionButton(
      //   onPressed: () {
      //     context.read<StatisticsBloc>().add(LoadStatistics());
      //   },
      //   child: const Icon(Icons.refresh),
      // ),
    );
  }

  Widget _buildStatistics(StatisticsEntity statistics) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildStatCard(
            'Total Entries',
            statistics.totalEntries,
            Icons.coffee,
          ),
          const SizedBox(height: 16),
          _buildStatCard(
            'This Week',
            statistics.entriesThisWeek,
            Icons.calendar_today,
          ),
          const SizedBox(height: 16),
          _buildStatCard(
            'This Month',
            statistics.entriesThisMonth,
            Icons.calendar_view_month,
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, int value, IconData icon) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Row(
          children: [
            Icon(icon, size: 40, color: Colors.brown),
            const SizedBox(width: 20),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontSize: 16, color: Colors.grey),
                ),
                Text(
                  '$value',
                  style: const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
