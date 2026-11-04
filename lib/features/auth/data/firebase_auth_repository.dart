// Firebase Auth Repository — STUB (Firebase removed)
//
// Firebase has been removed from this project. All authentication is handled
// by MockAuthRepository (local demo mode) using SharedPreferences for session
// persistence.
//
// To add Firebase in the future:
//   1. Re-add firebase_core, firebase_auth to pubspec.yaml
//   2. Run `flutterfire configure`
//   3. Implement AuthRepository against FirebaseAuth.instance
//   4. Update authRepositoryProvider in auth_providers.dart
//
// This file is intentionally left as a stub to preserve the repo structure.

import 'package:noticewise/features/auth/domain/app_user.dart';
import 'package:noticewise/features/auth/domain/auth_repository.dart';

/// Stub Firebase Auth repository — NOT active.
///
/// The active implementation is [MockAuthRepository].
class FirebaseAuthRepository implements AuthRepository {
  const FirebaseAuthRepository();

  @override
  Future<AppUser> signIn({required String email, required String password}) =>
      throw UnimplementedError('Firebase is not configured.');

  @override
  Future<AppUser> signUp({
    required String email,
    required String password,
    required String name,
  }) =>
      throw UnimplementedError('Firebase is not configured.');

  @override
  Future<void> signOut() =>
      throw UnimplementedError('Firebase is not configured.');

  @override
  Future<void> sendPasswordReset({required String email}) =>
      throw UnimplementedError('Firebase is not configured.');

  @override
  Stream<AppUser?> get authStateChanges =>
      throw UnimplementedError('Firebase is not configured.');

  @override
  AppUser? get currentUser =>
      throw UnimplementedError('Firebase is not configured.');
}
