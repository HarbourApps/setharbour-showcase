import '../shared/models/workout_session.dart';

/// A best-ever lift for one exercise.
class PersonalBest {
  const PersonalBest({
    required this.exerciseId,
    required this.exerciseName,
    required this.weightKg,
    required this.reps,
    required this.achievedOn,
  });

  final String exerciseId;
  final String exerciseName;
  final double weightKg;
  final int reps;
  final DateTime achievedOn;
}

/// Finds the heaviest logged set per exercise and ranks them.
class PersonalBestCalculator {
  const PersonalBestCalculator();

  /// Returns one [PersonalBest] per exercise, ranked by weight (heaviest
  /// first). Ties are broken by reps, then by the earliest achievement date so
  /// the ordering is fully deterministic.
  List<PersonalBest> calculate(List<WorkoutSession> sessions) {
    final Map<String, PersonalBest> best = {};

    for (final session in sessions.where((s) => s.isGym)) {
      for (final exercise in session.loggedExercises) {
        for (final set in exercise.sets.where((s) => s.hasData)) {
          final PersonalBest candidate = PersonalBest(
            exerciseId: exercise.exerciseId,
            exerciseName: exercise.exerciseName,
            weightKg: set.weightKg,
            reps: set.reps,
            achievedOn: set.completedAt ?? session.finishedAt,
          );
          final PersonalBest? current = best[exercise.exerciseId];
          if (current == null || _beats(candidate, current)) {
            best[exercise.exerciseId] = candidate;
          }
        }
      }
    }

    final List<PersonalBest> ranked = best.values.toList();
    ranked.sort((a, b) {
      final int byWeight = b.weightKg.compareTo(a.weightKg);
      if (byWeight != 0) return byWeight;
      final int byReps = b.reps.compareTo(a.reps);
      if (byReps != 0) return byReps;
      return a.exerciseName.compareTo(b.exerciseName);
    });
    return ranked;
  }

  bool _beats(PersonalBest candidate, PersonalBest current) {
    if (candidate.weightKg != current.weightKg) {
      return candidate.weightKg > current.weightKg;
    }
    if (candidate.reps != current.reps) return candidate.reps > current.reps;
    // Same weight and reps: keep the earliest achievement.
    return candidate.achievedOn.isBefore(current.achievedOn);
  }
}
