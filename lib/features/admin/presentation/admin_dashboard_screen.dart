import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:noticewise/app/router/app_routes.dart';
import 'package:noticewise/features/auth/presentation/providers/auth_controller.dart';
import 'package:noticewise/features/notices/domain/notice.dart';
import 'package:noticewise/features/notices/presentation/notice_providers.dart';

/// Functional admin dashboard with real statistics and quick actions.
class AdminDashboardScreen extends ConsumerWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final authState = ref.watch(authControllerProvider);
    final user = authState.asData?.value;
    final noticesState = ref.watch(noticesControllerProvider);

    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.campaign_rounded, color: cs.primary, size: 22),
            const SizedBox(width: 8),
            const Text('NoticeWise'),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            tooltip: 'Notifications',
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Sign out',
            onPressed: () =>
                ref.read(authControllerProvider.notifier).signOut(),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () =>
            ref.read(noticesControllerProvider.notifier).refresh(),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Welcome card ──────────────────────────────────────────
              Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                color: cs.primaryContainer,
                elevation: 0,
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 28,
                        backgroundColor:
                            cs.primary.withValues(alpha: 0.2),
                        child: Icon(
                          Icons.admin_panel_settings_rounded,
                          color: cs.primary,
                          size: 28,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Welcome back,',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: cs.onPrimaryContainer,
                              ),
                            ),
                            Text(
                              user?.name ?? 'Admin',
                              style: theme.textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: cs.onPrimaryContainer,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: cs.primary.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.verified_rounded,
                                      size: 14, color: cs.primary),
                                  const SizedBox(width: 4),
                                  Text(
                                    'Administrator',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: cs.primary,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // ── Statistics ────────────────────────────────────────────
              Text(
                'Overview',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),

              noticesState.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, _) => Text('Error: $e'),
                data: (notices) {
                  final total = notices.length;
                  final published = notices
                      .where((n) => n.status == NoticeStatus.published)
                      .length;
                  final draft = notices
                      .where((n) => n.status == NoticeStatus.draft)
                      .length;
                  final scheduled = notices
                      .where((n) => n.status == NoticeStatus.scheduled)
                      .length;
                  final urgent = notices
                      .where((n) =>
                          n.priority == NoticePriority.urgent &&
                          n.status == NoticeStatus.published)
                      .length;
                  // ignore: unused_local_variable
                  final pinned =
                      notices.where((n) => n.isPinned).length;

                  final now = DateTime.now();
                  final upcoming = notices
                      .where((n) =>
                          n.expiresAt != null && n.expiresAt!.isAfter(now))
                      .length;

                  return Column(
                    children: [
                      // Row 1
                      Row(
                        children: [
                          Expanded(
                            child: _StatCard(
                              label: 'Total Notices',
                              value: '$total',
                              icon: Icons.article_outlined,
                              color: cs.primary,
                              onTap: () => context.push(AppRoutes.notices),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _StatCard(
                              label: 'Published',
                              value: '$published',
                              icon: Icons.check_circle_outline,
                              color: Colors.green.shade600,
                              onTap: () => context.push(AppRoutes.notices),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      // Row 2
                      Row(
                        children: [
                          Expanded(
                            child: _StatCard(
                              label: 'Drafts',
                              value: '$draft',
                              icon: Icons.edit_note_outlined,
                              color: cs.outline,
                              onTap: () => context.push(AppRoutes.notices),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _StatCard(
                              label: 'Urgent',
                              value: '$urgent',
                              icon: Icons.priority_high,
                              color: cs.error,
                              onTap: () => context.push(AppRoutes.notices),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: _StatCard(
                              label: 'Scheduled',
                              value: '$scheduled',
                              icon: Icons.schedule_outlined,
                              color: cs.secondary,
                              onTap: () => context.push(AppRoutes.notices),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _StatCard(
                              label: 'Active',
                              value: '$upcoming',
                              icon: Icons.event_available_outlined,
                              color: Colors.teal.shade600,
                              onTap: () => context.push(AppRoutes.calendar),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // ── Quick Actions ──────────────────────────────────
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Quick Actions',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: _ActionCard(
                              label: 'Create Notice',
                              icon: Icons.add_circle_outline,
                              color: cs.primary,
                              onTap: () =>
                                  context.push(AppRoutes.noticeCreate),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _ActionCard(
                              label: 'All Notices',
                              icon: Icons.list_alt_outlined,
                              color: cs.secondary,
                              onTap: () => context.push(AppRoutes.notices),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: _ActionCard(
                              label: 'Calendar',
                              icon: Icons.calendar_month_outlined,
                              color: Colors.teal.shade600,
                              onTap: () => context.go(AppRoutes.calendar),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _ActionCard(
                              label: 'Bookmarks',
                              icon: Icons.bookmark_outline,
                              color: Colors.orange.shade700,
                              onTap: () => context.go(AppRoutes.bookmarks),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // ── Recent activity ────────────────────────────────
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Recent Activity',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      if (notices.isEmpty)
                        _EmptyActivity()
                      else
                        ...notices.take(5).map(
                              (n) => _RecentNoticeRow(notice: n),
                            ),
                      if (notices.length > 5)
                        Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: SizedBox(
                            width: double.infinity,
                            child: FilledButton.tonal(
                              onPressed: () =>
                                  context.push(AppRoutes.notices),
                              child: const Text('View all notices'),
                            ),
                          ),
                        ),
                      const SizedBox(height: 32),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push(AppRoutes.noticeCreate),
        icon: const Icon(Icons.add),
        label: const Text('New Notice'),
      ),
    );
  }
}

// ── Stat card ────────────────────────────────────────────────────────────────

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
    this.onTap,
  });

  final String label;
  final String value;
  final IconData icon;
  final Color color;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 14),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withValues(alpha: 0.2)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 26),
            const SizedBox(height: 10),
            Text(
              value,
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: color.withValues(alpha: 0.8),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Action card ──────────────────────────────────────────────────────────────

class _ActionCard extends StatelessWidget {
  const _ActionCard({
    required this.label,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(
            color: color.withValues(alpha: 0.25)),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: color,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Recent notice row ────────────────────────────────────────────────────────

class _RecentNoticeRow extends ConsumerWidget {
  const _RecentNoticeRow({required this.notice});

  final Notice notice;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    final statusColor = switch (notice.status) {
      NoticeStatus.published => Colors.green.shade600,
      NoticeStatus.draft => cs.outline,
      NoticeStatus.scheduled => cs.secondary,
    };

    return InkWell(
      borderRadius: BorderRadius.circular(10),
      onTap: () => context.push(AppRoutes.noticeDetail(notice.id)),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: statusColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(Icons.article_outlined,
                  size: 20, color: statusColor),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    notice.title,
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 1),
                        decoration: BoxDecoration(
                          color: statusColor.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          notice.status.label,
                          style: TextStyle(
                              fontSize: 10,
                              color: statusColor,
                              fontWeight: FontWeight.w600),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        _relDate(notice.updatedAt),
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: cs.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right, size: 18, color: cs.onSurfaceVariant),
          ],
        ),
      ),
    );
  }

  String _relDate(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return '${dt.day}/${dt.month}/${dt.year}';
  }
}

class _EmptyActivity extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Text(
          'No recent activity.',
          style: TextStyle(color: cs.onSurfaceVariant),
        ),
      ),
    );
  }
}
