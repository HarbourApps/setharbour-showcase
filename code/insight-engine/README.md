# Deterministic insight engine

**Related screenshot:** [`../../screenshots/smart-history-insights.png`](../../screenshots/smart-history-insights.png)

## The problem

Users want to know *how a session went* at a glance, and get light contextual
nudges on the dashboard — without any of it being sent to a server for "AI"
analysis, and without the app inventing trends it can't back up.

## The design approach

A small, rule-based engine that runs **entirely on-device** with **no network
and no external AI**. Given the same input it always produces the same output.
It has two jobs:

1. **Session summaries** (`SessionSummaryBuilder`) — classify a completed session
   (e.g. *Controlled*, *Demanding timed workout*, *Challenging interval
   session*, *Partial*) and produce a plain-English paragraph.
2. **Home insights** (`InsightEngine.homeInsights`) — the ordered ticker messages
   (frequency, workload/progress, last workout, or onboarding).

Metrics (the numbers) are kept separate from wording (the sentences).

## Included files

| File | Role |
|---|---|
| `insight_models.dart` | `SessionSummary`, `SessionClassification`, `HomeInsight` types. |
| `session_summary_builder.dart` | Pure metrics → classification for gym vs interval sessions. |
| `insight_wording.dart` | Pure fact → fixed-sentence mapping (the user-facing copy). |
| `insight_engine.dart` | Home-ticker rules, minimum-evidence guards, deterministic prioritisation. |
| [`../shared/models/workout_session.dart`](../shared/models/workout_session.dart) | The session model the engine reads. |

## Main technical decisions

- **Deterministic by construction:** no clocks (the "this week" reference is
  passed in), no randomness — identical history reads identically every time.
- **Minimum-evidence guards:** it only claims an "increase" (frequency/workload)
  when the previous window actually has data, so it never over-claims.
- **Never invents completion:** a session ended early is classified *Partial* and
  worded accordingly — it is never described as "finished in full".
- **Metrics ≠ wording:** classification logic is tested on numbers alone; copy
  can be tuned without touching rules.
- **Privacy by design:** because analysis is local and rule-based, workout data
  never leaves the device to be summarised.

Covered by [`../../test-examples/insight_engine_test.dart`](../../test-examples/insight_engine_test.dart).
See also [`../../docs/insight-engine.md`](../../docs/insight-engine.md).
