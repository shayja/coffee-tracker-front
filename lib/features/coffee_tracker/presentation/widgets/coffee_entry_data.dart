// lib/features/coffee_tracker/presentation/widgets/coffee_entry_data.dart

class CoffeeEntryData {
  DateTime dateTime;
  String description;
  int? coffeeTypeKey;
  int? sizeKey;

  CoffeeEntryData({
    required this.dateTime,
    this.description = '',
    this.coffeeTypeKey,
    this.sizeKey,
  });
}
