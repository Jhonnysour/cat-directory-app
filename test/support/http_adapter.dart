import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:dio/dio.dart';

/// Exercises Dio's real interceptor/decoding pipeline without opening sockets.
class StubHttpAdapter implements HttpClientAdapter {
  StubHttpAdapter(this.respond);
  final FutureOr<ResponseBody> Function(RequestOptions options, int attempt)
  respond;
  final requests = <RequestOptions>[];

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    requests.add(options.copyWith(extra: Map.of(options.extra)));
    return respond(options, requests.length);
  }

  @override
  void close({bool force = false}) {}
}

ResponseBody jsonResponse(Object? data, {int status = 200}) =>
    ResponseBody.fromString(
      jsonEncode(data),
      status,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
