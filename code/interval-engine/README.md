# Interval timer state engine

**Related screenshot:** [`../../screenshots/interval-workflow.png`](../../screenshots/interval-workflow.png)

## The problem

An interval workout is a state machine — an optional get-ready countdown, then
rounds of work and rest, then completion — with pause/resume and skip controls.
Timers that depend on the wall clock are notoriously hard to test and easy to
leak (duplicate timers, timers left running after dispose).

## The design approach

`IntervalEngine` (a `ChangeNotifier`) **separates the logic from the clock**:

- `advance()` applies exactly **one second** of progress and is a pure state
  transition (`getReady → work → rest → next round → done`).
- In a live app, a `Timer.periodic` simply calls `advance()` once per second.
- Tests drive `advance()` directly, so every transition is verified with **no
  real waiting**, and the output is fully deterministic.

Controls (`pause`, `resume`, `nextRound`, `previousRound`) and a completion
summary (`buildSummary()` → `IntervalSessionSummary`) round it out.

## Included files

| File | Role |
|---|---|
| `interval_engine.dart` | The deterministic state machine + timer safety. |
| [`../shared/models/interval_plan.dart`](../shared/models/interval_plan.dart) | The `IntervalPlan` model (work/rest/rounds/prepare, derived totals). |
| [`../shared/models/workout_session.dart`](../shared/models/workout_session.dart) | Supplies `IntervalSessionSummary` for the completion summary. |

## Main technical decisions

- **Clock/logic split:** the one-second `advance()` step makes the whole engine
  unit-testable without fake-async plumbing or timing flakiness.
- **No duplicate timers:** `_ensureTimer()` is null-guarded, so repeated
  `start()`/`resume()` calls never stack a second periodic timer (asserted via a
  `timersCreated` counter).
- **Always disposes:** `dispose()` cancels the timer; a test confirms no timer
  remains active afterwards.
- **Deterministic completion:** `buildSummary()` reports planned vs completed
  intervals/rounds honestly, feeding the insight engine without inventing
  completion.

Covered by [`../../test-examples/interval_engine_test.dart`](../../test-examples/interval_engine_test.dart).
