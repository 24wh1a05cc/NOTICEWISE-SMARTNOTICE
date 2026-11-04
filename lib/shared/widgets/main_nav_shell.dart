import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:noticewise/app/router/app_routes.dart';
import 'package:noticewise/features/auth/domain/app_user.dart';
import 'package:noticewise/features/auth/presentation/providers/auth_controller.dart';

/// Bottom navigation destinations configuration.
class _NavDestination {
  const _NavDestination({
    required this.label,
    required this.icon,
    required this.selectedIcon,
    required this.route,
  });

  final String label;
  final IconData icon;
  final IconData selectedIcon;
  final String route;
}

const _viewerDestinations = [
  _NavDestination(
    label: 'Home',
    icon: Icons.home_outlined,
    selectedIcon: Icons.home,
    route: AppRoutes.home,
  ),
  _NavDestination(
    label: 'Notices',
    icon: Icons.article_outlined,
    selectedIcon: Icons.article,
    route: AppRoutes.notices,
  ),
  _NavDestination(
    label: 'Calendar',
    icon: Icons.calendar_month_outlined,
    selectedIcon: Icons.calendar_month,
    route: AppRoutes.calendar,
  ),
  _NavDestination(
    label: 'Bookmarks',
    icon: Icons.bookmark_outline,
    selectedIcon: Icons.bookmark,
    route: AppRoutes.bookmarks,
  ),
  _NavDestination(
    label: 'Profile',
    icon: Icons.person_outline,
    selectedIcon: Icons.person,
    route: AppRoutes.profile,
  ),
];

const _adminDestinations = [
  _NavDestination(
    label: 'Dashboard',
    icon: Icons.dashboard_outlined,
    selectedIcon: Icons.dashboard,
    route: AppRoutes.adminDashboard,
  ),
  _NavDestination(
    label: 'Notices',
    icon: Icons.article_outlined,
    selectedIcon: Icons.article,
    route: AppRoutes.notices,
  ),
  _NavDestination(
    label: 'Calendar',
    icon: Icons.calendar_month_outlined,
    selectedIcon: Icons.calendar_month,
    route: AppRoutes.calendar,
  ),
  _NavDestination(
    label: 'Bookmarks',
    icon: Icons.bookmark_outline,
    selectedIcon: Icons.bookmark,
    route: AppRoutes.bookmarks,
  ),
  _NavDestination(
    label: 'Profile',
    icon: Icons.person_outline,
    selectedIcon: Icons.person,
    route: AppRoutes.profile,
  ),
];

/// Wraps any content screen with the shared bottom navigation bar.
///
/// Used by all main app screens (Home, Notices, Calendar, Bookmarks, Profile,
/// AdminDashboard) so navigation is always available.
class MainNavShell extends ConsumerWidget {
  const MainNavShell({super.key, required this.child});

  final Widget child;

  int _currentIndex(String location, List<_NavDestination> destinations) {
    for (var i = 0; i < destinations.length; i++) {
      if (location.startsWith(destinations[i].route)) {
        return i;
      }
    }
    return 0;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authControllerProvider);
    final user = authState.asData?.value;
    final isAdmin = user?.role == AppUserRole.admin;
    final destinations = isAdmin ? _adminDestinations : _viewerDestinations;
    final location = GoRouterState.of(context).uri.path;
    final currentIndex = _currentIndex(location, destinations);

    return Scaffold(
      body: child,
      bottomNavigationBar: NavigationBar(
        selectedIndex: currentIndex,
        onDestinationSelected: (index) {
          final dest = destinations[index];
          if (!location.startsWith(dest.route)) {
            context.go(dest.route);
          }
        },
        destinations: destinations
            .map(
              (d) => NavigationDestination(
                icon: Icon(d.icon),
                selectedIcon: Icon(d.selectedIcon),
                label: d.label,
              ),
            )
            .toList(),
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        height: 68,
      ),
    );
  }
}
