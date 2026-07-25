import 'dart:math' as math;

import '../shared/models/workout_session.dart';
import 'insight_models.dart';
import 'insight_wording.dart';

/// Turns a raw [WorkoutSession] into a calculated [SessionSummary].
///
/// This is pure and deterministic: identical input always yields identical
/// output. It never invents completion — a session that was ended early is
/// classified as partial and worded accordingly.
class SessionSummaryBuilder {
  const SessionSummaryBuilder();

  SessionSummary build(WorkoutSession session) {
    return session.isInterval ? _interval(session) : _gym(session);
  }

  // ── Gym ────────────────────────────────────────────────────────────────

  SessionSummary _gym(WorkoutSession session) {
    final List<LoggedSet> dataSets = [
      for (final e in session.loggedExercises)
        ...e.sets.where((s) => s.hasData),
    ];
    final int totalSets = dataSets.length;
    final int exerciseCount = session.loggedExercises
        .where((e) => e.sets.any((s) => s.hasData))
        .length;

    final int hardOrFailure = dataSets
        .where((s) => s.effort == Effort.hard || s.effort == Effort.failure)
        .length;
    final bool hasFailure = dataSets.any((s) => s.effort == Effort.failure);
    final double hardShare = totalSets == 0 ? 0 : hardOrFailure / totalSets;

    final _RestStats rest = _restStats(session);
    // A session is "completed" when every logged exercise recorded at least one
    // set with data. We never assert completion beyond what was recorded.
    final bool completed = session.loggedExercises.isNotEmpty &&
        session.loggedExercises.every((e) => e.sets.any((s) => s.hasData));

    final bool controlled = !hasFailure && hardShare <= 0.4 && rest.consistent;
    final SessionClassification classification =
        (hasFailure || hardShare >= 0.5)
            ? SessionClassification.demandingSession
            : controlled
                ? SessionClassification.controlledSession
                : SessionClassification.balancedSession;

    final List<String> chips = [
      '$totalSets sets',
      '$exerciseCount exercises',
      if (rest.hasRest) '${rest.label} rest',
    ];

    return SessionSummary(
      isInterval: false,
      classification: classification,
      completed: completed,
      chips: chips,
      body: InsightWording.gymBody(
        consistentRest: rest.consistent,
        controlled: controlled,
        completed: completed,
      ),
    );
  }

  _RestStats _restStats(WorkoutSession session) {
    final List<int> gaps = [];
    for (final e in session.loggedExercises) {
      final List<DateTime> stamps = e.sets
          .where((s) => s.completedAt != null)
          .map((s) => s.completedAt!)
          .toList()
        ..sort();
      for (int i = 1; i < stamps.length; i++) {
        gaps.add(stamps[i].difference(stamps[i - 1]).inSeconds);
      }
    }
    if (gaps.isEmpty) {
      return const _RestStats(hasRest: false, consistent: false, label: '');
    }
    final double mean = gaps.reduce((a, b) => a + b) / gaps.length;
    final double variance = gaps
            .map((g) => math.pow(g - mean, 2).toDouble())
            .reduce((a, b) => a + b) /
        gaps.length;
    final double cv = mean == 0 ? 0 : math.sqrt(variance) / mean;
    final String label = '${(mean / 60).toStringAsFixed(1)}m';
    return _RestStats(hasRest: true, consistent: cv < 0.25, label: label);
  }

  // ── Interval ───────────────────────────────────────────────────────────

  SessionSummary _interval(WorkoutSession session) {
    final IntervalSessionSummary s = session.intervalSummary ??
        const IntervalSessionSummary(
          plannedWorkIntervals: 0,
          completedWorkIntervals: 0,
          totalRounds: 0,
          completedRounds: 0,
          plannedSeconds: 0,
          completedSeconds: 0,
        );
    final int minutes = (s.plannedSeconds / 60).round();
    final bool completed = s.targetMet;

    final SessionClassification classification;
    if (!completed) {
      classification = SessionClassification.partialSession;
    } else if (minutes >= 18) {
      classification = SessionClassification.demandingTimedWorkout;
    } else if (minutes >= 10) {
      classification = SessionClassification.challengingIntervalSession;
    } else {
      classification = SessionClassification.steadyIntervalSession;
    }

    final List<String> chips = [
      '${s.plannedWorkIntervals} intervals',
      '${s.totalRounds} rounds',
      '$minutes min',
      minutes >= 15 ? 'Hard interval' : 'Timed interval',
    ];

    return SessionSummary(
      isInterval: true,
      classification: classification,
      completed: completed,
      chips: chips,
      body: InsightWording.intervalBody(
        classification: classification,
        intervals: s.plannedWorkIntervals,
        completedIntervals: s.completedWorkIntervals,
        rounds: s.totalRounds,
        minutes: minutes,
      ),
    );
  }
}

class _RestStats {
  const _RestStats({
    required this.hasRest,
    required this.consistent,
    required this.label,
  });
  final bool hasRest;
  final bool consistent;
  final String label;
}
