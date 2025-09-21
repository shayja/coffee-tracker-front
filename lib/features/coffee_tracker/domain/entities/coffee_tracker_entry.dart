// lib/features/coffee_tracker/domain/entities/coffee_tracker_entry.dart
class CoffeeTrackerEntry {
  final String id;
  final DateTime timestamp;
  final String? notes;
  final double? latitude;
  final double? longitude;
  final int? coffeeType;
  final int? size;

  CoffeeTrackerEntry({
    required this.id,
    required this.timestamp,
    this.notes,
    this.latitude,
    this.longitude,
    this.coffeeType,
    this.size,
  }) : assert(id.isNotEmpty, 'ID cannot be empty') {
    CoffeeTrackerEntry.validateCoordinates(latitude, longitude);
  }

  static void validateCoordinates(double? lat, double? lon) {
    if (lat != null && (lat < -90 || lat > 90)) {
      throw ArgumentError('Latitude must be between -90 and 90');
    }
    if (lon != null && (lon < -180 || lon > 180)) {
      throw ArgumentError('Longitude must be between -180 and 180');
    }
    if ((lat != null) != (lon != null)) {
      throw ArgumentError(
        'Both latitude and longitude must be provided together, or both null',
      );
    }
  }

  factory CoffeeTrackerEntry.create({
    required DateTime timestamp,
    String? notes,
    double? latitude,
    double? longitude,
    int? coffeeType,
    int? size,
  }) {
    return CoffeeTrackerEntry(
      id: '', // Will be assigned by server
      timestamp: timestamp,
      notes: notes,
      latitude: latitude,
      longitude: longitude,
      coffeeType: coffeeType,
      size: size,
    );
  }

  CoffeeTrackerEntry copyWith({
    String? id,
    DateTime? timestamp,
    String? notes,
    double? latitude,
    double? longitude,
    int? coffeeType,
    int? size,
  }) {
    return CoffeeTrackerEntry(
      id: id ?? this.id,
      timestamp: timestamp ?? this.timestamp,
      notes: notes ?? this.notes,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      coffeeType: coffeeType ?? this.coffeeType,
      size: size ?? this.size,
    );
  }

  factory CoffeeTrackerEntry.fromJson(Map<String, dynamic> json) {
    final rawId = json['id'] as String?;
    final rawTimestamp = json['timestamp'] as String?;
    if (rawId == null || rawTimestamp == null) {
      throw ArgumentError('Missing required fields in CoffeeTrackerEntry JSON');
    }
    return CoffeeTrackerEntry(
      id: rawId,
      timestamp: DateTime.parse(rawTimestamp),
      notes: json['notes'] as String?,
      latitude: (json
      ['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
      coffeeType: json['type'] as int?,
      size: json['size'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{
      'id': id,
      'timestamp': _formatTimestampForGo(timestamp),
      'type': coffeeType,
      'size': size,
      if (notes != null) 'notes': notes,
      if (latitude != null && longitude != null) ...{
        'latitude': latitude,
        'longitude': longitude,
      },
    };

    return data;
  }

  bool get hasLocation => latitude != null && longitude != null;

  ({double latitude, double longitude})? get location =>
      hasLocation ? (latitude: latitude!, longitude: longitude!) : null;

  String _formatTimestampForGo(DateTime t) => t.toUtc().toIso8601String();

  @override
  String toString() =>
      'CoffeeTrackerEntry{id: $id, timestamp: $timestamp, notes: $notes, '
      'latitude: $latitude, longitude: $longitude, coffeeType: $coffeeType, size: $size }';

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
          coffeeType == other.coffeeType &&
          size == other.size;

  @override
  int get hashCode =>
      Object.hash(id, timestamp, notes, latitude, longitude, coffeeType, size);
}
