import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'theme_notifier.g.dart';

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
@Riverpod(keepAlive: true)
class ThemeNotifier extends _$ThemeNotifier {
  @override
  ThemeMode build() => ThemeMode.system;

  /// Updates the theme mode.
  void setTheme(ThemeMode mode) => state = mode;

  /// Toggles between light and dark. System default counts as light.
  void toggle() {
    state = state == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
  }
}
