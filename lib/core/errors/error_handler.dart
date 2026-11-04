import 'package:noticewise/core/errors/app_exception.dart';

/// Maps [AppException] subtypes to user-friendly display messages.
///
/// Use this in the presentation layer to convert errors from
/// [AsyncValue.error] into strings for snackbars, error banners, etc.
///
/// Example:
/// ```dart
/// ref.watch(noticeListProvider).when(
///   error: (e, _) => Text(AppErrorHandler.toUserMessage(e)),
///   ...
/// );
/// ```
abstract final class AppErrorHandler {
  /// Returns a localised, user-friendly error message for [exception].
  ///
  /// Falls back to the exception's own [AppException.message] for all
  /// typed variants. Unrecognised objects get a generic fallback.
  static String toUserMessage(Object exception) {
    if (exception is AppException) {
      return exception.message;
    }
    return 'An unexpected error occurred. Please try again.';
  }

  /// Returns `true` if the error represents a connectivity/network issue.
  static bool isNetworkError(Object exception) => exception is NetworkException;

  /// Returns `true` if the error means the user is not authorised.
  static bool isAuthError(Object exception) =>
      exception is AuthException || exception is PermissionException;
}
