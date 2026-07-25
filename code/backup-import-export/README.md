# Local JSON backup, import & export

**Related screenshot:** [`../../screenshots/backup-and-privacy.png`](../../screenshots/backup-and-privacy.png)

## The problem

A privacy-first app that keeps everything on-device still needs to let users move
their data — to back it up or migrate it — **without an account or a cloud
service**. That means robust local serialisation, and an import path that safely
rejects anything malformed while never losing data the user already has.

## The design approach

`BackupService` serialises the entire dataset (`PortfolioBackup`) to
pretty-printed JSON. In the app the file is handed to the OS **share sheet** (no
storage permission, no network); import uses the system **file picker**. The
interesting logic is pure and fully tested:

- `encode(...)` → JSON string.
- `decode(...)` → validates and parses, throwing `BackupImportException` for
  malformed JSON, a wrong/missing app marker, or a missing/unsupported version.
- `merge(base, incoming)` → merges **by id**, so importing the same file twice
  changes nothing (idempotent) and on-device data is never overwritten.

`DemoDataset` builds a fully synthetic, deterministic dataset used for the demo
and the tests.

## Included files

| File | Role |
|---|---|
| `backup_service.dart` | `encode` / `decode` / `merge` (pure) + thin share/file-picker wrappers. |
| `demo_dataset.dart` | Synthetic, deterministic demo data (no real users or identifiers). |
| [`../shared/models/portfolio_backup.dart`](../shared/models/portfolio_backup.dart) | The whole-snapshot document model (version + app marker). |
| [`../shared/models/`](../shared/models/) — `exercise.dart`, `workout_plan.dart`, `interval_plan.dart`, `workout_session.dart` | The domain models that are serialised. |

## Main technical decisions

- **Validation before trust:** wrong app marker, missing version and
  newer-than-supported versions are all rejected with clear messages.
- **Idempotent, non-destructive merge:** matching ids are kept, only genuinely
  new entities are appended — re-importing is safe.
- **No network, user-controlled:** export goes through the OS share sheet to a
  destination the user picks; nothing is uploaded.
- **Pure core:** `encode`/`decode`/`merge` have no plugin dependencies and are
  covered by [`../../test-examples/backup_service_test.dart`](../../test-examples/backup_service_test.dart)
  and [`../../test-examples/serialization_test.dart`](../../test-examples/serialization_test.dart).
