import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' as p;

/// Singleton that owns the SQLite [Database] connection.
///
/// All repository implementations obtain the database through this service
/// rather than opening their own connections.
class DatabaseService {
  DatabaseService._();
  static final DatabaseService instance = DatabaseService._();

  Database? _db;

  /// Returns the open [Database], opening it on first call.
  Future<Database> get database async {
    _db ??= await _open();
    return _db!;
  }

  static const _dbName = 'noticewise.db';
  static const _dbVersion = 2;

  Future<Database> _open() async {
    final dbPath = await getDatabasesPath();
    final path = p.join(dbPath, _dbName);

    return openDatabase(
      path,
      version: _dbVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE notices (
        id          TEXT    PRIMARY KEY,
        title       TEXT    NOT NULL,
        body        TEXT    NOT NULL,
        category    TEXT    NOT NULL DEFAULT '',
        priority    INTEGER NOT NULL DEFAULT 0,
        is_pinned   INTEGER NOT NULL DEFAULT 0,
        created_at  TEXT    NOT NULL,
        updated_at  TEXT    NOT NULL,
        remind_at   TEXT,
        status      INTEGER NOT NULL DEFAULT 0,
        author_name TEXT    NOT NULL DEFAULT '',
        publish_at  TEXT,
        expires_at  TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE bookmarks (
        id            TEXT PRIMARY KEY,
        notice_id     TEXT NOT NULL UNIQUE,
        bookmarked_at TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE seed_done (
        id   INTEGER PRIMARY KEY DEFAULT 1,
        done INTEGER NOT NULL DEFAULT 0
      )
    ''');
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      // Add new columns to notices table
      await db.execute(
        'ALTER TABLE notices ADD COLUMN status INTEGER NOT NULL DEFAULT 0',
      );
      await db.execute(
        'ALTER TABLE notices ADD COLUMN author_name TEXT NOT NULL DEFAULT \'\'',
      );
      await db.execute('ALTER TABLE notices ADD COLUMN publish_at TEXT');
      await db.execute('ALTER TABLE notices ADD COLUMN expires_at TEXT');

      // Create bookmarks table
      await db.execute('''
        CREATE TABLE IF NOT EXISTS bookmarks (
          id            TEXT PRIMARY KEY,
          notice_id     TEXT NOT NULL UNIQUE,
          bookmarked_at TEXT NOT NULL
        )
      ''');

      // Create seed_done table
      await db.execute('''
        CREATE TABLE IF NOT EXISTS seed_done (
          id   INTEGER PRIMARY KEY DEFAULT 1,
          done INTEGER NOT NULL DEFAULT 0
        )
      ''');
    }
  }

  /// Closes the database. Useful in tests.
  Future<void> close() async {
    await _db?.close();
    _db = null;
  }
}
