# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this is

Sittilingi SHG Portal — a Flutter mobile app (offline-first) paired with a FastAPI backend for SHG monthly bookkeeping used by SOFA field workers. Full product requirements and API spec are in `docs/solution-architecture.md`.

## First-time setup (new developer)

### Prerequisites
- Python 3.11+
- Flutter 3.19+ (`flutter doctor` should pass)
- Docker Desktop (for local Postgres)
- Git

### 1 — Clone and enter the repo
```bash
git clone https://github.com/umakesan/sittling-sofa-shg-flutter
cd sittling-sofa-shg-flutter
```

### 2 — Backend: create `.env`
Create `backend/.env` — this file is gitignored and must be created manually:
```
DATABASE_URL=postgresql+psycopg://postgres:postgres@localhost:5432/sittilingi_shg
CORS_ORIGINS=["http://localhost:4200","http://localhost:8000","http://localhost"]
JWT_SECRET_KEY=change-me-in-production
```
For the production server use the real DB credentials instead of the defaults above.

### 3 — Backend: install dependencies and run migrations
```bash
cd backend
python3 -m venv .venv
source .venv/bin/activate          # Windows: .venv\Scripts\activate
pip install -e ".[dev]"
```
Start Postgres (Docker):
```bash
cd ..
docker compose up -d db
```
Apply migrations and seed data:
```bash
cd backend
alembic upgrade head
python seed.py
```

### 4 — Flutter: install dependencies
```bash
cd frontend
flutter pub get
# local_db.g.dart is committed — no need to run build_runner unless schema changes
```

### 5 — API URL (env-based switching)
The API URL is set via `--dart-define-from-file` at build/run time. Two env files are provided (both gitignored):

| File | Points to |
|------|-----------|
| `frontend/.env.local.json` | `http://localhost:8000` (local backend) |
| `frontend/.env.dev.json` | `http://139.59.60.230:8000` (dev server) |

Copy `.env.example.json` as a starting point if these don't exist yet.

### 6 — Run
```bash
# Backend (local)
cd backend && uvicorn app.main:app --reload

# Flutter web — local backend
cd frontend
flutter build web --profile --dart-define-from-file=.env.local.json
cd build/web && python -m http.server 4200

# Flutter web — dev server
cd frontend
flutter build web --profile --dart-define-from-file=.env.dev.json
cd build/web && python -m http.server 4200

# Flutter native (Android/iOS)
cd frontend && flutter run --dart-define-from-file=.env.local.json
# or against dev server:
cd frontend && flutter run --dart-define-from-file=.env.dev.json
```

### Default login credentials (seeded)
| User ID | Password | Role |
|---------|----------|------|
| `admin` | `admin123` | Admin |
| `field1` | `sofa1234` | Field Worker |

---

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

### Auth

No sign-up flow. Users are created manually in the backend database by an admin (via `seed.py` or direct DB insert).

**Online login:** POST credentials to `/api/v1/auth/login` → JWT (7-day expiry) stored in `flutter_secure_storage`. On success, groups and entries are synced from server into local Drift DB.

**Offline login:** compares entered password against a SHA-256 hash cached locally during the last successful online login. Requires at least one prior online login on that device.

**Critical assumption:** field workers must first log in from a location with internet (e.g. the SOFA office). This seeds the local DB with credentials, groups, and entries needed for offline use.

**Web:** always online — no local DB used. Auth and data come entirely from the API.

### What's not built yet

- AI image extraction (models defined, no service or upload endpoint)
- Month-on-month jump validation
- Role-based access enforcement beyond the `role` field in JWT
