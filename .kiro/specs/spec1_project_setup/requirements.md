# Spec 1 — Project Setup: Requirements

**Project:** NoticeWise – SmartNotice  
**Spec:** 1 of 10 — Project Setup  
**Status:** Draft — Pending Approval  
**Deadline:** [DD-MMM-YYYY]  
**Last Updated:** 2026-10-11

---

## 1. Purpose

This specification defines all requirements for bootstrapping the NoticeWise – SmartNotice Flutter project so that:

- The project compiles and runs on Android (physical device or emulator) from a clean checkout.
- The folder structure, architecture, configuration, and tooling are established and agreed upon before any feature code is written.
- Every subsequent specification (Specs 2–10) can be implemented consistently without re-visiting foundational decisions.

---

## 2. Scope

Spec 1 covers only project scaffolding, configuration, and tooling. It does **not** include:

- Any authentication UI or logic (Spec 2)
- Any notice screens or data (Spec 3–4)
- Firebase Firestore rules, data model, or Security Rules (designed per feature spec)
- AI functionality (Spec 7)
- Final polish, icons, or splash screen (Spec 10)

---

## 3. Stakeholders and User Roles

At this stage there are no end-user-visible features. The primary beneficiary of this spec is the development team.

| Role | Concern |
|---|---|
| Developer | Consistent, compilable project from day one |
| Architect | Clean separation enforced by structure |
| QA / Test Engineer | Test harness available from first commit |
| Security Reviewer | No secrets committed; lint enforced |

---

## 4. Functional Requirements

### FR-01 — Flutter Project Creation
- The project must be created as a Flutter application targeting Android (minimum SDK 21, target SDK 34) and iOS (minimum deployment target iOS 13.0).
- Package name (Android): `com.noticewise.smartnotice`
- Bundle ID (iOS): `com.noticewise.smartnotice`
- Application display name: `NoticeWise`
- The project must use Dart null safety.

### FR-02 — Dependency Declaration
- `pubspec.yaml` must declare all required direct dependencies with pinned or constrained stable versions.
- Required dependency categories:
  - State management: `flutter_riverpod`, `riverpod_annotation`, `hooks_riverpod` (optional but preferred)
  - Navigation: `go_router`
  - Firebase: `firebase_core`, `firebase_auth`, `cloud_firestore`, `firebase_storage`, `firebase_messaging`
  - Environment: `flutter_dotenv` or `--dart-define` strategy (decision documented in design.md)
  - UI utilities: `gap` (spacing), `cached_network_image` (image caching)
  - Code generation: `build_runner`, `riverpod_generator`, `freezed`, `freezed_annotation`, `json_serializable`, `json_annotation`
  - Testing: `flutter_test` (SDK), `mockito` or `mocktail`, `fake_cloud_firestore` (for repository tests)
  - Linting: `flutter_lints` (or a stricter custom ruleset)
- `dev_dependencies` must be separated from `dependencies`.
- No unnecessary packages. Each package choice must be justified in `design.md`.

### FR-03 — Feature-First Folder Structure
- The `lib/` directory must conform to the following top-level structure:
  ```
  lib/
    app/
      firebase/
      router/
      theme/
      app.dart
    core/
      constants/
      errors/
      utils/
      services/
    features/
      auth/
      notices/
      admin/
      search/
      notifications/
      bookmarks/
      profile/
      smart_features/
    shared/
      widgets/
    main.dart
  ```
- Each feature directory must contain subdirectories for at least:
  `data/`, `domain/`, `presentation/` (populated in later specs).
- Placeholder files (`README.md` or `.gitkeep`) must be placed in each feature directory so the structure is committed.

### FR-04 — Material 3 Theme System
- The app must configure a Material 3 `ThemeData` with a custom `ColorScheme` for both light and dark modes.
- Typography must use the Material 3 type scale.
- Themes must be defined in `lib/app/theme/` and consumed only via `Theme.of(context)` — no hard-coded colors in widgets.
- Seed color: `Color(0xFF1565C0)` (institutional blue — adjustable after visual design review).
- Theme mode must be switchable at runtime (persisted setting implemented in Spec 9; toggle stub provided now).

### FR-05 — Riverpod Configuration
- `ProviderScope` must wrap the root widget in `main.dart`.
- The app-level `ProviderScope` must be configured for override support (to facilitate testing).
- A global Riverpod `ProviderObserver` for debug logging must be included (disabled in release builds).

