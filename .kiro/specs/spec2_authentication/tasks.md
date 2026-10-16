# Spec 2 — Authentication: Tasks

**Project:** NoticeWise – SmartNotice  
**Spec:** 2 of 10 — Authentication  
**Status:** Draft — Pending Approval  
**Deadline:** [DD-MMM-YYYY]  
**Last Updated:** 2026-10-11  
**Estimated Total Effort:** 5–7 hours

---

## Prerequisites

| # | Prerequisite | Status |
|---|---|---|
| P-01 | Spec 1 complete — Flutter project compiles, `flutter analyze` clean | ✅ Done |
| P-02 | `flutter test` passes (34/34 from Spec 1) | ✅ Done |
| P-03 | `pubspec.yaml` has `freezed`, `json_serializable`, `riverpod_generator` | ✅ Done |

---

## Implementation Tasks

### TASK-01 — Add `shared_preferences` dependency
**Estimated effort:** 5 min  
**Depends on:** —

```powershell
flutter pub add shared_preferences
```

Update `pubspec.yaml` (keep alphabetical sort in dependencies).

**Verification:**
```powershell
flutter pub get
```
**Acceptance:** `flutter pub get` exits 0. `shared_preferences` visible in `pubspec.yaml`.

---

### TASK-02 — Create `AppUser` domain model
**Estimated effort:** 15 min  
**Depends on:** TASK-01

Create `lib/features/auth/domain/app_user.dart`:
- `@freezed` class with fields: `id` (String), `email` (String), `name` (String), `role` (AppUserRole), `createdAt` (DateTime).
- `factory AppUser.fromJson(...)` for `json_serializable`.
- `AppUserRole` enum with `admin` and `viewer` values.
- Convenience getter `bool get isAdmin` on `AppUserRole`.

Run codegen:
```powershell
dart run build_runner build --delete-conflicting-outputs
```

**Verification:**
```powershell
flutter analyze
```
**Acceptance:** `app_user.freezed.dart` and `app_user.g.dart` generated. Zero analyzer issues.

---

### TASK-03 — Create `AuthFailure` types
**Estimated effort:** 10 min  
**Depends on:** TASK-02

Create `lib/features/auth/domain/auth_failure.dart`:
- Sealed class `AuthFailure` with subtypes:
  `InvalidCredentialsFailure`, `EmailAlreadyInUseFailure`, `WeakPasswordFailure`, `NetworkFailure`, `UnknownAuthFailure`.
- Per design.md Section 3.3.

**Verification:** `flutter analyze` — zero issues.

---

### TASK-04 — Create `AuthRepository` interface
**Estimated effort:** 10 min  
**Depends on:** TASK-03

Create `lib/features/auth/domain/auth_repository.dart`:
- `abstract interface class AuthRepository`
- Methods: `signIn`, `signUp`, `signOut`, `sendPasswordReset`
- Getters: `authStateChanges` (Stream), `currentUser` (AppUser?)
- Zero imports from Firebase, `shared_preferences`, or platform packages.

**Verification:** `flutter analyze` — zero issues.

---

### TASK-05 — Create `LocalSessionStore`
**Estimated effort:** 15 min  
**Depends on:** TASK-02

Create `lib/features/auth/data/local_session_store.dart`:
- Uses `shared_preferences`.
- `loadSession()` → `Future<AppUser?>`
- `saveSession(AppUser)` → `Future<void>`
- `clearSession()` → `Future<void>`
- Handles JSON parse errors gracefully (returns null, logs warning).

**Verification:** Unit test in `auth_repository_test.dart` (written in TASK-11).

---

### TASK-06 — Create `MockAuthRepository`
**Estimated effort:** 30 min  
**Depends on:** TASK-04, TASK-05

