import 'package:intl/intl.dart';

import '../shared/models/workout_session.dart';

/// One column in the "workouts per week" chart.
class WeekCount {
  const WeekCount({
    required this.label,
    required this.count,
    required this.isCurrent,
  });

  final String label;
  final int count;
  final bool isCurrent;
}

/// Computes weekly training frequency and an overall consistency rate.
class WorkoutFrequencyCalculator {
  const WorkoutFrequencyCalculator();

  /// Counts workouts per week across the last [weeks] weeks ending at
  /// [reference] (oldest column first, the last column labelled "Now").
  List<WeekCount> weeklyCounts(
    List<WorkoutSession> sessions, {
    required DateTime reference,
    int weeks = 8,
  }) {
    final List<WeekCount> out = [];
    for (int i = weeks - 1; i >= 0; i--) {
      final DateTime end = reference.subtract(Duration(days: i * 7));
      final DateTime start = end.subtract(const Duration(days: 7));
      final int count = sessions
          .where((s) =>
              s.finishedAt.isAfter(start) &&
              (s.finishedAt.isBefore(end) || s.finishedAt == end))
          .length;
      out.add(WeekCount(
        label: i == 0 ? 'Now' : DateFormat('d MMM').format(start),
        count: count,
        isCurrent: i == 0,
      ));
    }
    return out;
  }

  /// Average workouts per week across the active span (first → last session).
  /// Returns 0 when there is no history.
  double consistencyRate(List<WorkoutSession> sessions) {
    if (sessions.isEmpty) return 0;
    final DateTime first = sessions
        .map((s) => s.finishedAt)
        .reduce((a, b) => a.isBefore(b) ? a : b);
    final DateTime last = sessions
        .map((s) => s.finishedAt)
        .reduce((a, b) => a.isAfter(b) ? a : b);
    final double spanDays = last.difference(first).inHours / 24.0;
    final double weeksSpan = (spanDays / 7).clamp(1, double.infinity);
    return sessions.length / weeksSpan;
  }
}
