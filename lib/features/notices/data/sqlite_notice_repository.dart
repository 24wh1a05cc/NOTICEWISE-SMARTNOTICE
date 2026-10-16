import 'package:noticewise/core/services/database_service.dart';
import 'package:noticewise/features/notices/domain/notice.dart';
import 'package:noticewise/features/notices/domain/notice_repository.dart';

/// SQLite-backed implementation of [NoticeRepository].
class SqliteNoticeRepository implements NoticeRepository {
  SqliteNoticeRepository(this._db);

  final DatabaseService _db;

  static Notice _fromRow(Map<String, dynamic> row) {
    return Notice(
      id: row['id'] as String,
      title: row['title'] as String,
      body: row['body'] as String,
      category: row['category'] as String? ?? '',
      priority: NoticePriority.values[row['priority'] as int],
      isPinned: (row['is_pinned'] as int) == 1,
      createdAt: DateTime.parse(row['created_at'] as String),
      updatedAt: DateTime.parse(row['updated_at'] as String),
      remindAt: row['remind_at'] != null
          ? DateTime.parse(row['remind_at'] as String)
          : null,
      status: NoticeStatus.values[row['status'] as int? ?? 0],
      authorName: row['author_name'] as String? ?? '',
      publishAt: row['publish_at'] != null
          ? DateTime.parse(row['publish_at'] as String)
          : null,
      expiresAt: row['expires_at'] != null
          ? DateTime.parse(row['expires_at'] as String)
          : null,
    );
  }

  static Map<String, dynamic> _toRow(Notice n) => {
        'id': n.id,
        'title': n.title,
        'body': n.body,
        'category': n.category,
        'priority': n.priority.index,
        'is_pinned': n.isPinned ? 1 : 0,
        'created_at': n.createdAt.toIso8601String(),
        'updated_at': n.updatedAt.toIso8601String(),
        'remind_at': n.remindAt?.toIso8601String(),
        'status': n.status.index,
        'author_name': n.authorName,
        'publish_at': n.publishAt?.toIso8601String(),
        'expires_at': n.expiresAt?.toIso8601String(),
      };

  @override
  Future<List<Notice>> getAll() async {
    final db = await _db.database;
    final rows = await db.query(
      'notices',
      orderBy: 'is_pinned DESC, created_at DESC',
    );
    return rows.map(_fromRow).toList();
  }

  @override
  Future<Notice?> getById(String id) async {
    final db = await _db.database;
    final rows = await db.query(
      'notices',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (rows.isEmpty) return null;
    return _fromRow(rows.first);
  }

  @override
  Future<Notice> create(Notice notice) async {
    final db = await _db.database;
    await db.insert('notices', _toRow(notice));
    return notice;
  }

  @override
  Future<Notice> update(Notice notice) async {
    final db = await _db.database;
    await db.update(
      'notices',
      _toRow(notice),
      where: 'id = ?',
      whereArgs: [notice.id],
    );
    return notice;
  }

  @override
  Future<void> delete(String id) async {
    final db = await _db.database;
    await db.delete('notices', where: 'id = ?', whereArgs: [id]);
  }

  /// Returns all published notices only.
  Future<List<Notice>> getPublished() async {
    final db = await _db.database;
    final now = DateTime.now().toIso8601String();
    final rows = await db.query(
      'notices',
      where: 'status = ? AND (expires_at IS NULL OR expires_at > ?)',
      whereArgs: [NoticeStatus.published.index, now],
      orderBy: 'is_pinned DESC, created_at DESC',
    );
    return rows.map(_fromRow).toList();
  }
}
