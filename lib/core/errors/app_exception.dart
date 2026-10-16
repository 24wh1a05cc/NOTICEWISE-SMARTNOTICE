// TODO(i18n): replace user-facing messages with AppStrings constants

/// Base sealed class for all application-level exceptions.
///
/// All repository methods that can fail must catch platform/Firebase
/// exceptions and rethrow as [AppException] subclasses. The presentation
/// layer only ever sees [AppException] variants — never raw Firebase or
/// Dart I/O exceptions.
sealed class AppException implements Exception {
  const AppException({required this.message, this.code, this.cause});

  /// Human-readable message safe to display to the user.
  final String message;

  /// Optional machine-readable error code (e.g., Firebase error code).
  final String? code;

  /// The underlying exception that caused this [AppException], if any.
  final Object? cause;

  @override
  String toString() =>
      'AppException($runtimeType): $message'
      '${code != null ? ' [code: $code]' : ''}'
      '${cause != null ? '\nCaused by: $cause' : ''}';
}

/// Thrown when a network request fails (no connectivity, timeout, etc.).
final class NetworkException extends AppException {
  const NetworkException({
    super.message = 'A network error occurred. Please check your connection.',
    super.code,
    super.cause,
  });
}

/// Thrown when an authentication operation fails.
final class AuthException extends AppException {
  const AuthException({required super.message, super.code, super.cause});
}

/// Thrown when a Firestore or local database operation fails.
final class DatabaseException extends AppException {
  const DatabaseException({required super.message, super.code, super.cause});
}

/// Thrown when a Firebase Storage operation fails.
final class StorageException extends AppException {
  const StorageException({required super.message, super.code, super.cause});
}

/// Thrown when a permission check fails (e.g., Firestore security rule denied).
final class PermissionException extends AppException {
  const PermissionException({
    super.message = 'You do not have permission to perform this action.',
    super.code,
    super.cause,
  });
}

/// Thrown when a requested resource is not found.
final class NotFoundException extends AppException {
  const NotFoundException({
    super.message = 'The requested resource was not found.',
    super.code,
    super.cause,
  });
}

/// Thrown when an AI/smart-feature service call fails.
final class SmartFeatureException extends AppException {
  const SmartFeatureException({
    super.message = 'The smart feature is temporarily unavailable.',
    super.code,
    super.cause,
  });
}

/// Fallback for unexpected errors not covered by a specific subclass.
final class UnknownException extends AppException {
  const UnknownException({
    super.message = 'An unexpected error occurred. Please try again.',
    super.code,
    super.cause,
  });
}
