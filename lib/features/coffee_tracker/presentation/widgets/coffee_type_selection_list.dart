import 'package:coffee_tracker/features/coffee_tracker/domain/entities/coffee_type.dart';
import 'package:flutter/material.dart';

class CoffeeTypeSelectionList extends StatefulWidget {
  final List<CoffeeType> coffeeTypes;
  final int? selectedKey;
  final void Function(String? selectedKey) onSelectionChanged;

  const CoffeeTypeSelectionList({
    super.key,
    required this.coffeeTypes,
    this.selectedKey,
    required this.onSelectionChanged,
  });

  @override
  State<CoffeeTypeSelectionList> createState() =>
      _CoffeeTypeSelectionListState();
}

class _CoffeeTypeSelectionListState extends State<CoffeeTypeSelectionList> {
  String? _selectedKey;

  @override
  void initState() {
    super.initState();
    _selectedKey = widget.selectedKey?.toString();
  }

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      shrinkWrap: true,
      itemCount: widget.coffeeTypes.length + 1, // +1 for "None" option
      separatorBuilder: (context, index) => const Divider(height: 1),
      itemBuilder: (context, index) {
        if (index == 0) {
          return RadioListTile<String?>(
            title: const Text('None'),
            value: null,
            groupValue: _selectedKey,
            onChanged: (value) {
              setState(() {
                _selectedKey = value;
              });
              widget.onSelectionChanged(value);
            },
          );
        }

        final coffeeType = widget.coffeeTypes[index - 1];
        return RadioListTile<String?>(
          title: Text(coffeeType.value),
          value: coffeeType.key.toString(),
          groupValue: _selectedKey,
          onChanged: (value) {
            setState(() {
              _selectedKey = value;
            });
            widget.onSelectionChanged(value);
          },
        );
      },
    );
  }
}
