import 'package:freezed_annotation/freezed_annotation.dart';

part 'app_user.freezed.dart';
part 'app_user.g.dart';

/// Roles a user can hold in NoticeWise.
///
/// Admin accounts are seeded in [MockAuthRepository] and cannot be
/// self-assigned by clients. Sign-up always produces [AppUserRole.viewer].
enum AppUserRole {
  admin,
  viewer;

  /// Convenience getter — avoids raw enum comparisons in widget/logic code.
  bool get isAdmin => this == AppUserRole.admin;

  /// Human-readable label used in the UI.
  String get label => switch (this) {
        AppUserRole.admin => 'Admin',
        AppUserRole.viewer => 'Viewer',
      };
}

/// Immutable representation of a signed-in user.
///
/// Shared across the entire app. The presentation and domain layers only
/// ever hold [AppUser] — they have no knowledge of Firebase [User] objects
/// or any platform-specific user types.
@freezed
abstract class AppUser with _$AppUser {
  const factory AppUser({
    required String id,
    required String email,
    required String name,
    required AppUserRole role,
    required DateTime createdAt,
  }) = _AppUser;

  factory AppUser.fromJson(Map<String, dynamic> json) =>
      _$AppUserFromJson(json);
}
