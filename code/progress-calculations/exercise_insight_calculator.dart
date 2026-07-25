import '../shared/models/workout_session.dart';

/// Named-exercise highlights derived from history.
class ExerciseHighlights {
  const ExerciseHighlights({
    required this.mostPerformed,
    required this.mostConsistent,
    required this.mostImproved,
    required this.mostImprovedGainKg,
  });

  /// Exercise with the most logged sets (`null` if there is no data).
  final String? mostPerformed;

  /// Exercise appearing in the most distinct sessions.
  final String? mostConsistent;

  /// Exercise with the largest top-set weight gain from first to last session.
  final String? mostImproved;
  final double mostImprovedGainKg;
}

/// Derives "most performed / consistent / improved" highlights.
class ExerciseInsightCalculator {
  const ExerciseInsightCalculator();

  ExerciseHighlights calculate(List<WorkoutSession> sessions) {
    final Map<String, String> names = {};
    final Map<String, int> setCounts = {};
    final Map<String, Set<String>> sessionsPerExercise = {};
    // Ordered top-set weights per exercise, following session chronology.
    final Map<String, List<double>> topBySession = {};

    final List<WorkoutSession> gym = sessions.where((s) => s.isGym).toList()
      ..sort((a, b) => a.finishedAt.compareTo(b.finishedAt));

    for (final session in gym) {
      for (final exercise in session.loggedExercises) {
        final List<double> weights = exercise.sets
            .where((s) => s.hasData)
            .map((s) => s.weightKg)
            .toList();
        if (weights.isEmpty) continue;
        final String id = exercise.exerciseId;
        names[id] = exercise.exerciseName;
        setCounts.update(id, (v) => v + weights.length,
            ifAbsent: () => weights.length);
        sessionsPerExercise.putIfAbsent(id, () => <String>{}).add(session.id);
        topBySession
            .putIfAbsent(id, () => <double>[])
            .add(weights.reduce((a, b) => a > b ? a : b));
      }
    }

    final String? mostPerformed = _argMax(setCounts, names);
    final String? mostConsistent = _argMax(
      {for (final e in sessionsPerExercise.entries) e.key: e.value.length},
      names,
    );

    String? mostImproved;
    double bestGain = 0;
    final List<String> ids = topBySession.keys.toList()..sort();
    for (final id in ids) {
      final List<double> tops = topBySession[id]!;
      if (tops.length < 2) continue;
      final double gain = tops.last - tops.first;
      if (gain > bestGain) {
        bestGain = gain;
        mostImproved = names[id];
      }
    }

    return ExerciseHighlights(
      mostPerformed: mostPerformed,
      mostConsistent: mostConsistent,
      mostImproved: mostImproved,
      mostImprovedGainKg: bestGain,
    );
  }

  /// Deterministic argmax: highest value wins, ties broken by exercise name.
  String? _argMax(Map<String, int> values, Map<String, String> names) {
    String? bestId;
    int bestValue = -1;
    final List<String> ids = values.keys.toList()..sort();
    for (final id in ids) {
      final int v = values[id]!;
      if (v > bestValue ||
          (v == bestValue &&
              bestId != null &&
              (names[id] ?? '').compareTo(names[bestId] ?? '') < 0)) {
        bestValue = v;
        bestId = id;
      }
    }
    return bestId == null ? null : names[bestId];
  }
}
