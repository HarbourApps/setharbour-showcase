import 'insight_models.dart';

/// The user-facing sentence layer for session summaries.
///
/// Kept separate from the metric calculations so wording can be tuned without
/// touching the rules, and so the rules can be unit-tested on their numbers
/// alone. Every function here is a pure mapping from facts to a fixed sentence,
/// which is what makes the engine deterministic.
class InsightWording {
  InsightWording._();

  /// Onboarding guidance shown when there is no history yet. Deliberately
  /// makes no claims about progress.
  static const String onboarding =
      'Start your first workout to build momentum.';

  static String gymBody({
    required bool consistentRest,
    required bool controlled,
    required bool completed,
  }) {
    final String spacing = consistentRest
        ? 'Set spacing was consistent from start to finish'
        : 'Set spacing varied across the session';
    final String execution = controlled
        ? 'alongside disciplined execution throughout'
        : 'with several efforts pushed close to the limit';
    final String close = completed
        ? 'The target workload was completed cleanly.'
        : 'The planned workload was not finished in full.';
    return '$spacing, $execution. $close';
  }

  static String intervalBody({
    required SessionClassification classification,
    required int intervals,
    required int completedIntervals,
    required int rounds,
    required int minutes,
  }) {
    switch (classification) {
      case SessionClassification.demandingTimedWorkout:
        return 'The interval workout was finished in full. This session '
            'covered $intervals intervals across $rounds rounds and $minutes '
            'min of planned timer work. This was a longer interval session '
            'with a meaningful conditioning demand.';
      case SessionClassification.challengingIntervalSession:
        return 'All planned timer blocks were completed successfully. This '
            'session covered $intervals intervals across $rounds rounds and '
            '$minutes min of planned timer work. The total timer length pushed '
            'this beyond a quick finisher.';
      case SessionClassification.steadyIntervalSession:
        return 'All $intervals planned intervals were completed across $rounds '
            'rounds and $minutes min of timer work. A short, sharp '
            'conditioning finisher.';
      case SessionClassification.partialSession:
        return 'This session covered $completedIntervals of $intervals planned '
            'intervals across $rounds rounds. It was ended before the full '
            'plan was finished.';
      default:
        return 'This interval session covered $completedIntervals of '
            '$intervals planned intervals.';
    }
  }
}
