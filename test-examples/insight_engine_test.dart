import 'package:flutter_test/flutter_test.dart';
import '../code/insight-engine/insight_engine.dart';
import '../code/insight-engine/insight_models.dart';
import '../code/shared/models/workout_session.dart';

const InsightEngine engine = InsightEngine();
final DateTime ref = DateTime(2026, 7, 25, 12);

WorkoutSession gym(DateTime finished,
    {int sets = 3, Effort effort = Effort.moderate}) {
  return WorkoutSession(
    id: 'g${finished.millisecondsSinceEpoch}',
    planId: 'p',
    planName: 'Legs Day',
    startedAt: finished.subtract(const Duration(minutes: 50)),
    finishedAt: finished,
    type: WorkoutSessionType.gym,
    loggedExercises: [
      LoggedExercise(
        exerciseId: 'ex',
        exerciseName: 'Squat',
        muscleGroup: 'Legs',
        sets: [
          for (int i = 0; i < sets; i++)
            LoggedSet(
              setNumber: i + 1,
              reps: 8,
              weightKg: 60,
              effort: effort,
              completedAt: finished.subtract(Duration(minutes: (sets - i) * 3)),
            ),
        ],
      ),
    ],
  );
}

WorkoutSession interval(DateTime finished,
    {int planned = 10, int completed = 10, int seconds = 1200}) {
  return WorkoutSession(
    id: 'i${finished.millisecondsSinceEpoch}',
    planId: 'ip',
    planName: 'Harbour Cardio Builder',
    startedAt: finished.subtract(Duration(seconds: seconds)),
    finishedAt: finished,
    type: WorkoutSessionType.interval,
    intervalSummary: IntervalSessionSummary(
      plannedWorkIntervals: planned,
      completedWorkIntervals: completed,
      totalRounds: planned,
      completedRounds: completed,
      plannedSeconds: seconds,
      completedSeconds: (seconds * completed / planned).round(),
    ),
  );
}

void main() {
  test('no workouts returns onboarding guidance', () {
    final List<HomeInsight> out = engine.homeInsights(const []);
    expect(out, hasLength(1));
    expect(out.single.type, HomeInsightType.onboarding);
  });

  test('insufficient data avoids unreliable "increase" claims', () {
    // Two sessions this week, none in the previous week.
    final out = engine.homeInsights(
      [
        gym(ref.subtract(const Duration(days: 1))),
        gym(ref.subtract(const Duration(days: 2)))
      ],
      reference: ref,
    );
    expect(out.any((i) => i.type == HomeInsightType.frequency), isFalse);
    expect(out.any((i) => i.type == HomeInsightType.progress), isFalse);
  });

  test('increased frequency produces a frequency insight', () {
    final out = engine.homeInsights(
      [
        // previous week: 1 session
        gym(ref.subtract(const Duration(days: 10))),
        // this week: 3 sessions
        gym(ref.subtract(const Duration(days: 1))),
        gym(ref.subtract(const Duration(days: 3))),
        gym(ref.subtract(const Duration(days: 5))),
      ],
      reference: ref,
    );
    expect(out.any((i) => i.type == HomeInsightType.frequency), isTrue);
  });

  test('increased workload produces a progress insight', () {
    final out = engine.homeInsights(
      [
        gym(ref.subtract(const Duration(days: 10)), sets: 2), // prev week low
        gym(ref.subtract(const Duration(days: 2)), sets: 6), // this week high
      ],
      reference: ref,
    );
    expect(out.any((i) => i.type == HomeInsightType.progress), isTrue);
  });

  test('a completed gym workout produces a gym summary', () {
    final s = engine.summariseSession(gym(ref, sets: 3));
    expect(s.isInterval, isFalse);
    expect(s.completed, isTrue);
  });

  test('a completed interval workout produces an interval summary', () {
    final s =
        engine.summariseSession(interval(ref, planned: 10, completed: 10));
    expect(s.isInterval, isTrue);
    expect(s.completed, isTrue);
    expect(s.badge, isNotEmpty);
  });

  test('identical history produces identical insight output', () {
    final a = engine.homeInsights([gym(ref.subtract(const Duration(days: 1)))],
        reference: ref);
    final b = engine.homeInsights([gym(ref.subtract(const Duration(days: 1)))],
        reference: ref);
    expect(a.map((i) => '${i.type}:${i.message}').toList(),
        b.map((i) => '${i.type}:${i.message}').toList());
  });

  test('competing insights are prioritised deterministically', () {
    final out = engine.homeInsights(
      [
        gym(ref.subtract(const Duration(days: 10)), sets: 2),
        gym(ref.subtract(const Duration(days: 1)), sets: 6),
        gym(ref.subtract(const Duration(days: 3)), sets: 6),
      ],
      reference: ref,
    );
    // Priorities are non-increasing (sorted highest first).
    for (int i = 1; i < out.length; i++) {
      expect(out[i - 1].priority >= out[i].priority, isTrue);
    }
  });

  test('incomplete interval sessions make no false completion claim', () {
    final s = engine.summariseSession(
        interval(ref, planned: 10, completed: 6, seconds: 1200));
    expect(s.completed, isFalse);
    expect(s.classification, SessionClassification.partialSession);
    expect(s.body.contains('finished in full'), isFalse);
    expect(s.body.contains('completed successfully'), isFalse);
  });
}
