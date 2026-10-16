// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'theme_notifier.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Manages the application's [ThemeMode].
///
/// Kept alive so the theme setting persists across navigation.
/// Spec 9 will persist the selected theme to SharedPreferences.
///
/// Usage in widgets:
/// ```dart
/// final themeMode = ref.watch(themeNotifierProvider);
/// ref.read(themeNotifierProvider.notifier).setTheme(ThemeMode.dark);
/// ```

@ProviderFor(ThemeNotifier)
final themeProvider = ThemeNotifierProvider._();

/// Manages the application's [ThemeMode].
///
/// Kept alive so the theme setting persists across navigation.
/// Spec 9 will persist the selected theme to SharedPreferences.
///
/// Usage in widgets:
/// ```dart
/// final themeMode = ref.watch(themeNotifierProvider);
/// ref.read(themeNotifierProvider.notifier).setTheme(ThemeMode.dark);
/// ```
final class ThemeNotifierProvider
    extends $NotifierProvider<ThemeNotifier, ThemeMode> {
  /// Manages the application's [ThemeMode].
  ///
  /// Kept alive so the theme setting persists across navigation.
  /// Spec 9 will persist the selected theme to SharedPreferences.
  ///
  /// Usage in widgets:
  /// ```dart
  /// final themeMode = ref.watch(themeNotifierProvider);
  /// ref.read(themeNotifierProvider.notifier).setTheme(ThemeMode.dark);
  /// ```
  ThemeNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'themeProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$themeNotifierHash();

  @$internal
  @override
  ThemeNotifier create() => ThemeNotifier();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ThemeMode value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ThemeMode>(value),
    );
  }
}

String _$themeNotifierHash() => r'3a9db7c8242fd99d332be297e24f495d54a4a9ac';

/// Manages the application's [ThemeMode].
///
/// Kept alive so the theme setting persists across navigation.
/// Spec 9 will persist the selected theme to SharedPreferences.
///
/// Usage in widgets:
/// ```dart
/// final themeMode = ref.watch(themeNotifierProvider);
/// ref.read(themeNotifierProvider.notifier).setTheme(ThemeMode.dark);
/// ```

abstract class _$ThemeNotifier extends $Notifier<ThemeMode> {
  ThemeMode build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<ThemeMode, ThemeMode>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<ThemeMode, ThemeMode>,
              ThemeMode,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
