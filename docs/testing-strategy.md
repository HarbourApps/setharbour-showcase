# Testing strategy

Testing focuses where the risk is: the pure domain logic. Because behaviour is
kept out of the widgets, most of it can be verified with fast, deterministic unit
tests.

> The excerpts included in this showcase live under [`../test-examples/`](../test-examples/).
> In the complete private SetHarbour project these run as the app's test suite;
> here they are provided for review only. The logic-test files are listed below;
> the full project additionally includes widget/screen tests that are not part of
> this excerpt.

## What is tested, and why there

| Area | File (in `test-examples/`) | Focus |
|---|---|---|
| Model serialisation | `serialization_test.dart` | `toJson`/`fromJson` round-trips for every model + the whole backup document. |
| Backup & import | `backup_service_test.dart` | Encode/decode round trip, malformed/wrong-app/missing-version/unsupported-version rejection, unknown-field tolerance, merge/dedupe. |
| Validation | `numeric_input_validator_test.dart` | The three-digit rule, decimals, no truncation, empty handling, and the exact Superman message. |
| Plan browser | `plan_browser_controller_test.dart` | Folder counts, category/difficulty/combined filters, clearing filters, shared-collection guarantee, persisted preferred view. |
| Insight engine | `insight_engine_test.dart` | Onboarding, minimum-evidence guards, frequency/progress insights, gym vs interval summaries, determinism, prioritisation, no false completion. |
| Progress calcs | `progress_service_test.dart` | Weekly counts, totals, personal-best ranking, muscle-group totals, most-used plan, most improved/performed/consistent, consistency rate, empty safety. |
| Interval engine | `interval_engine_test.dart` | Get-ready → work → rest → round progression → done, pause/resume, next/previous round, disposal, no duplicate timers. |

## Principles

- **Deterministic by construction.** The domain logic has no clocks or
  randomness (the only time reference is injected), so tests never flake. The
  interval engine is driven by a manual `advance()` rather than real time.
- **Test the rule, not the pixels.** Validation, insights, progress and timing
  are asserted on their pure outputs.
- **Assert the branded copy exactly.** The Superman message is checked verbatim,
  so it cannot silently change.
- **Synthetic fixtures.** Tests build their own small sessions, or use the
  deterministic `DemoDataset`, so results are stable and contain no real data.

## Scope of this excerpt

The selected files are sanitised excerpts from the production application and are
intended for code review. The complete runnable Android application is available
through Google Play.

## Where coverage could grow

Natural extensions include golden tests for the ticker/visual identity, more
exhaustive property-based validation cases, and integration tests that drive a
full log-a-workout → view-in-history flow.
