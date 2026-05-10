# build-apk

Build a signed debug or release APK for the SHG Portal mobile app and install it on a running Android emulator or connected device.

## Usage

```
/build-apk [target]
```

| `target` | API URL baked in | Use when |
|----------|-----------------|----------|
| `dev` (default) | `http://139.59.60.230:8000` | Testing against the live shared dev server |
| `local` | `http://10.0.2.2:8001` | Testing against your local backend from an emulator |

## Prerequisites

Before running this skill, verify the Android toolchain is ready:

```bash
flutter doctor -v
```

All of `Flutter`, `Android toolchain`, and `Android Studio` must be green. If not, follow the steps below.

### Install Android SDK Platform 35

1. Open **Android Studio → SDK Manager**.
2. Under **SDK Platforms**, check **Android API 35** → Apply / OK.
3. Wait for the full download (~127 MB total SDK directory for API 35).

### Fix SDK path (if `flutter doctor` reports wrong SDK)

**Windows** — Two SDK directories often co-exist. Run:
```powershell
flutter config --android-sdk "$env:LOCALAPPDATA\Android\Sdk"
```
The uppercase `Sdk` is where Android Studio installs. Flutter may have defaulted to a legacy lowercase `sdk` path.

**macOS** — Auto-detected. If not:
```bash
flutter config --android-sdk ~/Library/Android/sdk
```

### Add adb to PATH (optional convenience)

**Windows:** Add `%LOCALAPPDATA%\Android\Sdk\platform-tools` to your system PATH.
**macOS/Linux:** Add `~/Library/Android/sdk/platform-tools` to your shell PATH (`.zshrc` / `.bashrc`).

---

## What this skill does

1. Checks that an Android emulator or device is running; launches the default emulator if none is found.
2. Picks the correct `--dart-define-from-file` env file based on `target`.
3. Builds a **release** APK (`flutter build apk`).
4. Installs the APK on the running device via `adb install`.
5. Launches the app and takes a screenshot to confirm it started.

---

## Step-by-step instructions

### 1 — Ensure emulator is running

```bash
flutter devices
```

If no Android device is listed:

```bash
# List available emulators
flutter emulators

# Launch one (replace with your emulator name from the list above)
flutter emulators --launch Pixel_3a_API_34_extension_level_7_x86_64
```

Wait ~30 seconds for the emulator to boot, then re-run `flutter devices` to confirm it appears.

### 2 — Env file setup (one-time)

The env files are gitignored — create them once from the example:

```bash
cp frontend/.env.example.json frontend/.env.dev.json
# edit .env.dev.json → {"API_URL": "http://139.59.60.230:8000"}

cp frontend/.env.example.json frontend/.env.local.json
# edit .env.local.json → {"API_URL": "http://10.0.2.2:8001"}
# Note: 10.0.2.2 is the emulator's alias for the host machine (not localhost)
```

### 3 — Build the APK

```bash
cd frontend

# Dev server (default — recommended for first test)
flutter build apk --dart-define-from-file=.env.dev.json --release

# Local backend
flutter build apk --dart-define-from-file=.env.local.json --release
```

Output APK path: `frontend/build/app/outputs/flutter-apk/app-release.apk`

Build takes 2–5 minutes on first run (Gradle download + full compile). Subsequent builds are faster (~30 seconds).

### 4 — Install on emulator / device

**macOS / Linux:**
```bash
adb install -r build/app/outputs/flutter-apk/app-release.apk
```

**Windows (if adb is on PATH):**
```powershell
adb install -r build/app/outputs/flutter-apk/app-release.apk
```

**Windows (if adb is not on PATH):**
```powershell
& "$env:LOCALAPPDATA\Android\Sdk\platform-tools\adb.exe" install -r build/app/outputs/flutter-apk/app-release.apk
```

### 5 — Launch and verify

```bash
# macOS/Linux
adb shell am start -n com.example.frontend/.MainActivity

# Windows
& "$env:LOCALAPPDATA\Android\Sdk\platform-tools\adb.exe" shell am start -n com.example.frontend/.MainActivity
```

