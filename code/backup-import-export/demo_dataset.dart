import '../shared/models/exercise.dart';
import '../shared/models/interval_plan.dart';
import '../shared/models/portfolio_backup.dart';
import '../shared/models/workout_plan.dart';
import '../shared/models/workout_session.dart';

/// Builds the synthetic demonstration dataset.
///
/// Everything here is invented for the portfolio: there are no real users,
/// no personal workout history and no private identifiers. The data is fully
/// deterministic for a given [anchor] date, so the dashboard, progress screen
/// and insight engine all produce stable, reproducible output.
///
/// This same builder is used by `tool/generate_demo_json.dart` to write the
/// bundled `assets/demo/setharbour_demo_portfolio.json` file.
class DemoDataset {
  DemoDataset._();

  /// Fixed reference date used for the bundled JSON asset (matches the
  /// screenshots). Sessions are dated back from here across ~8 weeks.
  static final DateTime defaultAnchor = DateTime(2026, 7, 25, 10, 0);

  static PortfolioBackup build({DateTime? anchor}) {
    final DateTime end = anchor ?? defaultAnchor;
    final List<Exercise> exercises = _exercises();
    final List<PlanFolder> folders = _folders();
    final List<WorkoutPlan> plans = _plans();
    final List<IntervalPlan> intervalPlans = _intervalPlans();
    final List<WorkoutSession> sessions =
        _sessions(end, plans, intervalPlans, exercises);

    return PortfolioBackup(
      exportedAt: end,
      exercises: exercises,
      folders: folders,
      plans: plans,
      intervalPlans: intervalPlans,
      sessions: sessions,
    );
  }

  // ── Exercise library ────────────────────────────────────────────────────

  static List<Exercise> _exercises() => const [
        Exercise(id: 'ex_squat', name: 'Squat', muscleGroup: MuscleGroups.legs),
        Exercise(
            id: 'ex_leg_press',
            name: 'Leg Press',
            muscleGroup: MuscleGroups.legs),
        Exercise(
            id: 'ex_leg_curl',
            name: 'Leg Curl',
            muscleGroup: MuscleGroups.legs),
        Exercise(
            id: 'ex_leg_ext',
            name: 'Leg Extension',
            muscleGroup: MuscleGroups.legs),
        Exercise(
            id: 'ex_calf_raise',
            name: 'Calf Raise',
            muscleGroup: MuscleGroups.calves),
        Exercise(
            id: 'ex_hip_thrust',
            name: 'Hip Thrust',
            muscleGroup: MuscleGroups.glutes),
        Exercise(
            id: 'ex_deadlift',
            name: 'Deadlift',
            muscleGroup: MuscleGroups.back),
        Exercise(
            id: 'ex_rdl',
            name: 'Romanian Deadlift',
            muscleGroup: MuscleGroups.back),
        Exercise(id: 'ex_row', name: 'Row', muscleGroup: MuscleGroups.back),
        Exercise(
            id: 'ex_lat_pulldown',
            name: 'Lat Pulldown',
            muscleGroup: MuscleGroups.back),
        Exercise(
            id: 'ex_bench',
            name: 'Bench Press',
            muscleGroup: MuscleGroups.chest),
        Exercise(
            id: 'ex_incline_db',
            name: 'Incline Dumbbell Press',
            muscleGroup: MuscleGroups.chest),
        Exercise(
            id: 'ex_ohp',
            name: 'Overhead Press',
            muscleGroup: MuscleGroups.shoulders),
        Exercise(
            id: 'ex_lateral_raise',
            name: 'Lateral Raise',
            muscleGroup: MuscleGroups.shoulders),
        Exercise(
            id: 'ex_hammer_curl',
            name: 'Hammer Curl',
            muscleGroup: MuscleGroups.arms),
        Exercise(
            id: 'ex_tricep_pushdown',
            name: 'Tricep Pushdown',
            muscleGroup: MuscleGroups.arms),
      ];

  // ── Folders (5) ─────────────────────────────────────────────────────────

  static List<PlanFolder> _folders() => const [
        PlanFolder(id: 'f_full_body', name: 'Full Body'),
        PlanFolder(id: 'f_ppl', name: 'Push Pull Legs'),
        PlanFolder(id: 'f_5x5', name: '5×5'),
        PlanFolder(id: 'f_split', name: 'Body Part Split'),
        PlanFolder(id: 'f_ul', name: 'Upper / Lower'),
      ];

  // ── Plans (20 across the 5 folders) ──────────────────────────────────────

