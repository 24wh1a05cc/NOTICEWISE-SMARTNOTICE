import 'package:flutter/material.dart';

/// Semantic color constants for the NoticeWise brand.
///
/// ⚠️  Do NOT use these constants directly in widgets.
///     Always use [Theme.of(context).colorScheme.*] in widget code.
///     These constants are only used here in [AppTheme] to seed the
///     Material 3 [ColorScheme].
abstract final class AppColors {
  // ── Brand ─────────────────────────────────────────────────────────────────
  /// Primary institutional blue. Used as the Material 3 seed color.
  static const Color brandBlue = Color(0xFF1565C0);

  /// Lighter variant used for subtle accents.
  static const Color brandBlueSurface = Color(0xFFE3F2FD);

  // ── Notice priority indicators ────────────────────────────────────────────
  /// Colour for normal-priority notices (informational).
  static const Color priorityNormal = Color(0xFF1976D2); // blue

  /// Colour for important-priority notices.
  static const Color priorityImportant = Color(0xFFF57C00); // orange

  /// Colour for urgent-priority notices.
  static const Color priorityUrgent = Color(0xFFD32F2F); // red

  // ── Status indicators ─────────────────────────────────────────────────────
  static const Color statusSuccess = Color(0xFF388E3C);
  static const Color statusWarning = Color(0xFFF9A825);
  static const Color statusError = Color(0xFFD32F2F);
  static const Color statusInfo = Color(0xFF0288D1);

  // ── Unread badge ──────────────────────────────────────────────────────────
  static const Color unreadDot = Color(0xFF1565C0);
}
