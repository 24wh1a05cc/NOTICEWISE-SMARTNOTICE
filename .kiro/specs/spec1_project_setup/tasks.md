# Spec 1 — Project Setup: Tasks

**Project:** NoticeWise – SmartNotice  
**Spec:** 1 of 10 — Project Setup  
**Status:** Draft — Pending Approval  
**Deadline:** [DD-MMM-YYYY]  
**Last Updated:** 2026-10-11  
**Estimated Total Effort:** 4–6 hours (solo developer, Flutter toolchain already installed)

---

## Prerequisites (Before Any Task)

These conditions must be satisfied before beginning implementation. They are not tasks themselves but hard dependencies.

| # | Prerequisite | Verification |
|---|---|---|
| P-01 | Flutter SDK (stable ≥ 3.22.0) installed and on system PATH | `flutter --version` |
| P-02 | Dart SDK (≥ 3.4.0) available via Flutter install | `dart --version` |
| P-03 | Android SDK and at minimum one Android emulator or physical device | `flutter devices` |
| P-04 | Git initialized in the project directory | `git status` |
| P-05 | `flutterfire_cli` installed globally (for Firebase setup step) | `flutterfire --version` |

---

## Implementation Tasks

Tasks must be completed in the order listed. A task may only begin when all its dependencies are marked complete.

---

### TASK-01 — Install and Verify Flutter SDK
**Depends on:** P-01 (prerequisite)  
**Estimated effort:** 30–60 min (download) + 15 min verification  
**Owner:** Developer (environment setup; cannot be automated by Kiro)

