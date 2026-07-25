# Plan browser (folder + list)

**Related screenshot:** [`../../screenshots/plans-folder-and-list.png`](../../screenshots/plans-folder-and-list.png)

## The problem

Different users organise plans differently: some think in **folders** (Push Pull
Legs, 5×5, Upper/Lower), others prefer to **scan and filter a flat list** by
category and difficulty. The browser must offer both — without duplicating data,
and without the two views ever drifting out of sync.

## The design approach

`PlanBrowserController` (a `ChangeNotifier`) holds **one immutable
`List<WorkoutPlan>`**. Each plan carries an optional `folderId`. The two views
are just two *renderings* of that single list:

- **Folder view** groups the plans by `folderId`.
- **List view** shows them flat.

The same category/difficulty filters apply to both, so switching views never
changes which plans are shown. The preferred view is persisted via
`PreferencesService` (`shared_preferences`).

## Included files

| File | Role |
|---|---|
| `plan_browser_controller.dart` | View mode, filter state, shared-collection logic, preferred-view persistence. |
| `preferences_service.dart` | Thin `shared_preferences` wrapper for the preferred view. |
| `folder_card.dart`, `plan_list_card.dart` | Reusable cards for the two presentations. |
| `plan_filter_chips.dart`, `plan_view_toggle.dart` | Category/difficulty chips and the Folders/List toggle. |
| [`../shared/models/workout_plan.dart`](../shared/models/workout_plan.dart) | The `WorkoutPlan` / `PlanFolder` / `PlanItem` models (with `folderId`). |
| [`../shared/ui/app_colours.dart`](../shared/ui/app_colours.dart), [`../shared/ui/surface_card.dart`](../shared/ui/surface_card.dart) | Shared theme + card surface. |

## Main technical decisions

- **One model, two presentations:** folders are produced by *grouping*, never by
  holding a second copy — proven by a test asserting the folder-grouped plans
  equal the flat filtered list.
- **Filters are view-agnostic:** they operate on the shared collection, so a
  filtered result is identical whichever view is active.
- **Persisted default:** long-pressing a view saves it; a fresh controller
  reloads it on startup.
- **Reusable cards:** `FolderCard` and `PlanListCard` are standalone widgets so
  the same list card is used in both list view and a folder's detail screen.
