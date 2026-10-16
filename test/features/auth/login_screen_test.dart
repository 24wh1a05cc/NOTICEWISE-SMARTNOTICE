import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:noticewise/features/auth/domain/app_user.dart';
import 'package:noticewise/features/auth/domain/auth_failure.dart';
import 'package:noticewise/features/auth/domain/auth_repository.dart';
import 'package:noticewise/features/auth/presentation/providers/auth_providers.dart';
import 'package:noticewise/features/auth/presentation/screens/login_screen.dart';

// ---------------------------------------------------------------------------
// Mocktail mock
// ---------------------------------------------------------------------------

class MockAuthRepository extends Mock implements AuthRepository {}

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// Pumps [LoginScreen] with [MockAuthRepository] injected.
Future<void> _pumpLoginScreen(
  WidgetTester tester,
  AuthRepository mockRepo,
) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        authRepositoryProvider.overrideWithValue(mockRepo),
      ],
      child: const MaterialApp(
        home: LoginScreen(),
      ),
    ),
  );
  // Allow async providers to settle.
  await tester.pumpAndSettle();
}

MockAuthRepository _defaultMock() {
  final mock = MockAuthRepository();
  when(() => mock.currentUser).thenReturn(null);
  when(() => mock.authStateChanges).thenAnswer(
    (_) => const Stream.empty(),
  );
  return mock;
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  group('LoginScreen', () {
    // ── Rendering ───────────────────────────────────────────────────────────
    group('renders without crash', () {
      testWidgets('renders login form', (tester) async {
        final mock = _defaultMock();
        await _pumpLoginScreen(tester, mock);
        expect(find.byType(LoginScreen), findsOneWidget);
      });
    });

    group('demo mode banner', () {
      testWidgets('demo mode banner is visible', (tester) async {
        final mock = _defaultMock();
        await _pumpLoginScreen(tester, mock);
        // The banner contains the key text.
        expect(find.textContaining('Demo Mode'), findsOneWidget);
        expect(find.textContaining('local authentication'), findsOneWidget);
      });
    });

    group('demo accounts card', () {
      testWidgets('demo accounts card is visible', (tester) async {
        final mock = _defaultMock();
        await _pumpLoginScreen(tester, mock);
        expect(find.text('Demo Accounts'), findsOneWidget);
      });

      testWidgets('shows admin@demo.com credential', (tester) async {
        final mock = _defaultMock();
        await _pumpLoginScreen(tester, mock);
        expect(find.text('admin@demo.com'), findsOneWidget);
      });

      testWidgets('shows user@demo.com credential', (tester) async {
        final mock = _defaultMock();
        await _pumpLoginScreen(tester, mock);
        expect(find.text('user@demo.com'), findsOneWidget);
      });
    });

    group('form fields', () {
      testWidgets('email field is present', (tester) async {
        final mock = _defaultMock();
        await _pumpLoginScreen(tester, mock);
        expect(find.widgetWithText(TextFormField, 'Email address'), findsWidgets);
      });

      testWidgets('password field is present', (tester) async {
        final mock = _defaultMock();
        await _pumpLoginScreen(tester, mock);
        expect(find.widgetWithText(TextFormField, 'Password'), findsWidgets);
      });

      testWidgets('sign-in button is present', (tester) async {
        final mock = _defaultMock();
        await _pumpLoginScreen(tester, mock);
        expect(find.text('Sign In'), findsWidgets);
      });

      testWidgets('forgot password link is present', (tester) async {
        final mock = _defaultMock();
        await _pumpLoginScreen(tester, mock);
        expect(find.text('Forgot Password?'), findsOneWidget);
      });

      testWidgets('sign-up link is present', (tester) async {
        final mock = _defaultMock();
        await _pumpLoginScreen(tester, mock);
        expect(find.text('Sign Up'), findsWidgets);
      });
    });

    // ── Validation ───────────────────────────────────────────────────────────
    group('validation', () {
      testWidgets('shows error when submitting empty form', (tester) async {
        final mock = _defaultMock();
        await _pumpLoginScreen(tester, mock);

        // Tap the FilledButton labelled "Sign In"
        final signInButton = find.ancestor(
          of: find.text('Sign In'),
          matching: find.byType(FilledButton),
        );
        await tester.tap(signInButton.first);
        await tester.pumpAndSettle();

        expect(find.text('Email is required.'), findsOneWidget);
      });

      testWidgets('shows error for invalid email format', (tester) async {
        final mock = _defaultMock();
        await _pumpLoginScreen(tester, mock);

        // Enter an invalid email.
        await tester.enterText(
          find.widgetWithText(TextFormField, 'Email address').first,
          'not-an-email',
        );
        // Enter a valid password to bypass that check.
        await tester.enterText(
          find.widgetWithText(TextFormField, 'Password').first,
          'pass123',
        );

        final signInButton = find.ancestor(
          of: find.text('Sign In'),
          matching: find.byType(FilledButton),
        );
        await tester.tap(signInButton.first);
        await tester.pumpAndSettle();

        expect(find.text('Enter a valid email address.'), findsOneWidget);
      });

      testWidgets('shows error when password is too short', (tester) async {
        final mock = _defaultMock();
        await _pumpLoginScreen(tester, mock);

        await tester.enterText(
          find.widgetWithText(TextFormField, 'Email address').first,
          'valid@example.com',
        );
        await tester.enterText(
          find.widgetWithText(TextFormField, 'Password').first,
          'abc',
        );

        final signInButton = find.ancestor(
          of: find.text('Sign In'),
          matching: find.byType(FilledButton),
        );
        await tester.tap(signInButton.first);
        await tester.pumpAndSettle();

        expect(
          find.text('Password must be at least 6 characters.'),
          findsOneWidget,
        );
      });
    });

    // ── Success flow ─────────────────────────────────────────────────────────
    group('signIn success', () {
      testWidgets('calls signIn on repository with entered credentials',
          (tester) async {
        final mock = _defaultMock();
        final user = AppUser(
          id: 'u1',
          email: 'user@demo.com',
          name: 'Demo User',
          role: AppUserRole.viewer,
          createdAt: DateTime(2026),
        );
        when(
          () => mock.signIn(
            email: 'user@demo.com',
            password: 'user123',
          ),
        ).thenAnswer((_) async => user);

        await _pumpLoginScreen(tester, mock);

        await tester.enterText(
          find.widgetWithText(TextFormField, 'Email address').first,
          'user@demo.com',
        );
        await tester.enterText(
          find.widgetWithText(TextFormField, 'Password').first,
          'user123',
        );

        final signInButton = find.ancestor(
          of: find.text('Sign In'),
          matching: find.byType(FilledButton),
        );
        await tester.tap(signInButton.first);
        await tester.pump(); // Start async

        verify(
          () => mock.signIn(
            email: 'user@demo.com',
            password: 'user123',
          ),
        ).called(1);
      });
    });

    // ── Error display ────────────────────────────────────────────────────────
    group('signIn failure', () {
      testWidgets('shows error snackbar on invalid credentials', (tester) async {
        final mock = _defaultMock();
        when(
          () => mock.signIn(
            email: any(named: 'email'),
            password: any(named: 'password'),
          ),
        ).thenThrow(const InvalidCredentialsFailure());

        await _pumpLoginScreen(tester, mock);

        await tester.enterText(
          find.widgetWithText(TextFormField, 'Email address').first,
          'bad@example.com',
        );
        await tester.enterText(
          find.widgetWithText(TextFormField, 'Password').first,
          'wrongpass',
        );

        final signInButton = find.ancestor(
          of: find.text('Sign In'),
          matching: find.byType(FilledButton),
        );
        await tester.tap(signInButton.first);
        await tester.pumpAndSettle();

        expect(
          find.text('Invalid email or password.'),
          findsOneWidget,
        );
      });
    });
  });
}
