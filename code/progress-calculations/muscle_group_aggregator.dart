import '../shared/models/workout_session.dart';

/// Total working sets performed for one muscle group.
class MuscleGroupTotal {
  const MuscleGroupTotal({required this.muscleGroup, required this.sets});
  final String muscleGroup;
  final int sets;
}

/// Aggregates logged sets by muscle group (the "muscle group focus" bars).
class MuscleGroupAggregator {
  const MuscleGroupAggregator();

  /// Returns totals sorted by set count (largest first). Ties are broken
  /// alphabetically for stable ordering.
  List<MuscleGroupTotal> aggregate(List<WorkoutSession> sessions) {
    final Map<String, int> totals = {};
    for (final session in sessions.where((s) => s.isGym)) {
      for (final exercise in session.loggedExercises) {
        final int sets = exercise.sets.where((s) => s.hasData).length;
        if (sets == 0) continue;
        totals.update(
          exercise.muscleGroup,
          (value) => value + sets,
          ifAbsent: () => sets,
        );
      }
    }
    final List<MuscleGroupTotal> list = totals.entries
        .map((e) => MuscleGroupTotal(muscleGroup: e.key, sets: e.value))
        .toList();
    list.sort((a, b) {
      final int bySets = b.sets.compareTo(a.sets);
      return bySets != 0 ? bySets : a.muscleGroup.compareTo(b.muscleGroup);
    });
    return list;
  }
}
