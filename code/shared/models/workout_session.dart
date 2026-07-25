/// Whether a completed session was a strength (gym) or timed (interval) workout.
enum WorkoutSessionType {
  gym,
  interval;

  static WorkoutSessionType fromKey(String? value) {
    return value == 'interval'
        ? WorkoutSessionType.interval
        : WorkoutSessionType.gym;
  }
}

/// How hard a set felt.
enum Effort {
  easy,
  moderate,
  hard,
  failure;

  String get label => switch (this) {
        Effort.easy => 'Easy',
        Effort.moderate => 'Moderate',
        Effort.hard => 'Hard',
        Effort.failure => 'Failure',
      };

  static Effort fromKey(String? v) => Effort.values
      .firstWhere((e) => e.name == v, orElse: () => Effort.moderate);
}

/// The role of a set within an exercise.
enum SetType {
  warmUp,
  working,
  dropSet,
  backOff;

  String get label => switch (this) {
        SetType.warmUp => 'Warm Up',
        SetType.working => 'Working',
        SetType.dropSet => 'Drop Set',
        SetType.backOff => 'Back Off',
      };

  static SetType fromKey(String? v) => SetType.values
      .firstWhere((e) => e.name == v, orElse: () => SetType.working);
}

/// Execution style tag for a set.
enum SetForm {
  strict,
  assisted,
  paused,
  explosive,
  controlled;

  String get label => switch (this) {
        SetForm.strict => 'Strict',
        SetForm.assisted => 'Assisted',
        SetForm.paused => 'Paused',
        SetForm.explosive => 'Explosive',
        SetForm.controlled => 'Controlled',
      };

  static SetForm fromKey(String? v) => SetForm.values
      .firstWhere((e) => e.name == v, orElse: () => SetForm.strict);
}

/// A single completed set. Reps and weight are stored as numbers here, having
/// already passed through [NumericInputValidator] at entry time.
class LoggedSet {
  const LoggedSet({
    required this.setNumber,
    required this.reps,
    required this.weightKg,
    this.type = SetType.working,
    this.effort = Effort.moderate,
    this.form = SetForm.strict,
    this.completedAt,
  });

  final int setNumber;
  final int reps;
  final double weightKg;
  final SetType type;
  final Effort effort;
  final SetForm form;
  final DateTime? completedAt;

  bool get hasData => reps > 0 || weightKg > 0;

  Map<String, dynamic> toJson() => {
        'setNumber': setNumber,
        'reps': reps,
        'weightKg': weightKg,
        'type': type.name,
        'effort': effort.name,
        'form': form.name,
        'completedAt': completedAt?.toIso8601String(),
      };

  factory LoggedSet.fromJson(Map<String, dynamic> json) => LoggedSet(
        setNumber: json['setNumber'] as int? ?? 0,
        reps: json['reps'] as int? ?? 0,
        weightKg: (json['weightKg'] as num?)?.toDouble() ?? 0,
        type: SetType.fromKey(json['type'] as String?),
        effort: Effort.fromKey(json['effort'] as String?),
        form: SetForm.fromKey(json['form'] as String?),
        completedAt: json['completedAt'] != null
            ? DateTime.tryParse(json['completedAt'] as String)
            : null,
      );
}

/// All sets logged for one exercise within a session.
class LoggedExercise {
  const LoggedExercise({
    required this.exerciseId,
    required this.exerciseName,
    required this.muscleGroup,
    required this.sets,
  });

  final String exerciseId;
  final String exerciseName;
  final String muscleGroup;
  final List<LoggedSet> sets;

  int get workingSetCount =>
      sets.where((s) => s.type != SetType.warmUp && s.hasData).length;

  Map<String, dynamic> toJson() => {
        'exerciseId': exerciseId,
        'exerciseName': exerciseName,
        'muscleGroup': muscleGroup,
        'sets': sets.map((s) => s.toJson()).toList(),
      };

  factory LoggedExercise.fromJson(Map<String, dynamic> json) => LoggedExercise(
        exerciseId: json['exerciseId'] as String? ?? '',
        exerciseName: json['exerciseName'] as String? ?? '',
        muscleGroup: json['muscleGroup'] as String? ?? 'Other',
        sets: (json['sets'] as List<dynamic>? ?? [])
            .map((s) => LoggedSet.fromJson(Map<String, dynamic>.from(s as Map)))
            .toList(),
      );
}