Create `lib/features/auth/data/mock_auth_repository.dart`:
- Implements `AuthRepository`.
- Seeded with two demo accounts (see requirements FR-03 demo accounts table).
- `signIn`: match email+password, throw `InvalidCredentialsFailure` on mismatch.
- `signUp`: check duplicate email, create `viewer`-role user with `Uuid().v4()` id, save session, emit on stream.
- `signOut`: clear session, emit null on stream.
- `sendPasswordReset`: no-op, resolves successfully.
- `authStateChanges`: `StreamController<AppUser?>.broadcast()`.
- Artificial 400ms delay on `signIn` and `signUp` (makes loading state visible in demo).
- Add `uuid` package for ID generation.

Add `uuid` to pubspec:
```powershell
flutter pub add uuid
```

**Verification:** `flutter analyze` — zero issues.

---

### TASK-07 — Create `FirebaseAuthRepository` stub
**Estimated effort:** 10 min  
**Depends on:** TASK-04

Create `lib/features/auth/data/firebase_auth_repository.dart`:
- `class FirebaseAuthRepository implements AuthRepository`
- All methods throw `UnimplementedError` with a descriptive message.
- File-level comment explaining how to activate it (per design.md Section 10).
- Must NOT import `firebase_auth` (avoids requiring Firebase packages to compile).

**Verification:** `flutter analyze` — zero issues.

---

### TASK-08 — Create `authRepositoryProvider` and `authStateChangesProvider`
**Estimated effort:** 15 min  
**Depends on:** TASK-06, TASK-07

Create `lib/features/auth/presentation/providers/auth_providers.dart`:
- `authRepositoryProvider` (`@Riverpod(keepAlive: true)`) returns `MockAuthRepository`.
- `authStateChangesProvider` (`@Riverpod(keepAlive: true)`) returns `repo.authStateChanges` stream.

Run codegen:
```powershell
dart run build_runner build --delete-conflicting-outputs
```

**Verification:** `flutter analyze` — zero issues.

---

### TASK-09 — Create `AuthController`
**Estimated effort:** 20 min  
**Depends on:** TASK-08

Create `lib/features/auth/presentation/providers/auth_controller.dart`:
- `@Riverpod(keepAlive: true)` `AsyncNotifier<AppUser?>`.
- `build()`: returns `repo.currentUser` (loads persisted session).
- `signIn(email, password)`: sets `AsyncLoading`, calls repo, sets `AsyncData` or `AsyncError`.
- `signUp(email, password, name)`: same pattern.
- `signOut()`: calls repo, sets `AsyncData(null)`, then invalidates router.
- `sendPasswordReset(email)`: calls repo, surfacing success/error.
- Catches `AuthFailure` and rethrows as `AppException` for consistent UI handling.

Run codegen:
```powershell
dart run build_runner build --delete-conflicting-outputs
```

**Verification:** `flutter analyze` — zero issues.

---

### TASK-10 — Create shared auth widgets
**Estimated effort:** 20 min  
**Depends on:** TASK-09

Create the following reusable widgets:

**`lib/features/auth/presentation/widgets/demo_mode_banner.dart`**
- Non-dismissible amber `MaterialBanner`-style widget.
- Text: "⚠️ Demo Mode — local authentication only. No data is sent to any server."
- Uses `Theme.of(context).colorScheme` — amber tones via `AppColors`.

**`lib/features/auth/presentation/widgets/auth_form_field.dart`**
- Styled `TextFormField` wrapper used by all auth screens.
- Supports: label, hint, icon, obscure toggle, keyboard type, validator, controller.
- Uses the `InputDecorationTheme` from `AppTheme`.

**`lib/features/auth/presentation/widgets/demo_accounts_card.dart`**
- Card showing both demo accounts and quick-login buttons.
- Quick-login buttons call a provided callback with pre-filled credentials.

**Verification:** `flutter analyze` — zero issues.

---

### TASK-11 — Create `LoginScreen`
**Estimated effort:** 45 min  
**Depends on:** TASK-10

Create `lib/features/auth/presentation/screens/login_screen.dart`:
- `ConsumerStatefulWidget` (needs `TextEditingController` + `GlobalKey<FormState>`).
- `DemoModeBanner` at top.
- Email + password fields using `AuthFormField`.
- Show/hide password toggle.
- "Forgot Password?" `TextButton`.
- "Sign In" `FilledButton` — disabled during `AsyncLoading`.
- Error display via `SnackBar` on `AsyncError`.
- `DemoAccountsCard` with quick-login buttons.
- "Don't have an account? Sign Up" `TextButton`.
- Listens to `authControllerProvider` — on `AsyncData(user != null)`, navigation is handled by router redirect (LoginScreen does NOT push routes).
- Dispose controllers in `dispose()`.

