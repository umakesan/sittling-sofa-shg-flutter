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
- **For Android APK builds only:** Android Studio with Android SDK Platform 35 installed (see step 9)

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

### 9 — Android APK build setup (only needed for mobile builds)

The `android/` directory and all Gradle config are already committed. You only need to install the correct Android SDK on your machine.

#### Install Android SDK Platform 35

1. Open **Android Studio** → **SDK Manager** (or **More Actions → SDK Manager** from the welcome screen).
2. Under **SDK Platforms**, check **Android API 35** and click Apply / OK.
3. Wait for the download to complete (total SDK directory for API 35 is ~127 MB).

#### Point Flutter at the SDK (if `flutter doctor` complains)

**Windows** — Flutter sometimes finds a stale legacy SDK at `C:\Users\<you>\AppData\Local\Android\sdk` (lowercase). If `flutter doctor` reports a wrong SDK path, run:
```powershell
flutter config --android-sdk "C:\Users\<you>\AppData\Local\Android\Sdk"
```
The correct path (uppercase `Sdk`) is where Android Studio installs by default.

**macOS** — Flutter auto-detects the SDK at `~/Library/Android/sdk`. If `flutter doctor` complains, run:
```bash
flutter config --android-sdk ~/Library/Android/sdk
```

#### Verify everything is ready
```bash
flutter doctor -v
```
All items should be green. The important ones are `Flutter`, `Android toolchain`, and `Android Studio`.

#### Build the APK

Use the `/build-apk` Claude Code skill (`.claude/commands/build-apk.md`) or run manually:
```bash
cd frontend

# Against the shared dev server (http://139.59.60.230:8000)
flutter build apk --dart-define-from-file=.env.dev.json --release

# Against your local backend (use 10.0.2.2 not localhost if testing in emulator)
flutter build apk --dart-define-from-file=.env.local.json --release
```

Output: `frontend/build/app/outputs/flutter-apk/app-release.apk`

Install on a running emulator or device:
```bash
# macOS/Linux
adb install -r build/app/outputs/flutter-apk/app-release.apk

# Windows (if adb not on PATH)
& "$env:LOCALAPPDATA\Android\Sdk\platform-tools\adb.exe" install -r build/app/outputs/flutter-apk/app-release.apk
```

---

## Development commands

### Database (Docker)
```bash
docker compose up -d db        # PostgreSQL on localhost:55432
docker compose down            # stop and remove containers (data volume persists)
docker compose down -v         # full wipe including data volume (use /reimport-data skill after)
```

Use the `/reimport-data` Claude Code skill (`.claude/commands/reimport-data.md`) to fully wipe and rebuild the local DB — runs migrations, seed, and Excel import in one step.

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
flutter gen-l10n                      # regenerate l10n dart files (only if .arb files change)
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

**State management:** Riverpod. Key providers:
- `apiClientProvider` — single `ApiClient`, base URL set at compile time via `--dart-define-from-file`
- `localDbProvider` — single `LocalDb` instance (native only; throws on web)
- `groupRepositoryProvider` / `entryRepositoryProvider` — use `ApiGroupRepository`/`ApiEntryRepository` on web, `LocalGroupRepository`/`LocalEntryRepository` on native
- `connectivityProvider` — `StreamProvider<List<ConnectivityResult>>` tracking network state
- `isOnlineProvider` — derived bool; defaults to `true` if stream has no data yet
- `localeProvider` — `StateNotifier<Locale>`; persisted in `flutter_secure_storage`

**Navigation:** `go_router` in `main.dart`. Routes:
- `/login` → Login screen
- `/` → HomeScreen (wrapped in `AppShell` on tablet ≥600px)
- `/dashboard` → DashboardScreen
- `/entries/new` → NewEntryScreen
- `/entries/edit` → EditEntryScreen (entry passed as route extra)
- `/ledger/:groupId` → LedgerScreen
- `/admin/create-village` → CreateVillageScreen (admin only)
- `/admin/create-group` → CreateGroupScreen (admin only)

Use `context.push()` for stack navigation (back button), `context.go()` only for full replacements (login → home).

**Local DB:** Drift schema in `database/local_db.dart`. After any schema change, run `build_runner build` to regenerate `local_db.g.dart`. The SQLite connection is split by platform: `database/connection/native.dart` uses `NativeDatabase.createBackgroundConnection()` (with `sqlite3_flutter_libs` + `path_provider`); `database/connection/web.dart` throws `UnsupportedError`. **Do not add `drift_flutter`** — it requires Dart 3.4+ and was removed because the project is locked to 3.3.x.

**Warning logic is duplicated intentionally:** `entries_provider.dart::_buildWarnings()` mirrors `backend/app/services/validation.py::build_warning_flags()`. Both must stay in sync. See `docs/warning-logic.txt` for the full spec.

