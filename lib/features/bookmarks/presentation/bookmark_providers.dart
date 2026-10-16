import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:noticewise/core/services/database_service.dart';
import 'package:noticewise/features/bookmarks/data/sqlite_bookmark_repository.dart';
import 'package:noticewise/features/bookmarks/domain/bookmark_repository.dart';
import 'package:noticewise/features/notices/domain/notice.dart';
import 'package:noticewise/features/notices/presentation/notice_providers.dart';

// ── Repository provider ────────────────────────────────────────────────────

final bookmarkRepositoryProvider = Provider<BookmarkRepository>((ref) {
  return SqliteBookmarkRepository(DatabaseService.instance);
});

// ── Bookmarked IDs controller ──────────────────────────────────────────────

class _BookmarksNotifier extends AsyncNotifier<List<String>> {
  @override
  Future<List<String>> build() async {
    return ref.read(bookmarkRepositoryProvider).getBookmarkedNoticeIds();
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(
      () => ref.read(bookmarkRepositoryProvider).getBookmarkedNoticeIds(),
    );
  }

  Future<void> toggleBookmark(String noticeId) async {
    final repo = ref.read(bookmarkRepositoryProvider);
    final isBookmarked = await repo.isBookmarked(noticeId);
    if (isBookmarked) {
      await repo.removeBookmark(noticeId);
    } else {
      await repo.addBookmark(noticeId);
    }
    await refresh();
  }
}

final bookmarksControllerProvider =
    AsyncNotifierProvider<_BookmarksNotifier, List<String>>(
  _BookmarksNotifier.new,
);

// ── Bookmarked notices (full Notice objects) ────────────────────────────────

final bookmarkedNoticesProvider = FutureProvider<List<Notice>>((ref) async {
  final ids = await ref.watch(bookmarksControllerProvider.future);
  final repo = ref.read(noticeRepositoryProvider);
  final notices = <Notice>[];
  for (final id in ids) {
    final notice = await repo.getById(id);
    if (notice != null) notices.add(notice);
  }
  return notices;
});

// ── Single notice bookmark state ────────────────────────────────────────────

final isBookmarkedProvider =
    FutureProvider.family<bool, String>((ref, noticeId) async {
  final ids = await ref.watch(bookmarksControllerProvider.future);
  return ids.contains(noticeId);
});
