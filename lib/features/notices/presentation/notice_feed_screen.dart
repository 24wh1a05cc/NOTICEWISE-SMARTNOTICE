import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:noticewise/app/router/app_routes.dart';
import 'package:noticewise/features/auth/domain/app_user.dart';
import 'package:noticewise/features/auth/presentation/providers/auth_controller.dart';
import 'package:noticewise/features/bookmarks/presentation/bookmark_providers.dart';
import 'package:noticewise/features/notices/domain/notice.dart';
import 'package:noticewise/features/notices/presentation/notice_providers.dart';

/// Sort options for the notice feed.
enum _SortOption { newest, oldest, priority, category }

/// Full notice feed with filtering, sorting and search.
class NoticeFeedScreen extends ConsumerStatefulWidget {
  const NoticeFeedScreen({super.key});

  @override
  ConsumerState<NoticeFeedScreen> createState() => _NoticeFeedScreenState();
}

class _NoticeFeedScreenState extends ConsumerState<NoticeFeedScreen> {
  final _searchController = TextEditingController();
  String _searchQuery = '';
  String _selectedCategory = 'All';
  NoticePriority? _priorityFilter;
  _SortOption _sort = _SortOption.newest;
  bool _showPublishedOnly = true;

  static const _categories = [
    'All',
    'Examinations',
    'Academic',
    'Events',
    'Placements',
    'General',
    'Sports',
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Notice> _process(List<Notice> all) {
    var result = all.toList();

    // Status filter
    if (_showPublishedOnly) {
      result = result
          .where((n) => n.status == NoticeStatus.published)
          .toList();
    }

    // Category filter
    if (_selectedCategory != 'All') {
      result = result
          .where((n) =>
              n.category.toLowerCase() == _selectedCategory.toLowerCase())
          .toList();
    }

    // Priority filter
    if (_priorityFilter != null) {
      result = result.where((n) => n.priority == _priorityFilter).toList();
    }

    // Search
    if (_searchQuery.isNotEmpty) {
      final q = _searchQuery.toLowerCase();
      result = result
          .where((n) =>
              n.title.toLowerCase().contains(q) ||
              n.body.toLowerCase().contains(q) ||
              n.authorName.toLowerCase().contains(q))
          .toList();
    }

    // Sort
    result.sort((a, b) => switch (_sort) {
          _SortOption.newest => b.createdAt.compareTo(a.createdAt),
          _SortOption.oldest => a.createdAt.compareTo(b.createdAt),
          _SortOption.priority => b.priority.index.compareTo(a.priority.index),
          _SortOption.category => a.category.compareTo(b.category),
        });

    // Pinned always first
    result.sort((a, b) {
      if (a.isPinned && !b.isPinned) return -1;
      if (!a.isPinned && b.isPinned) return 1;
      return 0;
    });

    return result;
  }

  void _showSortDialog() {
    showModalBottomSheet<void>(
      context: context,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Sort by',
                style: Theme.of(ctx).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    )),
            const SizedBox(height: 12),
            ...(_SortOption.values.map((opt) => ListTile(
                  leading: Icon(
                    _sort == opt
                        ? Icons.radio_button_checked
                        : Icons.radio_button_unchecked,
                    color: _sort == opt
                        ? Theme.of(ctx).colorScheme.primary
                        : null,
                  ),
                  title: Text(opt.name
                      .replaceFirst(opt.name[0], opt.name[0].toUpperCase())),
                  onTap: () {
                    setState(() => _sort = opt);
                    Navigator.pop(ctx);
                  },
                ))),
          ],
        ),
      ),
    );
  }

  void _showFilterDialog() {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setInner) => Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Filters',
                  style: Theme.of(ctx).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      )),
              const SizedBox(height: 16),
              Text('Priority',
                  style: Theme.of(ctx).textTheme.labelLarge),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: [
                  FilterChip(
                    label: const Text('All priorities'),
                    selected: _priorityFilter == null,
                    onSelected: (_) {
                      setInner(() => _priorityFilter = null);
                      setState(() => _priorityFilter = null);
                    },
                  ),
                  ...NoticePriority.values.map(
                    (p) => FilterChip(
                      label: Text(p.label),
                      selected: _priorityFilter == p,
                      onSelected: (_) {
                        setInner(() => _priorityFilter = p);
                        setState(() => _priorityFilter = p);
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              SwitchListTile(
                title: const Text('Published only'),
                value: _showPublishedOnly,
                contentPadding: EdgeInsets.zero,
                onChanged: (v) {
                  setInner(() => _showPublishedOnly = v);
                  setState(() => _showPublishedOnly = v);
                },
              ),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text('Apply'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context, ) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final authState = ref.watch(authControllerProvider);
    final user = authState.asData?.value;
    final isAdmin = user?.role == AppUserRole.admin;
    final noticesState = ref.watch(noticesControllerProvider);

    final hasActiveFilters =
        _selectedCategory != 'All' || _priorityFilter != null;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notices'),
        actions: [
          IconButton(
            icon: Icon(
              Icons.filter_list,
              color: hasActiveFilters ? cs.primary : null,
            ),
            tooltip: 'Filter',
            onPressed: _showFilterDialog,
          ),
          IconButton(
            icon: const Icon(Icons.sort),
            tooltip: 'Sort',
            onPressed: _showSortDialog,
          ),
          if (isAdmin)
            IconButton(
              icon: const Icon(Icons.add_circle_outline),
              tooltip: 'New Notice',
              onPressed: () => context.push(AppRoutes.noticeCreate),
            ),
        ],
      ),
      body: Column(
        children: [
          // ── Search bar ──────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search notices…',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          setState(() => _searchQuery = '');
                        },
                      )
                    : null,
                isDense: true,
              ),
              onChanged: (v) => setState(() => _searchQuery = v),
            ),
          ),

          // ── Category chips ──────────────────────────────────────────────
          SizedBox(
            height: 48,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
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
                  visualDensity: VisualDensity.compact,
                );
              },
            ),
          ),

          // ── Sort indicator ──────────────────────────────────────────────
          if (_searchQuery.isNotEmpty ||
              hasActiveFilters ||
              _sort != _SortOption.newest)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
              child: Row(
                children: [
                  Text(
                    'Sorted: ${_sort.name}',
                    style: theme.textTheme.labelSmall
                        ?.copyWith(color: cs.onSurfaceVariant),
                  ),
                  const Spacer(),
                  if (hasActiveFilters)
                    TextButton(
                      onPressed: () => setState(() {
                        _selectedCategory = 'All';
                        _priorityFilter = null;
                        _showPublishedOnly = true;
                      }),
                      style: TextButton.styleFrom(
                          padding: EdgeInsets.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap),
                      child: const Text('Clear filters'),
                    ),
                ],
              ),
            ),

          // ── Notices list ──────────────────────────────────────────────────
          Expanded(
            child: noticesState.when(
              loading: () =>
                  const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.error_outline, color: cs.error, size: 48),
                    const SizedBox(height: 12),
                    Text('Failed to load: $e'),
                    const SizedBox(height: 12),
                    FilledButton(
                      onPressed: () => ref
                          .read(noticesControllerProvider.notifier)
                          .refresh(),
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
              data: (all) {
                final notices = _process(all);
                if (notices.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.search_off,
                            size: 56,
                            color: cs.onSurfaceVariant
                                .withValues(alpha: 0.35)),
                        const SizedBox(height: 12),
                        Text(
                          'No notices found',
                          style: theme.textTheme.titleMedium,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Try different search terms or filters.',
                          style: theme.textTheme.bodySmall
                              ?.copyWith(color: cs.onSurfaceVariant),
                        ),
                      ],
                    ),
                  );
                }
                return RefreshIndicator(
                  onRefresh: () => ref
                      .read(noticesControllerProvider.notifier)
                      .refresh(),
                  child: ListView.builder(
                    padding:
                        const EdgeInsets.fromLTRB(16, 8, 16, 100),
                    itemCount: notices.length,
                    itemBuilder: (context, i) =>
                        _FeedNoticeCard(notice: notices[i]),
                  ),
                );
              },
            ),
          ),
        ],
      ),
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

