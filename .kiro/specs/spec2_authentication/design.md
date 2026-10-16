# Spec 2 — Authentication: Design

**Project:** NoticeWise – SmartNotice  
**Spec:** 2 of 10 — Authentication  
**Status:** Draft — Pending Approval  
**Deadline:** [DD-MMM-YYYY]  
**Last Updated:** 2026-10-11

---

## 1. Architecture Overview

Authentication follows the same feature-first clean architecture established in Spec 1:

```
Presentation          Domain                  Data
────────────          ──────                  ────
LoginScreen           AuthRepository          MockAuthRepository
SignUpScreen    ───►  (interface)      ◄───   FirebaseAuthRepository (stub)
ForgotPwdScreen       AppUser (model)         LocalAuthDataSource
AuthController        AppUserRole (enum)      SharedPrefsSessionStore
                      AuthFailure types
```

The key design principle: **the domain and presentation layers are completely unaware of whether the data layer is backed by Firebase or a local mock.** The only place this changes is in the Riverpod provider that registers the repository implementation.

### 1.1 Dependency Inversion

```
AuthController (presentation)
    └── reads: authRepositoryProvider → AuthRepository (interface)
                                              ↑
                             MockAuthRepository (data, Spec 2)
                             FirebaseAuthRepository (data, future)
```

Switching from mock to Firebase = changing one provider override in `main.dart`. Zero other files change.

---

## 2. File Structure

All new files created in Spec 2:

```
lib/
  features/
    auth/
      domain/
        app_user.dart              ← AppUser freezed model + AppUserRole enum
        app_user.freezed.dart      ← generated
        app_user.g.dart            ← generated (json_serializable)
        auth_repository.dart       ← abstract interface class AuthRepository
        auth_failure.dart          ← typed failures (InvalidCredentials, etc.)
      data/
        mock_auth_repository.dart  ← MockAuthRepository (demo mode)
        firebase_auth_repository.dart ← stub (not activated)
        local_session_store.dart   ← SharedPreferences read/write
      presentation/
        screens/
          login_screen.dart
          signup_screen.dart
          forgot_password_screen.dart
        widgets/
          auth_form_field.dart     ← shared styled TextFormField
          demo_mode_banner.dart    ← amber warning banner
          demo_accounts_card.dart  ← shows demo credentials
        providers/
          auth_controller.dart     ← AuthController AsyncNotifier
          auth_controller.g.dart   ← generated
          auth_providers.dart      ← authRepositoryProvider + currentUserProvider

  app/
    router/
      app_router.dart              ← UPDATED: redirect populated
      app_router.g.dart            ← re-generated

  shared/
    widgets/
      placeholder_home_screen.dart ← UPDATED: sign-out button

test/
  features/
    auth/
      mock_auth_repository_test.dart
      auth_controller_test.dart
      login_screen_test.dart
```

---

## 3. Domain Layer

### 3.1 AppUser Model

```dart
// lib/features/auth/domain/app_user.dart

@freezed
class AppUser with _$AppUser {
  const factory AppUser({
    required String id,
    required String email,
    required String name,
    required AppUserRole role,
    required DateTime createdAt,
  }) = _AppUser;

  factory AppUser.fromJson(Map<String, dynamic> json) =>
      _$AppUserFromJson(json);
}

enum AppUserRole {
  admin,
  viewer;

  bool get isAdmin => this == AppUserRole.admin;
}
```

- Immutable via `freezed` — `copyWith`, structural equality, `toString` all generated.
- `fromJson`/`toJson` via `json_serializable` — used for `shared_preferences` persistence.
- `AppUserRole` is an enum, not a raw string. Role checks use `.isAdmin`.

### 3.2 AuthRepository Interface

```dart
// lib/features/auth/domain/auth_repository.dart

abstract interface class AuthRepository {
  /// Signs in with email and password.
  /// Throws [AuthFailure] on failure.
  Future<AppUser> signIn({
    required String email,
    required String password,
  });

  /// Creates a new account. Role is always [AppUserRole.viewer].
  /// Throws [AuthFailure] on failure (e.g. duplicate email).
  Future<AppUser> signUp({
    required String email,
    required String password,
    required String name,
  });

  /// Signs out the current user and clears the persisted session.
  Future<void> signOut();

  /// Sends a password reset email.
  /// In demo mode: resolves immediately without sending email.
  Future<void> sendPasswordReset({required String email});

  /// Emits the current user on subscription and on auth state changes.
  /// Emits null when signed out.
  Stream<AppUser?> get authStateChanges;

  /// The synchronously available current user, or null.
  AppUser? get currentUser;
}
```

