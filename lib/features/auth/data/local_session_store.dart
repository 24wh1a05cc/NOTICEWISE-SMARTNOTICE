import 'dart:convert';

import 'package:noticewise/core/utils/logger.dart';
import 'package:noticewise/features/auth/domain/app_user.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Persists the current [AppUser] session to [SharedPreferences].
///
/// Only the [AppUser] object (without any password) is stored.
/// Passwords are never written to disk.
///
/// Key: 'noticewise_demo_session'
/// Value: JSON-encoded [AppUser]
class LocalSessionStore {
  static const _key = 'noticewise_demo_session';

  /// Loads and deserialises the persisted [AppUser], or returns null if
  /// no session exists or the stored data is corrupt.
  Future<AppUser?> loadSession() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_key);
      if (raw == null) return null;
      final json = jsonDecode(raw) as Map<String, dynamic>;
      return AppUser.fromJson(json);
    } catch (e) {
      logger.w('[LocalSessionStore] Failed to load session — clearing. $e');
      await clearSession();
      return null;
    }
  }

  /// Serialises and persists [user] to [SharedPreferences].
  Future<void> saveSession(AppUser user) async {
    final prefs = await SharedPreferences.getInstance();
    final json = jsonEncode(user.toJson());
    await prefs.setString(_key, json);
  }

  /// Removes the persisted session.
  Future<void> clearSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }
}
