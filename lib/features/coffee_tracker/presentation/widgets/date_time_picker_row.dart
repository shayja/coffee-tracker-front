import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DateTimePickerRow extends StatefulWidget {
  final DateTime initialDateTime;
  final ValueChanged<DateTime> onDateTimeChanged;

  const DateTimePickerRow({
    super.key,
    required this.initialDateTime,
    required this.onDateTimeChanged,
  });

  @override
  State<DateTimePickerRow> createState() => _DateTimePickerRowState();
}

class _DateTimePickerRowState extends State<DateTimePickerRow> {
  late DateTime selectedDateTime;

  @override
  void initState() {
    super.initState();
    selectedDateTime = widget.initialDateTime;
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            icon: const Icon(Icons.calendar_today, size: 18),
            label: Text(
              DateFormat('dd/MM').format(selectedDateTime),
            ),
            onPressed: () async {
              final date = await showDatePicker(
                context: context,
                initialDate: selectedDateTime,
                firstDate: DateTime(2020),
                lastDate: DateTime.now(),
              );
              if (date != null && mounted) {
                final newDateTime = DateTime(
                  date.year,
                  date.month,
                  date.day,
                  selectedDateTime.hour,
                  selectedDateTime.minute,
                );
                setState(() {
                  selectedDateTime = newDateTime;
                });
                widget.onDateTimeChanged(newDateTime);
              }
            },
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: OutlinedButton.icon(
            icon: const Icon(Icons.access_time, size: 18),
            label: Text(
              TimeOfDay.fromDateTime(selectedDateTime).format(context),
            ),
            onPressed: () async {
              final time = await showTimePicker(
                context: context,
                initialTime: TimeOfDay.fromDateTime(selectedDateTime),
              );
              if (time != null && mounted) {
                final newDateTime = DateTime(
                  selectedDateTime.year,
                  selectedDateTime.month,
                  selectedDateTime.day,
                  time.hour,
                  time.minute,
                );
                setState(() {
                  selectedDateTime = newDateTime;
                });
                widget.onDateTimeChanged(newDateTime);
              }
            },
          ),
        ),
      ],
    );
  }
}
