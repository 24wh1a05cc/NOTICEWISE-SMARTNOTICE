import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:noticewise/app/router/app_routes.dart';
import 'package:noticewise/features/admin/presentation/admin_dashboard_screen.dart';
import 'package:noticewise/features/auth/domain/app_user.dart';
import 'package:noticewise/features/auth/presentation/providers/auth_controller.dart';
import 'package:noticewise/features/auth/presentation/screens/forgot_password_screen.dart';
import 'package:noticewise/features/auth/presentation/screens/login_screen.dart';
import 'package:noticewise/features/auth/presentation/screens/signup_screen.dart';
import 'package:noticewise/features/auth/presentation/splash_screen.dart';
import 'package:noticewise/features/bookmarks/presentation/bookmarks_screen.dart';
import 'package:noticewise/features/notices/presentation/calendar_screen.dart';
import 'package:noticewise/features/notices/presentation/home_screen.dart';
import 'package:noticewise/features/notices/presentation/notice_detail_screen.dart';
import 'package:noticewise/features/notices/presentation/notice_feed_screen.dart';
import 'package:noticewise/features/notices/presentation/notice_form_screen.dart';
import 'package:noticewise/features/profile/presentation/profile_screen.dart';
import 'package:noticewise/shared/widgets/main_nav_shell.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'app_router.g.dart';

/// Provides the application's [GoRouter] instance.
@Riverpod(keepAlive: true)
GoRouter router(Ref ref) {
  final authController = ref.watch(authControllerProvider);

  return GoRouter(
    initialLocation: AppRoutes.splash,
    debugLogDiagnostics: true,

    redirect: (BuildContext context, GoRouterState state) {
      final authState = authController;
      final AppUser? user = authState.asData?.value;
      final bool isLoading = authState.isLoading;

      if (isLoading && state.matchedLocation == AppRoutes.splash) return null;

      final String location = state.matchedLocation;

      const authRoutes = {
        AppRoutes.splash,
        AppRoutes.login,
        AppRoutes.signup,
        AppRoutes.forgotPassword,
      };
      final bool isAuthRoute = authRoutes.contains(location);

      if (user == null && !isAuthRoute) return AppRoutes.login;

      if (user != null && isAuthRoute && location != AppRoutes.splash) {
        return user.role.isAdmin ? AppRoutes.adminDashboard : AppRoutes.home;
      }

      if (user != null &&
          !user.role.isAdmin &&
          location.startsWith('/admin')) {
        return AppRoutes.home;
      }

      return null;
    },

    routes: [
      // ── Splash ──────────────────────────────────────────────────────────
      GoRoute(
        path: AppRoutes.splash,
        name: 'splash',
        builder: (context, state) => const SplashScreen(),
      ),

      // ── Auth ────────────────────────────────────────────────────────────
      GoRoute(
        path: AppRoutes.login,
        name: 'login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: AppRoutes.signup,
        name: 'signup',
        builder: (context, state) => const SignUpScreen(),
      ),
      GoRoute(
        path: AppRoutes.forgotPassword,
        name: 'forgotPassword',
        builder: (context, state) => const ForgotPasswordScreen(),
      ),

      // ── Main shell — viewer ──────────────────────────────────────────────
      ShellRoute(
        builder: (context, state, child) => MainNavShell(child: child),
        routes: [
          // Home
          GoRoute(
            path: AppRoutes.home,
            name: 'home',
            builder: (context, state) => const HomeScreen(),
          ),

          // Notices feed (viewer) — list + detail
          GoRoute(
            path: AppRoutes.notices,
            name: 'notices',
            builder: (context, state) => const NoticeFeedScreen(),
            routes: [
              GoRoute(
                path: 'new',
                name: 'noticeCreate',
                builder: (context, state) => const NoticeFormScreen(),
              ),
              GoRoute(
                path: ':noticeId',
                name: 'noticeDetail',
                builder: (context, state) => NoticeDetailScreen(
                  noticeId: state.pathParameters['noticeId']!,
                ),
                routes: [
                  GoRoute(
                    path: 'edit',
                    name: 'noticeEdit',
                    builder: (context, state) => NoticeFormScreen(
                      noticeId: state.pathParameters['noticeId'],
                    ),
                  ),
                ],
              ),
            ],
          ),

          // Calendar
          GoRoute(
            path: AppRoutes.calendar,
            name: 'calendar',
            builder: (context, state) => const CalendarScreen(),
          ),

          // Bookmarks
          GoRoute(
            path: AppRoutes.bookmarks,
            name: 'bookmarks',
            builder: (context, state) => const BookmarksScreen(),
          ),

          // Profile
          GoRoute(
            path: AppRoutes.profile,
            name: 'profile',
            builder: (context, state) => const ProfileScreen(),
          ),

          // Admin dashboard (inside shell so nav bar is available)
          GoRoute(
            path: AppRoutes.adminDashboard,
            name: 'adminDashboard',
            builder: (context, state) => const AdminDashboardScreen(),
          ),
        ],
      ),
    ],

    errorBuilder: (context, state) => Scaffold(
      appBar: AppBar(title: const Text('Page Not Found')),
      body: Center(
        child: Text(
          'Route "${state.uri.path}" does not exist.',
          style: Theme.of(context).textTheme.bodyLarge,
        ),
      ),
    ),
  );
}
