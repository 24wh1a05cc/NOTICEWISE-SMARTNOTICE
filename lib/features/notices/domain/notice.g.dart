// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'notice.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Notice _$NoticeFromJson(Map<String, dynamic> json) => _Notice(
  id: json['id'] as String,
  title: json['title'] as String,
  body: json['body'] as String,
  category: json['category'] as String? ?? '',
  priority:
      $enumDecodeNullable(_$NoticePriorityEnumMap, json['priority']) ??
      NoticePriority.normal,
  isPinned: json['isPinned'] as bool? ?? false,
  createdAt: DateTime.parse(json['createdAt'] as String),
  updatedAt: DateTime.parse(json['updatedAt'] as String),
  remindAt: json['remindAt'] == null
      ? null
      : DateTime.parse(json['remindAt'] as String),
  status:
      $enumDecodeNullable(_$NoticeStatusEnumMap, json['status']) ??
      NoticeStatus.draft,
  authorName: json['authorName'] as String? ?? '',
  publishAt: json['publishAt'] == null
      ? null
      : DateTime.parse(json['publishAt'] as String),
  expiresAt: json['expiresAt'] == null
      ? null
      : DateTime.parse(json['expiresAt'] as String),
);

Map<String, dynamic> _$NoticeToJson(_Notice instance) => <String, dynamic>{
  'id': instance.id,
  'title': instance.title,
  'body': instance.body,
  'category': instance.category,
  'priority': _$NoticePriorityEnumMap[instance.priority]!,
  'isPinned': instance.isPinned,
  'createdAt': instance.createdAt.toIso8601String(),
  'updatedAt': instance.updatedAt.toIso8601String(),
  'remindAt': instance.remindAt?.toIso8601String(),
  'status': _$NoticeStatusEnumMap[instance.status]!,
  'authorName': instance.authorName,
  'publishAt': instance.publishAt?.toIso8601String(),
  'expiresAt': instance.expiresAt?.toIso8601String(),
};

const _$NoticePriorityEnumMap = {
  NoticePriority.low: 'low',
  NoticePriority.normal: 'normal',
  NoticePriority.high: 'high',
  NoticePriority.urgent: 'urgent',
};

const _$NoticeStatusEnumMap = {
  NoticeStatus.draft: 'draft',
  NoticeStatus.published: 'published',
  NoticeStatus.scheduled: 'scheduled',
};
