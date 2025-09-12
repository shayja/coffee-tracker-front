// lib/features/coffee_tracker/domain/entities/coffee_tracker_entry.dart
class CoffeeTrackerEntry {
  final String id;
  final DateTime timestamp;
  final String? notes;

  CoffeeTrackerEntry({required this.id, required this.timestamp, this.notes});

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

  // Parse from JSON (server response includes id)
  factory CoffeeTrackerEntry.fromJson(Map<String, dynamic> json) {
    return CoffeeTrackerEntry(
      id: json['id'],
      timestamp: DateTime.parse(json['timestamp']),
      notes: json['notes'],
    );
  }

  // Convert to JSON for creating new entry
  Map<String, dynamic> toCreateJson() {
    return {'timestamp': _formatTimestampForGo(timestamp), 'notes': notes};
  }

  Map<String, dynamic> toUpdateJson() {
    return {
      'id': id,
      'timestamp': _formatTimestampForGo(timestamp),
      'notes': notes,
    };
  }

  String _formatTimestampForGo(DateTime timestamp) {
    return timestamp.toUtc().toIso8601String();
  }

  @override
  String toString() {
    return 'CoffeeTrackerEntry{id: $id, timestamp: $timestamp, notes: $notes}';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CoffeeTrackerEntry &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          timestamp == other.timestamp &&
          notes == other.notes;

  @override
  int get hashCode => id.hashCode ^ timestamp.hashCode ^ notes.hashCode;
}
