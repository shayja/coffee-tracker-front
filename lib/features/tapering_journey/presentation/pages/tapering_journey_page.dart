// lib/features/tapering_journey/presentation/pages/tapering_journey_page.dart

import 'package:coffee_tracker/features/tapering_journey/domain/entities/tapering_journey.dart';
import 'package:coffee_tracker/features/tapering_journey/presentation/widgets/show_add_tapering_journey_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:coffee_tracker/features/tapering_journey/presentation/bloc/tapering_journey_bloc.dart';
import 'package:coffee_tracker/core/widgets/app_scaffold.dart';

class TaperingJourneyPage extends StatefulWidget {
  const TaperingJourneyPage({super.key});

  @override
  State<TaperingJourneyPage> createState() => _TaperingJourneyPageState();
}

class _TaperingJourneyPageState extends State<TaperingJourneyPage> {
  @override
  void initState() {
    super.initState();
    context.read<TaperingJourneyBloc>().add(const LoadTaperingJourneys());
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      appBar: AppBar(title: const Text('Tapering Journey')),
      body: BlocBuilder<TaperingJourneyBloc, TaperingJourneyState>(
        builder: (context, state) {
          if (state is TaperingJourneyLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is TaperingJourneyLoaded) {
            final journeys = state.journeys;
            if (journeys.isEmpty) {
              return const Center(child: Text('No tapering journeys found.'));
            }
            return ListView.builder(
              itemCount: journeys.length,
              itemBuilder: (context, index) {
                final journey = journeys[index];
                return Card(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  child: ListTile(
                    title: Text(
                      'Goal: ${journey.startLimit} to ${journey.targetLimit} cups',
                    ),
                    subtitle: Text(
                      'Frequency: ${_frequencyText(journey.goalFrequency)}\n'
                      'Step Period: ${journey.stepPeriod} days',
                    ),
                    trailing: Text(_statusText(journey.statusId!)),
                    onTap: () {
                      // TODO: Navigate to journey detail/edit page
                    },
                  ),
                );
              },
            );
          } else if (state is TaperingJourneyError) {
            return Center(child: Text('Error: ${state.message}'));
          } else {
            return const Center(child: Text('Start your tapering journey!'));
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        tooltip: 'Create new journey',
        onPressed: () async {
          final initialData = TaperingJourneyData();
          final confirmed = await showAddTaperingJourneyDialog(
            context,
            initialData,
          );
          if (context.mounted && confirmed == true) {
            context.read<TaperingJourneyBloc>().add(
              CreateTaperingJourney(initialData),
            );
          }
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  String _frequencyText(int frequency) {
    switch (frequency) {
      case 1:
        return 'Daily';
      case 2:
        return 'Weekly';
      case 3:
        return 'Monthly';
      default:
        return 'Unknown';
    }
  }

  String _statusText(int statusId) {
    switch (statusId) {
      case 1:
        return 'Active';
      case 2:
        return 'Paused';
      case 3:
        return 'Completed';
      default:
        return 'Unknown';
    }
  }
}
