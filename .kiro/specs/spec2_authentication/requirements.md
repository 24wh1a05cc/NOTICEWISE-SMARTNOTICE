# Spec 2 — Authentication: Requirements

**Project:** NoticeWise – SmartNotice  
**Spec:** 2 of 10 — Authentication  
**Status:** Draft — Pending Approval  
**Deadline:** [DD-MMM-YYYY]  
**Last Updated:** 2026-10-11  
**Depends on:** Spec 1 (complete ✅)

---

## 1. Purpose

This specification defines requirements for the authentication system of NoticeWise – SmartNotice. The critical constraint for this spec is:

> **The app must run with `flutter run` without any Firebase project, `google-services.json`, or internet connection. All authentication in this spec is demo/local-only.**

Firebase Authentication is the intended production backend (Spec 2 Phase 2, post-MVP). This spec implements a complete, production-architecture authentication system backed by a local mock repository. Swapping in Firebase later requires only replacing the data layer — no presentation or domain changes.

The demo mode must be clearly and permanently labelled in the UI so users are never misled into believing they are using production-secure authentication.

---

## 2. Scope

### In scope
- Sign in, sign up, sign out flows (demo/local mode)
- Forgot password flow (demo — shows confirmation, no real email)
- Persistent demo session (survives app restart via `shared_preferences`)
- Two demo roles: `admin` and `viewer`
- Protected route redirects (unauthenticated → login, authenticated user → notices, authenticated admin → admin dashboard)
- Role-aware navigation guard in `go_router`
- Input validation and error states on all auth forms
- Loading, success, error, and offline states
- Demo mode banner/indicator on all auth screens
- `AuthRepository` interface in the domain layer
- `MockAuthRepository` implementation in the data layer
- `AuthController` Riverpod provider in the presentation layer
- Unit tests for `AuthController` and `MockAuthRepository`
- Widget tests for `LoginScreen` and `SignUpScreen`

### Out of scope
- Real Firebase Authentication (deferred — `FirebaseAuthRepository` stub to be created but not activated)
- Email verification
- OAuth/social login (Google, Apple)
- Biometric authentication
- Account deletion
- Admin-assigned roles via Firestore (covered in Spec 3+)
- Password strength enforcement beyond minimum length (demo only)

---

## 3. Demo Accounts

Two hard-coded demo accounts enable role testing without a backend:

| Email | Password | Role | Name |
|---|---|---|---|
| `admin@demo.com` | `admin123` | `admin` | Demo Admin |
| `user@demo.com` | `user123` | `viewer` | Demo User |

These credentials must be clearly displayed on the login screen in a "Demo Accounts" card so evaluators can test both roles without reading documentation.

**Security note:** These are demo-only credentials with no access to real data. They must be labelled as such. The production app will use Firebase Auth with real email/password; these hard-coded values will be removed entirely when `FirebaseAuthRepository` is activated.

---

## 4. Functional Requirements

### FR-01 — Login Screen
- Email and password fields with validation.
- "Sign In" button triggers the auth flow.
- "Forgot Password?" link navigates to the forgot-password screen.
- "Don't have an account? Sign Up" link navigates to sign-up.
- Demo accounts card showing both demo credentials.
- Demo mode banner clearly visible.
- Loading indicator while signing in.
- Error message displayed on invalid credentials.
- Fields cleared on navigation away.

### FR-02 — Sign-Up Screen
- Name, email, and password fields with validation.
- "Create Account" button creates a new demo account.
- "Already have an account? Sign In" link navigates back.
- Demo mode banner visible.
- New accounts created in demo mode are stored locally (not persisted across reinstall).
- New accounts are always assigned the `viewer` role — clients cannot self-assign `admin`.
- Loading indicator while creating account.
- Duplicate email error displayed if email already exists.

### FR-03 — Forgot Password Screen
- Email field with validation.
- "Send Reset Link" button shows a success confirmation message.
- In demo mode: confirmation is shown immediately without sending any email.
- Confirmation message must state this is demo mode and no email was sent.
- "Back to Sign In" navigation.