**Actions:**
1. Download Flutter SDK from https://flutter.dev/docs/get-started/install/windows
2. Extract to a stable path (e.g., `C:\flutter\`) with no spaces in path.
3. Add `C:\flutter\bin` to the system `PATH` environment variable.
4. Run `flutter doctor` and resolve all reported issues (Android licenses, SDK tools).

**Verification commands:**
```powershell
flutter --version
dart --version
flutter doctor -v
```

**Acceptance criteria:**
- `flutter doctor` reports no critical issues.
- `flutter --version` shows stable ≥ 3.22.0.
- `flutter devices` shows at least one connected device or emulator.

---

### TASK-02 — Create Flutter Project
**Depends on:** TASK-01  
**Estimated effort:** 10 min

**Actions:**
1. Navigate to `C:\Users\Macha Sindhuja\OneDrive\Desktop\UID_FLUTTER`.
2. Run Flutter project creation:
   ```powershell
   flutter create --org com.noticewise --project-name noticewise --platforms android,ios .
   ```
3. Verify the project compiles immediately after creation.

**Verification commands:**
```powershell
flutter run --debug   # should launch on connected device/emulator
flutter build apk --debug
```

**Acceptance criteria:**
- Default Flutter counter app compiles and runs on Android.
- `pubspec.yaml` has `name: noticewise` and `description: NoticeWise – SmartNotice`.
- `android/app/build.gradle` has `applicationId "com.noticewise.smartnotice"`.

**Notes:**
- The `--org` flag sets the Android package prefix to `com.noticewise`; the full ID `com.noticewise.smartnotice` is set by the project name.
- If the project is created with a different `applicationId`, update `android/app/build.gradle` manually.
- The existing `.dist` folder must not be deleted; the Flutter project must be created in the same root directory.

---

### TASK-03 — Configure `.gitignore` and Initial Commit
**Depends on:** TASK-02  
**Estimated effort:** 10 min

**Actions:**
1. Replace the default Flutter `.gitignore` with a comprehensive version covering (per requirements FR-08):
   - `google-services.json`, `GoogleService-Info.plist`
   - `.env`, `.env.*` (but NOT `.env.example`)
   - `*.keystore`, `*.jks`, `key.properties`
   - `build/`, `.dart_tool/`, `.flutter-plugins`, `.flutter-plugins-dependencies`
   - IDE files (`.idea/`, `*.iml`, `.vscode/settings.json`)
2. Stage all project files **except** any secret files.
3. Make the initial commit: `git commit -m "chore: initialize Flutter project scaffold"`.

**Verification commands:**
```powershell
git status              # no untracked secrets visible
git check-ignore -v google-services.json   # should report a match
```

**Acceptance criteria:**
- `git status` shows a clean working tree after commit.
- `google-services.json` (even if not yet created) is confirmed ignored by git.
- `.env` is confirmed ignored by git.

---

### TASK-04 — Add Dependencies to `pubspec.yaml`
**Depends on:** TASK-02  
**Estimated effort:** 20 min

**Actions:**
1. Update `pubspec.yaml` to declare all dependencies per the design document (Section 3):

**Runtime dependencies:**
```yaml
dependencies:
  flutter:
    sdk: flutter
  flutter_riverpod: ^2.5.1
  riverpod_annotation: ^2.3.5
  hooks_riverpod: ^2.5.1
  go_router: ^14.2.0
  firebase_core: ^3.4.0
  firebase_auth: ^5.2.0
  cloud_firestore: ^5.3.0
  firebase_storage: ^12.2.0
  firebase_messaging: ^15.1.0
  flutter_dotenv: ^5.1.0
  freezed_annotation: ^2.4.4
  json_annotation: ^4.9.0
  gap: ^3.0.1
  cached_network_image: ^3.4.0
  logger: ^2.4.0
```

**Dev dependencies:**
```yaml
dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^4.0.0
  build_runner: ^2.4.12
  riverpod_generator: ^2.4.3
  freezed: ^2.5.7
  json_serializable: ^6.8.0
  mocktail: ^1.0.4
  fake_cloud_firestore: ^3.0.2
  firebase_auth_mocks: ^0.14.0
```

2. Add `.env` to `flutter/assets` section:
```yaml
flutter:
  assets:
    - .env
```

3. Run `flutter pub get`.

**Verification commands:**
```powershell
flutter pub get
flutter pub deps   # inspect dependency tree for conflicts
```

**Acceptance criteria:**
- `flutter pub get` exits with code 0 and no version resolution errors.
- No dependency conflicts reported.
- All packages are resolvable on the declared Flutter stable version.

---

### TASK-05 — Establish Folder Structure
**Depends on:** TASK-02  
**Estimated effort:** 15 min

**Actions:**
1. Create all directories from the design document (Section 2) under `lib/`.
2. Place a `.gitkeep` file in each leaf directory that would otherwise be empty.
3. Create the full `test/` mirror structure with `.gitkeep` placeholders.

**Directories to create:**
```
lib/app/firebase/
lib/app/router/
lib/app/theme/
lib/core/constants/
lib/core/errors/
lib/core/utils/
lib/core/services/
lib/features/auth/data/
lib/features/auth/domain/
lib/features/auth/presentation/
lib/features/notices/data/
lib/features/notices/domain/
lib/features/notices/presentation/
lib/features/admin/data/
lib/features/admin/domain/
lib/features/admin/presentation/
lib/features/search/data/
lib/features/search/domain/
lib/features/search/presentation/
lib/features/notifications/data/
lib/features/notifications/domain/
lib/features/notifications/presentation/
lib/features/bookmarks/data/
lib/features/bookmarks/domain/
lib/features/bookmarks/presentation/
lib/features/profile/data/
lib/features/profile/domain/
lib/features/profile/presentation/
lib/features/smart_features/data/
lib/features/smart_features/domain/
lib/features/smart_features/presentation/
lib/shared/widgets/
test/helpers/
test/app/
test/core/errors/
test/features/auth/
test/features/notices/
test/features/admin/
test/features/search/
test/features/notifications/
test/features/bookmarks/
test/features/profile/
test/features/smart_features/
```

**Verification commands:**
```powershell
tree lib /F    # Windows: show full folder tree
```

**Acceptance criteria:**
- All directories exist and are committed (via `.gitkeep` files).
- No feature directory is missing any of `data/`, `domain/`, `presentation/`.

---

### TASK-06 — Configure `analysis_options.yaml`
**Depends on:** TASK-04  
**Estimated effort:** 10 min

**Actions:**
1. Replace the default `analysis_options.yaml` with the configuration from design document Section 10.
2. Verify the project still analyzes cleanly.

**Verification commands:**
```powershell
flutter analyze
```

**Acceptance criteria:**
- `flutter analyze` exits with code 0.
- Zero errors; zero warnings.
- Generated file exclusions (`*.g.dart`, `*.freezed.dart`) are in place.

---

### TASK-07 — Create Core Foundation Files
**Depends on:** TASK-05  
**Estimated effort:** 30 min

Create the following files. These are non-trivial foundation pieces that later specs depend on.

**7a. `lib/core/errors/app_exception.dart`**
- Sealed class hierarchy: `AppException`, `NetworkException`, `AuthException`, `DatabaseException`, `StorageException`, `UnknownException`.
- Per design Section 11.1.

**7b. `lib/core/errors/error_handler.dart`**
- `AppErrorHandler` class with static method `toUserMessage(AppException e) → String`.
- Maps exception types to friendly strings using `AppStrings`.

**7c. `lib/core/constants/app_strings.dart`**
- `AppStrings` abstract class.
- Initial constants: `appName`, `tagline`, error messages.
- `// TODO(i18n): replace with ARB` comment at top.

**7d. `lib/core/constants/app_constants.dart`**
- `AppConstants` abstract class.
- Initial constants: `requestTimeoutSeconds`, `maxNoticeTitleLength`, `maxNoticeBodyLength`.

**7e. `lib/core/utils/logger.dart`**
- `logger` singleton per design Section 12.
- Release-mode level suppression via `kReleaseMode`.

**Verification commands:**
```powershell
flutter analyze
```

**Acceptance criteria:**
- All files compile without errors.
- `flutter analyze` still passes.

---

### TASK-08 — Create Theme System
**Depends on:** TASK-05  
**Estimated effort:** 20 min

Create:

**8a. `lib/app/theme/app_colors.dart`**
- `AppColors` abstract class with `brandBlue`, `brandBlueLight`, and semantic color constants.
- A comment: `// Do not use AppColors directly in widgets. Use Theme.of(context).colorScheme.*`

**8b. `lib/app/theme/app_theme.dart`**
- `AppTheme` abstract class with `static ThemeData light` and `static ThemeData dark`.
- Both derived from `ColorScheme.fromSeed(seedColor: AppColors.brandBlue)`.
- `CardTheme`, `AppBarTheme`, `InputDecorationTheme` overrides per design Section 7.3.

**Verification commands:**
```powershell
flutter analyze
```

**Acceptance criteria:**
- Theme compiles; no lint warnings.

---

### TASK-09 — Create Router and App Entry Point
**Depends on:** TASK-07, TASK-08  
**Estimated effort:** 25 min

**9a. `lib/app/router/app_routes.dart`**
- `AppRoutes` abstract class with `splash` and `home` string constants.

**9b. `lib/app/router/app_router.dart`**
- `routerProvider` using `@Riverpod(keepAlive: true)`.
- Two routes: `/` → `SplashScreen`, `/home` → `PlaceholderHomeScreen`.
- Redirect stub returning `null`.

**9c. `lib/app/app.dart`**
- `NoticeWiseApp` as a `ConsumerWidget`.
- Reads `routerProvider` and `themeNotifierProvider`.
- Returns `MaterialApp.router(...)` with `AppTheme.light`, `AppTheme.dark`.

**9d. `lib/main.dart`**
- `main()` function: `WidgetsFlutterBinding.ensureInitialized()`, `dotenv.load()`, `Firebase.initializeApp()`, `runApp(ProviderScope(...))`.
- `ProviderScope` includes `AppProviderObserver` in debug mode.

**9e. Placeholder screens**
- `lib/features/auth/presentation/splash_screen.dart` — minimal `Scaffold` that immediately navigates to `/home`.
- `lib/shared/widgets/placeholder_home_screen.dart` — `Scaffold` with app name, tagline, and a theme toggle `IconButton`.

**Verification commands:**
```powershell
flutter run --debug
flutter analyze
```

**Acceptance criteria:**
- App launches on device/emulator without crashes.
- Light and dark theme are switchable via the toggle.
- `flutter analyze` passes.

---

### TASK-10 — Firebase Initialization Setup
**Depends on:** TASK-09  
**Estimated effort:** 20 min (without a live Firebase project) / 30 min (with one)

**Actions:**
1. Create `lib/app/firebase/` directory.
2. Document `firebase_options.dart` as a generated file (add `# Generated by flutterfire` comment stub or a real generated file if a Firebase project exists).
3. If no Firebase project exists yet: use a conditional compile guard in `main.dart` so the app still runs without crashing (Firebase init wrapped in try/catch with a clear debug log message).
4. Add `firebase_options.dart` to `.gitignore` if it contains real API keys, OR confirm that committing mobile SDK API keys is acceptable per team security policy (document the decision in README).
5. Create `.env.example` at project root per design Section 9.1.

**Verification commands:**
```powershell
flutter build apk --debug
```

**Acceptance criteria:**
- App builds to APK without errors.
- If Firebase project exists: app initializes Firebase and logs a success message.
- If no Firebase project: app logs a clear warning and continues to placeholder home screen.
- `.env.example` is committed; `.env` is not.

---

### TASK-11 — Configure Android Build
**Depends on:** TASK-10  
**Estimated effort:** 15 min

**Actions:**
1. Verify `android/app/build.gradle`:
   - `compileSdkVersion 34`
   - `minSdkVersion 21`
   - `targetSdkVersion 34`
   - `applicationId "com.noticewise.smartnotice"`
2. Verify `android/build.gradle` has required Google Services classpath for Firebase:
   ```groovy
   classpath 'com.google.gms:google-services:4.4.2'
   ```
3. Verify `android/app/build.gradle` applies the plugin:
   ```groovy
   apply plugin: 'com.google.gms.google-services'
   ```
4. Note in README: `google-services.json` must be placed at `android/app/google-services.json` before a Firebase-connected build.

**Verification commands:**
```powershell
flutter build apk --debug
```

**Acceptance criteria:**
- APK builds successfully.
- `applicationId` is correct.
- `minSdkVersion` is 21.

---

### TASK-12 — Run Code Generation
**Depends on:** TASK-09  
**Estimated effort:** 10 min

**Actions:**
1. Run the initial `build_runner` pass to ensure codegen is configured correctly.
2. Verify no generated files are accidentally committed (they should be in `.gitignore`).

```powershell
dart run build_runner build --delete-conflicting-outputs
```

**Verification commands:**
```powershell
dart run build_runner build --delete-conflicting-outputs
flutter analyze
```

**Acceptance criteria:**
- `build_runner` exits with code 0.
- `flutter analyze` passes after codegen.
- Generated `*.g.dart` and `*.freezed.dart` files are excluded from git via `.gitignore` or are committed intentionally (document the decision).

**Note:** At Spec 1 stage, there may be minimal generated files (only `app_router.dart` using `@riverpod`). This task ensures the pipeline is working before Spec 2 adds more codegen targets.

---

### TASK-13 — Write Baseline Tests
**Depends on:** TASK-07  
**Estimated effort:** 20 min

**13a. `test/core/errors/app_exception_test.dart`**

Verify:
- Each `AppException` subclass can be instantiated.
- `is` pattern matching correctly identifies each type.
- `message` and `code` fields are accessible.

**13b. `test/app/app_widget_test.dart`**

Verify:
- `NoticeWiseApp` pumps without throwing.
- The placeholder home screen renders.
- Theme toggle button is present and tappable.

**13c. `test/helpers/test_helpers.dart`**

Provide:
- `makeProviderContainer({List<Override> overrides})` helper.
- `pumpApp(WidgetTester tester, Widget child)` helper.

**Verification commands:**
```powershell
flutter test
flutter test --coverage
```

**Acceptance criteria:**
- All tests pass.
- Zero test errors or failures.

---

### TASK-14 — Final Analysis and Formatting Pass
**Depends on:** All previous tasks  
**Estimated effort:** 10 min

**Actions:**
1. Run formatter on all Dart files.
2. Run analyzer.
3. Fix any remaining issues.

**Verification commands:**
```powershell
flutter format .
flutter format --set-exit-if-changed .   # must exit 0 (no changes)
flutter analyze                          # must exit 0 (no issues)
flutter test                             # must exit 0 (all pass)
```

**Acceptance criteria:**
- All three commands exit with code 0.

---

### TASK-15 — Write README
**Depends on:** TASK-10, TASK-11  
**Estimated effort:** 30 min

Write `README.md` at the project root with the following sections per FR-14:

1. **Project Overview** — What NoticeWise is and who it is for.
2. **Prerequisites** — Flutter SDK version, Android SDK, Firebase CLI, `flutterfire_cli`.
3. **Environment Setup** — Copying `.env.example` → `.env` and filling in values.
4. **Firebase Setup** — Create project, run `flutterfire configure`, place `google-services.json`.
5. **Android Setup** — SDK version requirements, Gradle configuration notes.
6. **iOS Setup** — macOS/Xcode requirement note; `GoogleService-Info.plist` placement.
7. **Build and Run** — `flutter pub get`, `flutter run`, `flutter build apk`.
8. **Code Generation** — `dart run build_runner build --delete-conflicting-outputs`.
9. **Testing** — `flutter test`, `flutter test --coverage`.
10. **Static Analysis** — `flutter analyze`, `flutter format .`.
11. **Architecture** — Brief overview with reference to `design.md`.
12. **Demo Data** — Placeholder section (populated in Spec 3).
13. **Known Limitations** — iOS secondary, Firebase setup required for real features.
14. **License** — To be decided.

**Verification:**
- Manual review against FR-14 checklist.

**Acceptance criteria:**
- All 14 sections are present.
- All commands in the README are accurate and have been verified to work.

---

## Validation Tasks

These tasks verify the completed implementation rather than building it. Run after all implementation tasks are complete.

---

### VALIDATE-01 — Full Acceptance Criteria Check
**Depends on:** All implementation tasks  

Verify every acceptance criterion from `requirements.md` Section 8:

| AC-ID | Check | Command | Expected Result |
|---|---|---|---|
| AC-01 | Project compiles | `flutter build apk --debug` | Exit 0 |
| AC-02 | Folder structure | `tree lib /F` | Matches design.md Section 2 |
| AC-03 | Dependencies declared | `flutter pub get` | Exit 0 |
| AC-04 | Analyzer passes | `flutter analyze` | 0 errors, 0 warnings |
| AC-05 | Formatter passes | `flutter format --set-exit-if-changed .` | Exit 0 |
| AC-06 | Tests pass | `flutter test` | 0 failures |
| AC-07 | Codegen succeeds | `dart run build_runner build` | Exit 0 |
| AC-08 | No secrets committed | `git log --all --full-history -- "*.env"` | No `.env` in history |
| AC-09 | `.gitignore` covers secrets | `git check-ignore -v google-services.json` | Returns a match |
| AC-10 | README complete | Manual review | All 14 sections present |
| AC-11 | Theme modes work | Run app, toggle theme | Both themes render |
| AC-12 | ProviderScope present | Code review `main.dart` | ProviderScope wraps root |

---

### VALIDATE-02 — Security Check
**Depends on:** TASK-03, TASK-10  

1. Confirm no API keys, tokens, or passwords in any committed file.
2. Confirm `.env` is listed in `.gitignore` and has never been committed.
3. Confirm `google-services.json` is listed in `.gitignore`.
4. Review `firebase_options.dart` — if committed, confirm the API key is a mobile SDK key (acceptable) and not a server key (not acceptable).

---

### VALIDATE-03 — Architecture Compliance Check
**Depends on:** TASK-05, TASK-07  

1. Confirm no `import 'package:firebase_auth/firebase_auth.dart'` in any `presentation/` or widget file.
2. Confirm no `import 'package:cloud_firestore/cloud_firestore.dart'` in any `presentation/` file.
3. Confirm no hard-coded color values in widget files (all via `Theme.of(context)`).

---

## Task Dependency Graph

```
TASK-01 (Flutter SDK)
  └─ TASK-02 (Create project)
       ├─ TASK-03 (gitignore + commit)
       ├─ TASK-04 (pubspec.yaml)
       │    ├─ TASK-05 (folder structure)
       │    │    ├─ TASK-06 (analysis_options.yaml)
       │    │    ├─ TASK-07 (core foundation files)
       │    │    │    ├─ TASK-08 (theme system)
       │    │    │    │    └─ TASK-09 (router + app entry)
       │    │    │    │         ├─ TASK-10 (Firebase setup)
       │    │    │    │         │    └─ TASK-11 (Android build)
       │    │    │    │         ├─ TASK-12 (code generation)
       │    │    │    │         └─ TASK-13 (baseline tests)
       │    │    │    └─ TASK-13 (baseline tests)
       │    │    └─ TASK-06
       │    └─ TASK-12 (build_runner)
       └─ TASK-14 (format + analyze) ← all tasks complete
            └─ TASK-15 (README)
                 └─ VALIDATE-01
                 └─ VALIDATE-02
                 └─ VALIDATE-03
```

---

## Effort Estimates and Risks

| Task | Estimated Time | Risk | Dependency |
|---|---|---|---|
| TASK-01 | 45–75 min | Flutter not on PATH; Windows install nuances | P-01 |
| TASK-02 | 10 min | Low | TASK-01 |
| TASK-03 | 10 min | Low | TASK-02 |
| TASK-04 | 20 min | Version conflicts possible | TASK-02 |
| TASK-05 | 15 min | Low | TASK-02 |
| TASK-06 | 10 min | Low | TASK-04 |
| TASK-07 | 30 min | Low | TASK-05 |
| TASK-08 | 20 min | Low | TASK-05 |
| TASK-09 | 25 min | Router codegen may need adjustment | TASK-07, TASK-08 |
| TASK-10 | 20–30 min | Firebase project may not exist yet | TASK-09 |
| TASK-11 | 15 min | Gradle version compatibility | TASK-10 |
| TASK-12 | 10 min | Low | TASK-09 |
| TASK-13 | 20 min | Low | TASK-07 |
| TASK-14 | 10 min | Low | All |
| TASK-15 | 30 min | Low | TASK-10, TASK-11 |
| **Total** | **~4.7–5.7 hours** | **Critical path: TASK-01 → TASK-02 → ... → TASK-14** | |

**Critical Path Risk:** Flutter SDK installation (TASK-01) is the biggest unknown. If the SDK is already installed but not on PATH, this reduces to ~5 minutes. If it needs to be downloaded fresh, allow 45–75 minutes.

---

## Must-Have vs. Deferrable

| Item | Must-Have for Spec 1 Completion | Can Defer |
|---|---|---|
| Flutter project compiles | ✅ | |
| Folder structure established | ✅ | |
| Core error types defined | ✅ | |
| Theme system (light + dark) | ✅ | |
| Router + ProviderScope | ✅ | |
| Baseline tests pass | ✅ | |
| `.gitignore` covers secrets | ✅ | |
| `analysis_options.yaml` | ✅ | |
| Firebase initialization | ✅ (stub acceptable) | |
| Android build verified | ✅ | |
| Real Firebase project connected | | ✅ Deferred to Spec 2 |
| iOS build verified | | ✅ Deferred (requires macOS) |
| Demo seed data | | ✅ Deferred to Spec 3 |
| README fully detailed | ✅ | |

---

*End of Spec 1 — Tasks*