  static WorkoutPlan _plan(
    String id,
    String name,
    PlanCategory cat,
    Difficulty diff,
    String folderId,
    int minutes,
    List<String> exerciseIds,
  ) {
    return WorkoutPlan(
      id: id,
      name: name,
      category: cat,
      difficulty: diff,
      folderId: folderId,
      estimatedMinutes: minutes,
      items: [
        for (final e in exerciseIds)
          PlanItem(exerciseId: e, targetSets: 3, targetReps: 10),
      ],
    );
  }

  static List<WorkoutPlan> _plans() => [
        // Full Body (3)
        _plan(
            'p_fb_a',
            'Beginner • Full Body A',
            PlanCategory.fullBody,
            Difficulty.beginner,
            'f_full_body',
            35,
            ['ex_squat', 'ex_bench', 'ex_row', 'ex_ohp', 'ex_hammer_curl']),
        _plan('p_fb_b', 'Beginner • Full Body B', PlanCategory.fullBody,
            Difficulty.beginner, 'f_full_body', 35, [
          'ex_deadlift',
          'ex_bench',
          'ex_lat_pulldown',
          'ex_ohp',
          'ex_calf_raise'
        ]),
        _plan('p_fb_c', 'Beginner • Full Body C', PlanCategory.fullBody,
            Difficulty.beginner, 'f_full_body', 35, [
          'ex_leg_press',
          'ex_incline_db',
          'ex_row',
          'ex_lateral_raise',
          'ex_tricep_pushdown'
        ]),
        // Push Pull Legs (6)
        _plan('p_ppl_push1', 'Intermediate • Push Day', PlanCategory.push,
            Difficulty.intermediate, 'f_ppl', 50, [
          'ex_bench',
          'ex_ohp',
          'ex_incline_db',
          'ex_lateral_raise',
          'ex_tricep_pushdown'
        ]),
        _plan(
            'p_ppl_pull1',
            'Intermediate • Pull Day',
            PlanCategory.pull,
            Difficulty.intermediate,
            'f_ppl',
            50,
            ['ex_deadlift', 'ex_row', 'ex_lat_pulldown', 'ex_hammer_curl']),
        _plan('p_ppl_legs1', 'Intermediate • Legs Day', PlanCategory.legs,
            Difficulty.intermediate, 'f_ppl', 50, [
          'ex_squat',
          'ex_rdl',
          'ex_leg_press',
          'ex_leg_curl',
          'ex_calf_raise'
        ]),
        _plan('p_ppl_push2', 'Advanced • Push Volume', PlanCategory.push,
            Difficulty.advanced, 'f_ppl', 60, [
          'ex_bench',
          'ex_incline_db',
          'ex_ohp',
          'ex_lateral_raise',
          'ex_tricep_pushdown'
        ]),
        _plan(
            'p_ppl_pull2',
            'Advanced • Pull Volume',
            PlanCategory.pull,
            Difficulty.advanced,
            'f_ppl',
            60,
            ['ex_deadlift', 'ex_row', 'ex_lat_pulldown', 'ex_hammer_curl']),
        _plan('p_ppl_legs2', 'Advanced • Legs Volume', PlanCategory.legs,
            Difficulty.advanced, 'f_ppl', 60, [
          'ex_squat',
          'ex_leg_press',
          'ex_leg_curl',
          'ex_leg_ext',
          'ex_calf_raise'
        ]),
        // 5x5 (2)
        _plan(
            'p_5x5_a',
            '5×5 • Workout A',
            PlanCategory.fullBody,
            Difficulty.intermediate,
            'f_5x5',
            45,
            ['ex_squat', 'ex_bench', 'ex_row']),
        _plan(
            'p_5x5_b',
            '5×5 • Workout B',
            PlanCategory.fullBody,
            Difficulty.intermediate,
            'f_5x5',
            45,
            ['ex_squat', 'ex_ohp', 'ex_deadlift']),
        // Body Part Split (5)
        _plan(
            'p_split_chest',
            'Chest Day',
            PlanCategory.push,
            Difficulty.intermediate,
            'f_split',
            45,
            ['ex_bench', 'ex_incline_db', 'ex_tricep_pushdown']),
        _plan(
            'p_split_back',
            'Back Day',
            PlanCategory.pull,
            Difficulty.intermediate,
            'f_split',
            45,
            ['ex_deadlift', 'ex_row', 'ex_lat_pulldown']),
        _plan(
            'p_split_legs',
            'Leg Day',
            PlanCategory.legs,
            Difficulty.intermediate,
            'f_split',
            50,
            ['ex_squat', 'ex_leg_press', 'ex_leg_curl', 'ex_calf_raise']),
        _plan('p_split_shoulders', 'Shoulder Day', PlanCategory.push,
            Difficulty.beginner, 'f_split', 40, ['ex_ohp', 'ex_lateral_raise']),
        _plan(
            'p_split_arms',
            'Arm Day',
            PlanCategory.other,
            Difficulty.beginner,
            'f_split',
            35,
            ['ex_hammer_curl', 'ex_tricep_pushdown']),
        // Upper / Lower (4)
        _plan(
            'p_ul_upper1',
            'Upper A',
            PlanCategory.upper,
            Difficulty.intermediate,
            'f_ul',
            50,
            ['ex_bench', 'ex_row', 'ex_ohp', 'ex_hammer_curl']),
        _plan(
            'p_ul_lower1',
            'Lower A',
            PlanCategory.lower,
            Difficulty.intermediate,
            'f_ul',
            50,
            ['ex_squat', 'ex_rdl', 'ex_leg_curl', 'ex_calf_raise']),
        _plan('p_ul_upper2', 'Upper B', PlanCategory.upper, Difficulty.advanced,
            'f_ul', 55, [
          'ex_incline_db',
          'ex_lat_pulldown',
          'ex_lateral_raise',
          'ex_tricep_pushdown'
        ]),
        _plan(
            'p_ul_lower2',
            'Lower B',
            PlanCategory.lower,
            Difficulty.advanced,
            'f_ul',
            55,
            ['ex_deadlift', 'ex_leg_press', 'ex_leg_ext', 'ex_calf_raise']),
      ];

