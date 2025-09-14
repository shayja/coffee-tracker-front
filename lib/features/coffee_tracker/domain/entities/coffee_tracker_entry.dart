// lib/features/coffee_tracker/domain/entities/coffee_tracker_entry.dart
class CoffeeTrackerEntry {
  final String id;
  final DateTime timestamp;
  final String? notes;
  final double? latitude;
  final double? longitude;
  final int? coffeeType;

  CoffeeTrackerEntry({
    required this.id,
    required this.timestamp,
    this.notes,
    this.latitude,
    this.longitude,
    this.coffeeType,
  }) {
    if (id.isEmpty) {
      throw ArgumentError('ID cannot be empty');
    }
    _validateCoordinates(latitude, longitude);
  }

  void _validateCoordinates(double? lat, double? lon) {
    if (lat != null && (lat < -90 || lat > 90)) {
      throw ArgumentError('Latitude must be between -90 and 90');
    }
    if (lon != null && (lon < -180 || lon > 180)) {
      throw ArgumentError('Longitude must be between -180 and 180');
    }
    if ((lat != null && lon == null) || (lat == null && lon != null)) {
      throw ArgumentError(
        'Both latitude and longitude must be provided together, or both null',
      );
    }
  }

  // For creating new entries
  factory CoffeeTrackerEntry.create({
    required DateTime timestamp,
    String? notes,
    double? latitude,
    double? longitude,
    int? coffeeType,
  }) {
    return CoffeeTrackerEntry(
      id: '', // Will be assigned by server
      timestamp: timestamp,
      notes: notes,
      latitude: latitude,
      longitude: longitude,
      coffeeType: coffeeType,
    );
  }

  CoffeeTrackerEntry copyWith({
    String? id,
    DateTime? timestamp,
    String? notes,
    double? latitude,
    double? longitude,
    int? coffeeType,
  }) {
    return CoffeeTrackerEntry(
      id: id ?? this.id,
      timestamp: timestamp ?? this.timestamp,
      notes: notes ?? this.notes,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      coffeeType: coffeeType ?? this.coffeeType,
    );
  }

  factory CoffeeTrackerEntry.fromJson(Map<String, dynamic> json) {
    return CoffeeTrackerEntry(
      id: json['id'] as String? ?? '',
      timestamp: DateTime.parse(
        json['timestamp'] as String? ?? DateTime.now().toIso8601String(),
      ),
      notes: json['notes'] as String?,
      latitude: json['latitude'] != null
          ? (json['latitude'] as num).toDouble()
          : null,
      longitude: json['longitude'] != null
          ? (json['longitude'] as num).toDouble()
          : null,
      coffeeType: json['coffeeType'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'timestamp': _formatTimestampForGo(timestamp),
      'notes': notes,
      if (latitude != null) 'latitude': latitude,
      if (longitude != null) 'longitude': longitude,
      if (coffeeType != null) 'coffeeType': coffeeType,
    };
  }

  Map<String, dynamic> toCreateJson() {
    return {
      'timestamp': _formatTimestampForGo(timestamp),
      'notes': notes,
      if (latitude != null) 'latitude': latitude,
      if (longitude != null) 'longitude': longitude,
      if (coffeeType != null) 'coffeeType': coffeeType,
    };
  }

  Map<String, dynamic> toUpdateJson() {
    return toJson(); // Reuse toJson since it includes ID
  }

  // Helper method to check if location data exists
  bool get hasLocation => latitude != null && longitude != null;

  // Get location as a tuple (if available)
  ({double latitude, double longitude})? get location {
    if (hasLocation) {
      return (latitude: latitude!, longitude: longitude!);
    }
    return null;
  }

  String _formatTimestampForGo(DateTime timestamp) {
    return timestamp.toUtc().toIso8601String();
  }

  @override
  String toString() {
    return 'CoffeeTrackerEntry{id: $id, timestamp: $timestamp, notes: $notes, '
        'latitude: $latitude, longitude: $longitude, coffeeType: $coffeeType}';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CoffeeTrackerEntry &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          timestamp.isAtSameMomentAs(other.timestamp) &&
          notes == other.notes &&
          latitude == other.latitude &&
          longitude == other.longitude &&
          coffeeType == other.coffeeType;

  @override
  int get hashCode =>
      Object.hash(id, timestamp, notes, latitude, longitude, coffeeType);
}
