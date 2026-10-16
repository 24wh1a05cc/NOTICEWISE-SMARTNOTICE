// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auth_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Provides the active [AuthRepository] implementation.
///
/// ─── DEMO MODE ──────────────────────────────────────────────────────────────
/// Currently returns [MockAuthRepository]. No Firebase required.
///
/// To switch to Firebase Authentication (requires a configured project):
///   return FirebaseAuthRepository(FirebaseAuth.instance);
/// ────────────────────────────────────────────────────────────────────────────

@ProviderFor(authRepository)
final authRepositoryProvider = AuthRepositoryProvider._();

/// Provides the active [AuthRepository] implementation.
///
/// ─── DEMO MODE ──────────────────────────────────────────────────────────────
/// Currently returns [MockAuthRepository]. No Firebase required.
///
/// To switch to Firebase Authentication (requires a configured project):
///   return FirebaseAuthRepository(FirebaseAuth.instance);
/// ────────────────────────────────────────────────────────────────────────────

final class AuthRepositoryProvider
    extends $FunctionalProvider<AuthRepository, AuthRepository, AuthRepository>
    with $Provider<AuthRepository> {
  /// Provides the active [AuthRepository] implementation.
  ///
  /// ─── DEMO MODE ──────────────────────────────────────────────────────────────
  /// Currently returns [MockAuthRepository]. No Firebase required.
  ///
  /// To switch to Firebase Authentication (requires a configured project):
  ///   return FirebaseAuthRepository(FirebaseAuth.instance);
  /// ────────────────────────────────────────────────────────────────────────────
  AuthRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'authRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$authRepositoryHash();

  @$internal
  @override
  $ProviderElement<AuthRepository> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  AuthRepository create(Ref ref) {
    return authRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AuthRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AuthRepository>(value),
    );
  }
}

String _$authRepositoryHash() => r'ed710c9bbca7b733227836591ffb711185cbb943';

/// Stream of auth state changes — emits [AppUser] when signed in, null when
/// signed out. Kept alive so all screens share the same stream subscription.

@ProviderFor(authStateChanges)
final authStateChangesProvider = AuthStateChangesProvider._();

/// Stream of auth state changes — emits [AppUser] when signed in, null when
/// signed out. Kept alive so all screens share the same stream subscription.

final class AuthStateChangesProvider
    extends
        $FunctionalProvider<AsyncValue<AppUser?>, AppUser?, Stream<AppUser?>>
    with $FutureModifier<AppUser?>, $StreamProvider<AppUser?> {
  /// Stream of auth state changes — emits [AppUser] when signed in, null when
  /// signed out. Kept alive so all screens share the same stream subscription.
  AuthStateChangesProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'authStateChangesProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$authStateChangesHash();

  @$internal
  @override
  $StreamProviderElement<AppUser?> $createElement($ProviderPointer pointer) =>
      $StreamProviderElement(pointer);

  @override
  Stream<AppUser?> create(Ref ref) {
    return authStateChanges(ref);
  }
}

String _$authStateChangesHash() => r'4b9b8b4440f556333925dba88bb26bd5e2b59c67';
