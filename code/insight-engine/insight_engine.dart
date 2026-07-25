import '../shared/models/workout_session.dart';
import 'insight_models.dart';
import 'insight_wording.dart';
import 'session_summary_builder.dart';

/// Deterministic, rule-based analysis of local workout history.
///
/// No network, no external AI: the same input always produces the same output.
/// The engine is careful never to assert a trend it cannot evidence — an
/// "increase" is only reported when the comparison window actually has data.
class InsightEngine {
  const InsightEngine({SessionSummaryBuilder? summaryBuilder})
      : _summaryBuilder = summaryBuilder ?? const SessionSummaryBuilder();

  final SessionSummaryBuilder _summaryBuilder;

  /// Builds the per-session summary shown on the history detail screen.
  SessionSummary summariseSession(WorkoutSession session) =>
      _summaryBuilder.build(session);

  /// Produces the ordered list of contextual messages for the home ticker.
  ///
  /// [reference] anchors the "this week" window; when omitted it defaults to
  /// the most recent session (or, if there are none, the epoch — which yields
  /// onboarding guidance).
  List<HomeInsight> homeInsights(
    List<WorkoutSession> sessions, {
    DateTime? reference,
  }) {
    if (sessions.isEmpty) {
      return const [
        HomeInsight(
          id: 'onboarding',
          type: HomeInsightType.onboarding,
          message: InsightWording.onboarding,
          priority: 100,
        ),
      ];
    }

    final DateTime anchor = reference ??
        sessions
            .map((s) => s.finishedAt)
            .reduce((a, b) => a.isAfter(b) ? a : b);

    final List<WorkoutSession> thisWeek =
        _within(sessions, anchor.subtract(const Duration(days: 7)), anchor);
    final List<WorkoutSession> prevWeek = _within(
      sessions,
      anchor.subtract(const Duration(days: 14)),
      anchor.subtract(const Duration(days: 7)),
    );

    final int thisCount = thisWeek.length;
    final int prevCount = prevWeek.length;
    final int thisSets = _sets(thisWeek);
    final int prevSets = _sets(prevWeek);

    final List<HomeInsight> insights = [];

    // Frequency — only claim an increase when the previous week had data.
    if (prevCount >= 1 && thisCount > prevCount && thisCount >= 2) {
      insights.add(HomeInsight(
        id: 'frequency',
        type: HomeInsightType.frequency,
        message: '$thisCount workouts logged this week.',
        priority: 70,
      ));
    }

    // Progress / workload — same minimum-evidence guard.
    if (prevSets >= 1 && thisSets > prevSets) {
      insights.add(HomeInsight(
        id: 'progress',
        type: HomeInsightType.progress,
        message: 'Workload is up this week — $thisSets sets logged.',
        priority: 60,
      ));
    }

    // Last workout — always available once there is any history.
    final WorkoutSession last =
        sessions.reduce((a, b) => a.finishedAt.isAfter(b.finishedAt) ? a : b);
    final SessionSummary lastSummary = _summaryBuilder.build(last);
    insights.add(HomeInsight(
      id: 'last_workout',
      type: HomeInsightType.lastWorkout,
      message: last.isInterval
          ? 'Last session: ${last.planName} — '
              '${last.intervalSummary?.completedWorkIntervals ?? 0} intervals done.'
          : 'Last session: ${last.planName} — ${lastSummary.completed ? 'workload completed' : '${last.totalSets} sets logged'}.',
      priority: 40,
    ));

    _sort(insights);
    return insights;
  }

  List<WorkoutSession> _within(
    List<WorkoutSession> sessions,
    DateTime start,
    DateTime end,
  ) {
    return sessions
        .where((s) =>
            s.finishedAt.isAfter(start) &&
            (s.finishedAt.isBefore(end) || s.finishedAt == end))
        .toList();
  }

  int _sets(List<WorkoutSession> sessions) =>
      sessions.fold(0, (sum, s) => sum + s.totalSets);

  /// Deterministic ordering: highest priority first, ties broken by id.
  void _sort(List<HomeInsight> insights) {
    insights.sort((a, b) {
      final int byPriority = b.priority.compareTo(a.priority);
      return byPriority != 0 ? byPriority : a.id.compareTo(b.id);
    });
  }
}
