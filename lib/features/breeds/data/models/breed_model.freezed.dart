// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'breed_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$BreedModel {

 String get breed; String get country; String get origin; String get coat; String get pattern;
/// Create a copy of BreedModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$BreedModelCopyWith<BreedModel> get copyWith => _$BreedModelCopyWithImpl<BreedModel>(this as BreedModel, _$identity);

  /// Serializes this BreedModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is BreedModel&&(identical(other.breed, breed) || other.breed == breed)&&(identical(other.country, country) || other.country == country)&&(identical(other.origin, origin) || other.origin == origin)&&(identical(other.coat, coat) || other.coat == coat)&&(identical(other.pattern, pattern) || other.pattern == pattern));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,breed,country,origin,coat,pattern);

@override
String toString() {
  return 'BreedModel(breed: $breed, country: $country, origin: $origin, coat: $coat, pattern: $pattern)';
}


}

/// @nodoc
abstract mixin class $BreedModelCopyWith<$Res>  {
  factory $BreedModelCopyWith(BreedModel value, $Res Function(BreedModel) _then) = _$BreedModelCopyWithImpl;
@useResult
$Res call({
 String breed, String country, String origin, String coat, String pattern
});




}
/// @nodoc
class _$BreedModelCopyWithImpl<$Res>
    implements $BreedModelCopyWith<$Res> {
  _$BreedModelCopyWithImpl(this._self, this._then);

  final BreedModel _self;
  final $Res Function(BreedModel) _then;

/// Create a copy of BreedModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? breed = null,Object? country = null,Object? origin = null,Object? coat = null,Object? pattern = null,}) {
  return _then(_self.copyWith(
breed: null == breed ? _self.breed : breed // ignore: cast_nullable_to_non_nullable
as String,country: null == country ? _self.country : country // ignore: cast_nullable_to_non_nullable
as String,origin: null == origin ? _self.origin : origin // ignore: cast_nullable_to_non_nullable
as String,coat: null == coat ? _self.coat : coat // ignore: cast_nullable_to_non_nullable
as String,pattern: null == pattern ? _self.pattern : pattern // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [BreedModel].
extension BreedModelPatterns on BreedModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _BreedModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _BreedModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _BreedModel value)  $default,){
final _that = this;
switch (_that) {
case _BreedModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _BreedModel value)?  $default,){
final _that = this;
switch (_that) {
case _BreedModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String breed,  String country,  String origin,  String coat,  String pattern)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _BreedModel() when $default != null:
return $default(_that.breed,_that.country,_that.origin,_that.coat,_that.pattern);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String breed,  String country,  String origin,  String coat,  String pattern)  $default,) {final _that = this;
switch (_that) {
case _BreedModel():
return $default(_that.breed,_that.country,_that.origin,_that.coat,_that.pattern);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String breed,  String country,  String origin,  String coat,  String pattern)?  $default,) {final _that = this;
switch (_that) {
case _BreedModel() when $default != null:
return $default(_that.breed,_that.country,_that.origin,_that.coat,_that.pattern);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _BreedModel extends BreedModel {
  const _BreedModel({required this.breed, required this.country, required this.origin, required this.coat, required this.pattern}): super._();
  factory _BreedModel.fromJson(Map<String, dynamic> json) => _$BreedModelFromJson(json);

@override final  String breed;
@override final  String country;
@override final  String origin;
@override final  String coat;
@override final  String pattern;

/// Create a copy of BreedModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$BreedModelCopyWith<_BreedModel> get copyWith => __$BreedModelCopyWithImpl<_BreedModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$BreedModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _BreedModel&&(identical(other.breed, breed) || other.breed == breed)&&(identical(other.country, country) || other.country == country)&&(identical(other.origin, origin) || other.origin == origin)&&(identical(other.coat, coat) || other.coat == coat)&&(identical(other.pattern, pattern) || other.pattern == pattern));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,breed,country,origin,coat,pattern);

@override
String toString() {
  return 'BreedModel(breed: $breed, country: $country, origin: $origin, coat: $coat, pattern: $pattern)';
}


}

/// @nodoc
abstract mixin class _$BreedModelCopyWith<$Res> implements $BreedModelCopyWith<$Res> {
  factory _$BreedModelCopyWith(_BreedModel value, $Res Function(_BreedModel) _then) = __$BreedModelCopyWithImpl;
@override @useResult
$Res call({
 String breed, String country, String origin, String coat, String pattern
});




}
/// @nodoc
class __$BreedModelCopyWithImpl<$Res>
    implements _$BreedModelCopyWith<$Res> {
  __$BreedModelCopyWithImpl(this._self, this._then);

  final _BreedModel _self;
  final $Res Function(_BreedModel) _then;

/// Create a copy of BreedModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? breed = null,Object? country = null,Object? origin = null,Object? coat = null,Object? pattern = null,}) {
  return _then(_BreedModel(
breed: null == breed ? _self.breed : breed // ignore: cast_nullable_to_non_nullable
as String,country: null == country ? _self.country : country // ignore: cast_nullable_to_non_nullable
as String,origin: null == origin ? _self.origin : origin // ignore: cast_nullable_to_non_nullable
as String,coat: null == coat ? _self.coat : coat // ignore: cast_nullable_to_non_nullable
as String,pattern: null == pattern ? _self.pattern : pattern // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