**Verification:** `flutter run` — login screen visible, quick login works.

---

### TASK-12 — Create `SignUpScreen`
**Estimated effort:** 30 min  
**Depends on:** TASK-10

Create `lib/features/auth/presentation/screens/signup_screen.dart`:
- Name, email, password fields.
- `DemoModeBanner`.
- Form validation per FR-08.
- "Create Account" button — disabled during loading.
- Error display via `SnackBar`.
- "Already have an account? Sign In" link.

**Verification:** Sign up with new email → reaches home screen with viewer role.

---

### TASK-13 — Create `ForgotPasswordScreen`
**Estimated effort:** 20 min  
**Depends on:** TASK-10

Create `lib/features/auth/presentation/screens/forgot_password_screen.dart`:
- Email field + `DemoModeBanner`.
- On submit success: shows inline confirmation widget (replaces form).
- Confirmation states: "Demo confirmation — no email was sent."
- "Back to Sign In" button.

**Verification:** Submit → confirmation shows. No crash.

---

### TASK-14 — Create admin dashboard stub
**Estimated effort:** 15 min  
**Depends on:** TASK-09

Create `lib/features/admin/presentation/admin_dashboard_screen.dart`:
- `ConsumerWidget`.
- `AppBar` with title "Admin Dashboard" and sign-out `IconButton`.
- Shows logged-in user's name and role.
- "Full admin features coming in Spec 4" placeholder card.

**Verification:** Login as admin → reaches admin dashboard.

---

### TASK-15 — Update `SplashScreen`
**Estimated effort:** 15 min  
**Depends on:** TASK-09

Update `lib/features/auth/presentation/splash_screen.dart`:
- Replace the `Future.delayed` stub with a real auth-state check.
- Reads `authControllerProvider`.
- Waits for `AsyncValue` to resolve (not loading).
- Redirects to appropriate route based on user role (or login if null).
- Keeps the current branded splash UI.

**Verification:** Cold start with saved session → correct screen without login.

---

### TASK-16 — Update `app_router.dart` with auth redirect
**Estimated effort:** 20 min  
**Depends on:** TASK-09, TASK-14

Update `lib/app/router/app_router.dart`:
- Add routes: `/login` → `LoginScreen`, `/signup` → `SignUpScreen`, `/forgot-password` → `ForgotPasswordScreen`, `/admin` → `AdminDashboardScreen`.
- Populate the `redirect` callback per design.md Section 5.3.
- Router reads `authControllerProvider` via `ref`.
- Run codegen to regenerate `app_router.g.dart`.

**Verification:** `flutter analyze` — zero issues. Manual route protection tests.

---

### TASK-17 — Update `PlaceholderHomeScreen` with sign-out
**Estimated effort:** 10 min  
**Depends on:** TASK-09

Update `lib/shared/widgets/placeholder_home_screen.dart`:
- Add sign-out `IconButton` to `AppBar`.
- Also show current user's name and role in the status card.
- Sign-out calls `ref.read(authControllerProvider.notifier).signOut()`.

**Verification:** Tap sign-out → redirected to login.

---

### TASK-18 — Write unit tests
**Estimated effort:** 45 min  
**Depends on:** TASK-06, TASK-09

**`test/features/auth/mock_auth_repository_test.dart`**
- `signIn` with valid demo credentials → returns correct `AppUser`.
- `signIn` with wrong password → throws `InvalidCredentialsFailure`.
- `signUp` with new email → returns `viewer`-role `AppUser`.
- `signUp` with duplicate email → throws `EmailAlreadyInUseFailure`.
- `signOut` → `currentUser` becomes null.
- `authStateChanges` emits user after signIn, null after signOut.

