import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:noticewise/app/router/app_routes.dart';
import 'package:noticewise/features/bookmarks/presentation/bookmark_providers.dart';
import 'package:noticewise/features/notices/domain/notice.dart';

/// Displays all bookmarked notices.
class BookmarksScreen extends ConsumerWidget {
  const BookmarksScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final bookmarkedAsync = ref.watch(bookmarkedNoticesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Bookmarks'),
        actions: [
          bookmarkedAsync.when(
            data: (notices) => notices.isNotEmpty
                ? TextButton(
                    onPressed: () => _confirmClearAll(context, ref, notices),
                    child: const Text('Clear all'),
                  )
                : const SizedBox.shrink(),
            loading: () => const SizedBox.shrink(),
            error: (_, _) => const SizedBox.shrink(),
          ),
        ],
      ),
      body: bookmarkedAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (notices) {
          if (notices.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.bookmark_outline,
                      size: 72,
                      color: cs.onSurfaceVariant.withValues(alpha: 0.35),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No bookmarks yet',
                      style: theme.textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Tap the bookmark icon on any notice to save it here.',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodySmall
                          ?.copyWith(color: cs.onSurfaceVariant),
                    ),
                    const SizedBox(height: 24),
                    FilledButton.tonal(
                      onPressed: () => context.go(AppRoutes.notices),
                      child: const Text('Browse Notices'),
                    ),
                  ],
                ),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
            itemCount: notices.length,
            itemBuilder: (context, i) =>
                _BookmarkCard(notice: notices[i]),
          );
        },
      ),
    );
  }

  Future<void> _confirmClearAll(
      BuildContext context, WidgetRef ref, List<Notice> notices) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Clear all bookmarks?'),
        content: Text(
            'Remove all ${notices.length} bookmarks? This cannot be undone.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancel')),
          FilledButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Clear')),
        ],
      ),
    );
    if (confirmed == true) {
      for (final n in notices) {
        await ref
            .read(bookmarksControllerProvider.notifier)
            .toggleBookmark(n.id);
      }
    }
  }
}

class _BookmarkCard extends ConsumerWidget {
  const _BookmarkCard({required this.notice});

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

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(color: cs.outlineVariant),
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
                  if (notice.category.isNotEmpty)
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
                  // Remove bookmark icon
                  IconButton(
                    icon: const Icon(Icons.bookmark, size: 20),
                    color: cs.primary,
                    tooltip: 'Remove bookmark',
                    onPressed: () {
                      ref
                          .read(bookmarksControllerProvider.notifier)
                          .toggleBookmark(notice.id);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Bookmark removed'),
                          duration: Duration(seconds: 1),
                        ),
                      );
                    },
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(
                        minWidth: 28, minHeight: 28),
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
                  Icon(Icons.person_outline, size: 12, color: cs.onSurfaceVariant),
                  const SizedBox(width: 4),
                  Flexible(
                    child: Text(
                      notice.authorName.isNotEmpty
                          ? notice.authorName
                          : 'Unknown',
                      style: theme.textTheme.labelSmall
                          ?.copyWith(color: cs.onSurfaceVariant),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Icon(Icons.access_time, size: 12, color: cs.onSurfaceVariant),
                  const SizedBox(width: 4),
                  Text(
                    _fmtDate(notice.createdAt),
                    style: theme.textTheme.labelSmall
                        ?.copyWith(color: cs.onSurfaceVariant),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _fmtDate(DateTime dt) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${dt.day} ${months[dt.month - 1]} ${dt.year}';
  }
}
