import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

/// Creates a [ProviderContainer] scoped to a single test.
///
/// Dispose the container after each test using [addTearDown]:
///
/// ```dart
/// final container = makeProviderContainer();
/// addTearDown(container.dispose);
/// ```
ProviderContainer makeProviderContainer() {
  return ProviderContainer();
}

/// Pumps [child] wrapped in a [ProviderScope] and a minimal [MaterialApp].
///
/// Use this for widget tests that need Riverpod providers and theme access
/// without the full router setup.
///
/// ```dart
/// await pumpApp(tester, const MyWidget());
/// ```
Future<void> pumpApp(
  WidgetTester tester,
  Widget child, {
  ThemeMode themeMode = ThemeMode.light,
}) async {
  await tester.pumpWidget(
    ProviderScope(
      child: MaterialApp(
        theme: ThemeData(useMaterial3: true),
        darkTheme: ThemeData.dark(useMaterial3: true),
        themeMode: themeMode,
        home: child,
      ),
    ),
  );
}
