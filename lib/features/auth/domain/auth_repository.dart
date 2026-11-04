import 'package:noticewise/features/auth/domain/app_user.dart';

/// Contract for all authentication backends.
///
/// The domain and presentation layers depend only on this interface —
/// never on [MockAuthRepository] or [FirebaseAuthRepository] directly.
///
/// To swap backends, change the provider in `auth_providers.dart`:
///   - Demo mode:  return MockAuthRepository(LocalSessionStore())
///   - Production: return FirebaseAuthRepository(FirebaseAuth.instance)
abstract interface class AuthRepository {
  /// Signs in with [email] and [password].
  ///
  /// Returns the authenticated [AppUser] on success.
  /// Throws [AuthFailure] on failure (invalid credentials, network, etc.).
  Future<AppUser> signIn({
    required String email,
    required String password,
  });

  /// Creates a new account.
  ///
  /// The new user always receives [AppUserRole.viewer].
  /// Clients cannot self-assign [AppUserRole.admin].
  /// Throws [AuthFailure] on failure (duplicate email, weak password, etc.).
  Future<AppUser> signUp({
    required String email,
    required String password,
    required String name,
  });

  /// Signs out the current user and clears the persisted session.
  Future<void> signOut();

  /// Sends a password-reset email to [email].
  ///
  /// In demo/mock mode this resolves immediately without sending any email.
  /// Callers must display a suitable disclaimer to the user.
  Future<void> sendPasswordReset({required String email});

  /// Stream that emits the current [AppUser] when signed in, or null
  /// when signed out. Emits the current state on subscription.
  Stream<AppUser?> get authStateChanges;

  /// Synchronously returns the current user from the last known auth state,
  /// or null if no session is active.
  AppUser? get currentUser;
}
