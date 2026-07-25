import '../shared/models/workout_session.dart';
import 'exercise_insight_calculator.dart';
import 'muscle_group_aggregator.dart';
import 'personal_best_calculator.dart';
import 'workout_frequency_calculator.dart';

/// The fully-calculated view model for the progress dashboard.
class ProgressStats {
  const ProgressStats({
    required this.totalWorkouts,
    required this.totalSets,
    required this.totalMinutes,
    required this.avgSessionMinutes,
    required this.consistencyRate,
    required this.weeklyCounts,
    required this.personalBests,
    required this.muscleGroups,
    required this.highlights,
    required this.mostUsedPlan,
  });

  final int totalWorkouts;
  final int totalSets;
  final int totalMinutes;
  final int avgSessionMinutes;
  final double consistencyRate;
  final List<WeekCount> weeklyCounts;
  final List<PersonalBest> personalBests;
  final List<MuscleGroupTotal> muscleGroups;
  final ExerciseHighlights highlights;
  final String? mostUsedPlan;

  double get hoursTrained => totalMinutes / 60.0;

  bool get isEmpty => totalWorkouts == 0;
}

/// Orchestrates the individual calculators into a single [ProgressStats].
///
/// Every figure is derived from the supplied [sessions] — nothing is
/// hard-coded. Given the same sessions, the output is identical every time.
class ProgressService {
  const ProgressService({
    this.personalBests = const PersonalBestCalculator(),
    this.frequency = const WorkoutFrequencyCalculator(),
    this.muscleGroups = const MuscleGroupAggregator(),
    this.exerciseInsights = const ExerciseInsightCalculator(),
  });

  final PersonalBestCalculator personalBests;
  final WorkoutFrequencyCalculator frequency;
  final MuscleGroupAggregator muscleGroups;
  final ExerciseInsightCalculator exerciseInsights;

  ProgressStats compute(
    List<WorkoutSession> sessions, {
    DateTime? reference,
  }) {
    final DateTime anchor = reference ??
        (sessions.isEmpty
            ? DateTime.now()
            : sessions
                .map((s) => s.finishedAt)
                .reduce((a, b) => a.isAfter(b) ? a : b));

    final int totalWorkouts = sessions.length;
    final int totalSets = sessions.fold(0, (sum, s) => sum + s.totalSets);
    final int totalMinutes =
        sessions.fold(0, (sum, s) => sum + s.durationMinutes);
    final int avgSession =
        totalWorkouts == 0 ? 0 : (totalMinutes / totalWorkouts).round();

    return ProgressStats(
      totalWorkouts: totalWorkouts,
      totalSets: totalSets,
      totalMinutes: totalMinutes,
      avgSessionMinutes: avgSession,
      consistencyRate: frequency.consistencyRate(sessions),
      weeklyCounts: frequency.weeklyCounts(sessions, reference: anchor),
      personalBests: personalBests.calculate(sessions),
      muscleGroups: muscleGroups.aggregate(sessions),
      highlights: exerciseInsights.calculate(sessions),
      mostUsedPlan: _mostUsedPlan(sessions),
    );
  }

  String? _mostUsedPlan(List<WorkoutSession> sessions) {
    final Map<String, int> counts = {};
    for (final s in sessions) {
      if (s.planName.isEmpty) continue;
      counts.update(s.planName, (v) => v + 1, ifAbsent: () => 1);
    }
    if (counts.isEmpty) return null;
    final List<String> names = counts.keys.toList()..sort();
    String best = names.first;
    for (final name in names) {
      if (counts[name]! > counts[best]!) best = name;
    }
    return best;
  }
}
