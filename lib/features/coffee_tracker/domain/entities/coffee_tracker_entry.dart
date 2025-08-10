class CoffeeTrackerEntry {
  final String id;
  final DateTime timestamp;
  final String description;

  CoffeeTrackerEntry({
    required this.id,
    required this.timestamp,
    required this.description,
  });

  CoffeeTrackerEntry copyWith({
    String? id,
    DateTime? timestamp,
    String? description,
  }) {
    return CoffeeTrackerEntry(
      id: id ?? this.id,
      timestamp: timestamp ?? this.timestamp,
      description: description ?? this.description,
    );
  }

  // Include `id` in JSON serialization
  factory CoffeeTrackerEntry.fromJson(Map<String, dynamic> json) {
    return CoffeeTrackerEntry(
      id: json['id'],
      timestamp: DateTime.parse(json['timestamp']),
      description: json['description'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'timestamp': timestamp.toIso8601String(),
      'description': description,
    };
  }
}
