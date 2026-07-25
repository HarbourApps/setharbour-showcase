# The smart insight engine

SetHarbour describes your training in plain English using a small, deterministic
rule engine that runs entirely on-device.

## Deterministic rules

There is **no machine learning, no external AI and no network call**. Every
summary is produced by explicit rules operating on the numbers in a session or
in your recent history. Given the same input, the engine always produces exactly
the same output — a property directly asserted in the tests
(`identical history produces identical insight output`).

The engine has two responsibilities:

1. **Session summaries** (`SessionSummaryBuilder`) — describe one completed
   session for the history detail screen.
2. **Home insights** (`InsightEngine.homeInsights`) — produce the ordered
   contextual messages for the dashboard ticker.

## Raw metrics versus user-facing comments

The engine is split deliberately:

- **Metrics** (`SessionSummaryBuilder`, the progress calculators): pure numbers
  — total sets, exercise count, rest consistency, workload completion, planned
  vs completed intervals, weekly frequency, etc.
- **Wording** (`InsightWording`): pure functions mapping those facts to fixed
  sentences.

Keeping numbers and prose apart means the classification logic can be tested on
its numbers alone, and the copy can be tuned without touching the rules.

## Minimum evidence thresholds

The engine refuses to over-claim:

- With **no history**, it returns onboarding guidance ("Start your first workout
  to build momentum."), not fabricated stats.
- A **frequency** insight ("4 workouts logged this week.") is only emitted when
  the *previous* week also has data and this week genuinely exceeds it — so it
  never asserts an increase it cannot evidence.
- A **progress/workload** insight is likewise gated on the previous window
  having sets to compare against.

The test `insufficient data avoids unreliable claims` locks this in.

## Prioritisation

When several insights qualify, they are ordered **deterministically** by a fixed
priority (frequency > progress > last-workout), with ties broken by a stable id.
The ticker then rotates through them in that order. The test
`competing insights are prioritised deterministically` verifies the ordering is
non-increasing in priority.

## How gym and interval summaries differ

- **Gym sessions** are classified from effort distribution and rest consistency
  into *Controlled*, *Balanced* or *Demanding*, and the sentence describes set
  spacing, execution and whether the target workload was completed cleanly.
- **Interval sessions** are classified from planned length and completion into
  *Steady*, *Challenging* or *Demanding timed workout* (or *Partial* if ended
  early), and the sentence reports intervals, rounds and minutes of timer work.

## Never inventing completion

An interval session that was ended early (completed intervals < planned) is
classified as **Partial** and worded accordingly ("ended before the full plan
was finished"). The engine will never say a session was "finished in full" or
"completed successfully" unless the numbers show it was — asserted by
`incomplete interval sessions make no false completion claim`.

## Why identical input produces identical output

Every step is a pure function of the input with no clocks, randomness or hidden
state (the only time reference — "this week" — is passed in explicitly). This
determinism is what makes the feature trustworthy: the same history always reads
the same way, and it is what makes the engine straightforward to test.

## Privacy advantage over cloud AI analysis

Because analysis is local and rule-based, your workout data never leaves the
device to be summarised. There is no server round-trip, no third-party model and
nothing to leak — you get readable insight with zero data exposure.

## Limitations of rule-based interpretation

Rules trade nuance for transparency and privacy. The engine won't infer subtle,
cross-exercise patterns the way a large statistical model might, and its
classifications are intentionally coarse. That is an accepted trade-off: every
statement it makes is explainable, reproducible and private.
