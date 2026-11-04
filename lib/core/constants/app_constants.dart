/// Application-wide numeric and configuration constants.
///
/// Avoid magic numbers in widget or logic code — reference these instead.
/// Add new constants here as features are built.
abstract final class AppConstants {
  // ── Timeouts ──────────────────────────────────────────────────────────────
  /// Default timeout for network/repository requests (seconds).
  static const int requestTimeoutSeconds = 30;

  /// Timeout for AI/smart-feature requests (seconds).
  static const int aiRequestTimeoutSeconds = 15;

  // ── Notice content limits ─────────────────────────────────────────────────
  static const int maxNoticeTitleLength = 120;
  static const int maxNoticeBodyLength = 10000;
  static const int maxNoticeAttachments = 5;
  static const int maxAttachmentSizeMb = 10;

  // ── Pagination ────────────────────────────────────────────────────────────
  /// Number of notices to fetch per page in the notice feed.
  static const int noticeFeedPageSize = 20;

  /// Number of notifications to fetch per page.
  static const int notificationPageSize = 30;

  // ── Firestore collection names ────────────────────────────────────────────
  static const String colUsers = 'users';
  static const String colNotices = 'notices';
  static const String colCategories = 'categories';
  static const String colBookmarks = 'bookmarks';
  static const String colReadReceipts = 'readReceipts';
  static const String colNotifications = 'notifications';

  // ── User roles ────────────────────────────────────────────────────────────
  /// Role value stored in the Firestore user document.
  /// Must match Firebase Security Rules role checks exactly.
  static const String roleAdmin = 'admin';
  static const String roleUser = 'user';

  // ── Animation durations ───────────────────────────────────────────────────
  static const Duration animFast = Duration(milliseconds: 150);
  static const Duration animNormal = Duration(milliseconds: 300);
  static const Duration animSlow = Duration(milliseconds: 500);

  // ── Layout ────────────────────────────────────────────────────────────────
  static const double cardBorderRadius = 12.0;
  static const double screenHorizontalPadding = 16.0;
  static const double screenVerticalPadding = 16.0;
}
