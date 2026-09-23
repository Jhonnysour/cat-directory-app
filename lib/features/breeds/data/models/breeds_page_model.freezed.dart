// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'breeds_page_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$BreedsPageModel {

@JsonKey(name: 'current_page') int get currentPage; List<BreedModel> get data;@JsonKey(name: 'last_page') int get lastPage;@JsonKey(name: 'per_page') int get perPage; int get total;@JsonKey(name: 'next_page_url') String? get nextPageUrl;@JsonKey(name: 'prev_page_url') String? get previousPageUrl;
/// Create a copy of BreedsPageModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$BreedsPageModelCopyWith<BreedsPageModel> get copyWith => _$BreedsPageModelCopyWithImpl<BreedsPageModel>(this as BreedsPageModel, _$identity);

  /// Serializes this BreedsPageModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is BreedsPageModel&&(identical(other.currentPage, currentPage) || other.currentPage == currentPage)&&const DeepCollectionEquality().equals(other.data, data)&&(identical(other.lastPage, lastPage) || other.lastPage == lastPage)&&(identical(other.perPage, perPage) || other.perPage == perPage)&&(identical(other.total, total) || other.total == total)&&(identical(other.nextPageUrl, nextPageUrl) || other.nextPageUrl == nextPageUrl)&&(identical(other.previousPageUrl, previousPageUrl) || other.previousPageUrl == previousPageUrl));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,currentPage,const DeepCollectionEquality().hash(data),lastPage,perPage,total,nextPageUrl,previousPageUrl);

@override
String toString() {
  return 'BreedsPageModel(currentPage: $currentPage, data: $data, lastPage: $lastPage, perPage: $perPage, total: $total, nextPageUrl: $nextPageUrl, previousPageUrl: $previousPageUrl)';
}


}

/// @nodoc
abstract mixin class $BreedsPageModelCopyWith<$Res>  {
  factory $BreedsPageModelCopyWith(BreedsPageModel value, $Res Function(BreedsPageModel) _then) = _$BreedsPageModelCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: 'current_page') int currentPage, List<BreedModel> data,@JsonKey(name: 'last_page') int lastPage,@JsonKey(name: 'per_page') int perPage, int total,@JsonKey(name: 'next_page_url') String? nextPageUrl,@JsonKey(name: 'prev_page_url') String? previousPageUrl
});




}
/// @nodoc
class _$BreedsPageModelCopyWithImpl<$Res>
    implements $BreedsPageModelCopyWith<$Res> {
  _$BreedsPageModelCopyWithImpl(this._self, this._then);

  final BreedsPageModel _self;
  final $Res Function(BreedsPageModel) _then;

/// Create a copy of BreedsPageModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? currentPage = null,Object? data = null,Object? lastPage = null,Object? perPage = null,Object? total = null,Object? nextPageUrl = freezed,Object? previousPageUrl = freezed,}) {
  return _then(_self.copyWith(
currentPage: null == currentPage ? _self.currentPage : currentPage // ignore: cast_nullable_to_non_nullable
as int,data: null == data ? _self.data : data // ignore: cast_nullable_to_non_nullable
as List<BreedModel>,lastPage: null == lastPage ? _self.lastPage : lastPage // ignore: cast_nullable_to_non_nullable
as int,perPage: null == perPage ? _self.perPage : perPage // ignore: cast_nullable_to_non_nullable
as int,total: null == total ? _self.total : total // ignore: cast_nullable_to_non_nullable
as int,nextPageUrl: freezed == nextPageUrl ? _self.nextPageUrl : nextPageUrl // ignore: cast_nullable_to_non_nullable
as String?,previousPageUrl: freezed == previousPageUrl ? _self.previousPageUrl : previousPageUrl // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [BreedsPageModel].
extension BreedsPageModelPatterns on BreedsPageModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _BreedsPageModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _BreedsPageModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _BreedsPageModel value)  $default,){
final _that = this;
switch (_that) {
case _BreedsPageModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _BreedsPageModel value)?  $default,){
final _that = this;
switch (_that) {
case _BreedsPageModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: 'current_page')  int currentPage,  List<BreedModel> data, @JsonKey(name: 'last_page')  int lastPage, @JsonKey(name: 'per_page')  int perPage,  int total, @JsonKey(name: 'next_page_url')  String? nextPageUrl, @JsonKey(name: 'prev_page_url')  String? previousPageUrl)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _BreedsPageModel() when $default != null:
return $default(_that.currentPage,_that.data,_that.lastPage,_that.perPage,_that.total,_that.nextPageUrl,_that.previousPageUrl);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: 'current_page')  int currentPage,  List<BreedModel> data, @JsonKey(name: 'last_page')  int lastPage, @JsonKey(name: 'per_page')  int perPage,  int total, @JsonKey(name: 'next_page_url')  String? nextPageUrl, @JsonKey(name: 'prev_page_url')  String? previousPageUrl)  $default,) {final _that = this;
switch (_that) {
case _BreedsPageModel():
return $default(_that.currentPage,_that.data,_that.lastPage,_that.perPage,_that.total,_that.nextPageUrl,_that.previousPageUrl);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: 'current_page')  int currentPage,  List<BreedModel> data, @JsonKey(name: 'last_page')  int lastPage, @JsonKey(name: 'per_page')  int perPage,  int total, @JsonKey(name: 'next_page_url')  String? nextPageUrl, @JsonKey(name: 'prev_page_url')  String? previousPageUrl)?  $default,) {final _that = this;
switch (_that) {
case _BreedsPageModel() when $default != null:
return $default(_that.currentPage,_that.data,_that.lastPage,_that.perPage,_that.total,_that.nextPageUrl,_that.previousPageUrl);case _:
  return null;

}
}

}

