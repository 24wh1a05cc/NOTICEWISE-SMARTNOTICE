// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'notice.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Notice {

 String get id; String get title; String get body; String get category; NoticePriority get priority; bool get isPinned; DateTime get createdAt; DateTime get updatedAt; DateTime? get remindAt; NoticeStatus get status; String get authorName; DateTime? get publishAt; DateTime? get expiresAt;
/// Create a copy of Notice
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$NoticeCopyWith<Notice> get copyWith => _$NoticeCopyWithImpl<Notice>(this as Notice, _$identity);

  /// Serializes this Notice to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as Notice;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Notice&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.title, _this.title) || other.title == _this.title)&&(identical(other.body, _this.body) || other.body == _this.body)&&(identical(other.category, _this.category) || other.category == _this.category)&&(identical(other.priority, _this.priority) || other.priority == _this.priority)&&(identical(other.isPinned, _this.isPinned) || other.isPinned == _this.isPinned)&&(identical(other.createdAt, _this.createdAt) || other.createdAt == _this.createdAt)&&(identical(other.updatedAt, _this.updatedAt) || other.updatedAt == _this.updatedAt)&&(identical(other.remindAt, _this.remindAt) || other.remindAt == _this.remindAt)&&(identical(other.status, _this.status) || other.status == _this.status)&&(identical(other.authorName, _this.authorName) || other.authorName == _this.authorName)&&(identical(other.publishAt, _this.publishAt) || other.publishAt == _this.publishAt)&&(identical(other.expiresAt, _this.expiresAt) || other.expiresAt == _this.expiresAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as Notice;
  return Object.hash(runtimeType,_this.id,_this.title,_this.body,_this.category,_this.priority,_this.isPinned,_this.createdAt,_this.updatedAt,_this.remindAt,_this.status,_this.authorName,_this.publishAt,_this.expiresAt);
}

@override
String toString() {
  final _this = this as Notice;
  return 'Notice(id: ${_this.id}, title: ${_this.title}, body: ${_this.body}, category: ${_this.category}, priority: ${_this.priority}, isPinned: ${_this.isPinned}, createdAt: ${_this.createdAt}, updatedAt: ${_this.updatedAt}, remindAt: ${_this.remindAt}, status: ${_this.status}, authorName: ${_this.authorName}, publishAt: ${_this.publishAt}, expiresAt: ${_this.expiresAt})';
}


}

