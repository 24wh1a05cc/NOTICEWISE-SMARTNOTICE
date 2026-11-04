// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auth_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Manages authentication state for the entire application.
///
/// State: [AsyncValue<AppUser?>]
///   - [AsyncLoading]  — an auth operation is in progress
///   - [AsyncData(user)] — signed in (user != null) or signed out (user == null)
///   - [AsyncError]    — last operation failed with [AuthFailure]
///
/// Kept alive so auth state persists across navigation.

@ProviderFor(AuthController)
final authControllerProvider = AuthControllerProvider._();

/// Manages authentication state for the entire application.
///
/// State: [AsyncValue<AppUser?>]
///   - [AsyncLoading]  — an auth operation is in progress
///   - [AsyncData(user)] — signed in (user != null) or signed out (user == null)
///   - [AsyncError]    — last operation failed with [AuthFailure]
///
/// Kept alive so auth state persists across navigation.
final class AuthControllerProvider
    extends $AsyncNotifierProvider<AuthController, AppUser?> {
  /// Manages authentication state for the entire application.
  ///
  /// State: [AsyncValue<AppUser?>]
  ///   - [AsyncLoading]  — an auth operation is in progress
  ///   - [AsyncData(user)] — signed in (user != null) or signed out (user == null)
  ///   - [AsyncError]    — last operation failed with [AuthFailure]
  ///
  /// Kept alive so auth state persists across navigation.
  AuthControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'authControllerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$authControllerHash();

  @$internal
  @override
  AuthController create() => AuthController();
}

String _$authControllerHash() => r'7b46c3524546db6d791ef12b1a6be69caa392727';

/// Manages authentication state for the entire application.
///
/// State: [AsyncValue<AppUser?>]
///   - [AsyncLoading]  — an auth operation is in progress
///   - [AsyncData(user)] — signed in (user != null) or signed out (user == null)
///   - [AsyncError]    — last operation failed with [AuthFailure]
///
/// Kept alive so auth state persists across navigation.

abstract class _$AuthController extends $AsyncNotifier<AppUser?> {
  FutureOr<AppUser?> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<AsyncValue<AppUser?>, AppUser?>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<AppUser?>, AppUser?>,
              AsyncValue<AppUser?>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
