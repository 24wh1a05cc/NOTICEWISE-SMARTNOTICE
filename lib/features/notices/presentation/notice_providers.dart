import 'package:noticewise/core/services/database_service.dart';
import 'package:noticewise/core/services/notification_service.dart';
import 'package:noticewise/features/notices/data/sqlite_notice_repository.dart';
import 'package:noticewise/features/notices/domain/notice.dart';
import 'package:noticewise/features/notices/domain/notice_repository.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:uuid/uuid.dart';

part 'notice_providers.g.dart';

// ── Repository provider ────────────────────────────────────────────────────

@Riverpod(keepAlive: true)
NoticeRepository noticeRepository(Ref ref) {
  return SqliteNoticeRepository(DatabaseService.instance);
}

// ── Notices list provider ──────────────────────────────────────────────────

/// Loads all notices from SQLite.
///
/// State: [AsyncValue<List<Notice>>]
///   - [AsyncLoading] while the database query is running
///   - [AsyncData] with the list on success
///   - [AsyncError] if the query fails
@riverpod
class NoticesController extends _$NoticesController {
  @override
  Future<List<Notice>> build() async {
    return ref.read(noticeRepositoryProvider).getAll();
  }

  /// Reloads all notices from the database.
  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(
      () => ref.read(noticeRepositoryProvider).getAll(),
    );
  }

  /// Creates a new notice with [title], [body], and optional fields.
  Future<void> createNotice({
    required String title,
    required String body,
    String category = '',
    NoticePriority priority = NoticePriority.normal,
    bool isPinned = false,
    DateTime? remindAt,
  }) async {
    final now = DateTime.now();
    final notice = Notice(
      id: const Uuid().v4(),
      title: title,
      body: body,
      category: category,
      priority: priority,
      isPinned: isPinned,
      createdAt: now,
      updatedAt: now,
      remindAt: remindAt,
    );

    await ref.read(noticeRepositoryProvider).create(notice);

    // Schedule a local notification if remindAt is set.
    if (remindAt != null) {
      await NotificationService.instance.scheduleNotice(
        noticeId: notice.id,
        title: notice.title,
        body: notice.body,
        remindAt: remindAt,
      );
    }

    await refresh();
  }

  /// Updates an existing notice.
  Future<void> updateNotice(Notice notice) async {
    final updated = notice.copyWith(updatedAt: DateTime.now());
    await ref.read(noticeRepositoryProvider).update(updated);

    // Update notification: cancel old, schedule new if remindAt is set.
    await NotificationService.instance.cancelNotice(notice.id);
    if (updated.remindAt != null) {
      await NotificationService.instance.scheduleNotice(
        noticeId: updated.id,
        title: updated.title,
        body: updated.body,
        remindAt: updated.remindAt!,
      );
    }

    await refresh();
  }

  /// Deletes a notice by [id].
  Future<void> deleteNotice(String id) async {
    await ref.read(noticeRepositoryProvider).delete(id);
    await NotificationService.instance.cancelNotice(id);
    await refresh();
  }
}