### FR-04 — Sign Out
- Sign-out action available from the placeholder home screen (and later from the profile/settings screen in Spec 9).
- Signs out immediately, clears session, redirects to login.
- No confirmation dialog required (low-stakes in demo mode).

### FR-05 — Session Persistence
- After a successful sign-in, the session survives app restart.
- On cold start, the splash screen checks for a persisted session and redirects accordingly:
  - Valid session → role-appropriate home screen
  - No session → login screen
- Session stored via `shared_preferences` (JSON-encoded user object).
- Session cleared on sign-out.

### FR-06 — Route Protection
- All routes except `/login`, `/signup`, `/forgot-password`, and `/` (splash) are protected.
- Unauthenticated access to any protected route redirects to `/login`.
- Authenticated `viewer` accessing an admin-only route redirects to `/home`.
- Authenticated user accessing `/login` or `/signup` is redirected to their role-appropriate home.
- The router `redirect` callback (stubbed in Spec 1) is fully populated.

### FR-07 — Role-Aware Navigation
- After successful login:
  - `admin` role → navigates to `/admin` (admin dashboard stub, created in this spec)
  - `viewer` role → navigates to `/home` (placeholder notice feed)
- The routing decision is made in the router guard, not in widget code.

### FR-08 — Input Validation
All form fields must validate:

| Field | Rules |
|---|---|
| Email | Required; valid email format (`someone@domain.tld`) |
| Password (login) | Required; minimum 6 characters |
| Password (sign-up) | Required; minimum 6 characters |
| Name (sign-up) | Required; minimum 2 characters; max 60 characters |

Validation runs on form submission. Field-level inline errors shown after first submit attempt.

### FR-09 — Demo Mode Indicator
- A persistent, non-dismissible banner or chip must appear on every auth screen stating:
  - "Demo Mode — local authentication only, no data is sent to any server"
- The indicator must use a visually distinct colour (amber/warning) so it is unmistakeable.
- This requirement is non-negotiable. Demo mode must never be presented as production authentication.

### FR-10 — AuthRepository Interface
The domain layer must define:
```dart
abstract interface class AuthRepository {
  Future<AppUser> signIn({required String email, required String password});
  Future<AppUser> signUp({required String email, required String password, required String name});
  Future<void> signOut();
  Future<void> sendPasswordReset({required String email});
  Stream<AppUser?> get authStateChanges;
  AppUser? get currentUser;
}
```
This interface must not import any Firebase, `shared_preferences`, or platform packages. It depends only on domain models.

### FR-11 — AppUser Domain Model
A `AppUser` immutable model in the domain layer:
```dart
// fields: id, email, name, role (AppUserRole enum: admin / viewer), createdAt
```
- Must be a `freezed` data class with `copyWith`, equality, and `toString`.
- The `role` field must be an enum (`AppUserRole`) — never a raw string in domain code.
- `AppUserRole` must have exactly two values: `admin` and `viewer`. Clients cannot introduce other values.

### FR-12 — AuthController
A Riverpod `AsyncNotifier<AppUser?>` that:
- Exposes `signIn`, `signUp`, `signOut`, `sendPasswordReset` methods.
- Uses `AuthRepository` injected via Riverpod (never instantiated directly in the controller).
- Returns `AsyncValue.loading()` during async operations.
- Returns `AsyncValue.error(AppException, StackTrace)` on failure.
- Returns `AsyncValue.data(AppUser?)` on success (null = signed out).

---

## 5. Non-Functional Requirements

| ID | Requirement |
|---|---|
| NFR-01 | App runs with `flutter run` without Firebase, internet, or `google-services.json` |
| NFR-02 | Demo mode is permanently and unmistakeably labelled in the UI |
| NFR-03 | `flutter analyze` passes with zero issues after implementation |
| NFR-04 | `flutter test` passes — all existing + new tests |
| NFR-05 | Session persists across hot restart and cold start |
| NFR-06 | No Firebase packages imported in domain or presentation layers |
| NFR-07 | `AuthRepository` interface has no platform dependencies |
| NFR-08 | Swapping `MockAuthRepository` for `FirebaseAuthRepository` requires only changing one Riverpod provider override — no other files change |
| NFR-09 | Role elevation is impossible from the client — `signUp` always produces `viewer` role |
| NFR-10 | Auth forms show loading state and disable submit button during async operations |