### FR-06 — go_router Setup
- A root `GoRouter` instance must be defined in `lib/app/router/`.
- Initial routes must include at minimum: a placeholder home route and a splash/loading route.
- Route name constants must be defined as `const String` values.
- Route guard (redirect) stubs must be created, ready to be populated in Spec 2.
- The router must be provided via a Riverpod provider.

### FR-07 — Firebase Configuration Boundaries
- `firebase_core` must be initialized once in `main.dart` via `Firebase.initializeApp()`.
- `google-services.json` must **not** be committed. Its required location (`android/app/`) must be documented.
- A `.env.example` or `firebase_config.example` file must document all required Firebase configuration values.
- No Firebase project needs to exist at spec-approval time; the code must compile with a placeholder or mock Firebase Options if the real `google-services.json` is absent.
- `FirebaseOptions` can be sourced from `google-services.json` (via `flutterfire configure`) or provided via `--dart-define` constants. The strategy must be documented.

### FR-08 — Environment and Secret Management
- A `.gitignore` must be present and must cover: `google-services.json`, `GoogleService-Info.plist`, `.env`, `*.keystore`, `*.jks`, `key.properties`, `.dart_tool/`, `build/`, `.flutter-plugins`, `.flutter-plugins-dependencies`.
- A `.env.example` file must document every required environment variable with placeholder values and descriptions.
- No secret values may appear in committed code, configuration files, or spec documents.

### FR-09 — Dart Analysis and Formatting
- An `analysis_options.yaml` must be present, extending `package:flutter_lints/flutter.yaml` with stricter rules documented in `design.md`.
- `flutter analyze` must pass with zero errors and zero warnings on the scaffold.
- `flutter format --set-exit-if-changed .` must pass on every committed file.

### FR-10 — Error Handling Conventions
- A shared `AppException` sealed class (or equivalent) must be defined in `lib/core/errors/`.
- An `AppException` must carry: a human-readable message, an optional error code, and an optional underlying cause.
- A global `ErrorHandler` utility must be scaffolded for converting exceptions to UI-friendly messages.
- All `Future`-returning repository methods must return typed results (using `Either`, `Result`, or explicit `AsyncValue`) rather than throwing uncaught exceptions to UI layers.

### FR-11 — Localization-Ready String Organization
- All user-visible strings must be placed in `lib/core/constants/app_strings.dart` or an ARB-based `flutter_localizations` structure.
- **Decision required:** ARB-based i18n vs. a simple string constants class. Given MVP scope, a string constants class is the default assumption; ARB can be adopted if i18n is confirmed as a requirement.
- No raw string literals for UI text in widget code.

