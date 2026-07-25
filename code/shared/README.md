# Shared

Code used by more than one feature, kept here as a **single authoritative copy**
(rather than duplicated into each feature folder) so the showcase stays DRY and
imports resolve cleanly.

## `models/`

Pure, serialisable domain models with no Flutter dependencies:

| File | Used by |
|---|---|
| `workout_session.dart` | interval-engine, insight-engine, progress-calculations, backup-import-export |
| `workout_plan.dart` | plan-browser, backup-import-export |
| `interval_plan.dart` | interval-engine, backup-import-export |
| `exercise.dart` | backup-import-export |
| `portfolio_backup.dart` | backup-import-export (imports the four models above) |

## `ui/`

Small shared presentation helpers:

| File | Used by |
|---|---|
| `app_colours.dart` | animated-ticker, exercise-validation, plan-browser |
| `surface_card.dart` | plan-browser |

Feature folders import these with relative paths, e.g.
`import '../shared/models/workout_session.dart';` and
`import '../shared/ui/app_colours.dart';`.
