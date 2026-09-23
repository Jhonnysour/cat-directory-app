// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'failure.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$Failure {





@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Failure);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'Failure()';
}


}

/// @nodoc
class $FailureCopyWith<$Res>  {
$FailureCopyWith(Failure _, $Res Function(Failure) __);
}


/// Adds pattern-matching-related methods to [Failure].
extension FailurePatterns on Failure {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( NoConnectionFailure value)?  noConnection,TResult Function( TimeoutFailure value)?  timeout,TResult Function( ServerFailure value)?  server,TResult Function( ClientFailure value)?  client,TResult Function( CancelledFailure value)?  cancelled,TResult Function( CacheFailure value)?  cache,TResult Function( NotFoundFailure value)?  notFound,TResult Function( UnexpectedFailure value)?  unexpected,required TResult orElse(),}){
final _that = this;
switch (_that) {
case NoConnectionFailure() when noConnection != null:
return noConnection(_that);case TimeoutFailure() when timeout != null:
return timeout(_that);case ServerFailure() when server != null:
return server(_that);case ClientFailure() when client != null:
return client(_that);case CancelledFailure() when cancelled != null:
return cancelled(_that);case CacheFailure() when cache != null:
return cache(_that);case NotFoundFailure() when notFound != null:
return notFound(_that);case UnexpectedFailure() when unexpected != null:
return unexpected(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( NoConnectionFailure value)  noConnection,required TResult Function( TimeoutFailure value)  timeout,required TResult Function( ServerFailure value)  server,required TResult Function( ClientFailure value)  client,required TResult Function( CancelledFailure value)  cancelled,required TResult Function( CacheFailure value)  cache,required TResult Function( NotFoundFailure value)  notFound,required TResult Function( UnexpectedFailure value)  unexpected,}){
final _that = this;
switch (_that) {
case NoConnectionFailure():
return noConnection(_that);case TimeoutFailure():
return timeout(_that);case ServerFailure():
return server(_that);case ClientFailure():
return client(_that);case CancelledFailure():
return cancelled(_that);case CacheFailure():
return cache(_that);case NotFoundFailure():
return notFound(_that);case UnexpectedFailure():
return unexpected(_that);}
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( NoConnectionFailure value)?  noConnection,TResult? Function( TimeoutFailure value)?  timeout,TResult? Function( ServerFailure value)?  server,TResult? Function( ClientFailure value)?  client,TResult? Function( CancelledFailure value)?  cancelled,TResult? Function( CacheFailure value)?  cache,TResult? Function( NotFoundFailure value)?  notFound,TResult? Function( UnexpectedFailure value)?  unexpected,}){
final _that = this;
switch (_that) {
case NoConnectionFailure() when noConnection != null:
return noConnection(_that);case TimeoutFailure() when timeout != null:
return timeout(_that);case ServerFailure() when server != null:
return server(_that);case ClientFailure() when client != null:
return client(_that);case CancelledFailure() when cancelled != null:
return cancelled(_that);case CacheFailure() when cache != null:
return cache(_that);case NotFoundFailure() when notFound != null:
return notFound(_that);case UnexpectedFailure() when unexpected != null:
return unexpected(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function()?  noConnection,TResult Function()?  timeout,TResult Function( int? statusCode)?  server,TResult Function( int statusCode)?  client,TResult Function()?  cancelled,TResult Function()?  cache,TResult Function()?  notFound,TResult Function( String? message)?  unexpected,required TResult orElse(),}) {final _that = this;
switch (_that) {
case NoConnectionFailure() when noConnection != null:
return noConnection();case TimeoutFailure() when timeout != null:
return timeout();case ServerFailure() when server != null:
return server(_that.statusCode);case ClientFailure() when client != null:
return client(_that.statusCode);case CancelledFailure() when cancelled != null:
return cancelled();case CacheFailure() when cache != null:
return cache();case NotFoundFailure() when notFound != null:
return notFound();case UnexpectedFailure() when unexpected != null:
return unexpected(_that.message);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function()  noConnection,required TResult Function()  timeout,required TResult Function( int? statusCode)  server,required TResult Function( int statusCode)  client,required TResult Function()  cancelled,required TResult Function()  cache,required TResult Function()  notFound,required TResult Function( String? message)  unexpected,}) {final _that = this;
switch (_that) {
case NoConnectionFailure():
return noConnection();case TimeoutFailure():
return timeout();case ServerFailure():
return server(_that.statusCode);case ClientFailure():
return client(_that.statusCode);case CancelledFailure():
return cancelled();case CacheFailure():
return cache();case NotFoundFailure():
return notFound();case UnexpectedFailure():
return unexpected(_that.message);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function()?  noConnection,TResult? Function()?  timeout,TResult? Function( int? statusCode)?  server,TResult? Function( int statusCode)?  client,TResult? Function()?  cancelled,TResult? Function()?  cache,TResult? Function()?  notFound,TResult? Function( String? message)?  unexpected,}) {final _that = this;
switch (_that) {
case NoConnectionFailure() when noConnection != null:
return noConnection();case TimeoutFailure() when timeout != null:
return timeout();case ServerFailure() when server != null:
return server(_that.statusCode);case ClientFailure() when client != null:
return client(_that.statusCode);case CancelledFailure() when cancelled != null:
return cancelled();case CacheFailure() when cache != null:
return cache();case NotFoundFailure() when notFound != null:
return notFound();case UnexpectedFailure() when unexpected != null:
return unexpected(_that.message);case _:
  return null;

}
}

}