  // ── Interval plans (5, incl. the custom Harbour Cardio Builder) ───────────

  static List<IntervalPlan> _intervalPlans() => const [
        IntervalPlan(
            id: 'ip_tabata',
            name: 'Classic Tabata',
            workSeconds: 20,
            restSeconds: 10,
            rounds: 8),
        IntervalPlan(
            id: 'ip_hiit',
            name: 'HIIT Circuit',
            workSeconds: 40,
            restSeconds: 20,
            rounds: 14),
        IntervalPlan(
            id: 'ip_beginner',
            name: 'Beginner Intervals',
            workSeconds: 30,
            restSeconds: 30,
            rounds: 10),
        IntervalPlan(
            id: 'ip_emom',
            name: 'EMOM 10',
            workSeconds: 45,
            restSeconds: 15,
            rounds: 10),
        IntervalPlan(
            id: 'ip_harbour',
            name: 'Harbour Cardio Builder',
            workSeconds: 60,
            restSeconds: 60,
            rounds: 10,
            isPreset: false),
      ];

  // ── Session history ───────────────────────────────────────────────────────

  // Progressive-overload base weights (kg) and weekly increments, snapped to
  // 2.5kg. weekIndex 0 = oldest week, 7 = most recent.
  static const Map<String, List<double>> _lift = {
    'ex_squat': [60, 2.5],
    'ex_leg_press': [90, 6.5], // largest gain → "most improved"
    'ex_leg_curl': [35, 1.0],
    'ex_leg_ext': [40, 1.0],
    'ex_calf_raise': [45, 1.5],
    'ex_hip_thrust': [70, 2.5],
    'ex_deadlift': [80, 2.5],
    'ex_rdl': [55, 1.5],
    'ex_row': [50, 1.5],
    'ex_lat_pulldown': [45, 1.0],
    'ex_bench': [55, 1.5],
    'ex_incline_db': [24, 1.0],
    'ex_ohp': [35, 1.0],
    'ex_lateral_raise': [10, 0.5],
    'ex_hammer_curl': [16, 0.5],
    'ex_tricep_pushdown': [25, 0.5],
  };

  static double _snap(double v) => (v / 2.5).round() * 2.5;

  static double _weightFor(String exId, int weekIndex) {
    final List<double> spec = _lift[exId] ?? const [40, 1.0];
    return _snap(spec[0] + spec[1] * weekIndex);
  }

