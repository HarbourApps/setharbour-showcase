import 'package:flutter_test/flutter_test.dart';
import '../code/backup-import-export/demo_dataset.dart';
import '../code/shared/models/exercise.dart';
import '../code/shared/models/interval_plan.dart';
import '../code/shared/models/portfolio_backup.dart';
import '../code/shared/models/workout_plan.dart';
import '../code/shared/models/workout_session.dart';

void main() {
  test('Exercise round-trips through JSON', () {
    const e = Exercise(
        id: 'ex1', name: 'Squat', muscleGroup: 'Legs', isPreset: false);
    final Exercise back = Exercise.fromJson(e.toJson());
    expect(back.id, e.id);
    expect(back.name, e.name);
    expect(back.muscleGroup, e.muscleGroup);
    expect(back.isPreset, isFalse);
    expect(back.isCustom, isTrue);
  });

  test('WorkoutPlan round-trips through JSON', () {
    const plan = WorkoutPlan(
      id: 'p1',
      name: 'Upper A',
      category: PlanCategory.upper,
      difficulty: Difficulty.advanced,
      folderId: 'f1',
      estimatedMinutes: 50,
      items: [PlanItem(exerciseId: 'ex1', targetSets: 3, targetReps: 10)],
    );
    final WorkoutPlan back = WorkoutPlan.fromJson(plan.toJson());
    expect(back.name, 'Upper A');
    expect(back.category, PlanCategory.upper);
    expect(back.difficulty, Difficulty.advanced);
    expect(back.folderId, 'f1');
    expect(back.exerciseCount, 1);
  });

  test('LoggedSet round-trips through JSON', () {
    final set = LoggedSet(
      setNumber: 2,
      reps: 8,
      weightKg: 77.5,
      type: SetType.working,
      effort: Effort.hard,
      form: SetForm.strict,
      completedAt: DateTime(2026, 7, 20, 17, 32),
    );
    final LoggedSet back = LoggedSet.fromJson(set.toJson());
    expect(back.reps, 8);
    expect(back.weightKg, 77.5);
    expect(back.effort, Effort.hard);
    expect(back.completedAt, set.completedAt);
  });

  test('WorkoutSession (gym) round-trips through JSON', () {
    final session = WorkoutSession(
      id: 's1',
      planId: 'p1',
      planName: 'Legs Day',
      startedAt: DateTime(2026, 7, 20, 17, 20),
      finishedAt: DateTime(2026, 7, 20, 18, 10),
      type: WorkoutSessionType.gym,
      loggedExercises: [
        const LoggedExercise(
          exerciseId: 'ex1',
          exerciseName: 'Squat',
          muscleGroup: 'Legs',
          sets: [LoggedSet(setNumber: 1, reps: 10, weightKg: 60)],
        ),
      ],
    );
    final WorkoutSession back = WorkoutSession.fromJson(session.toJson());
    expect(back.isGym, isTrue);
    expect(back.durationMinutes, 50);
    expect(back.totalSets, 1);
    expect(back.loggedExercises.single.exerciseName, 'Squat');
  });

  test('WorkoutSession (interval) round-trips and stays interval', () {
    final session = WorkoutSession(
      id: 's2',
      planId: 'ip1',
      planName: 'Classic Tabata',
      startedAt: DateTime(2026, 7, 25, 9, 30),
      finishedAt: DateTime(2026, 7, 25, 9, 34),
      type: WorkoutSessionType.interval,
      intervalSummary: const IntervalSessionSummary(
        plannedWorkIntervals: 8,
        completedWorkIntervals: 8,
        totalRounds: 8,
        completedRounds: 8,
        plannedSeconds: 240,
        completedSeconds: 240,
      ),
    );
    final WorkoutSession back = WorkoutSession.fromJson(session.toJson());
    expect(back.isInterval, isTrue);
    expect(back.intervalSummary!.targetMet, isTrue);
  });

  test('IntervalPlan round-trips through JSON', () {
    const plan = IntervalPlan(
      id: 'ip1',
      name: 'Classic Tabata',
      workSeconds: 20,
      restSeconds: 10,
      rounds: 8,
    );
    final IntervalPlan back = IntervalPlan.fromJson(plan.toJson());
    expect(back.intervals, 8);
    expect(back.bodySeconds, 240);
    expect(back.displayMinutes, 4);
  });

  test('PortfolioBackup round-trips the whole demo dataset', () {
    final PortfolioBackup original = DemoDataset.build();
    final PortfolioBackup back = PortfolioBackup.fromJson(original.toJson());
    expect(back.app, PortfolioBackup.appTag);
    expect(back.version, PortfolioBackup.currentVersion);
    expect(back.plans.length, original.plans.length);
    expect(back.intervalPlans.length, original.intervalPlans.length);
    expect(back.sessions.length, original.sessions.length);
    expect(back.exercises.length, original.exercises.length);
  });
}
