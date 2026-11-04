# NoticeWise – SmartNotice

> Intelligent notice management for institutions, campuses, and organisations.

NoticeWise is a Flutter mobile application that makes it easy for administrators
to publish notices and for users to discover, understand, bookmark, and receive
alerts about important information.

---

## Table of Contents

1. [Project Overview](#project-overview)
2. [Prerequisites](#prerequisites)
3. [Environment Setup](#environment-setup)
4. [Firebase Setup](#firebase-setup)
5. [Android Setup](#android-setup)
6. [iOS Setup](#ios-setup)
7. [Build and Run](#build-and-run)
8. [Code Generation](#code-generation)
9. [Testing](#testing)
10. [Static Analysis and Formatting](#static-analysis-and-formatting)
11. [Architecture](#architecture)
12. [Demo Data](#demo-data)
13. [Known Limitations](#known-limitations)
14. [Spec Roadmap](#spec-roadmap)

---

## Project Overview

**Platform:** Android-first Flutter application (iOS secondary)  
**Package ID:** `com.noticewise.smartnotice`  
**Min Android SDK:** 21 (Android 5.0+)  
**Flutter channel:** Stable ≥ 3.22.0  

### Core user roles

| Role | Capabilities |
|---|---|
| **Admin/Publisher** | Create, edit, schedule, publish, delete notices; manage categories; monitor reach |
| **User/Viewer** | Browse notices, search, filter, bookmark, track unread, receive notifications |

---

## Prerequisites

Install the following before cloning and running the project.

| Tool | Version | Install |
|---|---|---|
| Flutter SDK | ≥ 3.22.0 stable | https://docs.flutter.dev/get-started/install/windows |
| Dart SDK | ≥ 3.4.0 (bundled with Flutter) | Included with Flutter |
| Android Studio / SDK | API 35 | https://developer.android.com/studio |
| Firebase CLI | Latest | `npm install -g firebase-tools` |
| FlutterFire CLI | Latest | `dart pub global activate flutterfire_cli` |
| Git | Any recent | https://git-scm.com |

Verify your Flutter installation:

```powershell
flutter doctor -v
```

All items should show a green checkmark. Accept any Android SDK licences if prompted:

```powershell
flutter doctor --android-licenses
```

---

## Environment Setup

The app uses `flutter_dotenv` to load environment variables from a `.env` file.

1. Copy the example file:

   ```powershell
   Copy-Item .env.example .env
   ```

2. Edit `.env` and fill in real values (see comments inside the file).

3. **Never commit `.env`** — it is listed in `.gitignore`.

### `.env` variables

| Variable | Required | Description |
|---|---|---|
| `FIREBASE_API_KEY` | Optional† | Firebase Web API key |
| `FIREBASE_PROJECT_ID` | Optional† | Firebase project ID |
| `FIREBASE_MESSAGING_SENDER_ID` | Optional† | FCM sender ID |
| `FIREBASE_APP_ID` | Optional† | Firebase app ID |
| `FIREBASE_STORAGE_BUCKET` | Optional† | Storage bucket URL |
| `AI_SERVICE_BASE_URL` | Spec 7 | Backend URL for AI features |
| `ENABLE_AI_FEATURES` | No | `true` / `false` (default `false`) |

†Firebase variables are only needed if you skip `flutterfire configure` and supply
options manually. The preferred approach is `flutterfire configure` (see below).

---

## Firebase Setup

Firebase is required for authentication, data storage, push notifications, and
file storage. Without a configured Firebase project the app will still launch but
all Firebase-dependent features will be unavailable.

### Step 1 — Create a Firebase project

1. Go to https://console.firebase.google.com
2. Click **Add project** and follow the wizard.
3. Enable **Google Analytics** (optional).

### Step 2 — Register the Android app

1. In the Firebase console, click **Add app → Android**.
2. Enter the Android package name: `com.noticewise.smartnotice`
3. Download `google-services.json`.
4. Place it at `android/app/google-services.json`.

   > `google-services.json` is listed in `.gitignore` — never commit it.

### Step 3 — Run FlutterFire CLI

```powershell
firebase login
flutterfire configure --project=<your-firebase-project-id>
```

This generates `lib/app/firebase/firebase_options.dart` with the correct options
for each platform. Commit this file (it contains mobile SDK API keys, which
are safe to commit for mobile apps — but consider keeping it out of public repos).

### Step 4 — Enable Firebase services (per spec)

| Service | Enable when | Console path |
|---|---|---|
| Authentication | Spec 2 | Build → Authentication → Sign-in method |
| Firestore | Spec 3 | Build → Firestore Database |
| Storage | Spec 4 | Build → Storage |
| Cloud Messaging | Spec 6 | Already enabled by default |

---

## Android Setup

### Required files

| File | Location | Notes |
|---|---|---|
| `google-services.json` | `android/app/` | Downloaded from Firebase console. Gitignored. |

### SDK versions

| Setting | Value |
|---|---|
| Min SDK | 21 (Android 5.0) |
| Target SDK | 35 (Android 15) |
| Compile SDK | 35 |
| applicationId | `com.noticewise.smartnotice` |

These are set in `android/app/build.gradle.kts` and should not need manual changes.

### Build variants

```powershell
# Debug build (default for development)
flutter build apk --debug

# Release build (requires signing config)
flutter build apk --release
```

---

## iOS Setup

> iOS builds require macOS with Xcode 15+. This is not available on Windows.
> iOS is a secondary target for NoticeWise. Android is the primary platform.

On macOS:

1. Open `ios/Runner.xcworkspace` in Xcode.
2. Set the Bundle Identifier to `com.noticewise.smartnotice`.
3. In the Firebase console, add an iOS app with Bundle ID `com.noticewise.smartnotice`.
4. Download `GoogleService-Info.plist` and place it at `ios/Runner/GoogleService-Info.plist`.
5. Run `flutterfire configure` to update `firebase_options.dart` for iOS.

---

## Build and Run

```powershell
# Install dependencies
flutter pub get

# Run in debug mode on connected device/emulator
flutter run

# Run on a specific device
flutter run -d <device-id>   # get IDs with: flutter devices

# Build debug APK
flutter build apk --debug

# Build release APK (requires signing)
flutter build apk --release
```

---

## Code Generation

The project uses `build_runner` for:

- **`riverpod_generator`** — generates `@riverpod` provider boilerplate
- **`freezed`** — generates immutable data classes (used from Spec 3 onwards)
- **`json_serializable`** — generates `fromJson`/`toJson` (used from Spec 3 onwards)

Run code generation after pulling changes or modifying annotated classes:

```powershell
dart run build_runner build
```

If you get conflicts from previously generated files:

```powershell
dart run build_runner build --delete-conflicting-outputs
```

For continuous generation during development:

```powershell
dart run build_runner watch
```

Generated files (`*.g.dart`, `*.freezed.dart`) are committed to the repository
so CI/CD does not need to run `build_runner`.

---

## Testing

```powershell
# Run all tests
flutter test

# Run a specific test file
flutter test test/core/errors/app_exception_test.dart

# Run with coverage report
flutter test --coverage
```

### Test structure

```
test/
  helpers/
    test_helpers.dart        ← shared ProviderContainer and pumpApp helpers
  app/
    app_widget_test.dart     ← PlaceholderHomeScreen, AppTheme, AppConstants
  core/
    errors/
      app_exception_test.dart ← AppException sealed class, AppErrorHandler
  features/
    auth/                    ← (populated in Spec 2)
    notices/                 ← (populated in Spec 3)
    ...
```

### Current baseline (Spec 1)

- `app_exception_test.dart` — 20 tests: all exception types, toString, sealed exhaustiveness, AppErrorHandler
- `app_widget_test.dart` — 14 tests: widget rendering, theme toggle, AppTheme, AppConstants

---

## Static Analysis and Formatting

```powershell
# Static analysis (must report zero issues)
flutter analyze

# Format all Dart files
dart format .

# Format check (exit 1 if any file would change — use in CI)
dart format --set-exit-if-changed .
```

The project uses `flutter_lints` as a base with additional strict rules defined
in `analysis_options.yaml`. Generated files (`*.g.dart`, `*.freezed.dart`) are
excluded from analysis.

---

## Architecture

NoticeWise follows **feature-first clean architecture**:

```
lib/
  app/          ← MaterialApp, router (go_router), theme, Firebase init
  core/         ← Errors, constants, utilities (cross-cutting concerns)
  features/     ← Self-contained feature modules (auth, notices, admin, ...)
    <feature>/
      data/         ← Repository implementations, Firebase datasources, DTOs
      domain/       ← Models (Freezed), repository interfaces, failure types
      presentation/ ← Widgets, screens, Riverpod providers
  shared/       ← Reusable widgets shared across features
  main.dart     ← Entry point: dotenv → Firebase init → ProviderScope → runApp
```

### Key principles

- **Widgets never call Firebase directly.** All backend access goes through repositories.
- **Riverpod** manages all state and dependency injection.
- **go_router** handles navigation with role-based redirect guards.
- **`AsyncValue`** makes loading / data / error states explicit in every provider.
- **`AppException`** hierarchy wraps all errors before they reach the UI.

For full architecture details, see `.kiro/specs/spec1_project_setup/design.md`.

---

## Demo Data

Demo data setup is documented in Spec 3 (Notice Feed). At the end of Spec 3,
a Firestore seed script will be provided to populate sample notices, categories,
and user profiles for demonstration purposes.

Until then, the app displays placeholder screens only.

---

## Known Limitations

| Limitation | Detail |
|---|---|
| Firebase features unavailable without `google-services.json` | App launches and shows the placeholder screen but auth, Firestore, and notifications require a configured Firebase project |
| iOS builds require macOS | Android is the primary target. iOS support is secondary. |
| No real notices yet | Spec 3 implements the notice feed. Only the scaffold is present. |
| AI features disabled | `ENABLE_AI_FEATURES=false` by default. Backend endpoint required (Spec 7). |
| No release signing | `release` build type uses debug signing. Configure `key.properties` and a keystore before distribution. |

---

## Spec Roadmap

| Spec | Feature | Status |
|---|---|---|
| 1 | Project Setup | ✅ Complete |
| 2 | Authentication | Pending approval |
| 3 | Notice Feed | Not started |
| 4 | Admin Notice Management | Not started |
| 5 | Search and Filters | Not started |
| 6 | Push Notifications | Not started |
| 7 | Smart Features (AI) | Not started |
| 8 | Bookmarks and Read Tracking | Not started |
| 9 | Profile and Settings | Not started |
| 10 | Final Polish | Not started |

---

*NoticeWise – SmartNotice © 2026. Built with Flutter.*
