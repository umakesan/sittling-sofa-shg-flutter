# 0001. Offline-first Flutter client on a pinned older toolchain

Status: accepted

## Context

Field workers enter SHG registers in villages with poor connectivity, so the app must work offline. The same codebase also needs a web build for the office.

The project's Dart SDK constraint is `>=3.3.0` (see `frontend/pubspec.yaml`). Newer Flutter/package APIs failed to compile against it, as the commits `71e1630`, `4cc1fdd` and `cd3b20e` record.

## Decision

- One Flutter app for Android, iOS and web, talking to the FastAPI backend.
- On native, entries are written to a local Drift (SQLite) database first and pushed by a manual Sync (`SyncService`). On web there is no local database; every read and write goes to the API.
- Stay compatible with the older toolchain: use `CardTheme` not `CardThemeData`, `Color.withOpacity` not `withValues`, pin `intl` to `^0.18.1` and `google_fonts` to `^6.3.0`, pin `drift` to 2.19.0, and do not add `drift_flutter` (it needs Dart 3.4+).

## Consequences

- Workers need one online login first to seed credentials and data locally.
- Warning logic and reports are computed on the client against local data.
- Raising the Flutter/Dart floor means revisiting these pins.