**API client:** `api/api_client.dart` uses Dio + `flutter_secure_storage` for JWT. Base URL set via `String.fromEnvironment('API_URL')` — never hardcoded. Methods: `login`, `fetchGroups`, `createGroup`, `fetchVillageNames`, `createVillage`, `createEntry`, `updateEntry`, `fetchEntries`, `fetchDashboard`.

**Group Dart model** (`models/group.dart`): includes `villageName` (String) and `openingBankBalance` (double). `createGroup` sends `village_name` as a plain string — no village ID.

**Theme:** `theme/app_theme.dart` — Material 3, Noto Sans (Google Fonts), 56px minimum button height for field-worker use. Color palette in `theme/app_colors.dart` (forest green primary, high-contrast status colors). Typography in `theme/app_text_styles.dart` (`AppTextStyles` class — fixed `height: 1.55` on all styles to prevent Tamil script clipping). Do not hardcode colors or text styles — always reference `AppColors` and `AppTextStyles` constants.

**Localization:** Full i18n in `lib/l10n/`. Supported locales: English (`en`), Tamil (`ta`), Tamil+English mixed (`ta_IN`). Source of truth: `lib/l10n/app_en.arb`. After editing `.arb` files run `flutter gen-l10n`. All UI strings must use `AppLocalizations.of(context)!.keyName` — no hardcoded English strings in widgets.

### Backend (`backend/app/`)

**Request path:** `main.py` → `api/router.py` → `api/v1/endpoints/{auth,groups,villages,month_entries,reports}.py`

- `api/deps.py` — yields SQLAlchemy `Session` via `Depends(db_session)`.
- `services/validation.py` — `build_warning_flags(entry)` + `derive_status()` called on every create/update.
- `core/config.py` — Pydantic-settings; reads `.env`. Key: `DATABASE_URL`, `CORS_ORIGINS`.
- The `month_entries` table has a unique constraint on `(group_id, entry_month)`.
- The `groups` table stores `village_name` as a plain `VARCHAR(120)` column (denormalized). Migration `b2c3d4e5f6a7` replaced the old `village_id` FK and dropped the `villages` table.
- `groups` also has `opening_bank_balance NUMERIC(12,2)` (added in migration `c3d4e5f6a7b8`).
- `month_entries` has three SOFA-specific columns added in migration `d4e5f6a7b8c9`: `sofa_loan_disbursed`, `sofa_loan_repayment`, `sofa_loan_interest_collected` (all `NUMERIC(12,2)`, default 0).
- Enum values in the DB are **lowercase**: `manual`, `prefill`, `draft`, `saved`, `saved_with_warnings`, `synced`. SQLAlchemy models use `values_callable=lambda x: [e.value for e in x]` to store the `.value` string, not the enum name.
- **Villages endpoint** (`/api/v1/villages`): `GET` returns list ordered by name; `POST` creates a new village (admin only, 409 if name already exists). Note: the `villages` table was dropped by migration `b2c3d4e5f6a7`; this endpoint still references the `Village` model and needs to be updated to derive distinct village names from the `groups` table.

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

### Navigation

`go_router` routes (all registered in `main.dart`):

| Route | Screen | Notes |
|-------|--------|-------|
| `/login` | LoginScreen | Redirected to if no JWT |
| `/` | HomeScreen | Wrapped in AppShell on tablet |
| `/dashboard` | DashboardScreen | Village-wide totals |
| `/ledger/:groupId` | LedgerScreen | Entry history for one group |
| `/entries/new` | NewEntryScreen | Two-step form |
| `/entries/edit` | EditEntryScreen | Entry passed as route extra |
| `/admin/create-village` | CreateVillageScreen | Admin only |
| `/admin/create-group` | CreateGroupScreen | Admin only |

- Use `context.push(route)` when you need a back-button stack.
- Use `context.go(route)` only for full-stack replacements (login → home, logout → login).
- `DashboardScreen` has an explicit `BackButton` that calls `context.pop()`.

### App drawer (`frontend/lib/widgets/app_drawer.dart`)

A `ConsumerStatefulWidget` Drawer attached to `HomeScreen` on mobile. On tablet (width ≥ 600px), navigation is provided by `AppShell` (`widgets/app_shell.dart`) with a `NavigationRail` instead.

| Item | Web (`kIsWeb`) | Native (Android/iOS) |
|------|---------------|----------------------|
| User header (name + role) | ✓ | ✓ |
| **Language switcher** (En / Ta / Mixed) | ✓ | ✓ |
| **Sync data** | hidden | shown with pending-count Badge |
| **Admin: Create Village** | admin only | admin only |
| **Admin: Create Group** | admin only | admin only |
| **Logout** | ✓ | ✓ |

