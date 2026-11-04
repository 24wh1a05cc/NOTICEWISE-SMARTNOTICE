import 'package:noticewise/core/services/database_service.dart';
import 'package:noticewise/features/bookmarks/domain/bookmark_repository.dart';
import 'package:sqflite/sqflite.dart';
import 'package:uuid/uuid.dart';

/// SQLite-backed implementation of [BookmarkRepository].
class SqliteBookmarkRepository implements BookmarkRepository {
  SqliteBookmarkRepository(this._db);

  final DatabaseService _db;
  final _uuid = const Uuid();

  @override
  Future<List<String>> getBookmarkedNoticeIds() async {
    final db = await _db.database;
    final rows = await db.query(
      'bookmarks',
      columns: ['notice_id'],
      orderBy: 'bookmarked_at DESC',
    );
    return rows.map((r) => r['notice_id'] as String).toList();
  }

  @override
  Future<void> addBookmark(String noticeId) async {
    final db = await _db.database;
    await db.insert(
      'bookmarks',
      {
        'id': _uuid.v4(),
        'notice_id': noticeId,
        'bookmarked_at': DateTime.now().toIso8601String(),
      },
      conflictAlgorithm: ConflictAlgorithm.ignore,
    );
  }

  @override
  Future<void> removeBookmark(String noticeId) async {
    final db = await _db.database;
    await db.delete(
      'bookmarks',
      where: 'notice_id = ?',
      whereArgs: [noticeId],
    );
  }

  @override
  Future<bool> isBookmarked(String noticeId) async {
    final db = await _db.database;
    final rows = await db.query(
      'bookmarks',
      where: 'notice_id = ?',
      whereArgs: [noticeId],
      limit: 1,
    );
    return rows.isNotEmpty;
  }
}
