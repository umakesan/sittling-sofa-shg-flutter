# build-apk

Build a signed debug or release APK for the SHG Portal mobile app and install it on a running Android emulator or connected device.

## Usage

```
/build-apk [target]
```

| `target` | API URL baked in | Use when |
|----------|-----------------|----------|
| `dev` (default) | `http://139.59.60.230:8000` | Testing against the live shared dev server |
| `local` | `http://localhost:8001` | Testing against your local backend |

## What this skill does

1. Checks that an Android emulator or device is running; launches the default emulator if none is found.
2. Picks the correct `--dart-define-from-file` env file based on `target`.
3. Builds a **release** APK (`flutter build apk`).
4. Installs the APK on the running device with `flutter install`.
5. Launches the app and takes a screenshot to confirm it started.

## Step-by-step instructions

### 1 — Ensure emulator is running

```bash
flutter devices
```

If no Android device is listed:

```bash
# List available emulators
flutter emulators

# Launch the standard emulator
flutter emulators --launch Pixel_3a_API_34_extension_level_7_x86_64
```

Wait ~30 seconds for the emulator to boot, then re-run `flutter devices` to confirm it appears.

### 2 — Choose env file

| Target | Env file | API URL |
|--------|----------|---------|
| `dev` | `frontend/.env.dev.json` | `http://139.59.60.230:8000` |
| `local` | `frontend/.env.local.json` | `http://localhost:8001` |

> **Note for `local` target**: The emulator runs in a separate virtual network. `localhost` inside the emulator refers to the emulator itself, not the host machine. Use `http://10.0.2.2:8001` instead of `http://localhost:8001` in `.env.local.json` when running on an Android emulator.

### 3 — Build the APK

```bash
cd frontend

# Dev server (default)
flutter build apk --dart-define-from-file=.env.dev.json --release

# Local backend
flutter build apk --dart-define-from-file=.env.local.json --release
```

Output APK path: `frontend/build/app/outputs/flutter-apk/app-release.apk`

Build takes 2–5 minutes on first run (Gradle download + full compile). Subsequent builds are faster.

### 4 — Install on emulator / device

```bash
# Install directly to the running device
flutter install --dart-define-from-file=.env.dev.json
```

Or install the APK manually:

```bash
adb install -r build/app/outputs/flutter-apk/app-release.apk
```

### 5 — Launch and verify

```bash
# Stream logs while the app runs
flutter run --dart-define-from-file=.env.dev.json --no-build
```

Or launch via adb:

```bash
adb shell am start -n com.example.frontend/com.example.frontend.MainActivity
```

## Expected behaviour after launch

1. App opens to the **Login screen**.
2. Log in with `field1` / `sofa1234` (or `admin` / `admin123`).
3. On first login (online): groups and entries are fetched from the server into local SQLite.
4. Home screen shows recent synced entries.
5. Open the **hamburger drawer** → "Sync data" item is visible with a pending-count badge.
6. Tap **Sync data** to push any pending entries to the server.

## Troubleshooting

| Symptom | Cause | Fix |
|---------|-------|-----|
| `unsupported Gradle project` | `android/` directory missing | Run `flutter create --platforms=android .` in `frontend/` |
| `localhost` unreachable on emulator | Emulator doesn't share host network | Use `10.0.2.2` instead of `localhost` in `.env.local.json` |
| Login fails with 401 | Wrong credentials or expired token | Tap Logout in drawer, log in again |
| Sync fails silently | No internet in emulator | Enable Wi-Fi in emulator settings (Extended controls → Cellular) |
| `adb: command not found` | Android platform tools not on PATH | Add `%LOCALAPPDATA%\Android\Sdk\platform-tools` to PATH |

## Files involved

| File | Purpose |
|------|---------|
| `frontend/.env.dev.json` | API URL for dev server build (gitignored) |
| `frontend/.env.local.json` | API URL for local backend build (gitignored) |
| `frontend/android/` | Android platform directory (created by `flutter create --platforms=android`) |
| `frontend/build/app/outputs/flutter-apk/app-release.apk` | Output APK |
| `frontend/lib/widgets/app_drawer.dart` | Drawer with Sync + Logout (mobile only) |
| `frontend/lib/services/auth_service.dart` | Login, offline auth, auto-sync on launch |
| `frontend/lib/database/sync_service.dart` | Pushes pending SQLite entries to API |