/// @nodoc


class NoConnectionFailure implements Failure {
  const NoConnectionFailure();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is NoConnectionFailure);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'Failure.noConnection()';
}


}




/// @nodoc


class TimeoutFailure implements Failure {
  const TimeoutFailure();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TimeoutFailure);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'Failure.timeout()';
}


}




/// @nodoc


class ServerFailure implements Failure {
  const ServerFailure({this.statusCode});
  

 final  int? statusCode;

/// Create a copy of Failure
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ServerFailureCopyWith<ServerFailure> get copyWith => _$ServerFailureCopyWithImpl<ServerFailure>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ServerFailure&&(identical(other.statusCode, statusCode) || other.statusCode == statusCode));
}


@override
int get hashCode => Object.hash(runtimeType,statusCode);

@override
String toString() {
  return 'Failure.server(statusCode: $statusCode)';
}


}

/// @nodoc
abstract mixin class $ServerFailureCopyWith<$Res> implements $FailureCopyWith<$Res> {
  factory $ServerFailureCopyWith(ServerFailure value, $Res Function(ServerFailure) _then) = _$ServerFailureCopyWithImpl;
@useResult
$Res call({
 int? statusCode
});




}
/// @nodoc
class _$ServerFailureCopyWithImpl<$Res>
    implements $ServerFailureCopyWith<$Res> {
  _$ServerFailureCopyWithImpl(this._self, this._then);

  final ServerFailure _self;
  final $Res Function(ServerFailure) _then;

/// Create a copy of Failure
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? statusCode = freezed,}) {
  return _then(ServerFailure(
statusCode: freezed == statusCode ? _self.statusCode : statusCode // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}


}

/// @nodoc


class ClientFailure implements Failure {
  const ClientFailure({required this.statusCode});
  

 final  int statusCode;

/// Create a copy of Failure
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ClientFailureCopyWith<ClientFailure> get copyWith => _$ClientFailureCopyWithImpl<ClientFailure>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ClientFailure&&(identical(other.statusCode, statusCode) || other.statusCode == statusCode));
}


@override
int get hashCode => Object.hash(runtimeType,statusCode);

@override
String toString() {
  return 'Failure.client(statusCode: $statusCode)';
}


}

/// @nodoc
abstract mixin class $ClientFailureCopyWith<$Res> implements $FailureCopyWith<$Res> {
  factory $ClientFailureCopyWith(ClientFailure value, $Res Function(ClientFailure) _then) = _$ClientFailureCopyWithImpl;
@useResult
$Res call({
 int statusCode
});




}
/// @nodoc
class _$ClientFailureCopyWithImpl<$Res>
    implements $ClientFailureCopyWith<$Res> {
  _$ClientFailureCopyWithImpl(this._self, this._then);

  final ClientFailure _self;
  final $Res Function(ClientFailure) _then;

/// Create a copy of Failure
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? statusCode = null,}) {
  return _then(ClientFailure(
statusCode: null == statusCode ? _self.statusCode : statusCode // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

/// @nodoc


class CancelledFailure implements Failure {
  const CancelledFailure();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CancelledFailure);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'Failure.cancelled()';
}


}




/// @nodoc


class CacheFailure implements Failure {
  const CacheFailure();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CacheFailure);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'Failure.cache()';
}


}




/// @nodoc


class NotFoundFailure implements Failure {
  const NotFoundFailure();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is NotFoundFailure);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'Failure.notFound()';
}


}




/// @nodoc


class UnexpectedFailure implements Failure {
  const UnexpectedFailure({this.message});
  

 final  String? message;

/// Create a copy of Failure
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$UnexpectedFailureCopyWith<UnexpectedFailure> get copyWith => _$UnexpectedFailureCopyWithImpl<UnexpectedFailure>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is UnexpectedFailure&&(identical(other.message, message) || other.message == message));
}


@override
int get hashCode => Object.hash(runtimeType,message);

@override
String toString() {
  return 'Failure.unexpected(message: $message)';
}


}

/// @nodoc
abstract mixin class $UnexpectedFailureCopyWith<$Res> implements $FailureCopyWith<$Res> {
  factory $UnexpectedFailureCopyWith(UnexpectedFailure value, $Res Function(UnexpectedFailure) _then) = _$UnexpectedFailureCopyWithImpl;
@useResult
$Res call({
 String? message
});




}
/// @nodoc
class _$UnexpectedFailureCopyWithImpl<$Res>
    implements $UnexpectedFailureCopyWith<$Res> {
  _$UnexpectedFailureCopyWithImpl(this._self, this._then);

  final UnexpectedFailure _self;
  final $Res Function(UnexpectedFailure) _then;

/// Create a copy of Failure
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? message = freezed,}) {
  return _then(UnexpectedFailure(
message: freezed == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