---

## 6. New Dependencies Required

| Package | Version | Purpose | Justification |
|---|---|---|---|
| `shared_preferences` | `^2.3.2` | Persist demo session | Lightest persistence option; no schema required for a single JSON user object |

No other new packages are needed. `freezed` and `riverpod_generator` are already in `dev_dependencies` from Spec 1.

The `shared_preferences` package is the only addition. A heavier local database (`sqflite`, `drift`, `isar`) is not justified for storing a single auth session object.

---

## 7. Constraints

| Constraint | Detail |
|---|---|
| C-01 | Firebase must not be initialised or required for the app to run |
| C-02 | Demo credentials must not resemble real-looking secure passwords |
| C-03 | `FirebaseAuthRepository` stub must be created but must not be registered as the active provider |
| C-04 | The `MockAuthRepository` is explicitly labelled as demo-only in code comments |
| C-05 | iOS builds remain secondary; all persistence uses packages compatible with both Android and iOS |

---

## 8. Assumptions

| ID | Assumption | Impact if Wrong |
|---|---|---|
| A-01 | `shared_preferences` is sufficient for demo session persistence | If richer persistence is needed, switch to `flutter_secure_storage` or `hive` |
| A-02 | No password hashing is required for demo credentials (stored as plain text in memory only; not written to disk) | If security audit requires it, add `crypto` package and hash stored credentials |
| A-03 | The admin dashboard stub screen (created in this spec) is a simple placeholder — full implementation in Spec 4 | If Spec 4 is merged into Spec 2, expand the admin screen |
| A-04 | `freezed` version `^4.0.2` (already in pubspec) is compatible with the `AppUser` model — no version conflicts | If codegen fails, update freezed version |
| A-05 | Demo user accounts created via sign-up do not persist across app reinstall (in-memory + shared_preferences only) | If persistence across reinstall is required, switch to a local database |

---

## 9. Acceptance Criteria

| ID | Criterion | Verification |
|---|---|---|
| AC-01 | App runs with `flutter run` — no Firebase needed | `flutter run` succeeds with placeholder `firebase_options.dart` |
| AC-02 | Login with `admin@demo.com` / `admin123` → reaches admin screen | Manual test |
| AC-03 | Login with `user@demo.com` / `user123` → reaches home screen | Manual test |
| AC-04 | Login with wrong password → shows error message | Manual test |
| AC-05 | Sign up with new email → creates account with `viewer` role | Manual test |
| AC-06 | Session persists after hot restart | Hot restart during active session |
| AC-07 | Sign out → returns to login screen | Manual test |
| AC-08 | Navigating to `/home` while signed out → redirects to `/login` | Manual navigation test |
| AC-09 | `viewer` navigating to `/admin` → redirects to `/home` | Manual navigation test |
| AC-10 | Demo mode banner visible on all auth screens | Visual inspection |
| AC-11 | All new tests pass | `flutter test` |
| AC-12 | `flutter analyze` passes | `flutter analyze` |
| AC-13 | `AuthRepository` interface has zero Firebase imports | Code review |
| AC-14 | Forgot password shows demo confirmation (no real email) | Manual test |

---

## 10. Open Questions

| # | Question | Default Assumption |
|---|---|---|
| OQ-01 | Should sign-up allow custom roles for demo purposes (e.g., a dropdown)? | **No** — always `viewer`. Admin accounts are pre-seeded only. |
| OQ-02 | Should in-memory sign-up accounts survive hot restart but not cold restart? | **No** — use `shared_preferences` so they survive cold restart too. |
| OQ-03 | Should the forgot-password screen send a real email in demo mode? | **No** — show a static confirmation banner stating no email was sent. |

---

*End of Spec 2 — Requirements*