Take a screenshot to confirm:
```bash
# macOS/Linux
adb shell screencap -p /sdcard/screen.png && adb pull /sdcard/screen.png .

# Windows
& "$env:LOCALAPPDATA\Android\Sdk\platform-tools\adb.exe" shell screencap -p /sdcard/screen.png
& "$env:LOCALAPPDATA\Android\Sdk\platform-tools\adb.exe" pull /sdcard/screen.png .
```

---

## Expected behaviour after launch

1. App opens to the **Login screen** (green SHG Portal branding).
2. Log in with `field1` / `sofa1234` (or `admin` / `admin123`).
3. On first login (online): groups and entries are fetched from the server into local SQLite.
4. Home screen shows recent synced entries.
5. Open the **hamburger drawer** → **Sync data** item is visible with a pending-count badge.
6. Tap **Sync data** to push any pending entries to the server.

---

## Troubleshooting

| Symptom | Cause | Fix |
|---------|-------|-----|
| `unsupported Gradle project` | `android/` directory missing | Run `flutter create --platforms=android .` inside `frontend/` |
| `AAPT2: RES_TABLE_TYPE_TYPE entry offsets overlap` | AGP too old for API 35 | Ensure `settings.gradle` has AGP 8.3.0 and `gradle-wrapper.properties` has Gradle 8.4 |
| `flutter doctor` reports wrong SDK path | Two SDK directories on Windows (`sdk` vs `Sdk`) | Run `flutter config --android-sdk "$env:LOCALAPPDATA\Android\Sdk"` |
| API 35 partially installed / corrupted | SDK Manager download interrupted | Re-open SDK Manager → uncheck then re-check API 35 → Apply |
| `localhost` unreachable on emulator | Emulator doesn't share host network | Use `10.0.2.2` instead of `localhost` in `.env.local.json` |
| Login fails with 401 | Wrong credentials or expired token | Tap Logout in drawer, log in again |
| Sync fails silently | No internet in emulator | Enable Wi-Fi in emulator Extended Controls → Cellular |
| `adb: command not found` | `platform-tools` not on PATH | Use full path or add to PATH (see Prerequisites above) |
| `connectTimeout` compile error | `drift_flutter` accidentally added | Remove `drift_flutter` from `pubspec.yaml`; the project uses `NativeDatabase` directly |

---

## Gradle / SDK version reference

These versions are already set in the committed code — do not change them:

| Component | Version |
|-----------|---------|
| Android Gradle Plugin | 8.3.0 (`android/settings.gradle`) |
| Gradle wrapper | 8.4 (`android/gradle/wrapper/gradle-wrapper.properties`) |
| Kotlin Android plugin | 1.9.22 (`android/settings.gradle`) |
| `compileSdk` | 35 (`android/app/build.gradle`) |
| `minSdkVersion` | 21 (`android/app/build.gradle`) |

---

## Files involved

| File | Purpose |
|------|---------|
| `frontend/.env.dev.json` | API URL for dev server build (gitignored — create from `.env.example.json`) |
| `frontend/.env.local.json` | API URL for local backend build (gitignored) |
| `frontend/android/` | Android platform directory (committed) |
| `frontend/android/settings.gradle` | AGP + Kotlin plugin versions |
| `frontend/android/gradle/wrapper/gradle-wrapper.properties` | Gradle wrapper version |
| `frontend/android/app/build.gradle` | compileSdk, minSdk, applicationId |
| `frontend/android/app/src/main/AndroidManifest.xml` | INTERNET permission + tablet screen support |
| `frontend/build/app/outputs/flutter-apk/app-release.apk` | Output APK (gitignored) |
| `frontend/lib/database/local_db.dart` | Drift SQLite schema + `_openConnection()` |
| `frontend/lib/widgets/app_drawer.dart` | Drawer with Sync + Logout (mobile only) |
| `frontend/lib/services/auth_service.dart` | Login, offline auth, auto-sync on launch |
| `frontend/lib/database/sync_service.dart` | Pushes pending SQLite entries to API |
