import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:noticewise/app/router/app_router.dart';
import 'package:noticewise/app/theme/app_theme.dart';
import 'package:noticewise/app/theme/theme_notifier.dart';
import 'package:noticewise/core/constants/app_strings.dart';

/// Root application widget.
///
/// Reads the [routerProvider] and [themeProvider] from Riverpod and
/// wires them into [MaterialApp.router]. Everything below this widget can
/// access the router and theme via [GoRouter] and [Theme.of(context)].
class NoticeWiseApp extends ConsumerWidget {
  const NoticeWiseApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    final themeMode = ref.watch(themeProvider);

    return MaterialApp.router(
      title: AppStrings.appName,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: themeMode,
      routerConfig: router,
      debugShowCheckedModeBanner: false,
    );
  }
}
