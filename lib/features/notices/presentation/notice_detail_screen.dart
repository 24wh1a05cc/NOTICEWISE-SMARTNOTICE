import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:noticewise/app/router/app_routes.dart';
import 'package:noticewise/features/auth/domain/app_user.dart';
import 'package:noticewise/features/auth/presentation/providers/auth_controller.dart';
import 'package:noticewise/features/bookmarks/presentation/bookmark_providers.dart';
import 'package:noticewise/features/notices/domain/notice.dart';
import 'package:noticewise/features/notices/presentation/notice_providers.dart';

/// Provider family to fetch a single notice by ID.
final noticeByIdProvider =
    FutureProvider.family<Notice?, String>((ref, id) async {
  return ref.read(noticeRepositoryProvider).getById(id);
});

/// Full-detail view for a single notice.
class NoticeDetailScreen extends ConsumerWidget {
  const NoticeDetailScreen({super.key, required this.noticeId});

  final String noticeId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final noticeAsync = ref.watch(noticeByIdProvider(noticeId));

    return noticeAsync.when(
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (e, _) => Scaffold(
        appBar: AppBar(title: const Text('Notice')),
        body: Center(child: Text('Error: $e')),
      ),
      data: (notice) {
        if (notice == null) {
          return Scaffold(
            appBar: AppBar(title: const Text('Notice')),
            body: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.article_outlined,
                    size: 64,
                    color: Theme.of(context)
                        .colorScheme
                        .onSurfaceVariant
                        .withValues(alpha: 0.4),
                  ),
                  const SizedBox(height: 16),
                  const Text('Notice not found'),
                ],
              ),
            ),
          );
        }
        return _NoticeDetailBody(notice: notice);
      },
    );
  }
}

class _NoticeDetailBody extends ConsumerWidget {
  const _NoticeDetailBody({required this.notice});

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
    final bookmarkIds = ref.watch(bookmarksControllerProvider);
    final authState = ref.watch(authControllerProvider);
    final user = authState.asData?.value;
    final isAdmin = user?.role == AppUserRole.admin;

    final isBookmarked =
        bookmarkIds.asData?.value.contains(notice.id) ?? false;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notice Detail'),
        actions: [
          IconButton(
            icon: Icon(
              isBookmarked ? Icons.bookmark : Icons.bookmark_outline,
              color: isBookmarked ? cs.primary : null,
            ),
            tooltip: isBookmarked ? 'Remove bookmark' : 'Bookmark',
            onPressed: () {
              ref
                  .read(bookmarksControllerProvider.notifier)
                  .toggleBookmark(notice.id);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                      isBookmarked ? 'Bookmark removed' : 'Bookmarked!'),
                  duration: const Duration(seconds: 1),
                ),
              );
            },
          ),
          if (isAdmin)
            IconButton(
              icon: const Icon(Icons.edit_outlined),
              tooltip: 'Edit',
              onPressed: () =>
                  context.push(AppRoutes.noticeEdit(notice.id)),
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Badges ──────────────────────────────────────────────────
            Wrap(
              spacing: 8,
              runSpacing: 6,
              children: [
                _Badge(
                  label: notice.priority.label,
                  color: _priorityColor(context),
                ),
                _Badge(
                  label: notice.status.label,
                  color: switch (notice.status) {
                    NoticeStatus.published => Colors.green.shade600,
                    NoticeStatus.draft => cs.outline,
                    NoticeStatus.scheduled => cs.secondary,
                  },
                ),
                if (notice.isPinned)
                  _Badge(
                    label: 'Pinned',
                    color: cs.primary,
                    icon: Icons.push_pin,
                  ),
                if (notice.category.isNotEmpty)
                  _Badge(
                    label: notice.category,
                    color: cs.secondary,
                  ),
              ],
            ),
            const SizedBox(height: 16),

            // ── Title ────────────────────────────────────────────────────
            Text(
              notice.title,
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),

            // ── Meta ─────────────────────────────────────────────────────
            _MetaRow(notice: notice),
            const SizedBox(height: 20),
            const Divider(),
            const SizedBox(height: 16),

            // ── Body ─────────────────────────────────────────────────────
            Text(
              notice.body,
              style: theme.textTheme.bodyLarge?.copyWith(height: 1.7),
            ),

            if (notice.expiresAt != null) ...[
              const SizedBox(height: 24),
              const Divider(),
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(Icons.event_busy_outlined,
                      size: 16, color: cs.onSurfaceVariant),
                  const SizedBox(width: 6),
                  Text(
                    'Expires: ${_fmtDate(notice.expiresAt!)}',
                    style: theme.textTheme.bodySmall
                        ?.copyWith(color: cs.onSurfaceVariant),
                  ),
                ],
              ),
            ],

            if (notice.remindAt != null) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.alarm_outlined, size: 16, color: cs.primary),
                  const SizedBox(width: 6),
                  Text(
                    'Reminder: ${_fmtDate(notice.remindAt!)}',
                    style: theme.textTheme.bodySmall
                        ?.copyWith(color: cs.primary),
                  ),
                ],
              ),
            ],

            if (isAdmin) ...[
              const SizedBox(height: 32),
              _AdminActions(notice: notice),
            ],
          ],
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

