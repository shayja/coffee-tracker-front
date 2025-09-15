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
    final List<Widget> radioListTiles = [];

    // Add 'None' option
    radioListTiles.add(
      RadioListTile<String?>(value: null, title: const Text('None')),
    );

    // Add coffee types options
    radioListTiles.addAll(
      widget.coffeeTypes.map((coffeeType) {
        return RadioListTile<String?>(
          value: coffeeType.key.toString(),
          title: Text(coffeeType.value),
        );
      }),
    );

    return RadioGroup<String?>(
      groupValue: _selectedKey,
      onChanged: (String? value) {
        setState(() {
          _selectedKey = value;
        });
        widget.onSelectionChanged(value);
      },
      child: SingleChildScrollView(child: Column(children: radioListTiles)),
    );
  }
}