/// @nodoc

@JsonSerializable(explicitToJson: true)
class _BreedsPageModel extends BreedsPageModel {
  const _BreedsPageModel({@JsonKey(name: 'current_page') required this.currentPage, required final  List<BreedModel> data, @JsonKey(name: 'last_page') required this.lastPage, @JsonKey(name: 'per_page') required this.perPage, required this.total, @JsonKey(name: 'next_page_url') this.nextPageUrl, @JsonKey(name: 'prev_page_url') this.previousPageUrl}): _data = data,super._();
  factory _BreedsPageModel.fromJson(Map<String, dynamic> json) => _$BreedsPageModelFromJson(json);

@override@JsonKey(name: 'current_page') final  int currentPage;
 final  List<BreedModel> _data;
@override List<BreedModel> get data {
  if (_data is EqualUnmodifiableListView) return _data;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_data);
}

@override@JsonKey(name: 'last_page') final  int lastPage;
@override@JsonKey(name: 'per_page') final  int perPage;
@override final  int total;
@override@JsonKey(name: 'next_page_url') final  String? nextPageUrl;
@override@JsonKey(name: 'prev_page_url') final  String? previousPageUrl;

/// Create a copy of BreedsPageModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$BreedsPageModelCopyWith<_BreedsPageModel> get copyWith => __$BreedsPageModelCopyWithImpl<_BreedsPageModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$BreedsPageModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _BreedsPageModel&&(identical(other.currentPage, currentPage) || other.currentPage == currentPage)&&const DeepCollectionEquality().equals(other._data, _data)&&(identical(other.lastPage, lastPage) || other.lastPage == lastPage)&&(identical(other.perPage, perPage) || other.perPage == perPage)&&(identical(other.total, total) || other.total == total)&&(identical(other.nextPageUrl, nextPageUrl) || other.nextPageUrl == nextPageUrl)&&(identical(other.previousPageUrl, previousPageUrl) || other.previousPageUrl == previousPageUrl));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,currentPage,const DeepCollectionEquality().hash(_data),lastPage,perPage,total,nextPageUrl,previousPageUrl);

@override
String toString() {
  return 'BreedsPageModel(currentPage: $currentPage, data: $data, lastPage: $lastPage, perPage: $perPage, total: $total, nextPageUrl: $nextPageUrl, previousPageUrl: $previousPageUrl)';
}


}

/// @nodoc
abstract mixin class _$BreedsPageModelCopyWith<$Res> implements $BreedsPageModelCopyWith<$Res> {
  factory _$BreedsPageModelCopyWith(_BreedsPageModel value, $Res Function(_BreedsPageModel) _then) = __$BreedsPageModelCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: 'current_page') int currentPage, List<BreedModel> data,@JsonKey(name: 'last_page') int lastPage,@JsonKey(name: 'per_page') int perPage, int total,@JsonKey(name: 'next_page_url') String? nextPageUrl,@JsonKey(name: 'prev_page_url') String? previousPageUrl
});




}
/// @nodoc
class __$BreedsPageModelCopyWithImpl<$Res>
    implements _$BreedsPageModelCopyWith<$Res> {
  __$BreedsPageModelCopyWithImpl(this._self, this._then);

  final _BreedsPageModel _self;
  final $Res Function(_BreedsPageModel) _then;

/// Create a copy of BreedsPageModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? currentPage = null,Object? data = null,Object? lastPage = null,Object? perPage = null,Object? total = null,Object? nextPageUrl = freezed,Object? previousPageUrl = freezed,}) {
  return _then(_BreedsPageModel(
currentPage: null == currentPage ? _self.currentPage : currentPage // ignore: cast_nullable_to_non_nullable
as int,data: null == data ? _self._data : data // ignore: cast_nullable_to_non_nullable
as List<BreedModel>,lastPage: null == lastPage ? _self.lastPage : lastPage // ignore: cast_nullable_to_non_nullable
as int,perPage: null == perPage ? _self.perPage : perPage // ignore: cast_nullable_to_non_nullable
as int,total: null == total ? _self.total : total // ignore: cast_nullable_to_non_nullable
as int,nextPageUrl: freezed == nextPageUrl ? _self.nextPageUrl : nextPageUrl // ignore: cast_nullable_to_non_nullable
as String?,previousPageUrl: freezed == previousPageUrl ? _self.previousPageUrl : previousPageUrl // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
