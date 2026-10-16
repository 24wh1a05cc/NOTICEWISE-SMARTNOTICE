// TODO(i18n): Replace string constants with ARB-based flutter_localizations
// if multi-language support is required. All user-visible text must live here —
// never use raw string literals for UI text in widget code.

/// Centralised string constants for the NoticeWise application.
///
/// Organised into nested abstract classes by screen/domain area.
/// Add new constants to the appropriate section as screens are built.
abstract final class AppStrings {
  // ── App identity ──────────────────────────────────────────────────────────
  static const String appName = 'NoticeWise';
  static const String appTagline = 'Smart Notice Management';

  // ── Generic actions ───────────────────────────────────────────────────────
  static const String actionRetry = 'Retry';
  static const String actionCancel = 'Cancel';
  static const String actionConfirm = 'Confirm';
  static const String actionSave = 'Save';
  static const String actionDelete = 'Delete';
  static const String actionEdit = 'Edit';
  static const String actionClose = 'Close';
  static const String actionBack = 'Back';
  static const String actionSearch = 'Search';
  static const String actionClearFilters = 'Clear Filters';
  static const String actionLoadMore = 'Load More';
  static const String actionBookmark = 'Bookmark';
  static const String actionRemoveBookmark = 'Remove Bookmark';

  // ── Generic states ────────────────────────────────────────────────────────
  static const String stateLoading = 'Loading…';
  static const String stateEmpty = 'Nothing here yet.';
  static const String stateNoResults = 'No results found.';
  static const String stateOffline =
      'You appear to be offline. Showing cached content.';

  // ── Error messages ────────────────────────────────────────────────────────
  static const String errorGeneric =
      'An unexpected error occurred. Please try again.';
  static const String errorNetwork =
      'A network error occurred. Please check your connection.';
  static const String errorUnauthorised =
      'You do not have permission to perform this action.';
  static const String errorNotFound = 'The requested resource was not found.';
  static const String errorLoadFailed = 'Failed to load content. Tap to retry.';
  static const String errorSaveFailed =
      'Failed to save changes. Please try again.';
  static const String errorDeleteFailed = 'Failed to delete. Please try again.';

  // ── Authentication (Spec 2) ───────────────────────────────────────────────
  static const String authSignIn = 'Sign In';
  static const String authSignUp = 'Sign Up';
  static const String authSignOut = 'Sign Out';
  static const String authForgotPassword = 'Forgot Password?';
  static const String authEmailLabel = 'Email address';
  static const String authPasswordLabel = 'Password';
  static const String authNameLabel = 'Full name';
  static const String authSigningIn = 'Signing in…';
  static const String authSigningUp = 'Creating account…';

  // ── Notices (Spec 3) ──────────────────────────────────────────────────────
  static const String noticesTitle = 'Notices';
  static const String noticeDetailTitle = 'Notice Detail';
  static const String noticesEmpty = 'No notices to display.';
  static const String noticeMarkAsRead = 'Mark as Read';
  static const String noticeUnread = 'Unread';
  static const String noticePriorityNormal = 'Normal';
  static const String noticePriorityImportant = 'Important';
  static const String noticePriorityUrgent = 'Urgent';

  // ── Admin (Spec 4) ────────────────────────────────────────────────────────
  static const String adminTitle = 'Admin Dashboard';
  static const String adminCreateNotice = 'New Notice';
  static const String adminEditNotice = 'Edit Notice';
  static const String adminDeleteConfirm =
      'Are you sure you want to delete this notice? This cannot be undone.';
  static const String adminPublish = 'Publish';
  static const String adminSaveDraft = 'Save as Draft';
  static const String adminSchedule = 'Schedule';

  // ── Search (Spec 5) ───────────────────────────────────────────────────────
  static const String searchHint = 'Search notices…';
  static const String searchTitle = 'Search';
  static const String searchFilters = 'Filters';

  // ── Notifications (Spec 6) ────────────────────────────────────────────────
  static const String notificationsTitle = 'Notifications';
  static const String notificationsEmpty = 'No notifications yet.';
  static const String notificationsPermissionTitle = 'Enable Notifications';
  static const String notificationsPermissionBody =
      'Allow NoticeWise to send you alerts for new and urgent notices.';

  // ── Profile & Settings (Spec 9) ───────────────────────────────────────────
  static const String profileTitle = 'Profile';
  static const String settingsTitle = 'Settings';
  static const String settingsThemeSystem = 'System default';
  static const String settingsThemeLight = 'Light';
  static const String settingsThemeDark = 'Dark';

  // ── Smart Features (Spec 7) ───────────────────────────────────────────────
  static const String smartSummarise = 'Summarise';
  static const String smartSummarising = 'Summarising…';
  static const String smartSummaryUnavailable =
      'Summary unavailable. Please read the full notice.';
  static const String smartExtractDates = 'Extract Dates & Deadlines';
}