/// Planned-vs-completed figures for a timed interval session.
class IntervalSessionSummary {
  const IntervalSessionSummary({
    required this.plannedWorkIntervals,
    required this.completedWorkIntervals,
    required this.totalRounds,
    required this.completedRounds,
    required this.plannedSeconds,
    required this.completedSeconds,
  });

  final int plannedWorkIntervals;
  final int completedWorkIntervals;
  final int totalRounds;
  final int completedRounds;
  final int plannedSeconds;
  final int completedSeconds;

  bool get targetMet =>
      plannedWorkIntervals > 0 &&
      completedWorkIntervals >= plannedWorkIntervals;

  double get completionRatio => plannedWorkIntervals <= 0
      ? 0
      : completedWorkIntervals / plannedWorkIntervals;

  Map<String, dynamic> toJson() => {
        'plannedWorkIntervals': plannedWorkIntervals,
        'completedWorkIntervals': completedWorkIntervals,
        'totalRounds': totalRounds,
        'completedRounds': completedRounds,
        'plannedSeconds': plannedSeconds,
        'completedSeconds': completedSeconds,
      };

  factory IntervalSessionSummary.fromJson(Map<String, dynamic> json) =>
      IntervalSessionSummary(
        plannedWorkIntervals: json['plannedWorkIntervals'] as int? ?? 0,
        completedWorkIntervals: json['completedWorkIntervals'] as int? ?? 0,
        totalRounds: json['totalRounds'] as int? ?? 0,
        completedRounds: json['completedRounds'] as int? ?? 0,
        plannedSeconds: json['plannedSeconds'] as int? ?? 0,
        completedSeconds: json['completedSeconds'] as int? ?? 0,
      );
}

/// A completed workout — either a strength session (with [loggedExercises]) or
/// a timed interval session (with an [intervalSummary]).
class WorkoutSession {
  const WorkoutSession({
    required this.id,
    required this.planId,
    required this.planName,
    required this.startedAt,
    required this.finishedAt,
    required this.type,
    this.loggedExercises = const [],
    this.intervalSummary,
  });

  final String id;
  final String planId;
  final String planName;
  final DateTime startedAt;
  final DateTime finishedAt;
  final WorkoutSessionType type;
  final List<LoggedExercise> loggedExercises;
  final IntervalSessionSummary? intervalSummary;

  bool get isInterval =>
      type == WorkoutSessionType.interval || intervalSummary != null;
  bool get isGym => !isInterval;

  int get durationMinutes =>
      finishedAt.difference(startedAt).inMinutes.clamp(0, 100000);

  int get totalSets => loggedExercises.fold(
        0,
        (sum, e) => sum + e.sets.where((s) => s.hasData).length,
      );

  int get exerciseCount => loggedExercises.length;

  Map<String, dynamic> toJson() => {
        'id': id,
        'planId': planId,
        'planName': planName,
        'startedAt': startedAt.toIso8601String(),
        'finishedAt': finishedAt.toIso8601String(),
        'type': type.name,
        'loggedExercises': loggedExercises.map((e) => e.toJson()).toList(),
        'intervalSummary': intervalSummary?.toJson(),
      };

  factory WorkoutSession.fromJson(Map<String, dynamic> json) {
    final Object? summaryJson = json['intervalSummary'];
    final IntervalSessionSummary? summary = summaryJson is Map
        ? IntervalSessionSummary.fromJson(
            Map<String, dynamic>.from(summaryJson))
        : null;
    final WorkoutSessionType parsedType =
        WorkoutSessionType.fromKey(json['type'] as String?);
    return WorkoutSession(
      id: json['id'] as String,
      planId: json['planId'] as String? ?? '',
      planName: json['planName'] as String? ?? '',
      startedAt: DateTime.tryParse(json['startedAt'] as String? ?? '') ??
          DateTime.fromMillisecondsSinceEpoch(0),
      finishedAt: DateTime.tryParse(json['finishedAt'] as String? ?? '') ??
          DateTime.fromMillisecondsSinceEpoch(0),
      type: summary != null ? WorkoutSessionType.interval : parsedType,
      loggedExercises: (json['loggedExercises'] as List<dynamic>? ?? [])
          .map((e) =>
              LoggedExercise.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList(),
      intervalSummary: summary,
    );
  }
}