### FR-12 — Logging
- A lightweight logger must be configured (e.g., the `logger` package or Dart's `developer.log`).
- Log calls must use severity levels: verbose/debug, info, warning, error.
- Debug logging must be automatically disabled in release builds (checked via `kReleaseMode`).

### FR-13 — Testing Structure
- A `test/` directory must mirror `lib/` structure:
  ```
  test/
    app/
    core/
    features/
      auth/
      notices/
      ...
    shared/
  ```
- A baseline `test/core/errors/app_exception_test.dart` must be written and must pass.
- A widget smoke test `test/app/app_widget_test.dart` must verify the app renders without crashing.
- Test utilities (mock factories, test helpers) must be placed in `test/helpers/`.

### FR-14 — README Documentation
- A `README.md` must be created at the project root covering:
  - Project overview and purpose
  - Prerequisites (Flutter SDK version, Dart version, Firebase CLI, Node.js if needed)
  - Environment setup instructions (`.env` / `--dart-define`)
  - Firebase project creation and `flutterfire configure` steps
  - Android build requirements (`google-services.json`, Gradle versions)
  - iOS build requirements (Xcode, `GoogleService-Info.plist`)
  - Commands to build, run, analyze, format, and test
  - Architecture overview (reference to `design.md`)
  - Known limitations and demo data setup (stubs for now)

---

## 5. Non-Functional Requirements

| ID | Requirement |
|---|---|
| NFR-01 | Cold-start compilation must succeed on a clean checkout after following README setup steps |
| NFR-02 | `flutter analyze` must report zero errors and zero warnings on the scaffold |
| NFR-03 | All baseline tests must pass (`flutter test`) |
| NFR-04 | No committed file may contain API keys, service credentials, or passwords |
| NFR-05 | The project must use null-safe Dart throughout; no `!` force-unwraps without documented justification |
| NFR-06 | Code generation (`build_runner`) must complete without errors |
| NFR-07 | The minimum Android SDK must be set to 21 (covers ~99% of active Android devices) |
| NFR-08 | The app must run on Flutter stable channel (version ≥ 3.22.0 at the time of setup) |
| NFR-09 | No circular imports between feature directories |
| NFR-10 | Folder structure must be enforced by convention; a lint rule or doc comment must make the rule discoverable |

---

## 6. Constraints

| Constraint | Detail |
|---|---|
| C-01 | Flutter and Dart SDK must be installed by the developer before running setup steps |
| C-02 | A Firebase project must be created and `flutterfire configure` run to generate `google-services.json` before running on a real device |
| C-03 | The Flutter SDK is not currently on the system PATH; this must be resolved during Spec 1 implementation |
| C-04 | iOS builds require macOS with Xcode — out of scope for the primary developer environment (Windows); Android is the primary target |
| C-05 | All package versions must be compatible with the chosen Flutter stable version |
| C-06 | Internet connection required to fetch packages during `flutter pub get` |

---

## 7. Assumptions

| ID | Assumption | Impact if Wrong |
|---|---|---|
| A-01 | Flutter 3.22+ stable will be installed by the developer | Package compatibility may need revision |
| A-02 | Firebase project will be created on Google's free Spark plan for demo purposes | Limits Storage and FCM usage volume; sufficient for MVP |
| A-03 | A single Firebase project with two environments (dev/prod) is not required at MVP stage; one project is acceptable | If multi-env is needed, config management will need expansion |
| A-04 | English-only UI is acceptable for MVP; localization structure must be extensible but ARB files are not required now | If i18n is required, switch to ARB-based approach in Spec 1 |
| A-05 | `flutter_dotenv` is the preferred environment strategy over `--dart-define` for readability | If CI/CD uses `--dart-define`, strategy will need revision |
| A-06 | Riverpod with code generation (`@riverpod`) is preferred over manual provider declarations | If team is unfamiliar with codegen, switch to manual providers |
| A-07 | The `.dist` folder in the repository is a Kiro build artifact and should not be modified | If `.dist` has a different purpose, clarify before proceeding |

---

## 8. Acceptance Criteria

| ID | Criterion | Verification Command |
|---|---|---|
| AC-01 | Project compiles without errors | `flutter build apk --debug` |
| AC-02 | Folder structure matches FR-03 | Manual inspection + `tree lib/` |
| AC-03 | All direct dependencies declared in pubspec.yaml | `flutter pub get` succeeds |
| AC-04 | `flutter analyze` passes with zero issues | `flutter analyze` |
| AC-05 | `flutter format` shows no changes needed | `flutter format --set-exit-if-changed .` |
| AC-06 | All baseline tests pass | `flutter test` |
| AC-07 | Code generation completes cleanly | `dart run build_runner build --delete-conflicting-outputs` |
| AC-08 | No secrets in any committed file | `git log --all --full-history -- "*.env"` + manual review |
| AC-09 | `.gitignore` covers all secret files | Attempt `git add google-services.json` — should be ignored |
| AC-10 | README contains all required sections (FR-14) | Manual review of README.md |
| AC-11 | Material 3 theme renders in both light and dark modes | Run app, toggle system theme |
| AC-12 | App entry point uses ProviderScope wrapping | Code review of `main.dart` |

---

## 9. Open Questions / Decisions Requiring Approval

| # | Question | Default Assumption |
|---|---|---|
| OQ-01 | ARB-based i18n vs. string constants class? | String constants (`AppStrings`) for MVP |
| OQ-02 | `flutter_dotenv` vs. `--dart-define` for env config? | `flutter_dotenv` (`.env` file, gitignored) |
| OQ-03 | `mocktail` vs. `mockito` for test mocking? | `mocktail` (no codegen required, simpler setup) |
| OQ-04 | Strict linting ruleset (`very_good_analysis`) vs. `flutter_lints`? | `flutter_lints` + additional rules for MVP |
| OQ-05 | Should the app scaffold display a placeholder home screen or a blank `Scaffold`? | Placeholder home screen with app name and theme toggle |

---

*End of Spec 1 — Requirements*
