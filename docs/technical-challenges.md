# Selected technical challenges

A few of the more interesting problems solved while building this edition.

## Extracting reusable widgets from large screens

The production home, plans and logger screens had grown large. For the portfolio
each was decomposed into small, single-purpose widgets — the dashboard, for
example, is now a thin `DashboardScreen` composing `DashboardHeader`,
`AnimatedStatusTicker`, `WeeklyStatsPanel`, `WeeklyActivityChart`,
`LatestWorkoutCard`, `StartWorkoutButton` and `EmptyDashboard`, with all the
number-crunching pushed into `DashboardSummaryService`. The screen file becomes a
readable layout, and each piece is independently reusable and testable.

## Keeping the demo independent from production configuration

The showcase had to be safe to publish with no secrets. The selected files are
sanitised excerpts from the production application and are intended for code
review — the complete runnable Android application is available through Google
Play. All data used in the excerpts is synthetic, and none of the production
signing/store/billing configuration is present.

## Making one data model support folders and lists

The requirement was that folders and lists be two *views* of one dataset, not
two datasets. `WorkoutPlan` carries an optional `folderId`;
`PlanBrowserController` holds a single immutable plan list and derives folder
view by grouping on `folderId` and list view by flattening, with identical
filters applied to both. A test asserts the two views draw from the same
collection, so they can never diverge.

## Designing reliable timer-state transitions

An interval timer is a state machine (get-ready → work → rest → next round →
done) that is awkward to test if it depends on a real clock. `IntervalEngine`
separates **logic from time**: `advance()` applies exactly one second of
progress and is a pure state transition; in the running app a `Timer.periodic`
just calls `advance()` once per second. Tests drive `advance()` directly and
verify every transition, pause/resume, next/previous round and completion with
no waiting. Timer safety is built in — a null-guard prevents duplicate periodic
timers, and `dispose()` always cancels — both covered by tests.

## Validating user input without interrupting a workout

Mid-workout, validation must be instant and non-blocking. The keypad routes each
press through a pure validator that returns the next value (or the unchanged
previous value on rejection). A rejected keystroke shows a dismissible banner but
never steals focus, clears the field or interrupts the set you're logging.

## Retaining branded validation copy consistently

The Superman message had to remain byte-for-byte identical everywhere it
appears. It is defined once as `kSupermanValidationMessage`, referenced by the
validator, the logger UI and the docs, and asserted verbatim in tests — so it
cannot drift out of sync or be accidentally reworded.

## Producing useful insights without inventing conclusions

The insight engine had to feel smart while never lying. The solution was strict
minimum-evidence thresholds (no "increase" claims without a populated comparison
window) and honest classification of partial sessions. Determinism plus these
guards means every sentence is both useful and defensible. See
[`insight-engine.md`](insight-engine.md).

## Using synthetic data without weakening the demonstration

Synthetic data can look flat if generated naïvely. `DemoDataset` builds eight
weeks of history with **progressive overload** (per-exercise base weights and
weekly increments), a mix of gym and interval sessions, warm-up/working/back-off
set structure and effort/form tags. The result drives believable personal bests,
a genuine "most improved" lift (Leg Press has the largest programmed gain),
muscle-group focus bars and weekly-frequency trends — all *computed* from the
data, not hard-coded — while remaining fully deterministic and free of any real
personal information.
