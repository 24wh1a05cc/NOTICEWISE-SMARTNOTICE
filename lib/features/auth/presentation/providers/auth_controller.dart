import 'package:noticewise/features/auth/domain/app_user.dart';
import 'package:noticewise/features/auth/domain/auth_failure.dart';
import 'package:noticewise/features/auth/presentation/providers/auth_providers.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'auth_controller.g.dart';

/// Manages authentication state for the entire application.
///
/// State: [AsyncValue<AppUser?>]
///   - [AsyncLoading]  — an auth operation is in progress
///   - [AsyncData(user)] — signed in (user != null) or signed out (user == null)
///   - [AsyncError]    — last operation failed with [AuthFailure]
///
/// Kept alive so auth state persists across navigation.
@Riverpod(keepAlive: true)
class AuthController extends _$AuthController {
  @override
  Future<AppUser?> build() async {
    // Return whatever session was loaded from SharedPreferences.
    return ref.watch(authRepositoryProvider).currentUser;
  }

  /// Signs in with [email] and [password].
  ///
  /// Sets state to [AsyncLoading] while the operation is in progress.
  /// On success: [AsyncData(AppUser)].
  /// On failure: [AsyncError(AuthFailure, StackTrace)].
  Future<void> signIn({
    required String email,
    required String password,
  }) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(
      () => ref
          .read(authRepositoryProvider)
          .signIn(email: email, password: password),
    );
  }

  /// Creates a new [AppUserRole.viewer] account.
  Future<void> signUp({
    required String email,
    required String password,
    required String name,
  }) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(
      () => ref.read(authRepositoryProvider).signUp(
            email: email,
            password: password,
            name: name,
          ),
    );
  }

  /// Signs out and clears the persisted session.
  Future<void> signOut() async {
    state = const AsyncValue.loading();
    await ref.read(authRepositoryProvider).signOut();
    state = const AsyncValue.data(null);
  }

  /// Requests a password reset for [email].
  ///
  /// In demo mode: resolves immediately without sending any email.
  /// Returns true on success, false on failure.
  Future<bool> sendPasswordReset({required String email}) async {
    try {
      await ref
          .read(authRepositoryProvider)
          .sendPasswordReset(email: email);
      return true;
    } on AuthFailure {
      return false;
    } catch (_) {
      return false;
    }
  }

  /// Convenience getter — returns the currently signed-in user synchronously,
  /// or null if signed out or state is loading/error.
  AppUser? get currentUser => state.asData?.value;
}
