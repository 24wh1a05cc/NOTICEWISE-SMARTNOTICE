import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:noticewise/app/router/app_routes.dart';
import 'package:noticewise/features/auth/domain/app_user.dart';
import 'package:noticewise/features/auth/presentation/providers/auth_controller.dart';
import 'package:noticewise/features/notices/domain/notice.dart';
import 'package:noticewise/features/notices/presentation/notice_providers.dart';

/// Main home screen — shown after login for viewer role.
class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final _searchController = TextEditingController();
  String _searchQuery = '';

  static const _categories = [
    'All',
    'Examinations',
    'Academic',
    'Events',
    'Placements',
    'General',
    'Sports',
  ];
  String _selectedCategory = 'All';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Notice> _filtered(List<Notice> notices) {
    var result = notices.where((n) => n.status == NoticeStatus.published).toList();

    if (_selectedCategory != 'All') {
      result = result
          .where((n) =>
              n.category.toLowerCase() == _selectedCategory.toLowerCase())
          .toList();
    }

    if (_searchQuery.isNotEmpty) {
      final q = _searchQuery.toLowerCase();
      result = result
          .where((n) =>
              n.title.toLowerCase().contains(q) ||
              n.body.toLowerCase().contains(q) ||
              n.category.toLowerCase().contains(q) ||
              n.authorName.toLowerCase().contains(q))
          .toList();
    }

    return result;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final authState = ref.watch(authControllerProvider);
    final user = authState.asData?.value;
    final noticesState = ref.watch(noticesControllerProvider);
    final isAdmin = user?.role == AppUserRole.admin;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // ── Large collapsing app bar ──────────────────────────────────────
          SliverAppBar.large(
            expandedHeight: 160,
            floating: false,
            pinned: true,
            backgroundColor: cs.surface,
            flexibleSpace: FlexibleSpaceBar(
              titlePadding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
              title: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.campaign_rounded,
                          color: cs.primary, size: 20),
                      const SizedBox(width: 6),
                      Text(
                        'NoticeWise',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: cs.primary,
                        ),
                      ),
                    ],
                  ),
                  if (user != null)
                    Text(
                      'Hello, ${user.name.split(' ').first}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: cs.onSurfaceVariant,
                      ),
                    ),
                ],
              ),
            ),
            actions: [
              if (isAdmin)
                IconButton(
                  icon: const Icon(Icons.add_circle_outline),
                  tooltip: 'Create Notice',
                  onPressed: () => context.push(AppRoutes.noticeCreate),
                ),
              IconButton(
                icon: const Icon(Icons.notifications_outlined),
                tooltip: 'Notifications',
                onPressed: () {},
              ),
            ],
          ),

          // ── Search bar ────────────────────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
              child: SearchBar(
                controller: _searchController,
                hintText: 'Search notices…',
                leading: const Icon(Icons.search),
                trailing: [
                  if (_searchQuery.isNotEmpty)
                    IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        _searchController.clear();
                        setState(() => _searchQuery = '');
                      },
                    ),
                ],
                onChanged: (v) => setState(() => _searchQuery = v),
              ),
            ),
          ),

          // ── Category chips ────────────────────────────────────────────────
          SliverToBoxAdapter(
            child: SizedBox(
              height: 52,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                itemCount: _categories.length,
                separatorBuilder: (_, _) => const SizedBox(width: 8),
                itemBuilder: (context, i) {
                  final cat = _categories[i];
                  final selected = _selectedCategory == cat;
                  return FilterChip(
                    label: Text(cat),
                    selected: selected,
                    onSelected: (_) =>
                        setState(() => _selectedCategory = cat),
                    showCheckmark: false,
                  );
                },
              ),
            ),
          ),

          // ── Notices list ──────────────────────────────────────────────────
          noticesState.when(
            loading: () => const SliverFillRemaining(
              child: Center(child: CircularProgressIndicator()),
            ),
            error: (e, _) => SliverFillRemaining(
              child: _ErrorState(
                onRetry: () =>
                    ref.read(noticesControllerProvider.notifier).refresh(),
              ),
            ),
            data: (allNotices) {
              final notices = _filtered(allNotices);

              if (notices.isEmpty) {
                return SliverFillRemaining(
                  child: _EmptyState(
                    query: _searchQuery,
                    category: _selectedCategory,
                    isAdmin: isAdmin,
                    onClear: () {
                      setState(() {
                        _searchQuery = '';
                        _selectedCategory = 'All';
                        _searchController.clear();
                      });
                    },
                    onCreateTap: isAdmin
                        ? () => context.push(AppRoutes.noticeCreate)
                        : null,
                  ),
                );
              }

              // Stats row
              final urgent = notices
                  .where((n) => n.priority == NoticePriority.urgent)
                  .length;
              final pinned = notices.where((n) => n.isPinned).length;

              return SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    if (index == 0) {
                      return _StatsRow(
                        total: notices.length,
                        urgent: urgent,
                        pinned: pinned,
                      );
                    }
                    return _HomeNoticeCard(notice: notices[index - 1]);
                  },
                  childCount: notices.length + 1,
                ),
              );
            },
          ),
        ],
      ),

      // FAB for admin
      floatingActionButton: isAdmin
          ? FloatingActionButton.extended(
              onPressed: () => context.push(AppRoutes.noticeCreate),
              icon: const Icon(Icons.add),
              label: const Text('New Notice'),
            )
          : null,
    );
  }
}

