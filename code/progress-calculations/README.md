# Progress & statistics calculations

**Related screenshot:** [`../../screenshots/progress-dashboard.png`](../../screenshots/progress-dashboard.png)

## The problem

The progress screen shows a lot of derived numbers — weekly training frequency,
personal bests, muscle-group focus, most performed / consistent / improved
exercises, consistency rate, hours trained, most-used plan. These must be
**computed from the actual session history**, not hard-coded to match a mockup,
and must be stable and reproducible.

## The design approach

Small, single-responsibility **calculators**, each pure and independently
testable, orchestrated by a `ProgressService` that returns one `ProgressStats`
view model for the UI to render:

- `PersonalBestCalculator` — heaviest set per exercise, ranked.
- `WorkoutFrequencyCalculator` — weekly counts over 8 weeks + consistency rate.
- `MuscleGroupAggregator` — sets per muscle group, sorted.
- `ExerciseInsightCalculator` — most performed / consistent / improved.
- `ProgressService` — totals, averages, most-used plan; combines the above.

## Included files

| File | Role |
|---|---|
| `personal_best_calculator.dart` | Best (heaviest) set per exercise, deterministically ranked. |
| `workout_frequency_calculator.dart` | 8-week weekly counts and average workouts/week. |
| `muscle_group_aggregator.dart` | Working-set totals per muscle group. |
| `exercise_insight_calculator.dart` | Most performed / consistent / most improved exercise. |
| `progress_service.dart` | Orchestrator → `ProgressStats` view model. |
| [`../shared/models/workout_session.dart`](../shared/models/workout_session.dart) | The session model all calculators read. |

## Main technical decisions

- **Derived, never hard-coded:** every figure comes from the supplied sessions;
  a test verifies "most improved" is the exercise with the largest programmed
  gain in the synthetic data (Leg Press).
- **Deterministic ordering:** ties are broken by explicit, stable rules (weight
  then reps then name), so rankings never shuffle.
- **Composable & pure:** each calculator is separately unit-tested, and the
  service just assembles them — easy to extend with new metrics.
- **Empty-safe:** with no history the service returns a valid, empty result
  rather than throwing.

Covered by [`../../test-examples/progress_service_test.dart`](../../test-examples/progress_service_test.dart).