No Firebase, no platform imports. Pure Dart interface.

### 3.3 AuthFailure Types

```dart
// lib/features/auth/domain/auth_failure.dart

sealed class AuthFailure implements Exception {
  const AuthFailure({required this.message});
  final String message;
}

final class InvalidCredentialsFailure extends AuthFailure {
  const InvalidCredentialsFailure()
      : super(message: 'Invalid email or password.');
}

final class EmailAlreadyInUseFailure extends AuthFailure {
  const EmailAlreadyInUseFailure()
      : super(message: 'An account with this email already exists.');
}

final class WeakPasswordFailure extends AuthFailure {
  const WeakPasswordFailure()
      : super(message: 'Password must be at least 6 characters.');
}

final class NetworkFailure extends AuthFailure {
  const NetworkFailure()
      : super(message: 'Network error. Please check your connection.');
}

final class UnknownAuthFailure extends AuthFailure {
  const UnknownAuthFailure({super.message = 'An unexpected error occurred.'});
}
```

These are caught by `AuthController` and surfaced as `AsyncValue.error` wrapping the `AuthFailure`.

---

## 4. Data Layer

### 4.1 MockAuthRepository

The demo implementation. Manages an in-memory user store seeded with the two demo accounts. New sign-ups are added to the in-memory store and persisted via `LocalSessionStore`.

**Demo accounts seed:**
```dart
static final _demoAccounts = [
  (email: 'admin@demo.com', password: 'admin123', role: AppUserRole.admin, name: 'Demo Admin'),
  (email: 'user@demo.com',  password: 'user123',  role: AppUserRole.viewer, name: 'Demo User'),
];
```

**Key behaviours:**
- `signIn`: looks up email in `_accounts`, compares password (plain comparison — demo only), throws `InvalidCredentialsFailure` if no match.
- `signUp`: checks for duplicate email, creates new `AppUser` with `viewer` role and a UUID, saves to `LocalSessionStore`.
- `signOut`: calls `LocalSessionStore.clear()`, emits null on the stream.
- `sendPasswordReset`: resolves with no-op (throws nothing, sends nothing).
- `authStateChanges`: a `BehaviorSubject`-equivalent `StreamController.broadcast` that emits on every auth state change.
- Implements `AuthRepository` interface exactly — no extra public methods.

**Important**: Passwords are never stored to disk. Only the `AppUser` (without password) is persisted via `shared_preferences`.

### 4.2 LocalSessionStore

Thin wrapper around `shared_preferences`:

```dart
class LocalSessionStore {
  static const _key = 'noticewise_demo_session';

  Future<AppUser?> loadSession();       // reads + deserialises AppUser JSON
  Future<void> saveSession(AppUser u);  // serialises + writes AppUser JSON
  Future<void> clearSession();          // removes key
}
```

### 4.3 FirebaseAuthRepository (Stub)

A stub file created now but not registered as the active provider:

```dart
// lib/features/auth/data/firebase_auth_repository.dart
// TODO(spec2-phase2): Implement when Firebase Auth is configured.
// Implements AuthRepository using FirebaseAuth.instance.
// To activate: change authRepositoryProvider in auth_providers.dart
// to return FirebaseAuthRepository(ref.watch(firebaseAuthProvider)).

class FirebaseAuthRepository implements AuthRepository {
  // All methods throw UnimplementedError with a clear message.
}
```

This file confirms the interface is complete and serves as the implementation guide for when Firebase is added.

---

## 5. Presentation Layer

### 5.1 AuthController

```dart
// lib/features/auth/presentation/providers/auth_controller.dart

@riverpod
class AuthController extends _$AuthController {
  @override
  Future<AppUser?> build() async {
    // Load persisted session on startup.
    final repo = ref.watch(authRepositoryProvider);
    return repo.currentUser;
  }

  Future<void> signIn({required String email, required String password}) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(
      () => ref.read(authRepositoryProvider).signIn(email: email, password: password),
    );
  }

  Future<void> signUp({...}) async { ... }
  Future<void> signOut() async { ... }
  Future<void> sendPasswordReset({required String email}) async { ... }
}
```

