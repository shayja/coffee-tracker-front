// lib/features/tapering_journey/presentation/widgets/tapering_journey_data.dart

class TaperingJourneyData {
  final String? id; // null if new record (add), set if editing
  int goalFrequency;
  int startLimit;
  int targetLimit;
  int reductionStep;
  int stepPeriod;
  int? statusId;
  DateTime startedAt;

  TaperingJourneyData({
    this.id,
    this.goalFrequency = 1,
    this.startLimit = 5,
    this.targetLimit = 2,
    this.reductionStep = 1,
    this.stepPeriod = 7,
    this.statusId = 1,
    DateTime? startedAt,
  }) : startedAt = startedAt ?? DateTime.now();

  Map<String, dynamic> toCreateJson() {
    return {
      'goal_frequency': goalFrequency,
      'start_limit': startLimit,
      'target_limit': targetLimit,
      'reduction_step': reductionStep,
      'step_period': stepPeriod,
      'started_at': startedAt.toUtc().toIso8601String(),
    };
  }

  Map<String, dynamic> toUpdateJson() {
    return {
      'id': id,
      'goal_frequency': goalFrequency,
      'start_limit': startLimit,
      'target_limit': targetLimit,
      'reduction_step': reductionStep,
      'step_period': stepPeriod,
      'started_at': startedAt.toUtc().toIso8601String(),
    };
  }

  // // Create a copy with updated values (helpful for state updates)
  // TaperingJourneyData copyWith({
  //   String? id,
  //   int? goalFrequency,
  //   int? startLimit,
  //   int? targetLimit,
  //   int? reductionStep,
  //   int? stepPeriod,
  //   DateTime? startedAt,
  // }) {
  //   return TaperingJourneyData(
  //     id: id ?? this.id,
  //     goalFrequency: goalFrequency ?? this.goalFrequency,
  //     startLimit: startLimit ?? this.startLimit,
  //     targetLimit: targetLimit ?? this.targetLimit,
  //     reductionStep: reductionStep ?? this.reductionStep,
  //     stepPeriod: stepPeriod ?? this.stepPeriod,
  //     startedAt: startedAt ?? this.startedAt,
  //   );
  // }

  factory TaperingJourneyData.fromJson(Map<String, dynamic> json) {
    return TaperingJourneyData(
      id: json['id'] as String?,
      goalFrequency: (json['goal_frequency'] ?? 1) as int,
      startLimit: (json['start_limit'] ?? 0) as int,
      targetLimit: (json['target_limit'] ?? 0) as int,
      reductionStep: (json['reduction_step'] ?? 1) as int,
      stepPeriod: (json['step_period'] ?? 7) as int,
      statusId: (json['status_id'] ?? 0) as int,
      startedAt: DateTime.parse(json['started_at'] as String),
    );
  }
}
