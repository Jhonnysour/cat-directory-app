import 'package:freezed_annotation/freezed_annotation.dart';

part 'failure.freezed.dart';

/// Typed failures that can cross from repositories into the presentation layer.
@freezed
sealed class Failure with _$Failure implements Exception {
  const factory Failure.noConnection() = NoConnectionFailure;

  const factory Failure.timeout() = TimeoutFailure;

  const factory Failure.server({int? statusCode}) = ServerFailure;

  const factory Failure.client({required int statusCode}) = ClientFailure;

  const factory Failure.cancelled() = CancelledFailure;

  const factory Failure.cache() = CacheFailure;

  const factory Failure.notFound() = NotFoundFailure;

  const factory Failure.unexpected({String? message}) = UnexpectedFailure;
}
