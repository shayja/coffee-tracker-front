// lib/features/coffee_tracker/domain/entities/kv_type.dart
class KvType {
  final int key;
  final String value;

  KvType({required this.key, required this.value});

  factory KvType.fromJson(Map<String, dynamic> json) {
    return KvType(key: json['key'] as int, value: json['value'] as String);
  }

  KvType copyWith({int? key, String? value}) {
    return KvType(key: key ?? this.key, value: value ?? this.value);
  }
}
