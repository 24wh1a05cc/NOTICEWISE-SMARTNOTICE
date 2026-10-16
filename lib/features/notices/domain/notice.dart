import 'package:freezed_annotation/freezed_annotation.dart';

part 'notice.freezed.dart';
part 'notice.g.dart';

/// Priority levels for a notice.
enum NoticePriority {
  low,
  normal,
  high,
  urgent;

  String get label => switch (this) {
        NoticePriority.low => 'Low',
        NoticePriority.normal => 'Normal',
        NoticePriority.high => 'High',
        NoticePriority.urgent => 'Urgent',
      };
}

/// Publication status for a notice.
enum NoticeStatus {
  draft,
  published,
  scheduled;

  String get label => switch (this) {
        NoticeStatus.draft => 'Draft',
        NoticeStatus.published => 'Published',
        NoticeStatus.scheduled => 'Scheduled',
      };
}

/// Immutable notice model stored locally via SQLite.
@freezed
abstract class Notice with _$Notice {
  const factory Notice({
    required String id,
    required String title,
    required String body,
    @Default('') String category,
    @Default(NoticePriority.normal) NoticePriority priority,
    @Default(false) bool isPinned,
    required DateTime createdAt,
    required DateTime updatedAt,
    DateTime? remindAt,
    @Default(NoticeStatus.draft) NoticeStatus status,
    @Default('') String authorName,
    DateTime? publishAt,
    DateTime? expiresAt,
  }) = _Notice;

  factory Notice.fromJson(Map<String, dynamic> json) => _$NoticeFromJson(json);
}
