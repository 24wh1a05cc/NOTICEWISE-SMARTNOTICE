import 'package:flutter_test/flutter_test.dart';
import 'package:noticewise/features/auth/data/local_session_store.dart';
import 'package:noticewise/features/auth/data/mock_auth_repository.dart';
import 'package:noticewise/features/auth/domain/app_user.dart';
import 'package:noticewise/features/auth/domain/auth_failure.dart';
import 'package:shared_preferences/shared_preferences.dart';

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// Creates a fresh [MockAuthRepository] backed by a real but in-memory
/// [SharedPreferences] instance (the flutter_test platform mock).
MockAuthRepository _makeRepo() {
  return MockAuthRepository(LocalSessionStore());
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  // Use SharedPreferences in-memory mock for all tests.
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('MockAuthRepository', () {
    // ── signIn ───────────────────────────────────────────────────────────────
    group('signIn', () {
      test('returns admin AppUser for demo admin credentials', () async {
        final repo = _makeRepo();
        final user = await repo.signIn(
          email: 'admin@demo.com',
          password: 'admin123',
        );
        expect(user.email, 'admin@demo.com');
        expect(user.name, 'Demo Admin');
        expect(user.role, AppUserRole.admin);
        expect(user.role.isAdmin, isTrue);
        repo.dispose();
      });

      test('returns viewer AppUser for demo viewer credentials', () async {
        final repo = _makeRepo();
        final user = await repo.signIn(
          email: 'user@demo.com',
          password: 'user123',
        );
        expect(user.email, 'user@demo.com');
        expect(user.name, 'Demo User');
        expect(user.role, AppUserRole.viewer);
        expect(user.role.isAdmin, isFalse);
        repo.dispose();
      });

      test('is case-insensitive for email', () async {
        final repo = _makeRepo();
        final user = await repo.signIn(
          email: 'ADMIN@DEMO.COM',
          password: 'admin123',
        );
        expect(user.role, AppUserRole.admin);
        repo.dispose();
      });

      test('throws InvalidCredentialsFailure for wrong password', () async {
        final repo = _makeRepo();
        expect(
          () => repo.signIn(
            email: 'admin@demo.com',
            password: 'wrong',
          ),
          throwsA(isA<InvalidCredentialsFailure>()),
        );
        repo.dispose();
      });

      test('throws InvalidCredentialsFailure for unknown email', () async {
        final repo = _makeRepo();
        expect(
          () => repo.signIn(
            email: 'nobody@example.com',
            password: 'pass123',
          ),
          throwsA(isA<InvalidCredentialsFailure>()),
        );
        repo.dispose();
      });

      test('persists user session after sign-in', () async {
        final sessionStore = LocalSessionStore();
        final repo = MockAuthRepository(sessionStore);
        await repo.signIn(email: 'user@demo.com', password: 'user123');
        final persisted = await sessionStore.loadSession();
        expect(persisted, isNotNull);
        expect(persisted!.email, 'user@demo.com');
        repo.dispose();
      });

      test('updates currentUser after sign-in', () async {
        final repo = _makeRepo();
        expect(repo.currentUser, isNull);
        await repo.signIn(email: 'user@demo.com', password: 'user123');
        expect(repo.currentUser, isNotNull);
        expect(repo.currentUser!.email, 'user@demo.com');
        repo.dispose();
      });
    });

    // ── signUp ───────────────────────────────────────────────────────────────
    group('signUp', () {
      test('returns viewer AppUser for new email', () async {
        final repo = _makeRepo();
        final user = await repo.signUp(
          email: 'new@example.com',
          password: 'pass123',
          name: 'New User',
        );
        expect(user.email, 'new@example.com');
        expect(user.name, 'New User');
        expect(user.role, AppUserRole.viewer);
        repo.dispose();
      });

      test('new account role is always viewer — admin elevation impossible',
          () async {
        final repo = _makeRepo();
        final user = await repo.signUp(
          email: 'hacker@example.com',
          password: 'pass123',
          name: 'Hacker',
        );
        // Regardless of what was requested, role must be viewer.
        expect(user.role, AppUserRole.viewer);
        expect(user.role.isAdmin, isFalse);
        repo.dispose();
      });

      test('assigns non-empty UUID id to new accounts', () async {
        final repo = _makeRepo();
        final user = await repo.signUp(
          email: 'new@example.com',
          password: 'pass123',
          name: 'New User',
        );
        expect(user.id, isNotEmpty);
        expect(user.id, isNot(equals('demo-admin-001')));
        expect(user.id, isNot(equals('demo-user-001')));
        repo.dispose();
      });

      test('throws EmailAlreadyInUseFailure for duplicate email', () async {
        final repo = _makeRepo();
        expect(
          () => repo.signUp(
            email: 'admin@demo.com',
            password: 'pass123',
            name: 'Dup',
          ),
          throwsA(isA<EmailAlreadyInUseFailure>()),
        );
        repo.dispose();
      });

      test('throws WeakPasswordFailure for password shorter than 6 chars',
          () async {
        final repo = _makeRepo();
        expect(
          () => repo.signUp(
            email: 'weak@example.com',
            password: '12',
            name: 'Weak',
          ),
          throwsA(isA<WeakPasswordFailure>()),
        );
        repo.dispose();
      });

      test('allows sign-in with newly created account', () async {
        final repo = _makeRepo();
        await repo.signUp(
          email: 'fresh@example.com',
          password: 'fresh123',
          name: 'Fresh',
        );
        // Sign out then sign back in.
        await repo.signOut();
        final user = await repo.signIn(
          email: 'fresh@example.com',
          password: 'fresh123',
        );
        expect(user.email, 'fresh@example.com');
        repo.dispose();
      });
    });

    // ── signOut ──────────────────────────────────────────────────────────────
    group('signOut', () {
      test('clears currentUser after sign-out', () async {
        final repo = _makeRepo();
        await repo.signIn(email: 'user@demo.com', password: 'user123');
        expect(repo.currentUser, isNotNull);
        await repo.signOut();
        expect(repo.currentUser, isNull);
        repo.dispose();
      });

      test('clears persisted session after sign-out', () async {
        final sessionStore = LocalSessionStore();
        final repo = MockAuthRepository(sessionStore);
        await repo.signIn(email: 'user@demo.com', password: 'user123');
        await repo.signOut();
        final persisted = await sessionStore.loadSession();
        expect(persisted, isNull);
        repo.dispose();
      });
    });

    // ── sendPasswordReset ────────────────────────────────────────────────────
    group('sendPasswordReset', () {
      test('resolves without throwing for any email', () async {
        final repo = _makeRepo();
        // Should not throw for known email.
        await expectLater(
          repo.sendPasswordReset(email: 'admin@demo.com'),
          completes,
        );
        // Should not throw for unknown email either (demo mode no-op).
        await expectLater(
          repo.sendPasswordReset(email: 'unknown@example.com'),
          completes,
        );
        repo.dispose();
      });
    });

    // ── authStateChanges stream ───────────────────────────────────────────────
    group('authStateChanges', () {
      test('emits AppUser after signIn', () async {
        final repo = _makeRepo();
        // Collect first emission after signIn.
        final future = repo.authStateChanges.first;
        await repo.signIn(email: 'user@demo.com', password: 'user123');
        final emitted = await future;
        expect(emitted, isNotNull);
        expect(emitted!.email, 'user@demo.com');
        repo.dispose();
      });

      test('emits null after signOut', () async {
        final repo = _makeRepo();
        await repo.signIn(email: 'user@demo.com', password: 'user123');
        // Next emission should be null.
        final future = repo.authStateChanges.first;
        await repo.signOut();
        final emitted = await future;
        expect(emitted, isNull);
        repo.dispose();
      });
    });

    // ── AppUserRole ───────────────────────────────────────────────────────────
    group('AppUserRole', () {
      test('admin.isAdmin returns true', () {
        expect(AppUserRole.admin.isAdmin, isTrue);
      });

      test('viewer.isAdmin returns false', () {
        expect(AppUserRole.viewer.isAdmin, isFalse);
      });

      test('label is human-readable', () {
        expect(AppUserRole.admin.label, 'Admin');
        expect(AppUserRole.viewer.label, 'Viewer');
      });
    });
  });
}
