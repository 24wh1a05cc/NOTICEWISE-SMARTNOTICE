/// Contract for the bookmarks data layer.
///
/// All presentation-layer code depends only on this interface —
/// never directly on the SQLite implementation.
abstract interface class BookmarkRepository {
  /// Returns all bookmarked notice IDs.
  Future<List<String>> getBookmarkedNoticeIds();

  /// Adds a bookmark for [noticeId].
  Future<void> addBookmark(String noticeId);

  /// Removes the bookmark for [noticeId].
  Future<void> removeBookmark(String noticeId);

  /// Returns true if [noticeId] is bookmarked.
  Future<bool> isBookmarked(String noticeId);
}
