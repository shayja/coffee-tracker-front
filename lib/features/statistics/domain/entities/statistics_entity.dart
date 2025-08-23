// file: lib/features/statistics/domain/entities/statistics_entity.dart
class StatisticsEntity {
  final int totalEntries;
  final int entriesThisWeek;
  final int entriesThisMonth;

  const StatisticsEntity({
    required this.totalEntries,
    required this.entriesThisWeek,
    required this.entriesThisMonth,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is StatisticsEntity &&
        other.totalEntries == totalEntries &&
        other.entriesThisWeek == entriesThisWeek &&
        other.entriesThisMonth == entriesThisMonth;
  }

  @override
  int get hashCode =>
      totalEntries.hashCode ^
      entriesThisWeek.hashCode ^
      entriesThisMonth.hashCode;
}
