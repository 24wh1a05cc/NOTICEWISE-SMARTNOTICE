/// Typed authentication failure hierarchy.
///
/// All [AuthRepository] implementations must throw subtypes of [AuthFailure]
/// rather than platform-specific exceptions (e.g. FirebaseAuthException).
/// The presentation layer catches [AuthFailure] and maps to UI messages.
sealed class AuthFailure implements Exception {
  const AuthFailure({required this.message});

  /// Human-readable message safe to display to the user.
  final String message;

  @override
  String toString() => 'AuthFailure($runtimeType): $message';
}

/// Email or password did not match any account.
final class InvalidCredentialsFailure extends AuthFailure {
  const InvalidCredentialsFailure()
      : super(message: 'Invalid email or password.');
}

/// Sign-up attempted with an email already registered.
final class EmailAlreadyInUseFailure extends AuthFailure {
  const EmailAlreadyInUseFailure()
      : super(message: 'An account with this email already exists.');
}

/// Password does not meet minimum length requirements.
final class WeakPasswordFailure extends AuthFailure {
  const WeakPasswordFailure()
      : super(message: 'Password must be at least 6 characters.');
}

/// A network error prevented the operation from completing.
final class NetworkAuthFailure extends AuthFailure {
  const NetworkAuthFailure()
      : super(message: 'Network error. Please check your connection.');
}

/// An unexpected error occurred during an auth operation.
final class UnknownAuthFailure extends AuthFailure {
  const UnknownAuthFailure({
    super.message = 'An unexpected error occurred. Please try again.',
  });
}
