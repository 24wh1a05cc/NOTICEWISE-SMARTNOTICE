// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_user.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_AppUser _$AppUserFromJson(Map<String, dynamic> json) => _AppUser(
  id: json['id'] as String,
  email: json['email'] as String,
  name: json['name'] as String,
  role: $enumDecode(_$AppUserRoleEnumMap, json['role']),
  createdAt: DateTime.parse(json['createdAt'] as String),
);

Map<String, dynamic> _$AppUserToJson(_AppUser instance) => <String, dynamic>{
  'id': instance.id,
  'email': instance.email,
  'name': instance.name,
  'role': _$AppUserRoleEnumMap[instance.role]!,
  'createdAt': instance.createdAt.toIso8601String(),
};

const _$AppUserRoleEnumMap = {
  AppUserRole.admin: 'admin',
  AppUserRole.viewer: 'viewer',
};