/// @nodoc
abstract mixin class $NoticeCopyWith<$Res>  {
  factory $NoticeCopyWith(Notice value, $Res Function(Notice) _then) = _$NoticeCopyWithImpl;
@useResult
$Res call({
 String id, String title, String body, String category, NoticePriority priority, bool isPinned, DateTime createdAt, DateTime updatedAt, DateTime? remindAt, NoticeStatus status, String authorName, DateTime? publishAt, DateTime? expiresAt
});




}
/// @nodoc
class _$NoticeCopyWithImpl<$Res>
    implements $NoticeCopyWith<$Res> {
  _$NoticeCopyWithImpl(this._self, this._then);

  final Notice _self;
  final $Res Function(Notice) _then;

/// Create a copy of Notice
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? title = null,Object? body = null,Object? category = null,Object? priority = null,Object? isPinned = null,Object? createdAt = null,Object? updatedAt = null,Object? remindAt = freezed,Object? status = null,Object? authorName = null,Object? publishAt = freezed,Object? expiresAt = freezed,}) {
  return _then(Notice(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,body: null == body ? _self.body : body // ignore: cast_nullable_to_non_nullable
as String,category: null == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as String,priority: null == priority ? _self.priority : priority // ignore: cast_nullable_to_non_nullable
as NoticePriority,isPinned: null == isPinned ? _self.isPinned : isPinned // ignore: cast_nullable_to_non_nullable
as bool,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,remindAt: freezed == remindAt ? _self.remindAt : remindAt // ignore: cast_nullable_to_non_nullable
as DateTime?,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as NoticeStatus,authorName: null == authorName ? _self.authorName : authorName // ignore: cast_nullable_to_non_nullable
as String,publishAt: freezed == publishAt ? _self.publishAt : publishAt // ignore: cast_nullable_to_non_nullable
as DateTime?,expiresAt: freezed == expiresAt ? _self.expiresAt : expiresAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [Notice].
extension NoticePatterns on Notice {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Notice value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Notice() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Notice value)  $default,){
final _that = this;
switch (_that) {
case _Notice():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Notice value)?  $default,){
final _that = this;
switch (_that) {
case _Notice() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String title,  String body,  String category,  NoticePriority priority,  bool isPinned,  DateTime createdAt,  DateTime updatedAt,  DateTime? remindAt,  NoticeStatus status,  String authorName,  DateTime? publishAt,  DateTime? expiresAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Notice() when $default != null:
return $default(_that.id,_that.title,_that.body,_that.category,_that.priority,_that.isPinned,_that.createdAt,_that.updatedAt,_that.remindAt,_that.status,_that.authorName,_that.publishAt,_that.expiresAt);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String title,  String body,  String category,  NoticePriority priority,  bool isPinned,  DateTime createdAt,  DateTime updatedAt,  DateTime? remindAt,  NoticeStatus status,  String authorName,  DateTime? publishAt,  DateTime? expiresAt)  $default,) {final _that = this;
switch (_that) {
case _Notice():
return $default(_that.id,_that.title,_that.body,_that.category,_that.priority,_that.isPinned,_that.createdAt,_that.updatedAt,_that.remindAt,_that.status,_that.authorName,_that.publishAt,_that.expiresAt);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String title,  String body,  String category,  NoticePriority priority,  bool isPinned,  DateTime createdAt,  DateTime updatedAt,  DateTime? remindAt,  NoticeStatus status,  String authorName,  DateTime? publishAt,  DateTime? expiresAt)?  $default,) {final _that = this;
switch (_that) {
case _Notice() when $default != null:
return $default(_that.id,_that.title,_that.body,_that.category,_that.priority,_that.isPinned,_that.createdAt,_that.updatedAt,_that.remindAt,_that.status,_that.authorName,_that.publishAt,_that.expiresAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Notice implements Notice {
  const _Notice({required this.id, required this.title, required this.body, this.category = '', this.priority = NoticePriority.normal, this.isPinned = false, required this.createdAt, required this.updatedAt, this.remindAt, this.status = NoticeStatus.draft, this.authorName = '', this.publishAt, this.expiresAt});
  factory _Notice.fromJson(Map<String, dynamic> json) => _$NoticeFromJson(json);

@override final  String id;
@override final  String title;
@override final  String body;
@override@JsonKey() final  String category;
@override@JsonKey() final  NoticePriority priority;
@override@JsonKey() final  bool isPinned;
@override final  DateTime createdAt;
@override final  DateTime updatedAt;
@override final  DateTime? remindAt;
@override@JsonKey() final  NoticeStatus status;
@override@JsonKey() final  String authorName;
@override final  DateTime? publishAt;
@override final  DateTime? expiresAt;

/// Create a copy of Notice
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$NoticeCopyWith<_Notice> get copyWith => __$NoticeCopyWithImpl<_Notice>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$NoticeToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _Notice&&(identical(other.id, id) || other.id == id)&&(identical(other.title, title) || other.title == title)&&(identical(other.body, body) || other.body == body)&&(identical(other.category, category) || other.category == category)&&(identical(other.priority, priority) || other.priority == priority)&&(identical(other.isPinned, isPinned) || other.isPinned == isPinned)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.remindAt, remindAt) || other.remindAt == remindAt)&&(identical(other.status, status) || other.status == status)&&(identical(other.authorName, authorName) || other.authorName == authorName)&&(identical(other.publishAt, publishAt) || other.publishAt == publishAt)&&(identical(other.expiresAt, expiresAt) || other.expiresAt == expiresAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,id,title,body,category,priority,isPinned,createdAt,updatedAt,remindAt,status,authorName,publishAt,expiresAt);
}

@override
String toString() {
    return 'Notice(id: $id, title: $title, body: $body, category: $category, priority: $priority, isPinned: $isPinned, createdAt: $createdAt, updatedAt: $updatedAt, remindAt: $remindAt, status: $status, authorName: $authorName, publishAt: $publishAt, expiresAt: $expiresAt)';
}


}

/// @nodoc
abstract mixin class _$NoticeCopyWith<$Res> implements $NoticeCopyWith<$Res> {
  factory _$NoticeCopyWith(_Notice value, $Res Function(_Notice) _then) = __$NoticeCopyWithImpl;
@override @useResult
$Res call({
 String id, String title, String body, String category, NoticePriority priority, bool isPinned, DateTime createdAt, DateTime updatedAt, DateTime? remindAt, NoticeStatus status, String authorName, DateTime? publishAt, DateTime? expiresAt
});




}
/// @nodoc
class __$NoticeCopyWithImpl<$Res>
    implements _$NoticeCopyWith<$Res> {
  __$NoticeCopyWithImpl(this._self, this._then);

  final _Notice _self;
  final $Res Function(_Notice) _then;

/// Create a copy of Notice
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? title = null,Object? body = null,Object? category = null,Object? priority = null,Object? isPinned = null,Object? createdAt = null,Object? updatedAt = null,Object? remindAt = freezed,Object? status = null,Object? authorName = null,Object? publishAt = freezed,Object? expiresAt = freezed,}) {
  return _then(_Notice(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,body: null == body ? _self.body : body // ignore: cast_nullable_to_non_nullable
as String,category: null == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as String,priority: null == priority ? _self.priority : priority // ignore: cast_nullable_to_non_nullable
as NoticePriority,isPinned: null == isPinned ? _self.isPinned : isPinned // ignore: cast_nullable_to_non_nullable
as bool,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,remindAt: freezed == remindAt ? _self.remindAt : remindAt // ignore: cast_nullable_to_non_nullable
as DateTime?,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as NoticeStatus,authorName: null == authorName ? _self.authorName : authorName // ignore: cast_nullable_to_non_nullable
as String,publishAt: freezed == publishAt ? _self.publishAt : publishAt // ignore: cast_nullable_to_non_nullable
as DateTime?,expiresAt: freezed == expiresAt ? _self.expiresAt : expiresAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}

// dart format on
