import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:noticewise/app/router/app_routes.dart';
import 'package:noticewise/core/constants/app_strings.dart';
import 'package:noticewise/features/auth/domain/app_user.dart';
import 'package:noticewise/features/auth/presentation/providers/auth_controller.dart';

/// Splash screen shown at app start while the auth session is resolved.
///
/// Reads [authControllerProvider] and redirects once the initial session
/// check completes:
///   - Authenticated admin  → [AppRoutes.adminDashboard]
///   - Authenticated viewer → [AppRoutes.home]
///   - No session           → [AppRoutes.login]
///
/// The go_router redirect guard also enforces these rules, so this screen
/// acts purely as a branded loading placeholder during cold start.
class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  bool _navigated = false;

  @override
  void initState() {
    super.initState();
    // Schedule after the first frame so GoRouter is ready to navigate.
    WidgetsBinding.instance.addPostFrameCallback((_) => _checkAuth());
  }

  Future<void> _checkAuth() async {
    // Wait briefly so the branded splash is visible.
    await Future<void>.delayed(const Duration(milliseconds: 600));
    if (!mounted || _navigated) return;

    final authState = ref.read(authControllerProvider);

    // If still loading (e.g. SharedPreferences is slow), wait for it.
    if (authState.isLoading) {
      ref.listenManual(authControllerProvider, (_, next) {
        if (!next.isLoading && mounted && !_navigated) {
          _navigateByState(next.asData?.value);
        }
      });
      return;
    }

    _navigateByState(authState.asData?.value);
  }

  void _navigateByState(AppUser? user) {
    if (!mounted || _navigated) return;
    _navigated = true;
    if (user == null) {
      context.go(AppRoutes.login);
    } else if (user.role.isAdmin) {
      context.go(AppRoutes.adminDashboard);
    } else {
      context.go(AppRoutes.home);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.campaign_rounded, size: 80, color: colorScheme.primary),
            const SizedBox(height: 24),
            Text(
              AppStrings.appName,
              style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                    color: colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              AppStrings.appTagline,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
            ),
            const SizedBox(height: 48),
            CircularProgressIndicator(
              color: colorScheme.primary,
              strokeWidth: 2,
            ),
          ],
        ),
      ),
    );
  }
}
