# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this is

Sittilingi SHG Portal — a Flutter mobile app (offline-first) paired with a FastAPI backend for SHG monthly bookkeeping used by SOFA field workers. Full product requirements and API spec are in `docs/solution-architecture.md`.

---

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

### 2 — Start Postgres (Docker)
```bash
docker compose up -d db
```
Postgres listens on **`localhost:55432`** (mapped from container port 5432 — see `docker-compose.yml`).

### 3 — Backend: create `.env`
Create `backend/.env` — gitignored, must be created manually:
```
DATABASE_URL=postgresql+psycopg://postgres:postgres@localhost:55432/sittilingi_shg
JWT_SECRET_KEY=change-me-in-production
```
> Note: `CORS_ORIGINS` defaults in `app/core/config.py` already include ports 4200 and 4201. Only add it to `.env` if you need to override those defaults.

### 4 — Backend: install dependencies and run migrations
```bash
cd backend
python3 -m venv .venv
source .venv/bin/activate          # Windows: .venv\Scripts\activate
pip install -e ".[dev]"
alembic upgrade head
python seed.py                     # seeds users + sample groups/entries
```

### 5 — Flutter: create env files and install dependencies
The API URL is baked in at build time via `--dart-define-from-file`. Two files are gitignored and must be created manually. Copy from the example:

```bash
cp frontend/.env.example.json frontend/.env.local.json   # edit to point to localhost
cp frontend/.env.example.json frontend/.env.dev.json      # edit to point to dev server
```

| File | Content | Points to |
|------|---------|-----------|
| `frontend/.env.local.json` | `{"API_URL": "http://localhost:8000"}` | Local backend |
| `frontend/.env.dev.json` | `{"API_URL": "http://139.59.60.230:8000"}` | Shared dev server |

```bash
cd frontend
flutter pub get
# local_db.g.dart is committed — no need to run build_runner unless schema changes
```

### 6 — Run everything

Open **three terminals**:

**Terminal 1 — Backend**
```bash
cd backend
source .venv/bin/activate      # Windows: .venv\Scripts\activate
uvicorn app.main:app --reload --port 8000
# API docs at http://localhost:8000/docs
```
> If port 8000 is already in use, run on `--port 8001` and update `frontend/.env.local.json` to match.

**Terminal 2 — Flutter web (local backend)**
```bash
cd frontend
flutter build web --profile --dart-define-from-file=.env.local.json --output=build/web_local
cd build/web_local && python -m http.server 4201
# Open http://localhost:4201
```

**Terminal 3 — Flutter web (dev server) — optional**
```bash
cd frontend
flutter build web --profile --dart-define-from-file=.env.dev.json --output=build/web_dev
cd build/web_dev && python -m http.server 4200
# Open http://localhost:4200
```

**Flutter native (Android/iOS)**
```bash
cd frontend && flutter run --dart-define-from-file=.env.local.json
# or against dev server:
cd frontend && flutter run --dart-define-from-file=.env.dev.json
```

### 7 — Default login credentials (seeded)
| User ID | Password | Role |
|---------|----------|------|
| `admin` | `admin123` | Admin |
| `field1` | `sofa1234` | Field Worker |

### 8 — Import historical savings data (optional)

If you have the Excel file `women savings total.xlsx`, place it in `docs/` and run:

```bash
cd backend
source .venv/bin/activate
pip install openpyxl          # not in pyproject.toml, needed only for this script
python scripts/import_savings.py
```

Expected output:
```
Loading women savings total.xlsx ...
  sittilingi             -> Sittilingi               399 month-records
  ...
Total month-records to insert: 1666
Inserted 50 groups
Inserted 1666 month_entries
Done.
```

The script is idempotent — re-running it upserts without creating duplicates.

---

## Development commands

### Database (Docker)
```bash
docker compose up -d db        # PostgreSQL on localhost:55432
docker compose down            # stop and remove containers (data volume persists)
```

### Backend
```bash
cd backend
source .venv/bin/activate
alembic upgrade head            # apply migrations
python seed.py                  # seed users + sample groups/entries
uvicorn app.main:app --reload --port 8000
```

Run tests (SQLite in-memory — no Docker needed):
```bash
cd backend && pytest
pytest tests/test_month_entry_flow.py::test_create_month_entry_marks_warning_status_when_totals_look_suspicious
```

