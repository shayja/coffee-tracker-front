// lib/features/coffee_tracker/domain/entities/coffee_type.dart
class CoffeeType {
  final int key;
  final String value;

  CoffeeType({required this.key, required this.value});

  factory CoffeeType.fromJson(Map<String, dynamic> json) {
    return CoffeeType(key: json['key'] as int, value: json['value'] as String);
  }

  CoffeeType copyWith({int? key, String? value}) {
    return CoffeeType(key: key ?? this.key, value: value ?? this.value);
  }
}
