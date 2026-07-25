# Privacy-first design

SetHarbour is built so that your training data stays yours. This document
describes how, and what the portfolio edition does and does not do.

## Local device storage

All workout data — plans, exercises, sessions and interval plans — lives on the
device. The production app persists it in local device storage; the portfolio
edition holds it in memory seeded from a bundled synthetic dataset. In neither
case is data sent anywhere automatically.

## No mandatory account

There is no sign-up, no login and no user identity. You can install and use the
app immediately. Nothing is tied to an email address or account.

## No adverts

There are no ad SDKs and no ad placements anywhere in the app.

## No analytics

There is no analytics, telemetry or tracking SDK. The app does not record how
you use it and does not phone home.

## No external workout-data processing

No workout data is uploaded for server-side processing. The "smart" history
summaries are produced entirely on-device by a deterministic rule engine (see
[`insight-engine.md`](insight-engine.md)) — there is **no external AI and no
network request** involved.

## User-controlled JSON export

You can export a full backup as a plain, human-readable JSON file. The app
writes it to a temporary file and hands it to the operating system's share
sheet — you choose where it goes (a file, a cloud drive of your choosing, a
messaging app). No storage permission is required, and the developer never
sees it.

## User-controlled JSON import

You can import a previously exported JSON backup via the system file picker.
Imports are validated (app marker, schema version, structure) and merged by id,
so importing the same file twice is harmless.

## Android backup considerations

The portfolio's Android manifest sets `android:allowBackup="false"` and provides
`dataExtractionRules` that exclude app storage from both cloud auto-backup and
device-to-device transfer. This means the OS will not silently copy on-device
workout data to a cloud backup — the only way data leaves the device is a
deliberate user-initiated export.

## What production configuration was deliberately excluded

To keep this repository safe to publish, the following production-only material
is **intentionally not present**:

- Signing configuration, keystore and any keystore path or password.
- The production release build configuration.
- Store listing / commercial configuration.
- Google Play Billing / Pro-unlock (in-app purchase) logic.
- Any production application ID, product identifiers or private release assets.
- Any real user data, real workout history, or personal backups.

## What the portfolio edition does and does not collect

- **Collects:** nothing about you. The only thing written to device preferences
  is a single UI setting — your preferred plan-browser view (`folders`/`list`).
- **Contains:** a fully synthetic demo dataset with invented plans, exercises
  and sessions. No real names, notes, identifiers, paths or credentials.
- **Sends:** nothing, except when *you* tap Export (to a destination you pick)
  or tap the support link (which opens the public HarbourApps support page in
  your browser).