// ── Feed notice card ─────────────────────────────────────────────────────────

class _FeedNoticeCard extends ConsumerWidget {
  const _FeedNoticeCard({required this.notice});

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
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final priorityColor = _priorityColor(context);
    final bookmarkIds = ref.watch(bookmarksControllerProvider);
    final isBookmarked =
        bookmarkIds.asData?.value.contains(notice.id) ?? false;

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Card(
        elevation: notice.isPinned ? 2 : 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: BorderSide(
            color: notice.isPinned
                ? cs.primary.withValues(alpha: 0.5)
                : cs.outlineVariant.withValues(alpha: 0.6),
          ),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: () => context.push(AppRoutes.noticeDetail(notice.id)),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    if (notice.isPinned) ...[
                      Icon(Icons.push_pin, size: 13, color: cs.primary),
                      const SizedBox(width: 4),
                    ],
                    if (notice.category.isNotEmpty)
                      Flexible(
                        child: Container(
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
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
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
                    const SizedBox(width: 4),
                    GestureDetector(
                      onTap: () => ref
                          .read(bookmarksControllerProvider.notifier)
                          .toggleBookmark(notice.id),
                      child: Icon(
                        isBookmarked ? Icons.bookmark : Icons.bookmark_outline,
                        size: 20,
                        color: isBookmarked ? cs.primary : cs.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  notice.title,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                if (notice.body.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    notice.body,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: cs.onSurfaceVariant,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
                const SizedBox(height: 8),
                Row(
                  children: [
                    if (notice.authorName.isNotEmpty) ...[
                      Icon(Icons.person_outline,
                          size: 12, color: cs.onSurfaceVariant),
                      const SizedBox(width: 3),
                      Flexible(
                        child: Text(
                          notice.authorName,
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: cs.onSurfaceVariant,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                    ],
                    Icon(Icons.access_time,
                        size: 12, color: cs.onSurfaceVariant),
                    const SizedBox(width: 3),
                    Text(
                      _relDate(notice.createdAt),
                      style: theme.textTheme.labelSmall
                          ?.copyWith(color: cs.onSurfaceVariant),
                    ),
                    if (notice.status == NoticeStatus.draft) ...[
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: cs.errorContainer,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          'Draft',
                          style: theme.textTheme.labelSmall
                              ?.copyWith(color: cs.onErrorContainer),
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
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