// ── Stats row ──────────────────────────────────────────────────────────────

class _StatsRow extends StatelessWidget {
  const _StatsRow({
    required this.total,
    required this.urgent,
    required this.pinned,
  });

  final int total;
  final int urgent;
  final int pinned;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
      child: Row(
        children: [
          _StatChip(
            label: '$total Notices',
            icon: Icons.article_outlined,
            color: cs.primary,
          ),
          const SizedBox(width: 8),
          if (urgent > 0)
            _StatChip(
              label: '$urgent Urgent',
              icon: Icons.priority_high,
              color: cs.error,
            ),
          const SizedBox(width: 8),
          if (pinned > 0)
            _StatChip(
              label: '$pinned Pinned',
              icon: Icons.push_pin_outlined,
              color: cs.secondary,
            ),
        ],
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  const _StatChip(
      {required this.label, required this.icon, required this.color});

  final String label;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
                fontSize: 12, fontWeight: FontWeight.w600, color: color),
          ),
        ],
      ),
    );
  }
}

// ── Notice card ─────────────────────────────────────────────────────────────

class _HomeNoticeCard extends StatelessWidget {
  const _HomeNoticeCard({required this.notice});

  final Notice notice;

  Color _priorityColor(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return switch (notice.priority) {
      NoticePriority.urgent => cs.error,
      NoticePriority.high => Colors.orange.shade700,
      NoticePriority.normal => cs.primary,
      NoticePriority.low => cs.onSurfaceVariant,
    };
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final priorityColor = _priorityColor(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
      child: Card(
        elevation: notice.isPinned ? 2 : 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: BorderSide(
            color: notice.isPinned
                ? cs.primary.withValues(alpha: 0.5)
                : cs.outlineVariant.withValues(alpha: 0.6),
            width: notice.isPinned ? 1.5 : 1,
          ),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: () => context.push(AppRoutes.noticeDetail(notice.id)),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top row: pin + category chip + priority badge
                Row(
                  children: [
                    if (notice.isPinned) ...[
                      Icon(Icons.push_pin, size: 13, color: cs.primary),
                      const SizedBox(width: 4),
                    ],
                    if (notice.category.isNotEmpty) ...[
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: cs.secondaryContainer,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          notice.category,
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: cs.onSecondaryContainer,
                          ),
                        ),
                      ),
                      const Spacer(),
                    ] else
                      const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: priorityColor.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        notice.priority.label,
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: priorityColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                // Title
                Text(
                  notice.title,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    height: 1.3,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                if (notice.body.isNotEmpty) ...[
                  const SizedBox(height: 5),
                  Text(
                    notice.body,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: cs.onSurfaceVariant,
                      height: 1.4,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
                const SizedBox(height: 10),
                // Footer: author + date
                Row(
                  children: [
                    if (notice.authorName.isNotEmpty) ...[
                      Icon(Icons.person_outline,
                          size: 13, color: cs.onSurfaceVariant),
                      const SizedBox(width: 3),
                      Expanded(
                        child: Text(
                          notice.authorName,
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: cs.onSurfaceVariant,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ] else
                      const Spacer(),
                    Icon(Icons.access_time,
                        size: 13, color: cs.onSurfaceVariant),
                    const SizedBox(width: 3),
                    Text(
                      _relativeDate(notice.createdAt),
                      style: theme.textTheme.labelSmall
                          ?.copyWith(color: cs.onSurfaceVariant),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _relativeDate(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return '${dt.day}/${dt.month}/${dt.year}';
  }
}

// ── Empty state ─────────────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  const _EmptyState({
    required this.query,
    required this.category,
    required this.isAdmin,
    this.onClear,
    this.onCreateTap,
  });

  final String query;
  final String category;
  final bool isAdmin;
  final VoidCallback? onClear;
  final VoidCallback? onCreateTap;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final hasFilter = query.isNotEmpty || category != 'All';

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.article_outlined,
                size: 64,
                color: cs.onSurfaceVariant.withValues(alpha: 0.35)),
            const SizedBox(height: 16),
            Text(
              hasFilter ? 'No notices match your filter' : 'No notices yet',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            if (hasFilter)
              Text(
                'Try clearing your search or changing the category.',
                textAlign: TextAlign.center,
                style: Theme.of(context)
                    .textTheme
                    .bodySmall
                    ?.copyWith(color: cs.onSurfaceVariant),
              ),
            const SizedBox(height: 20),
            if (hasFilter)
              FilledButton.tonal(
                onPressed: onClear,
                child: const Text('Clear Filters'),
              ),
            if (isAdmin && onCreateTap != null && !hasFilter) ...[
              const SizedBox(height: 8),
              FilledButton.icon(
                onPressed: onCreateTap,
                icon: const Icon(Icons.add),
                label: const Text('Create Notice'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.error_outline,
              size: 56, color: Theme.of(context).colorScheme.error),
          const SizedBox(height: 16),
          const Text('Failed to load notices'),
          const SizedBox(height: 12),
          FilledButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh),
            label: const Text('Retry'),
          ),
        ],
      ),
    );
  }
}