class _MetaRow extends StatelessWidget {
  const _MetaRow({required this.notice});
  final Notice notice;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final textStyle = Theme.of(context)
        .textTheme
        .bodySmall
        ?.copyWith(color: cs.onSurfaceVariant);

    return Wrap(
      spacing: 16,
      runSpacing: 4,
      children: [
        if (notice.authorName.isNotEmpty)
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.person_outline, size: 14, color: cs.onSurfaceVariant),
              const SizedBox(width: 4),
              Text(notice.authorName, style: textStyle),
            ],
          ),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.calendar_today_outlined,
                size: 14, color: cs.onSurfaceVariant),
            const SizedBox(width: 4),
            Text(_fmtDate(notice.createdAt), style: textStyle),
          ],
        ),
        if (notice.publishAt != null)
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.publish_outlined,
                  size: 14, color: cs.onSurfaceVariant),
              const SizedBox(width: 4),
              Text('Published ${_fmtDate(notice.publishAt!)}',
                  style: textStyle),
            ],
          ),
      ],
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

class _Badge extends StatelessWidget {
  const _Badge({required this.label, required this.color, this.icon});

  final String label;
  final Color color;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 12, color: color),
            const SizedBox(width: 4),
          ],
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _AdminActions extends ConsumerWidget {
  const _AdminActions({required this.notice});

  final Notice notice;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;

    Future<void> togglePublish() async {
      final newStatus = notice.status == NoticeStatus.published
          ? NoticeStatus.draft
          : NoticeStatus.published;
      final updated = notice.copyWith(
        status: newStatus,
        publishAt:
            newStatus == NoticeStatus.published ? DateTime.now() : null,
        updatedAt: DateTime.now(),
      );
      await ref
          .read(noticesControllerProvider.notifier)
          .updateNotice(updated);
      // Invalidate the detail provider so it refreshes
      ref.invalidate(noticeByIdProvider(notice.id));
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(newStatus == NoticeStatus.published
                ? 'Notice published'
                : 'Notice unpublished (draft)'),
          ),
        );
      }
    }

    Future<void> deleteNotice() async {
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Delete notice?'),
          content: Text(
              'Delete "${notice.title}"? This cannot be undone.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              style: FilledButton.styleFrom(backgroundColor: cs.error),
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Delete'),
            ),
          ],
        ),
      );
      if (confirmed == true && context.mounted) {
        await ref
            .read(noticesControllerProvider.notifier)
            .deleteNotice(notice.id);
        if (context.mounted) context.pop();
      }
    }

    final isPublished = notice.status == NoticeStatus.published;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Admin Actions',
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
                color: cs.onSurfaceVariant,
              ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: FilledButton.tonalIcon(
                onPressed: () =>
                    context.push(AppRoutes.noticeEdit(notice.id)),
                icon: const Icon(Icons.edit_outlined),
                label: const Text('Edit'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: FilledButton.tonalIcon(
                onPressed: togglePublish,
                icon: Icon(isPublished
                    ? Icons.unpublished_outlined
                    : Icons.publish_outlined),
                label: Text(isPublished ? 'Unpublish' : 'Publish'),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        OutlinedButton.icon(
          style: OutlinedButton.styleFrom(foregroundColor: cs.error),
          onPressed: deleteNotice,
          icon: const Icon(Icons.delete_outline),
          label: const Text('Delete Notice'),
        ),
      ],
    );
  }
}
