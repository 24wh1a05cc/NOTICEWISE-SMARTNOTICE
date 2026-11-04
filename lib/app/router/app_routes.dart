/// Route path and name constants for the NoticeWise application.
///
/// All GoRoute definitions reference these constants — never use raw
/// string literals for paths or route names.
abstract final class AppRoutes {
  // ── Spec 1 (scaffold) ─────────────────────────────────────────────────────
  static const String splash = '/';
  static const String home = '/home';

  // ── Spec 2 (auth) ─────────────────────────────────────────────────────────
  static const String login = '/login';
  static const String signup = '/signup';
  static const String forgotPassword = '/forgot-password';

  // ── Notices (local SQLite) ────────────────────────────────────────────────
  static const String notices = '/notices';
  static const String noticeCreate = '/notices/new';
  static const String _noticeEditTemplate = '/notices/:noticeId/edit';
  static const String _noticeDetailTemplate = '/notices/:noticeId';

  /// Builds the edit-notice path for a specific [noticeId].
  static String noticeEdit(String noticeId) => '/notices/$noticeId/edit';

  /// Builds the detail-notice path for a specific [noticeId].
  static String noticeDetail(String noticeId) => '/notices/$noticeId';

  // ── Spec 4 (admin) ────────────────────────────────────────────────────────
  static const String adminDashboard = '/admin';
  static const String adminCreateNotice = '/admin/notices/new';
  static const String adminEditNotice = '/admin/notices/:noticeId/edit';

  // ── Calendar ──────────────────────────────────────────────────────────────
  static const String calendar = '/calendar';

  // ── Spec 5 (search) ───────────────────────────────────────────────────────
  static const String search = '/search';

  // ── Spec 6 (notifications) ────────────────────────────────────────────────
  static const String notifications = '/notifications';

  // ── Spec 8 (bookmarks) ────────────────────────────────────────────────────
  static const String bookmarks = '/bookmarks';

  // ── Spec 9 (profile & settings) ───────────────────────────────────────────
  static const String profile = '/profile';
  static const String settings = '/settings';

  // Expose templates for GoRoute path parameter matching
  static String get noticeEditTemplate => _noticeEditTemplate;
  static String get noticeDetailTemplate => _noticeDetailTemplate;
}
