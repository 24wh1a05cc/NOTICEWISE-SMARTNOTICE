import 'package:noticewise/features/notices/domain/notice.dart';

/// Contract for the notices data layer.
///
/// All presentation-layer code depends only on this interface —
/// never directly on the SQLite implementation.
abstract interface class NoticeRepository {
  /// Returns all notices ordered by pinned-first, then newest-first.
  Future<List<Notice>> getAll();

  /// Returns a single notice by [id], or null if not found.
  Future<Notice?> getById(String id);

  /// Inserts [notice] and returns it.
  Future<Notice> create(Notice notice);

  /// Updates [notice] and returns it.
  Future<Notice> update(Notice notice);

  /// Deletes the notice with [id].
  Future<void> delete(String id);
}
