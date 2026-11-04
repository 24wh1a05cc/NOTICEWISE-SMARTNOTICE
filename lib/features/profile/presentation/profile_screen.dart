import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:noticewise/app/router/app_routes.dart';
import 'package:noticewise/app/theme/theme_notifier.dart';
import 'package:noticewise/features/auth/presentation/providers/auth_controller.dart';
import 'package:noticewise/features/bookmarks/presentation/bookmark_providers.dart';
import 'package:noticewise/features/notices/presentation/notice_providers.dart';
import 'package:noticewise/features/notices/domain/notice.dart';

/// Profile and settings screen.
class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final authState = ref.watch(authControllerProvider);
    final user = authState.asData?.value;
    final themeMode = ref.watch(themeProvider);
    final noticesState = ref.watch(noticesControllerProvider);
    final bookmarksState = ref.watch(bookmarksControllerProvider);

    if (user == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Profile')),
        body: Center(
          child: FilledButton(
            onPressed: () => context.go(AppRoutes.login),
            child: const Text('Sign In'),
          ),
        ),
      );
    }

    final allNotices = noticesState.asData?.value ?? [];
    final bookmarkCount = bookmarksState.asData?.value.length ?? 0;
    final publishedCount = allNotices
        .where((n) => n.status == NoticeStatus.published)
        .length;
    final totalNotices = allNotices.length;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 160,
            pinned: true,
            backgroundColor: cs.primaryContainer,
            flexibleSpace: FlexibleSpaceBar(
              background: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      cs.primary,
                      cs.primaryContainer,
                    ],
                  ),
                ),
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CircleAvatar(
                          radius: 32,
                          backgroundColor:
                              cs.onPrimary.withValues(alpha: 0.2),
                          child: Text(
                            _initials(user.name),
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: cs.onPrimary,
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          user.name,
                          style: theme.textTheme.titleLarge?.copyWith(
                            color: cs.onPrimary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          user.email,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: cs.onPrimary.withValues(alpha: 0.85),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            actions: [
              IconButton(
                icon: Icon(Icons.logout, color: cs.onPrimary),
                tooltip: 'Sign out',
                onPressed: () =>
                    ref.read(authControllerProvider.notifier).signOut(),
              ),
            ],
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Role badge ─────────────────────────────────────────
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 5),
                        decoration: BoxDecoration(
                          color: user.role.isAdmin
                              ? cs.primaryContainer
                              : cs.secondaryContainer,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              user.role.isAdmin
                                  ? Icons.admin_panel_settings_outlined
                                  : Icons.person_outline,
                              size: 16,
                              color: user.role.isAdmin
                                  ? cs.onPrimaryContainer
                                  : cs.onSecondaryContainer,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              user.role.label,
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: user.role.isAdmin
                                    ? cs.onPrimaryContainer
                                    : cs.onSecondaryContainer,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // ── Stats cards ───────────────────────────────────────
                  Row(
                    children: [
                      Expanded(
                        child: _StatCard(
                          label: 'Bookmarks',
                          value: '$bookmarkCount',
                          icon: Icons.bookmark_outlined,
                          color: cs.primary,
                        ),
                      ),
                      const SizedBox(width: 12),
                      if (user.role.isAdmin) ...[
                        Expanded(
                          child: _StatCard(
                            label: 'Total Notices',
                            value: '$totalNotices',
                            icon: Icons.article_outlined,
                            color: cs.secondary,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _StatCard(
                            label: 'Published',
                            value: '$publishedCount',
                            icon: Icons.check_circle_outline,
                            color: Colors.green.shade600,
                          ),
                        ),
                      ] else ...[
                        Expanded(
                          child: _StatCard(
                            label: 'Available',
                            value: '$publishedCount',
                            icon: Icons.article_outlined,
                            color: cs.secondary,
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 24),

                  // ── Settings section ───────────────────────────────────
                  Text('Settings',
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: cs.onSurfaceVariant,
                      )),
                  const SizedBox(height: 8),

                  Card(
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(color: cs.outlineVariant),
                    ),
                    child: Column(
                      children: [
                        // Theme toggle
                        SwitchListTile(
                          value: themeMode == ThemeMode.dark ||
                              (themeMode == ThemeMode.system &&
                                  MediaQuery.platformBrightnessOf(context) ==
                                      Brightness.dark),
                          onChanged: (_) =>
                              ref.read(themeProvider.notifier).toggle(),
                          title: const Text('Dark Mode'),
                          secondary: Icon(
                            themeMode == ThemeMode.dark
                                ? Icons.dark_mode
                                : Icons.light_mode,
                          ),
                          shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.vertical(
                                top: Radius.circular(12)),
                          ),
                        ),
                        const Divider(height: 1, indent: 16, endIndent: 16),
                        ListTile(
                          leading: const Icon(Icons.bookmark_outline),
                          title: const Text('My Bookmarks'),
                          trailing: const Icon(Icons.chevron_right),
                          onTap: () => context.go(AppRoutes.bookmarks),
                        ),
                        const Divider(height: 1, indent: 16, endIndent: 16),
                        ListTile(
                          leading: const Icon(Icons.calendar_month_outlined),
                          title: const Text('Calendar'),
                          trailing: const Icon(Icons.chevron_right),
                          onTap: () => context.go(AppRoutes.calendar),
                        ),
                        if (user.role.isAdmin) ...[
                          const Divider(height: 1, indent: 16, endIndent: 16),
                          ListTile(
                            leading: const Icon(Icons.dashboard_outlined),
                            title: const Text('Admin Dashboard'),
                            trailing: const Icon(Icons.chevron_right),
                            onTap: () =>
                                context.go(AppRoutes.adminDashboard),
                          ),
                          const Divider(height: 1, indent: 16, endIndent: 16),
                          ListTile(
                            leading: const Icon(Icons.add_circle_outline),
                            title: const Text('Create Notice'),
                            trailing: const Icon(Icons.chevron_right),
                            onTap: () =>
                                context.push(AppRoutes.noticeCreate),
                            shape: const RoundedRectangleBorder(
                              borderRadius: BorderRadius.vertical(
                                  bottom: Radius.circular(12)),
                            ),
                          ),
                        ] else ...[
                          const Divider(height: 1, indent: 16, endIndent: 16),
                          ListTile(
                            leading: const Icon(Icons.info_outline),
                            title: const Text('About NoticeWise'),
                            trailing: const Icon(Icons.chevron_right),
                            shape: const RoundedRectangleBorder(
                              borderRadius: BorderRadius.vertical(
                                  bottom: Radius.circular(12)),
                            ),
                            onTap: () => _showAbout(context),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // ── Account section ────────────────────────────────────
                  Text('Account',
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: cs.onSurfaceVariant,
                      )),
                  const SizedBox(height: 8),

                  Card(
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(color: cs.outlineVariant),
                    ),
                    child: Column(
                      children: [
                        ListTile(
                          leading: Icon(Icons.badge_outlined,
                              color: cs.onSurfaceVariant),
                          title: const Text('Account ID'),
                          subtitle: Text(
                            user.id,
                            style: TextStyle(fontSize: 11, color: cs.outline),
                          ),
                        ),
                        const Divider(height: 1, indent: 16, endIndent: 16),
                        ListTile(
                          leading: Icon(Icons.security_outlined,
                              color: cs.onSurfaceVariant),
                          title: const Text('Demo Mode'),
                          subtitle: const Text(
                              'Running fully offline — no Firebase required'),
                          shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.vertical(
                                bottom: Radius.circular(12)),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // ── Sign out button ─────────────────────────────────────
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: cs.error,
                        side: BorderSide(color: cs.error.withValues(alpha: 0.4)),
                      ),
                      onPressed: () =>
                          ref.read(authControllerProvider.notifier).signOut(),
                      icon: const Icon(Icons.logout),
                      label: const Text('Sign Out'),
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _initials(String name) {
    final parts = name.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name.isNotEmpty ? name[0].toUpperCase() : '?';
  }

  void _showAbout(BuildContext context) {
    showAboutDialog(
      context: context,
      applicationName: 'NoticeWise',
      applicationVersion: '1.0.0',
      children: const [
        Text(
            'NoticeWise is an intelligent notice management app for institutions and organisations.'),
        SizedBox(height: 8),
        Text('Runs fully offline using local SQLite storage.'),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  final String label;
  final String value;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 6),
          Text(
            value,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(fontSize: 11, color: color),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
