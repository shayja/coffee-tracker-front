// file: lib/features/coffee_tracker/domain/entities/coffee_tracker_entry.dart
class CoffeeTrackerEntry {
  final String id;
  final DateTime timestamp;
  final String notes;

  CoffeeTrackerEntry({
    required this.id,
    required this.timestamp,
    required this.notes,
  });

  CoffeeTrackerEntry copyWith({
    String? id,
    DateTime? timestamp,
    String? notes,
  }) {
    return CoffeeTrackerEntry(
      id: id ?? this.id,
      timestamp: timestamp ?? this.timestamp,
      notes: notes ?? this.notes,
    );
  }

  // Include `id` in JSON serialization
  factory CoffeeTrackerEntry.fromJson(Map<String, dynamic> json) {
    return CoffeeTrackerEntry(
      id: json['id'],
      timestamp: DateTime.parse(json['timestamp']),
      notes: json['notes'],
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'timestamp': timestamp.toIso8601String(), 'notes': notes};
  }
}
