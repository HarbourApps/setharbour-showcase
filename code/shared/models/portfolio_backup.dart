import 'exercise.dart';
import 'interval_plan.dart';
import 'workout_plan.dart';
import 'workout_session.dart';

/// The complete, serialisable snapshot of on-device data.
///
/// This is the document produced by an export and consumed by an import. It is
/// also the shape of the bundled demo dataset in
/// `assets/demo/setharbour_demo_portfolio.json`.
class PortfolioBackup {
  const PortfolioBackup({
    required this.exportedAt,
    required this.exercises,
    required this.folders,
    required this.plans,
    required this.intervalPlans,
    required this.sessions,
    this.version = currentVersion,
    this.app = appTag,
  });

  /// Bump when the on-disk schema changes in a breaking way.
  static const int currentVersion = 1;

  /// Marker used to reject files that are not SetHarbour backups.
  static const String appTag = 'SetHarbour';

  final int version;
  final String app;
  final DateTime exportedAt;
  final List<Exercise> exercises;
  final List<PlanFolder> folders;
  final List<WorkoutPlan> plans;
  final List<IntervalPlan> intervalPlans;
  final List<WorkoutSession> sessions;

  Map<String, dynamic> toJson() => {
        'version': version,
        'app': app,
        'exportedAt': exportedAt.toIso8601String(),
        'exercises': exercises.map((e) => e.toJson()).toList(),
        'folders': folders.map((f) => f.toJson()).toList(),
        'plans': plans.map((p) => p.toJson()).toList(),
        'intervalPlans': intervalPlans.map((p) => p.toJson()).toList(),
        'sessions': sessions.map((s) => s.toJson()).toList(),
      };

  factory PortfolioBackup.fromJson(Map<String, dynamic> json) =>
      PortfolioBackup(
        version: json['version'] as int? ?? currentVersion,
        app: json['app'] as String? ?? '',
        exportedAt: DateTime.tryParse(json['exportedAt'] as String? ?? '') ??
            DateTime.fromMillisecondsSinceEpoch(0),
        exercises: (json['exercises'] as List<dynamic>? ?? [])
            .map((e) => Exercise.fromJson(Map<String, dynamic>.from(e as Map)))
            .toList(),
        folders: (json['folders'] as List<dynamic>? ?? [])
            .map(
                (f) => PlanFolder.fromJson(Map<String, dynamic>.from(f as Map)))
            .toList(),
        plans: (json['plans'] as List<dynamic>? ?? [])
            .map((p) =>
                WorkoutPlan.fromJson(Map<String, dynamic>.from(p as Map)))
            .toList(),
        intervalPlans: (json['intervalPlans'] as List<dynamic>? ?? [])
            .map((p) =>
                IntervalPlan.fromJson(Map<String, dynamic>.from(p as Map)))
            .toList(),
        sessions: (json['sessions'] as List<dynamic>? ?? [])
            .map((s) =>
                WorkoutSession.fromJson(Map<String, dynamic>.from(s as Map)))
            .toList(),
      );
}