  static WorkoutSession _gymSession({
    required String id,
    required WorkoutPlan plan,
    required DateTime start,
    required int weekIndex,
    required Map<String, String> exNames,
    required Map<String, String> exGroups,
  }) {
    final List<LoggedExercise> logged = [];
    for (final item in plan.items) {
      final String exId = item.exerciseId;
      final double top = _weightFor(exId, weekIndex);
      final List<LoggedSet> sets = [
        LoggedSet(
          setNumber: 1,
          reps: 12,
          weightKg: _snap(top * 0.6),
          type: SetType.warmUp,
          effort: Effort.easy,
          form: SetForm.controlled,
          completedAt: start.add(const Duration(minutes: 2)),
        ),
        LoggedSet(
          setNumber: 2,
          reps: 10,
          weightKg: _snap(top * 0.9),
          completedAt: start.add(const Duration(minutes: 5)),
        ),
        LoggedSet(
          setNumber: 3,
          reps: 8,
          weightKg: top,
          effort: Effort.hard,
          completedAt: start.add(const Duration(minutes: 8)),
        ),
      ];
      logged.add(LoggedExercise(
        exerciseId: exId,
        exerciseName: exNames[exId] ?? exId,
        muscleGroup: exGroups[exId] ?? MuscleGroups.other,
        sets: sets,
      ));
    }
    final int minutes = 40 + plan.items.length * 2;
    return WorkoutSession(
      id: id,
      planId: plan.id,
      planName: plan.name,
      startedAt: start,
      finishedAt: start.add(Duration(minutes: minutes)),
      type: WorkoutSessionType.gym,
      loggedExercises: logged,
    );
  }

  static WorkoutSession _intervalSession({
    required String id,
    required IntervalPlan plan,
    required DateTime start,
    required bool completeInFull,
  }) {
    final int planned = plan.intervals;
    final int completed =
        completeInFull ? planned : (planned - 2).clamp(0, planned);
    return WorkoutSession(
      id: id,
      planId: plan.id,
      planName: plan.name,
      startedAt: start,
      finishedAt: start.add(Duration(seconds: plan.bodySeconds)),
      type: WorkoutSessionType.interval,
      intervalSummary: IntervalSessionSummary(
        plannedWorkIntervals: planned,
        completedWorkIntervals: completed,
        totalRounds: plan.rounds,
        completedRounds: completeInFull ? plan.rounds : completed,
        plannedSeconds: plan.bodySeconds,
        completedSeconds: completeInFull
            ? plan.bodySeconds
            : (plan.bodySeconds * completed / planned).round(),
      ),
    );
  }

  static List<WorkoutSession> _sessions(
    DateTime anchor,
    List<WorkoutPlan> plans,
    List<IntervalPlan> intervalPlans,
    List<Exercise> exercises,
  ) {
    final Map<String, String> exNames = {
      for (final e in exercises) e.id: e.name
    };
    final Map<String, String> exGroups = {
      for (final e in exercises) e.id: e.muscleGroup,
    };
    final WorkoutPlan legs = plans.firstWhere((p) => p.id == 'p_ppl_legs1');
    final WorkoutPlan push = plans.firstWhere((p) => p.id == 'p_ppl_push1');
    final WorkoutPlan pull = plans.firstWhere((p) => p.id == 'p_ppl_pull1');
    final IntervalPlan harbour =
        intervalPlans.firstWhere((p) => p.id == 'ip_harbour');
    final IntervalPlan tabata =
        intervalPlans.firstWhere((p) => p.id == 'ip_tabata');

    final List<WorkoutSession> out = [];
    int counter = 0;
    String nextId() => 's_${(++counter).toString().padLeft(3, '0')}';

    // 8 training weeks, weekIndex 7 == this week. Each week: Legs, Push, Pull
    // (gym) = 24; interval days in the 4 most recent weeks (+4) → 28 sessions.
    for (int w = 0; w < 8; w++) {
      final int weekIndex = w;
      final int weeksAgo = 7 - w;
      final DateTime weekStart =
          anchor.subtract(Duration(days: weeksAgo * 7 + 4));

      out.add(_gymSession(
        id: nextId(),
        plan: legs,
        start: DateTime(weekStart.year, weekStart.month, weekStart.day, 17, 20),
        weekIndex: weekIndex,
        exNames: exNames,
        exGroups: exGroups,
      ));
      out.add(_gymSession(
        id: nextId(),
        plan: push,
        start: DateTime(weekStart.year, weekStart.month, weekStart.day, 17, 20)
            .add(const Duration(days: 2)),
        weekIndex: weekIndex,
        exNames: exNames,
        exGroups: exGroups,
      ));
      out.add(_gymSession(
        id: nextId(),
        plan: pull,
        start: DateTime(weekStart.year, weekStart.month, weekStart.day, 9, 30)
            .add(const Duration(days: 4)),
        weekIndex: weekIndex,
        exNames: exNames,
        exGroups: exGroups,
      ));

      if (w >= 4) {
        final IntervalPlan ip = (w == 7) ? harbour : tabata;
        out.add(_intervalSession(
          id: nextId(),
          plan: ip,
          start: DateTime(weekStart.year, weekStart.month, weekStart.day, 9, 30)
              .add(const Duration(days: 5)),
          completeInFull: w != 5,
        ));
      }
    }

    out.sort((a, b) => a.startedAt.compareTo(b.startedAt));
    return out;
  }
}
