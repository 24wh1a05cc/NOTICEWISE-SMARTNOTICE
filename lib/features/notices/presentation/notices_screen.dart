import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:noticewise/app/router/app_routes.dart';
import 'package:noticewise/features/notices/domain/notice.dart';
import 'package:noticewise/features/notices/presentation/notice_providers.dart';

/// Displays all locally stored notices with create and delete capabilities.
class NoticesScreen extends ConsumerWidget {
  const NoticesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(noticesControllerProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notices'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh',
            onPressed: () =>
                ref.read(noticesControllerProvider.notifier).refresh(),
          ),
        ],
      ),
      body: state.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => _ErrorView(error: e, onRetry: () {
          ref.read(noticesControllerProvider.notifier).refresh();
        }),
        data: (notices) => notices.isEmpty
            ? _EmptyView(
                onCreateTap: () => context.push(AppRoutes.noticeCreate),
              )
            : _NoticesList(notices: notices),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push(AppRoutes.noticeCreate),
        icon: const Icon(Icons.add),
        label: const Text('New Notice'),
      ),
    );
  }
}

// ── Sub-widgets ────────────────────────────────────────────────────────────

class _EmptyView extends StatelessWidget {
  const _EmptyView({required this.onCreateTap});

  final VoidCallback onCreateTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.article_outlined,
              size: 72,
              color: colorScheme.onSurfaceVariant.withValues(alpha: 0.4),
            ),
            const SizedBox(height: 16),
            Text(
              'No notices yet',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              'Tap the button below to create your first notice.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: onCreateTap,
              icon: const Icon(Icons.add),
              label: const Text('Create Notice'),
            ),
          ],
        ),
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.error, required this.onRetry});

  final Object error;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.error_outline,
              size: 56,
              color: Theme.of(context).colorScheme.error,
            ),
            const SizedBox(height: 16),
            Text(
              'Failed to load notices',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              error.toString(),
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}

class _NoticesList extends ConsumerWidget {
  const _NoticesList({required this.notices});

  final List<Notice> notices;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return RefreshIndicator(
      onRefresh: () =>
          ref.read(noticesControllerProvider.notifier).refresh(),
      child: ListView.separated(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 96),
        itemCount: notices.length,
        separatorBuilder: (_, _) => const SizedBox(height: 8),
        itemBuilder: (context, index) =>
            _NoticeCard(notice: notices[index]),
      ),
    );
  }
}

class _NoticeCard extends ConsumerWidget {
  const _NoticeCard({required this.notice});

  final Notice notice;

  Color _priorityColor(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return switch (notice.priority) {
      NoticePriority.urgent => cs.error,
      NoticePriority.high => Colors.orange,
      NoticePriority.normal => cs.primary,
      NoticePriority.low => cs.onSurfaceVariant,
    };
  }

  Future<void> _confirmDelete(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete notice?'),
        content: Text(
          'Are you sure you want to delete "${notice.title}"? This cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await ref
          .read(noticesControllerProvider.notifier)
          .deleteNotice(notice.id);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Card(
      elevation: notice.isPinned ? 2 : 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: notice.isPinned
              ? cs.primary.withValues(alpha: 0.4)
              : cs.outlineVariant,
        ),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () =>
            context.push(AppRoutes.noticeEdit(notice.id)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  if (notice.isPinned) ...[
                    Icon(Icons.push_pin, size: 14, color: cs.primary),
                    const SizedBox(width: 4),
                  ],
                  Expanded(
                    child: Text(
                      notice.title,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  // Priority badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: _priorityColor(context).withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      notice.priority.label,
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: _priorityColor(context),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete_outline),
                    iconSize: 20,
                    color: cs.error,
                    tooltip: 'Delete',
                    onPressed: () => _confirmDelete(context, ref),
                  ),
                ],
              ),
              if (notice.body.isNotEmpty) ...[
                const SizedBox(height: 6),
                Text(
                  notice.body,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: cs.onSurfaceVariant,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
              if (notice.category.isNotEmpty || notice.remindAt != null) ...[
                const SizedBox(height: 8),
                Wrap(
                  spacing: 6,
                  runSpacing: 4,
                  children: [
                    if (notice.category.isNotEmpty)
                      Chip(
                        label: Text(notice.category),
                        visualDensity: VisualDensity.compact,
                        padding: EdgeInsets.zero,
                        labelStyle: theme.textTheme.labelSmall,
                      ),
                    if (notice.remindAt != null)
                      Chip(
                        avatar: const Icon(Icons.alarm, size: 14),
                        label: Text(_formatDate(notice.remindAt!)),
                        visualDensity: VisualDensity.compact,
                        padding: EdgeInsets.zero,
                        labelStyle: theme.textTheme.labelSmall,
                      ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime dt) {
    return '${dt.day}/${dt.month}/${dt.year} ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  }
}
