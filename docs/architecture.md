# Architecture

> **Note:** this document describes the architecture of the complete SetHarbour
> application. **This repository is a code showcase and does not contain that
> `lib/`/`test/` project structure** — the selected excerpts live under
> [`../code/`](../code/) and [`../test-examples/`](../test-examples/). The layout
> below is included to explain how the production app is organised.

The application is organised **feature-first**, with a small shared core and a
strict separation between pure domain logic and Flutter widgets.

## Layers (in the full application)

```
lib/
├── main.dart      Entry point. Loads the demo dataset, then runs the app.
├── app/           Root MaterialApp + the bottom-navigation shell.
├── core/          Cross-cutting, feature-agnostic code:
│   ├── theme/         AppColours + AppTheme (dark/light).
│   ├── validation/    NumericInputValidator + the branded message constant.
│   ├── utilities/     Formatters (durations, dates, weights).
│   └── widgets/       SurfaceCard, SectionHeader (shared building blocks).
├── data/          App-state plumbing:
│   ├── demo/          DemoDataset (canonical synthetic data) + DemoLoader.
│   └── local/         WorkoutRepository (in-memory) + PreferencesService.
├── models/        Pure, serialisable domain models (no Flutter imports).
└── features/      One folder per showcase feature; each owns its screen(s),
                   widgets and its own logic (services / controllers / engines).
```

## Design principles

**Pure logic, thin widgets.** Every non-trivial behaviour lives in a plain Dart
class with no `BuildContext`:

| Concern | Pure class |
|---|---|
| Input validation | `core/validation/NumericInputValidator` |
| Session summaries + home insights | `features/insights/*` |
| Progress statistics | `features/progress/*` (four calculators + orchestrator) |
| Interval timing | `features/intervals/IntervalEngine` |
| Backup encode/decode/merge | `features/backup/BackupService` (static methods) |
| Dashboard weekly stats | `features/dashboard/DashboardSummaryService` |

Because these are pure, they are unit-tested directly and the widgets simply
render their output. This is what keeps screen files small.

**One data model, multiple presentations.** `WorkoutPlan` carries a `folderId`.
The plan browser renders the *same* collection as folders (grouped by
`folderId`) or as a flat list — never as duplicated data. See
`PlanBrowserController`.

**State management.** Intentionally lightweight: `ChangeNotifier` +
`ListenableBuilder`/`setState`. The controllers that hold mutable UI state
(`PlanBrowserController`, `IntervalEngine`, `WorkoutRepository`) are
`ChangeNotifier`s; everything else is stateless and derives from inputs. No
heavyweight state framework is needed for a demo of this size, and it keeps the
data-flow obvious.

**Deterministic demo data.** `DemoDataset.build()` produces a fully synthetic,
deterministic `PortfolioBackup`. The dev tool `tool/generate_demo_json.dart`
writes it to `assets/demo/setharbour_demo_portfolio.json`, and the app loads
that asset **through the real backup import pipeline** (`BackupService.decode`)
on first launch — so startup exercises the same code path a genuine import
would.

## Data flow at startup

```
main()
  └─ WorkoutRepository.loadDemo()
        └─ DemoLoader.load()
              └─ rootBundle → assets/demo/…json → BackupService.decode()
        └─ repository holds the PortfolioBackup in memory
  └─ runApp(SetHarbourApp(repository))
        └─ AppShell reads repository.{sessions, plans, folders, …}
              └─ each feature screen computes its view from those lists
```

## Why in-memory only

The portfolio deliberately keeps data in memory rather than shipping a full
persistence engine. The showcase is about **data shape, analysis and UI**, not
about a database layer; import still merges into the in-memory store, and export
serialises it, so the round-trip is fully demonstrated without the noise of a
storage backend.
