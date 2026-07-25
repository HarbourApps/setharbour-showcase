/// How a completed session is characterised by the rule-based engine.
enum SessionClassification {
  controlledSession,
  demandingSession,
  balancedSession,
  demandingTimedWorkout,
  challengingIntervalSession,
  steadyIntervalSession,
  partialSession;

  /// The short badge label shown above a session summary.
  String get badge {
    switch (this) {
      case SessionClassification.controlledSession:
        return 'Controlled session';
      case SessionClassification.demandingSession:
        return 'Demanding session';
      case SessionClassification.balancedSession:
        return 'Balanced session';
      case SessionClassification.demandingTimedWorkout:
        return 'Demanding timed workout';
      case SessionClassification.challengingIntervalSession:
        return 'Challenging interval session';
      case SessionClassification.steadyIntervalSession:
        return 'Steady interval session';
      case SessionClassification.partialSession:
        return 'Partial session';
    }
  }
}

/// A calculated, presentation-ready summary of one session.
///
/// This is the boundary between *metrics* (numbers derived from the raw
/// session) and *wording* (the human sentence). The numbers live here; the
/// sentence is produced by the wording layer and stored in [body].
class SessionSummary {
  const SessionSummary({
    required this.isInterval,
    required this.classification,
    required this.body,
    required this.chips,
    required this.completed,
  });

  final bool isInterval;
  final SessionClassification classification;

  /// The deterministic, user-facing paragraph.
  final String body;

  /// Short stat chips shown under the badge (e.g. `21 sets`, `10 intervals`).
  final List<String> chips;

  /// Whether the planned work was completed in full.
  final bool completed;

  String get badge => classification.badge;
}

/// Category of a home-dashboard ticker insight, used for prioritisation.
enum HomeInsightType {
  onboarding,
  frequency,
  progress,
  lastWorkout,
  readiness,
}

/// A single contextual message for the animated status ticker.
class HomeInsight {
  const HomeInsight({
    required this.id,
    required this.type,
    required this.message,
    required this.priority,
  });

  final String id;
  final HomeInsightType type;
  final String message;

  /// Higher wins when the ticker orders competing messages.
  final int priority;
}