**Sync flow (native only):**
1. Reads `isOnlineProvider` before attempting.
2. Shows a friendly inline error if offline — does not attempt sync.
3. Calls `ref.read(entriesProvider.notifier).sync()` → `SyncService.syncPending()`.
4. Displays result from `SyncResult` enum (success, noPending, partialFailure, noInternet).

**Logout:** calls `authProvider.notifier.logout()` then `context.go('/login')`.

### AppShell (`frontend/lib/widgets/app_shell.dart`)

Wraps home and dashboard on tablet (viewport ≥ 600px). Renders a `NavigationRail` on the left with Home and Dashboard destinations, plus a language popup menu at the bottom. On mobile this widget is unused — drawer handles navigation instead.

### Platform data flow summary

| | Web | Native (Android/iOS) |
|--|-----|----------------------|
| Data store | API only (no Drift) | Drift SQLite (local) |
| Reads/Writes | Direct API call | Local DB only |
| Sync | N/A (always online) | Manual (drawer) + auto on launch |
| Drawer sync button | Hidden | Visible with pending count |
| Connectivity bar | Hidden | Shown when offline or entries pending |
| Navigation | Drawer (mobile) | Drawer (mobile) / NavigationRail (tablet) |

Auto-sync on launch: `AuthService.restoreSession()` fires `_initialSync()` in the background (non-blocking). Fetches fresh groups and entries from server, upserts into local Drift DB. UI loads from local DB instantly.

### Warning logic

Three checks run on every entry (see `docs/warning-logic.txt` for full spec):

| # | Condition | Flag |
|---|-----------|------|
| 1 | `to_bank > savings_collected + internal_loan_interest_collected + 1` | `bank_deposit_exceeds_visible_collections` |
| 2 | `from_bank > 0` AND `to_bank == 0` | `bank_withdrawal_present_check_context` |
| 3 | `entry_mode == "prefill"` AND `source_count == 0` | `prefill_mode_without_images` (backend only) |

Warnings are non-blocking — entry is saved with status `SAVED_WITH_WARNINGS`. Checks 1 & 2 are implemented identically in both frontend (`entries_provider.dart`) and backend (`services/validation.py`). They must stay in sync.

### Key widgets

| Widget | File | Purpose |
|--------|------|---------|
| `AppShell` | `widgets/app_shell.dart` | NavigationRail for tablet (≥600px) |
| `ConnectivityBar` | `widgets/connectivity_bar.dart` | Offline/pending-sync indicator (native only) |
| `StatusPill` | `widgets/status_pill.dart` | Colored status badge per entry |
| `ShimmerCard` | `widgets/shimmer_loader.dart` | Loading placeholder cards |
| `AppDrawer` | `widgets/app_drawer.dart` | Mobile nav: sync, language, admin, logout |
| `SofaLogo` | `widgets/sofa_logo.dart` | SOFA brand mark (orange rounded square with italic "S") |

### Android build toolchain

The committed Gradle config targets these exact versions — do not downgrade them:

| Component | Version | File |
|-----------|---------|------|
| Android Gradle Plugin (AGP) | 8.3.0 | `android/settings.gradle` |
| Gradle wrapper | 8.4 | `android/gradle/wrapper/gradle-wrapper.properties` |
| Kotlin Android plugin | 1.9.22 | `android/settings.gradle` |
| `compileSdk` / `targetSdkVersion` | 35 | `android/app/build.gradle` |
| `minSdkVersion` | 21 (Android 5+) | `android/app/build.gradle` |

AGP 8.3.0 is the minimum that can parse Android API 35 resource files. Older AGP versions (e.g. 7.x) produce `AAPT2: RES_TABLE_TYPE_TYPE entry offsets overlap` errors.

The app declares `<supports-screens>` for all screen sizes and uses `ConstrainedBox(maxWidth: 640)` on content-heavy screens to avoid stretch on tablets.

### Known data notes

- **Negative values in historical entries**: The Excel import (`import_savings.py`) contains months with negative `savings_collected` / `internal_loan_interest_collected` (ledger correction rows). The Pydantic **response** schema (`MonthEntryRead`) allows these; only the **input** schemas (`MonthEntryCreate`, `MonthEntryUpdate`) enforce `ge=0`.
- **CORS**: The dev server `.env` explicitly lists `http://localhost:4200` and `http://localhost:4201` in `CORS_ORIGINS`. `backend/app/main.py` also has `allow_origin_regex=r"http://localhost:\d+"` as a blanket fallback for any localhost port.

### What's not built yet

- AI image extraction (models defined, no service or upload endpoint)
- Month-on-month jump validation
- Role-based access enforcement beyond the `role` field in JWT
- Prefill warning (check #3 — `prefill_mode_without_images`) exists in backend only; frontend has no image upload yet