### 5.2 authRepositoryProvider

```dart
// lib/features/auth/presentation/providers/auth_providers.dart

@Riverpod(keepAlive: true)
AuthRepository authRepository(Ref ref) {
  return MockAuthRepository(LocalSessionStore());
  // To switch to Firebase: return FirebaseAuthRepository(...);
}

@Riverpod(keepAlive: true)
Stream<AppUser?> authStateChanges(Ref ref) {
  return ref.watch(authRepositoryProvider).authStateChanges;
}
```

### 5.3 Router Update

The router `redirect` reads `authStateChangesProvider` (or `authControllerProvider`) to guard routes:

```dart
redirect: (context, state) {
  final authState = ref.read(authControllerProvider);
  final user = authState.valueOrNull;
  final isOnAuthRoute = state.matchedLocation == AppRoutes.login ||
      state.matchedLocation == AppRoutes.signup ||
      state.matchedLocation == AppRoutes.forgotPassword ||
      state.matchedLocation == AppRoutes.splash;

  if (user == null && !isOnAuthRoute) return AppRoutes.login;
  if (user != null && isOnAuthRoute) {
    return user.role.isAdmin ? AppRoutes.adminDashboard : AppRoutes.home;
  }
  if (user != null && !user.role.isAdmin &&
      state.matchedLocation.startsWith('/admin')) return AppRoutes.home;
  return null;
},
```

**Note:** The router reads `authControllerProvider` synchronously via `ref.read` — this is safe because `keepAlive: true` keeps the provider alive across navigation events. The router itself is a Riverpod provider that has access to `ref`.

### 5.4 Screen Designs

#### LoginScreen
```
┌─────────────────────────────────┐
│  ⚠️  DEMO MODE  (amber banner)  │
├─────────────────────────────────┤
│                                 │
│   🔔  NoticeWise                │
│                                 │
│   [Email field          ]       │
│   [Password field       ] 👁    │
│                        Forgot?  │
│   [      Sign In       ]        │
│                                 │
│   ── Demo Accounts ──           │
│   admin@demo.com / admin123     │
│   user@demo.com  / user123      │
│   [Quick Login: Admin] [User]   │
│                                 │
│   Don't have an account?        │
│   [           Sign Up         ] │
└─────────────────────────────────┘
```

- Quick login buttons auto-fill and submit (reduces friction for demos).
- Password field has show/hide toggle.

#### SignUpScreen
```
┌─────────────────────────────────┐
│  ⚠️  DEMO MODE  (amber banner)  │
├─────────────────────────────────┤
│   Create Account                │
│                                 │
│   [Full Name field      ]       │
│   [Email field          ]       │
│   [Password field       ] 👁    │
│                                 │
│   [    Create Account   ]       │
│                                 │
│   Already have an account?      │
│   [          Sign In          ] │
└─────────────────────────────────┘
```

#### ForgotPasswordScreen
```
┌─────────────────────────────────┐
│  ⚠️  DEMO MODE  (amber banner)  │
├─────────────────────────────────┤
│   Reset Password                │
│                                 │
│   Enter your email and we'll    │
│   show a demo confirmation.     │
│                                 │
│   [Email field          ]       │
│                                 │
│   [   Send Reset Link   ]       │
│                                 │
│   ← Back to Sign In             │
└─────────────────────────────────┘
```

After submission (success state):
```
│   ✅ Demo confirmation          │
│   In a real app, a reset link   │
│   would be sent to your email.  │
│   No email was sent.            │
```

### 5.5 Admin Dashboard Stub

A minimal placeholder screen accessible to `admin` role only:

```
┌─────────────────────────────────┐
│  Admin Dashboard    [Sign Out]  │
├─────────────────────────────────┤
│  Logged in as: Demo Admin       │
│  Role: Admin ✓                  │
│                                 │
│  ┌─────────────────────────┐    │
│  │ 📋 Spec 4 — Notice Mgmt │    │
│  │ Full admin features     │    │
│  │ coming soon             │    │
│  └─────────────────────────┘    │
└─────────────────────────────────┘
```

