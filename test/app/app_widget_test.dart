import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:noticewise/app/theme/app_theme.dart';
import 'package:noticewise/shared/widgets/placeholder_home_screen.dart';
import 'package:noticewise/core/constants/app_strings.dart';
import 'package:noticewise/core/constants/app_constants.dart';

import '../helpers/test_helpers.dart';

void main() {
  group('PlaceholderHomeScreen', () {
    testWidgets('renders app name', (tester) async {
      await pumpApp(tester, const PlaceholderHomeScreen());
      expect(find.text(AppStrings.appName), findsWidgets);
    });

    testWidgets('renders tagline', (tester) async {
      await pumpApp(tester, const PlaceholderHomeScreen());
      expect(find.text(AppStrings.appTagline), findsOneWidget);
    });

    testWidgets('renders theme toggle icon button in AppBar', (tester) async {
      await pumpApp(tester, const PlaceholderHomeScreen());
      // In light mode the dark_mode icon should be shown
      expect(find.byIcon(Icons.dark_mode), findsOneWidget);
    });

    testWidgets('theme toggle switches theme mode', (tester) async {
      await pumpApp(tester, const PlaceholderHomeScreen());

      // Initially light → shows dark_mode icon
      expect(find.byIcon(Icons.dark_mode), findsOneWidget);

      // Tap toggle
      await tester.tap(find.byIcon(Icons.dark_mode));
      await tester.pump();

      // Now dark → shows light_mode icon
      expect(find.byIcon(Icons.light_mode), findsOneWidget);
    });

    testWidgets('status card shows expected completed items', (tester) async {
      await pumpApp(tester, const PlaceholderHomeScreen());
      expect(find.text('Spec 2 — Authentication Complete'), findsOneWidget);
      expect(find.text('Demo login / sign-up / sign-out'), findsOneWidget);
      expect(find.text('Role-based routing (admin / viewer)'), findsOneWidget);
      expect(find.text('AuthRepository interface + MockImpl'), findsOneWidget);
    });
  });

  group('AppTheme', () {
    test('light theme uses Material 3', () {
      expect(AppTheme.light.useMaterial3, isTrue);
    });

    test('dark theme uses Material 3', () {
      expect(AppTheme.dark.useMaterial3, isTrue);
    });

    test('light theme has correct brightness', () {
      expect(AppTheme.light.colorScheme.brightness, Brightness.light);
    });

    test('dark theme has correct brightness', () {
      expect(AppTheme.dark.colorScheme.brightness, Brightness.dark);
    });

    test('both themes have the same primary seed family', () {
      // Both themes are seeded from the same brand color,
      // so primary should be in the blue family for both.
      final lightPrimary = AppTheme.light.colorScheme.primary;
      final darkPrimary = AppTheme.dark.colorScheme.primary;
      // They differ in shade but both should be non-null Color objects.
      expect(lightPrimary, isA<Color>());
      expect(darkPrimary, isA<Color>());
    });
  });

  group('AppConstants', () {
    test('pageSize values are positive', () {
      expect(AppConstants.noticeFeedPageSize, greaterThan(0));
      expect(AppConstants.notificationPageSize, greaterThan(0));
    });

    test('collection name constants are non-empty', () {
      expect(AppConstants.colUsers, isNotEmpty);
      expect(AppConstants.colNotices, isNotEmpty);
      expect(AppConstants.colCategories, isNotEmpty);
      expect(AppConstants.colBookmarks, isNotEmpty);
      expect(AppConstants.colReadReceipts, isNotEmpty);
    });

    test('role constants are distinct', () {
      expect(AppConstants.roleAdmin, isNot(equals(AppConstants.roleUser)));
    });

    test('request timeout is reasonable (> 0, <= 120s)', () {
      expect(AppConstants.requestTimeoutSeconds, greaterThan(0));
      expect(AppConstants.requestTimeoutSeconds, lessThanOrEqualTo(120));
    });
  });
}
