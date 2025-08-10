// coffee_tracker/lib/features/coffee_tracker/presentation/widgets/log_summary.dart
import 'package:flutter/material.dart';

class LogSummary extends StatelessWidget {
  final int count;

  const LogSummary({required this.count, super.key});

  @override
  Widget build(BuildContext context) {
    return Text('Total Coffees Today: $count');
  }
}