---

## 6. Navigation Flow

```
App start
  └─ SplashScreen (checks persisted session)
       ├─ session exists, role=admin  → /admin
       ├─ session exists, role=viewer → /home
       └─ no session                  → /login

/login
  ├─ success, admin  → /admin
  ├─ success, viewer → /home
  ├─ tap "Forgot"    → /forgot-password
  └─ tap "Sign Up"   → /signup

/signup
  ├─ success (always viewer) → /home
  └─ tap "Sign In"           → /login

/forgot-password
  ├─ submit → shows inline confirmation (stays on screen)
  └─ tap "Back" → /login

/home, /admin, /notices, ...
  └─ sign out → /login
```

---

## 7. Session Persistence Design

```
signIn() success
  → MockAuthRepository saves AppUser to LocalSessionStore
  → SharedPreferences key: 'noticewise_demo_session'
  → Value: AppUser.toJson() serialised to JSON string

App cold start (main.dart)
  → AuthController.build() calls repo.currentUser
  → MockAuthRepository.currentUser reads from LocalSessionStore
  → If valid JSON found: deserialise AppUser, return as current user
  → If null/corrupt: return null (→ redirect to login)

signOut()
  → LocalSessionStore.clearSession()
  → StreamController emits null
  → Router redirect fires → /login
```

---

## 8. State Management Flow

```
User taps "Sign In"
  → LoginScreen calls ref.read(authControllerProvider.notifier).signIn(...)
  → AuthController sets state = AsyncLoading
  → UI shows CircularProgressIndicator, button disabled
  → MockAuthRepository.signIn() executes (synchronous in demo, ~200ms simulated delay)
  → Success: state = AsyncData(AppUser)
    → router listener fires redirect → navigates to role home
  → Failure: state = AsyncError(AuthFailure, stackTrace)
    → LoginScreen listens to error → shows SnackBar or inline error
```

`AuthController` is `keepAlive: true` so auth state survives navigation between screens.

---

## 9. Key Technical Decisions

| Decision | Choice | Rationale |
|---|---|---|
| Session persistence | `shared_preferences` | Lightest option for a single user object; no schema migration |
| Password storage | Never stored to disk | Passwords only exist in-memory during `signIn` comparison |
| Stream type | `StreamController.broadcast` | Simple; no `rxdart` dependency needed |
| Role model | `AppUserRole` enum | Compile-time exhaustiveness; cannot be forged via string injection |
| Admin elevation | Impossible client-side | `signUp` hardcodes `viewer`; admin accounts are seed-only |
| Firebase stub | Created but not registered | Confirms interface completeness; clear TODO for Phase 2 |
| Router reads auth | via `ref.read` in redirect | Avoids rebuilding the entire route tree on every auth state change |
| Demo delay | 400ms artificial delay in mock | Makes loading states visible and realistic during demo |

---

## 10. Firebase Swap Guide

When Firebase Auth is ready (future spec), the migration is:

1. Run `flutterfire configure` → real `firebase_options.dart`.
2. Implement `FirebaseAuthRepository.signIn/signUp/signOut/...` using `FirebaseAuth.instance`.
3. In `auth_providers.dart`, change one line:
   ```dart
   // Before:
   return MockAuthRepository(LocalSessionStore());
   // After:
   return FirebaseAuthRepository(FirebaseAuth.instance, LocalSessionStore());
   ```
4. Remove demo seed accounts from `MockAuthRepository`.
5. Remove demo mode banner.
6. All screens, tests for domain logic, and the router remain unchanged.

---

## 11. Risks and Mitigations

| Risk | Likelihood | Impact | Mitigation |
|---|---|---|---|
| `shared_preferences` JSON corruption | Low | User logged out | Clear on parse error; graceful fallback to login |
| Router reads stale auth state | Low | Wrong redirect | `keepAlive: true` on `authControllerProvider`; router re-evaluates on `ref.invalidate` after sign-in/out |
| `freezed` codegen breaks on `AppUser` | Low | Build failure | Keep model simple; test codegen in CI |
| Demo banner removed accidentally | Low | Security optics issue | Test that banner text is present in widget tests |

---

*End of Spec 2 — Design*
