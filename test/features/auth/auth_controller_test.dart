import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:noticewise/features/auth/domain/app_user.dart';
import 'package:noticewise/features/auth/domain/auth_failure.dart';
import 'package:noticewise/features/auth/domain/auth_repository.dart';
import 'package:noticewise/features/auth/presentation/providers/auth_controller.dart';
import 'package:noticewise/features/auth/presentation/providers/auth_providers.dart';

// ---------------------------------------------------------------------------
// Mocktail mock
// ---------------------------------------------------------------------------

class MockAuthRepository extends Mock implements AuthRepository {}

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// Builds a [ProviderContainer] with [MockAuthRepository] injected.
ProviderContainer _makeContainer(AuthRepository mock) {
  return ProviderContainer(
    overrides: [
      authRepositoryProvider.overrideWithValue(mock),
    ],
  );
}

/// A standard signed-in [AppUser] for test use.
AppUser _testUser({AppUserRole role = AppUserRole.viewer}) => AppUser(
      id: 'test-id-001',
      email: 'test@example.com',
      name: 'Test User',
      role: role,
      createdAt: DateTime(2026, 1, 1),
    );

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  // ── Setup ─────────────────────────────────────────────────────────────────

  late MockAuthRepository mockRepo;
  late ProviderContainer container;

  setUp(() {
    mockRepo = MockAuthRepository();

    // Default stub: no persisted session.
    when(() => mockRepo.currentUser).thenReturn(null);
    when(() => mockRepo.authStateChanges).thenAnswer(
      (_) => const Stream.empty(),
    );
  });

  tearDown(() {
    container.dispose();
  });

  // ── Initial state ─────────────────────────────────────────────────────────
  group('AuthController — initial state', () {
    test('initial state is AsyncData(null) when no session', () async {
      container = _makeContainer(mockRepo);
      // Allow the async build() to complete.
      await container.read(authControllerProvider.future);
      final state = container.read(authControllerProvider);
      expect(state.asData?.value, isNull);
    });

    test('initial state is AsyncData(user) when session is persisted',
        () async {
      final user = _testUser();
      when(() => mockRepo.currentUser).thenReturn(user);
      container = _makeContainer(mockRepo);
      await container.read(authControllerProvider.future);
      final state = container.read(authControllerProvider);
      expect(state.asData?.value, equals(user));
    });
  });

  // ── signIn ────────────────────────────────────────────────────────────────
  group('AuthController.signIn', () {
    test('sets AsyncData(user) on success', () async {
      final user = _testUser();
      when(
        () => mockRepo.signIn(email: 'test@example.com', password: 'pass123'),
      ).thenAnswer((_) async => user);

      container = _makeContainer(mockRepo);
      await container.read(authControllerProvider.future);

      await container
          .read(authControllerProvider.notifier)
          .signIn(email: 'test@example.com', password: 'pass123');

      final state = container.read(authControllerProvider);
      expect(state.asData?.value, equals(user));
      expect(state.hasError, isFalse);
    });

    test('sets AsyncError on InvalidCredentialsFailure', () async {
      when(
        () => mockRepo.signIn(email: any(named: 'email'), password: any(named: 'password')),
      ).thenThrow(const InvalidCredentialsFailure());

      container = _makeContainer(mockRepo);
      await container.read(authControllerProvider.future);

      await container
          .read(authControllerProvider.notifier)
          .signIn(email: 'bad@example.com', password: 'wrong');

      final state = container.read(authControllerProvider);
      expect(state.hasError, isTrue);
      expect(state.error, isA<InvalidCredentialsFailure>());
    });

    test('state is not loading after signIn completes', () async {
      final user = _testUser();
      when(
        () => mockRepo.signIn(email: any(named: 'email'), password: any(named: 'password')),
      ).thenAnswer((_) async => user);

      container = _makeContainer(mockRepo);
      await container.read(authControllerProvider.future);
      await container
          .read(authControllerProvider.notifier)
          .signIn(email: 'test@example.com', password: 'pass123');

      expect(container.read(authControllerProvider).isLoading, isFalse);
    });
  });

  // ── signUp ────────────────────────────────────────────────────────────────
  group('AuthController.signUp', () {
    test('sets AsyncData(user) on success', () async {
      final user = _testUser();
      when(
        () => mockRepo.signUp(
          email: any(named: 'email'),
          password: any(named: 'password'),
          name: any(named: 'name'),
        ),
      ).thenAnswer((_) async => user);

      container = _makeContainer(mockRepo);
      await container.read(authControllerProvider.future);
      await container.read(authControllerProvider.notifier).signUp(
            email: 'test@example.com',
            password: 'pass123',
            name: 'Test User',
          );

      final state = container.read(authControllerProvider);
      expect(state.asData?.value, equals(user));
    });

    test('sets AsyncError on EmailAlreadyInUseFailure', () async {
      when(
        () => mockRepo.signUp(
          email: any(named: 'email'),
          password: any(named: 'password'),
          name: any(named: 'name'),
        ),
      ).thenThrow(const EmailAlreadyInUseFailure());

      container = _makeContainer(mockRepo);
      await container.read(authControllerProvider.future);
      await container.read(authControllerProvider.notifier).signUp(
            email: 'existing@example.com',
            password: 'pass123',
            name: 'Dup',
          );

      expect(container.read(authControllerProvider).hasError, isTrue);
      expect(
        container.read(authControllerProvider).error,
        isA<EmailAlreadyInUseFailure>(),
      );
    });
  });

  // ── signOut ───────────────────────────────────────────────────────────────
  group('AuthController.signOut', () {
    test('sets AsyncData(null) after sign-out', () async {
      // Start signed in.
      final user = _testUser();
      when(() => mockRepo.currentUser).thenReturn(user);
      when(() => mockRepo.signOut()).thenAnswer((_) async {});

      container = _makeContainer(mockRepo);
      await container.read(authControllerProvider.future);
      await container.read(authControllerProvider.notifier).signOut();

      final state = container.read(authControllerProvider);
      expect(state.asData?.value, isNull);
      expect(state.hasError, isFalse);
    });

    test('calls repository.signOut() exactly once', () async {
      when(() => mockRepo.currentUser).thenReturn(null);
      when(() => mockRepo.signOut()).thenAnswer((_) async {});

      container = _makeContainer(mockRepo);
      await container.read(authControllerProvider.future);
      await container.read(authControllerProvider.notifier).signOut();

      verify(() => mockRepo.signOut()).called(1);
    });
  });

  // ── sendPasswordReset ─────────────────────────────────────────────────────
  group('AuthController.sendPasswordReset', () {
    test('returns true on success', () async {
      when(
        () => mockRepo.sendPasswordReset(email: any(named: 'email')),
      ).thenAnswer((_) async {});

      container = _makeContainer(mockRepo);
      await container.read(authControllerProvider.future);
      final result = await container
          .read(authControllerProvider.notifier)
          .sendPasswordReset(email: 'test@example.com');

      expect(result, isTrue);
    });

    test('returns false when repository throws AuthFailure', () async {
      when(
        () => mockRepo.sendPasswordReset(email: any(named: 'email')),
      ).thenThrow(const UnknownAuthFailure());

      container = _makeContainer(mockRepo);
      await container.read(authControllerProvider.future);
      final result = await container
          .read(authControllerProvider.notifier)
          .sendPasswordReset(email: 'test@example.com');

      expect(result, isFalse);
    });
  });

  // ── currentUser getter ────────────────────────────────────────────────────
  group('AuthController.currentUser getter', () {
    test('returns null when state is AsyncData(null)', () async {
      container = _makeContainer(mockRepo);
      await container.read(authControllerProvider.future);
      expect(
        container.read(authControllerProvider.notifier).currentUser,
        isNull,
      );
    });

    test('returns user when state is AsyncData(user)', () async {
      final user = _testUser();
      when(() => mockRepo.currentUser).thenReturn(user);
      container = _makeContainer(mockRepo);
      await container.read(authControllerProvider.future);
      expect(
        container.read(authControllerProvider.notifier).currentUser,
        equals(user),
      );
    });
  });
}
