import 'package:coffee_tracker/features/statistics/domain/entities/statistics_entity.dart';

class StatisticsModel extends StatisticsEntity {
  const StatisticsModel({
    required super.totalEntries,
    required super.entriesThisWeek,
    required super.entriesThisMonth,
  });

  factory StatisticsModel.fromJson(Map<String, dynamic> json) {
    return StatisticsModel(
      totalEntries: json['total_entries'] as int,
      entriesThisWeek: json['entries_this_week'] as int,
      entriesThisMonth: json['entries_this_month'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'total_entries': totalEntries,
      'entries_this_week': entriesThisWeek,
      'entries_this_month': entriesThisMonth,
    };
  }
}
