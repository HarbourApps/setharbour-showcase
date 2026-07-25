# Test examples

> **These extracted tests demonstrate how the selected production logic is
> verified. They are provided for portfolio review and are not intended to run
> independently outside the complete private SetHarbour project.**

Focused, deterministic tests for the logic showcased under [`../code/`](../code/).
Because the interesting behaviour is kept out of the widgets, most of it can be
verified with fast unit tests.

| File | Covers | Feature folder |
|---|---|---|
| `numeric_input_validator_test.dart` | Three-digit rule, decimals, no truncation, empty handling, and the **exact Superman message** (asserted verbatim). | [exercise-validation](../code/exercise-validation/) |
| `serialization_test.dart` | `toJson`/`fromJson` round-trips for every model + the whole backup document. | [backup-import-export](../code/backup-import-export/) |
| `backup_service_test.dart` | Encode/decode round trip, malformed / wrong-app / missing-version / unsupported-version rejection, unknown-field tolerance, idempotent merge. | [backup-import-export](../code/backup-import-export/) |
| `plan_browser_controller_test.dart` | Folder counts, category/difficulty/combined filters, clearing filters, shared-collection guarantee, persisted preferred view. | [plan-browser](../code/plan-browser/) |
| `insight_engine_test.dart` | Onboarding, minimum-evidence guards, frequency/progress insights, gym vs interval summaries, determinism, prioritisation, no false completion. | [insight-engine](../code/insight-engine/) |
| `progress_service_test.dart` | Weekly counts, totals, personal-best ranking, muscle-group totals, most-used plan, most improved/performed/consistent, empty safety. | [progress-calculations](../code/progress-calculations/) |
| `interval_engine_test.dart` | All state transitions, pause/resume, next/previous round, completion, disposal, no duplicate timers. | [interval-engine](../code/interval-engine/) |

## Notes

- These are logic tests extracted from the full application; widget/screen tests
  were left out along with the recreated screens.
- Test imports use relative paths to the selected files included in this showcase.
- The examples demonstrate the production testing approach but are not provided as an independently runnable test suite because the complete private Flutter project and package configuration are excluded.
- The tests are deterministic (no clocks or randomness — the interval engine is
  driven by a manual `advance()`), which is what makes them reliable.

See [`../docs/testing-strategy.md`](../docs/testing-strategy.md) for the rationale.
