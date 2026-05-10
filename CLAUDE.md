# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this is

Sittilingi SHG Portal — a Flutter mobile app (offline-first) paired with a FastAPI backend for SHG monthly bookkeeping used by SOFA field workers. Full product requirements and API spec are in `docs/solution-architecture.md`.

## Development commands

### Database (Docker)
```bash
docker compose up -d db        # PostgreSQL on localhost:5432
```

### Backend
```bash
cd backend
source .venv/bin/activate      # or: python3 -m venv .venv && pip install -e ".[dev]"
alembic upgrade head            # apply migrations
python seed.py                  # seed groups and sample entries
uvicorn app.main:app --reload   # API at http://localhost:8000/docs
```

Run tests (use SQLite in-memory, no Docker needed):
```bash
cd backend && pytest
pytest tests/test_month_entry_flow.py::test_create_month_entry_marks_warning_status_when_totals_look_suspicious
```

### Flutter frontend
```bash
cd frontend
flutter pub get
flutter pub run build_runner build    # regenerate drift local_db.g.dart
flutter run                           # default device
flutter run -d chrome                 # web
flutter run -d android
flutter test
```

## Architecture

### Data flow (offline-first)

Every entry is written **locally first** via Drift (SQLite on Android/iOS, IndexedDB on web). The `SyncService` then POSTs `pending_sync` entries to the FastAPI backend when the worker taps Sync. The key identifiers:

- `localId` — UUID generated on device, permanent primary key in the local DB
- `serverId` — populated only after a successful sync; null means not yet synced

### Flutter frontend (`frontend/lib/`)

**State management:** Riverpod. Two root providers live in `providers/shared_providers.dart` — `localDbProvider` (single `LocalDb` instance) and `apiClientProvider` (single `ApiClient`). Feature providers (`entriesProvider`, `groupsProvider`) are `AsyncNotifierProvider`s that read these.

**Navigation:** `go_router` declared in `main.dart`. Routes: `/login` → `/` (HomeScreen) → `/entries/new` → `/ledger/:groupId` → `/dashboard`.

**Local DB:** Drift schema in `database/local_db.dart`. After any schema change, run `build_runner build` to regenerate `local_db.g.dart`. The `_openConnection()` function at the bottom uses `driftDatabase(name: 'shg_portal')` — Drift picks the right executor (SQLite vs IndexedDB) per platform automatically.

**Warning logic is duplicated intentionally:** `entries_provider.dart::_buildWarnings()` mirrors `backend/app/services/validation.py::build_warning_flags()`. Both must stay in sync — the Flutter side shows live warnings while typing; the backend revalidates on save.

**API client:** `api/api_client.dart` uses Dio + `flutter_secure_storage` for JWT. The `baseUrl` defaults to `http://localhost:8000` — update `ApiClient()` instantiation in `shared_providers.dart` for production.

### Backend (`backend/app/`)

**Request path:** `main.py` → `api/router.py` → `api/v1/endpoints/{groups,month_entries,reports}.py`

- `api/deps.py` — yields SQLAlchemy `Session` via `Depends(db_session)`.
- `services/validation.py` — `build_warning_flags(entry)` + `derive_status()` called on every create/update.
- `core/config.py` — Pydantic-settings; reads `.env`. Key: `DATABASE_URL`, `CORS_ORIGINS`.
- The `month_entries` table has a unique constraint on `(group_id, entry_month)`.

**Tests** use SQLite in-memory (no Postgres needed). `conftest.py` seeds two Groups and a User, overrides `db_session`, and suppresses startup events.

**Auth** is not yet implemented — `users` table and `UserRole` enum exist but there is no login endpoint or JWT middleware.

### What's not built yet

- AI image extraction (models defined, no service or upload endpoint)
- Auth / JWT login endpoint  
- Flutter `flutter_secure_storage` on web requires additional setup (falls back to `localStorage`)
