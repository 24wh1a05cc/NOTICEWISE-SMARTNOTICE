import 'package:noticewise/features/auth/data/local_session_store.dart';
import 'package:noticewise/features/auth/data/mock_auth_repository.dart';
import 'package:noticewise/features/auth/domain/app_user.dart';
import 'package:noticewise/features/auth/domain/auth_repository.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'auth_providers.g.dart';

/// Provides the active [AuthRepository] implementation.
///
/// ─── DEMO MODE ──────────────────────────────────────────────────────────────
/// Currently returns [MockAuthRepository]. No Firebase required.
///
/// To switch to Firebase Authentication (requires a configured project):
///   return FirebaseAuthRepository(FirebaseAuth.instance);
/// ────────────────────────────────────────────────────────────────────────────
@Riverpod(keepAlive: true)
AuthRepository authRepository(Ref ref) {
  return MockAuthRepository(LocalSessionStore());
}

/// Stream of auth state changes — emits [AppUser] when signed in, null when
/// signed out. Kept alive so all screens share the same stream subscription.
@Riverpod(keepAlive: true)
Stream<AppUser?> authStateChanges(Ref ref) {
  return ref.watch(authRepositoryProvider).authStateChanges;
}