**`test/features/auth/auth_controller_test.dart`**
- Controller initial state: `AsyncData(null)` (no session).
- `signIn` sets `AsyncLoading` then `AsyncData(user)`.
- `signIn` failure sets `AsyncError`.
- `signOut` sets `AsyncData(null)`.

Use `mocktail` to mock `AuthRepository` in controller tests.

**Verification:**
```powershell
flutter test test/features/auth/
```
All pass.

---

### TASK-19 — Write widget tests
**Estimated effort:** 30 min  
**Depends on:** TASK-11, TASK-12

**`test/features/auth/login_screen_test.dart`**
- Login screen renders without crash.
- Demo mode banner is visible.
- Demo accounts card is visible.
- Submit with empty fields → validation errors shown.
- Submit with invalid email format → email validation error shown.

**Verification:**
```powershell
flutter test test/features/auth/login_screen_test.dart
```

---

### TASK-20 — Final analysis, format, and full test run
**Estimated effort:** 10 min  
**Depends on:** All previous tasks

```powershell
dart run build_runner build --delete-conflicting-outputs
dart format --set-exit-if-changed .
flutter analyze
flutter test
```

All four commands must exit with code 0.

**Acceptance:** Zero analyzer issues. Zero test failures. Zero format changes.

---

## Task Dependency Graph

```
TASK-01 (shared_preferences)
  └─ TASK-02 (AppUser model)
       ├─ TASK-03 (AuthFailure)
       │    └─ TASK-04 (AuthRepository interface)
       │         ├─ TASK-05 (LocalSessionStore)
       │         │    └─ TASK-06 (MockAuthRepository)
       │         │         └─ TASK-08 (authRepositoryProvider)
       │         │              └─ TASK-09 (AuthController)
       │         │                   ├─ TASK-10 (shared widgets)
       │         │                   │    ├─ TASK-11 (LoginScreen)
       │         │                   │    ├─ TASK-12 (SignUpScreen)
       │         │                   │    └─ TASK-13 (ForgotPasswordScreen)
       │         │                   ├─ TASK-14 (AdminDashboardStub)
       │         │                   ├─ TASK-15 (SplashScreen update)
       │         │                   ├─ TASK-16 (Router update)
       │         │                   └─ TASK-17 (HomeScreen sign-out)
       │         └─ TASK-07 (FirebaseAuthRepository stub)
       └─ TASK-18 (unit tests) ← after TASK-06, TASK-09
TASK-19 (widget tests)  ← after TASK-11, TASK-12
TASK-20 (final pass)    ← after all
```

---

## Effort Estimates and Risks

| Task | Effort | Risk |
|---|---|---|
| TASK-01–04 (domain) | 40 min | Low |
| TASK-05–07 (data layer) | 55 min | Low |
| TASK-08–09 (providers) | 35 min | Low — codegen straightforward |
| TASK-10–13 (screens) | 1h 55min | Medium — UI layout |
| TASK-14–17 (integration) | 1h | Low |
| TASK-18–19 (tests) | 1h 15min | Medium — mock setup |
| TASK-20 (final pass) | 10 min | Low |
| **Total** | **~5.5–7h** | |

**Critical path:** TASK-01 → TASK-02 → TASK-04 → TASK-06 → TASK-09 → TASK-16 → TASK-20

---

## Must-Have vs. Deferrable

| Item | Must-Have | Deferrable |
|---|---|---|
| Login / sign-out flow | ✅ | |
| Session persistence (cold start) | ✅ | |
| Role-based routing | ✅ | |
| Demo mode banner on all screens | ✅ | |
| Sign-up flow | ✅ | |
| Forgot password (demo no-op) | ✅ | |
| Admin dashboard stub | ✅ | |
| `FirebaseAuthRepository` stub | ✅ | |
| Unit tests for MockAuthRepository | ✅ | |
| Widget tests for LoginScreen | ✅ | |
| Password strength meter | | ✅ Spec 9 |
| Remember me / biometric | | ✅ Future |
| Email verification flow | | ✅ Firebase phase |

---

*End of Spec 2 — Tasks*