### Flutter frontend
```bash
cd frontend
flutter pub get
flutter pub run build_runner build    # regenerate drift local_db.g.dart (only on schema change)
flutter run -d chrome                 # web (uses default env — no --dart-define = localhost:8000)
flutter run -d android
flutter test
```

---

## Architecture

### Data flow (offline-first)

On **native (Android/iOS)**: entries are written locally first via Drift (SQLite). The `SyncService` POSTs `pending_sync` entries to the FastAPI backend when the worker taps Sync.

On **web**: always online — no local DB. All reads/writes go directly to the API.

Key identifiers:
- `localId` — UUID generated on device, permanent primary key in the local DB
- `serverId` — populated only after a successful sync; null means not yet synced

### Flutter frontend (`frontend/lib/`)

**State management:** Riverpod. Root providers in `providers/shared_providers.dart`:
- `apiClientProvider` — single `ApiClient`, base URL set at compile time via `--dart-define-from-file`
- `localDbProvider` — single `LocalDb` instance (native only; null on web)
- `groupRepositoryProvider` / `entryRepositoryProvider` — use `ApiGroupRepository`/`ApiEntryRepository` on web, `LocalGroupRepository`/`LocalEntryRepository` on native

**Navigation:** `go_router` in `main.dart`. Routes: `/login` → `/` (HomeScreen) → `/entries/new` → `/ledger/:groupId` → `/dashboard`.

**Local DB:** Drift schema in `database/local_db.dart`. After any schema change, run `build_runner build` to regenerate `local_db.g.dart`.

**Warning logic is duplicated intentionally:** `entries_provider.dart::_buildWarnings()` mirrors `backend/app/services/validation.py::build_warning_flags()`. Both must stay in sync.

**API client:** `api/api_client.dart` uses Dio + `flutter_secure_storage` for JWT. Base URL set via `String.fromEnvironment('API_URL')` — never hardcoded.

### Backend (`backend/app/`)

**Request path:** `main.py` → `api/router.py` → `api/v1/endpoints/{groups,month_entries,reports}.py`

- `api/deps.py` — yields SQLAlchemy `Session` via `Depends(db_session)`.
- `services/validation.py` — `build_warning_flags(entry)` + `derive_status()` called on every create/update.
- `core/config.py` — Pydantic-settings; reads `.env`. Key: `DATABASE_URL`, `CORS_ORIGINS`.
- The `month_entries` table has a unique constraint on `(group_id, entry_month)`.
- The `groups` table has `village_name` as a direct `VARCHAR(120)` column (not a FK — the `villages` table was removed in a later migration).
- Enum values in the DB are uppercase: `MANUAL`, `PREFILL`, `DRAFT`, `SAVED`, `SAVED_WITH_WARNINGS`, `SYNCED`.

**Tests** use SQLite in-memory (no Postgres needed). `conftest.py` seeds two Groups and a User, overrides `db_session`, and suppresses startup events.

### Auth

No sign-up flow. Users are created by an admin via `seed.py` or direct DB insert.

**Online login:** POST credentials → `/api/v1/auth/login` → JWT (7-day expiry) stored in `flutter_secure_storage`. On success, groups and entries sync from server into local Drift DB.

**Offline login:** compares entered password against a SHA-256 hash cached locally during the last successful online login. Requires at least one prior online login on that device.

**Session restore:** on every app open, `AuthService.restoreSession()` decodes the stored JWT client-side, checks expiry, and fires a background sync (`_initialSync`) to keep the local DB fresh.

**Critical assumption:** field workers must first log in from a location with internet (e.g. the SOFA office). This seeds the local DB with credentials, groups, and entries needed for offline use.

**Web:** always online — no local DB. Auth and data come entirely from the API.

### Production server

The shared dev server runs at `http://139.59.60.230:8000`.

- App: `/opt/shg-portal/`
- Systemd service: `shg-api` (`/etc/systemd/system/shg-api.service`)
- Backend `.env` at `/opt/shg-portal/backend/.env`

Deploy a new version:
```bash
ssh root@139.59.60.230
cd /opt/shg-portal && git pull
systemctl restart shg-api
```

### What's not built yet

- AI image extraction (models defined, no service or upload endpoint)
- Month-on-month jump validation
- Role-based access enforcement beyond the `role` field in JWT
