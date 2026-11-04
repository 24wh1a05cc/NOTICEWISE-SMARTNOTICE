import 'package:flutter_test/flutter_test.dart';
import 'package:noticewise/core/errors/app_exception.dart';
import 'package:noticewise/core/errors/error_handler.dart';

void main() {
  group('AppException', () {
    group('NetworkException', () {
      test('has default message', () {
        const e = NetworkException();
        expect(e.message, isNotEmpty);
        expect(e.code, isNull);
        expect(e.cause, isNull);
      });

      test('accepts custom message, code, and cause', () {
        const e = NetworkException(
          message: 'Timeout',
          code: 'timeout',
          cause: 'socket closed',
        );
        expect(e.message, 'Timeout');
        expect(e.code, 'timeout');
        expect(e.cause, 'socket closed');
      });

      test('is identified as NetworkException via pattern match', () {
        const AppException e = NetworkException();
        expect(e, isA<NetworkException>());
      });
    });

    group('AuthException', () {
      test('carries required message', () {
        const e = AuthException(message: 'Invalid credentials');
        expect(e.message, 'Invalid credentials');
      });

      test('is identified as AuthException', () {
        const AppException e = AuthException(message: 'test');
        expect(e, isA<AuthException>());
        expect(e, isNot(isA<NetworkException>()));
      });
    });

    group('DatabaseException', () {
      test('carries message and code', () {
        const e = DatabaseException(
          message: 'Document not found',
          code: 'not-found',
        );
        expect(e.message, 'Document not found');
        expect(e.code, 'not-found');
      });
    });

    group('StorageException', () {
      test('carries message', () {
        const e = StorageException(message: 'Upload failed');
        expect(e.message, 'Upload failed');
        expect(e, isA<StorageException>());
      });
    });

    group('PermissionException', () {
      test('has default message', () {
        const e = PermissionException();
        expect(e.message, isNotEmpty);
        expect(e, isA<PermissionException>());
      });
    });

    group('NotFoundException', () {
      test('has default message', () {
        const e = NotFoundException();
        expect(e.message, isNotEmpty);
        expect(e, isA<NotFoundException>());
      });
    });

    group('SmartFeatureException', () {
      test('has default message', () {
        const e = SmartFeatureException();
        expect(e.message, isNotEmpty);
        expect(e, isA<SmartFeatureException>());
      });
    });

    group('UnknownException', () {
      test('has default message', () {
        const e = UnknownException();
        expect(e.message, isNotEmpty);
        expect(e, isA<UnknownException>());
      });

      test('accepts cause', () {
        final cause = Exception('original');
        final e = UnknownException(cause: cause);
        expect(e.cause, cause);
      });
    });

    group('AppException.toString()', () {
      test('includes runtimeType and message', () {
        const e = AuthException(message: 'Bad token', code: 'auth/bad-token');
        final str = e.toString();
        expect(str, contains('AuthException'));
        expect(str, contains('Bad token'));
        expect(str, contains('auth/bad-token'));
      });

      test('includes cause when present', () {
        final inner = Exception('inner');
        final e = UnknownException(cause: inner);
        expect(e.toString(), contains('Caused by'));
      });

      test('omits cause section when cause is null', () {
        const e = NetworkException();
        expect(e.toString(), isNot(contains('Caused by')));
      });
    });

    group('Sealed class exhaustiveness', () {
      test('switch statement covers all AppException subtypes', () {
        // This test verifies that every subclass is accounted for.
        // If a new subclass is added without updating this list, the
        // test will fail to compile (sealed class exhaustiveness check).
        const exceptions = <AppException>[
          NetworkException(),
          AuthException(message: 'test'),
          DatabaseException(message: 'test'),
          StorageException(message: 'test'),
          PermissionException(),
          NotFoundException(),
          SmartFeatureException(),
          UnknownException(),
        ];

        for (final e in exceptions) {
          final label = switch (e) {
            NetworkException() => 'network',
            AuthException() => 'auth',
            DatabaseException() => 'database',
            StorageException() => 'storage',
            PermissionException() => 'permission',
            NotFoundException() => 'not_found',
            SmartFeatureException() => 'smart_feature',
            UnknownException() => 'unknown',
          };
          expect(label, isNotEmpty);
        }
      });
    });
  });

  group('AppErrorHandler', () {
    test(
      'toUserMessage returns exception message for AppException subtypes',
      () {
        const e = AuthException(message: 'Session expired');
        expect(AppErrorHandler.toUserMessage(e), 'Session expired');
      },
    );

    test('toUserMessage returns generic fallback for non-AppException', () {
      final message = AppErrorHandler.toUserMessage(Exception('raw'));
      expect(message, isNotEmpty);
    });

    test('isNetworkError returns true only for NetworkException', () {
      expect(AppErrorHandler.isNetworkError(const NetworkException()), isTrue);
      expect(
        AppErrorHandler.isNetworkError(const AuthException(message: 'test')),
        isFalse,
      );
    });

    test(
      'isAuthError returns true for AuthException and PermissionException',
      () {
        expect(
          AppErrorHandler.isAuthError(const AuthException(message: 'test')),
          isTrue,
        );
        expect(
          AppErrorHandler.isAuthError(const PermissionException()),
          isTrue,
        );
        expect(AppErrorHandler.isAuthError(const NetworkException()), isFalse);
      },
    );
  });
}
