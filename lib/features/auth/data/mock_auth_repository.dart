import 'dart:async';

import 'package:noticewise/features/auth/data/local_session_store.dart';
import 'package:noticewise/features/auth/domain/app_user.dart';
import 'package:noticewise/features/auth/domain/auth_failure.dart';
import 'package:noticewise/features/auth/domain/auth_repository.dart';
import 'package:uuid/uuid.dart';

// ─── Demo account seed data ───────────────────────────────────────────────────
// These credentials are intentionally simple and clearly labelled as demo-only.
// They are displayed on the login screen so evaluators can test both roles.
// They will be removed entirely when FirebaseAuthRepository is activated.

typedef _DemoAccount = ({
  String id,
  String email,
  String password,
  String name,
  AppUserRole role,
});

// ─────────────────────────────────────────────────────────────────────────────

/// Demo-mode [AuthRepository] backed entirely by in-memory state and
/// [LocalSessionStore] (SharedPreferences). No network calls are made.
///
/// ⚠️  DEMO MODE ONLY — not production-secure authentication.
///     Passwords are compared in plain text (in-memory only; never stored).
///     Replace with [FirebaseAuthRepository] for production use.
///
/// To activate Firebase: in `auth_providers.dart`, change:
///   MockAuthRepository(LocalSessionStore())
///   → FirebaseAuthRepository(FirebaseAuth.instance)
class MockAuthRepository implements AuthRepository {
  MockAuthRepository(this._sessionStore) {
    _loadInitialSession();
  }

  final LocalSessionStore _sessionStore;
  final _uuid = const Uuid();

  // StreamController that broadcasts auth state changes to all listeners.
  final _authController = StreamController<AppUser?>.broadcast();

  AppUser? _currentUser;

  // ── Seed accounts ──────────────────────────────────────────────────────────
  static final List<_DemoAccount> _seedAccounts = [
    (
      id: 'demo-admin-001',
      email: 'admin@demo.com',
      password: 'admin123',
      name: 'Demo Admin',
      role: AppUserRole.admin,
    ),
    (
      id: 'demo-user-001',
      email: 'user@demo.com',
      password: 'user123',
      name: 'Demo User',
      role: AppUserRole.viewer,
    ),
  ];

  // Mutable registry: seed accounts + any sign-up accounts for this session.
  final List<_DemoAccount> _accounts = List.from(_seedAccounts);

  // ── Initialise from persisted session ─────────────────────────────────────
  Future<void> _loadInitialSession() async {
    final user = await _sessionStore.loadSession();
    if (user != null) {
      _currentUser = user;
      _authController.add(user);
    }
  }

  // ── AuthRepository implementation ─────────────────────────────────────────

  @override
  AppUser? get currentUser => _currentUser;

  @override
  Stream<AppUser?> get authStateChanges => _authController.stream;

  @override
  Future<AppUser> signIn({
    required String email,
    required String password,
  }) async {
    // Simulate a realistic network delay so loading states are visible.
    await Future<void>.delayed(const Duration(milliseconds: 400));

    final match = _accounts.where(
      (a) =>
          a.email.toLowerCase() == email.toLowerCase() &&
          a.password == password,
    );

    if (match.isEmpty) throw const InvalidCredentialsFailure();

    final account = match.first;
    final user = AppUser(
      id: account.id,
      email: account.email,
      name: account.name,
      role: account.role,
      createdAt: DateTime.now(),
    );

    _currentUser = user;
    await _sessionStore.saveSession(user);
    _authController.add(user);
    return user;
  }

  @override
  Future<AppUser> signUp({
    required String email,
    required String password,
    required String name,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 400));

    if (password.length < 6) throw const WeakPasswordFailure();

    final duplicate = _accounts.any(
      (a) => a.email.toLowerCase() == email.toLowerCase(),
    );
    if (duplicate) throw const EmailAlreadyInUseFailure();

    // New accounts are ALWAYS viewer — clients cannot self-assign admin.
    final newAccount = (
      id: _uuid.v4(),
      email: email,
      password: password,
      name: name,
      role: AppUserRole.viewer,
    );
    _accounts.add(newAccount);

    final user = AppUser(
      id: newAccount.id,
      email: newAccount.email,
      name: newAccount.name,
      role: AppUserRole.viewer,
      createdAt: DateTime.now(),
    );

    _currentUser = user;
    await _sessionStore.saveSession(user);
    _authController.add(user);
    return user;
  }

  @override
  Future<void> signOut() async {
    _currentUser = null;
    await _sessionStore.clearSession();
    _authController.add(null);
  }

  @override
  Future<void> sendPasswordReset({required String email}) async {
    // Demo mode: no email is sent. Resolves successfully after a brief delay.
    // The UI must display a disclaimer that no real email was sent.
    await Future<void>.delayed(const Duration(milliseconds: 300));
    // No-op — success.
  }

  /// Disposes the internal [StreamController]. Call when the repository
  /// is no longer needed (e.g. in tests).
  void dispose() {
    _authController.close();
  }
}
