import 'dart:async';
import 'package:cat_directory_app/core/network/dio_client.dart';
import 'package:cat_directory_app/core/network/retry_interceptor.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import '../../support/http_adapter.dart';

void main() {
  late Dio dio;
  late List<Duration> delays;
  setUp(() {
    delays = [];
    dio = DioClient.create(
      retryDelay: (delay) async {
        delays.add(delay);
      },
    );
  });
  tearDown(() => dio.close(force: true));

  test('client configures API URL, JSON and bounded timeouts', () {
    expect(dio.options.baseUrl, 'https://catfact.ninja');
    expect(dio.options.headers['Accept'], 'application/json');
    expect(dio.options.connectTimeout, const Duration(seconds: 10));
    expect(dio.options.sendTimeout, const Duration(seconds: 10));
    expect(dio.options.receiveTimeout, const Duration(seconds: 10));
    expect(dio.interceptors.whereType<RetryInterceptor>(), hasLength(1));
  });
  test('successful request is not retried', () async {
    final adapter = StubHttpAdapter((_, _) => jsonResponse({'ok': true}));
    dio.httpClientAdapter = adapter;
    expect((await dio.get<Object?>('/fact')).statusCode, 200);
    expect(adapter.requests, hasLength(1));
    expect(delays, isEmpty);
  });
  test(
    'three retries use 500ms, 1s, 2s and preserve request options',
    () async {
      final adapter = StubHttpAdapter(
        (_, attempt) =>
            jsonResponse({'attempt': attempt}, status: attempt < 4 ? 503 : 200),
      );
      dio.httpClientAdapter = adapter;
      final response = await dio.get<Object?>(
        '/breeds',
        queryParameters: {'page': 2, 'limit': 10},
        options: Options(headers: {'X-Test': 'retained'}),
      );
      expect(response.data, {'attempt': 4});
      expect(delays, [
        const Duration(milliseconds: 500),
        const Duration(seconds: 1),
        const Duration(seconds: 2),
      ]);
      for (final request in adapter.requests) {
        expect(request.path, '/breeds');
        expect(request.queryParameters, {'page': 2, 'limit': 10});
        expect(request.headers['X-Test'], 'retained');
      }
      expect(adapter.requests.map((r) => r.extra['retryCount'] ?? 0), [
        0,
        1,
        2,
        3,
      ]);
    },
  );
  test(
    'exhausted retry budget exposes the final error after four attempts',
    () async {
      final adapter = StubHttpAdapter((_, _) => jsonResponse({}, status: 503));
      dio.httpClientAdapter = adapter;
      await expectLater(
        dio.get<Object?>('/fact'),
        throwsA(
          isA<DioException>().having(
            (e) => e.response?.statusCode,
            'status',
            503,
          ),
        ),
      );
      expect(adapter.requests, hasLength(4));
      expect(delays, hasLength(3));
    },
  );
  for (final status in [408, 429, 500, 502, 503, 504]) {
    test(
      'retries transient HTTP $status once when the next attempt succeeds',
      () async {
        final adapter = StubHttpAdapter(
          (_, attempt) => jsonResponse({}, status: attempt == 1 ? status : 200),
        );
        dio.httpClientAdapter = adapter;
        await dio.get<Object?>('/fact');
        expect(adapter.requests, hasLength(2));
        expect(delays, [const Duration(milliseconds: 500)]);
      },
    );
  }
  for (final status in [400, 401, 403, 404, 422, 501]) {
    test('does not retry non-transient HTTP $status', () async {
      final adapter = StubHttpAdapter(
        (_, _) => jsonResponse({}, status: status),
      );
      dio.httpClientAdapter = adapter;
      await expectLater(
        dio.get<Object?>('/fact'),
        throwsA(isA<DioException>()),
      );
      expect(adapter.requests, hasLength(1));
      expect(delays, isEmpty);
    });
  }
  for (final type in DioExceptionType.values.where(
    (t) => t != DioExceptionType.badResponse,
  )) {
    final retryable = {
      DioExceptionType.connectionTimeout,
      DioExceptionType.sendTimeout,
      DioExceptionType.receiveTimeout,
      DioExceptionType.connectionError,
    }.contains(type);
    test('${retryable ? 'retries' : 'does not retry'} $type', () async {
      final adapter = StubHttpAdapter((request, attempt) {
        if (attempt == 1) {
          throw DioException(requestOptions: request, type: type);
        }
        return jsonResponse({});
      });
      dio.httpClientAdapter = adapter;
      if (retryable) {
        await dio.get<Object?>('/fact');
      } else {
        await expectLater(
          dio.get<Object?>('/fact'),
          throwsA(isA<DioException>().having((e) => e.type, 'type', type)),
        );
      }
      expect(adapter.requests.length, retryable ? 2 : 1);
      expect(delays.length, retryable ? 1 : 0);
    });
  }
  for (final method in ['POST', 'PUT', 'PATCH', 'DELETE']) {
    test('does not retry $method even after a server error', () async {
      final adapter = StubHttpAdapter((_, _) => jsonResponse({}, status: 503));
      dio.httpClientAdapter = adapter;
      await expectLater(
        dio.request<Object?>('/fact', options: Options(method: method)),
        throwsA(isA<DioException>()),
      );
      expect(adapter.requests, hasLength(1));
      expect(delays, isEmpty);
    });
  }
  test('HEAD can be retried', () async {
    final adapter = StubHttpAdapter(
      (_, attempt) => jsonResponse({}, status: attempt == 1 ? 503 : 200),
    );
    dio.httpClientAdapter = adapter;
    await dio.head<Object?>('/fact');
    expect(adapter.requests, hasLength(2));
  });
  test('zero retry budget fails immediately', () async {
    dio.interceptors.clear();
    dio.interceptors.add(
      RetryInterceptor(
        dio,
        maxRetries: 0,
        delay: (d) async {
          delays.add(d);
        },
      ),
    );
    final adapter = StubHttpAdapter((_, _) => jsonResponse({}, status: 503));
    dio.httpClientAdapter = adapter;
    await expectLater(dio.get<Object?>('/fact'), throwsA(isA<DioException>()));
    expect(adapter.requests, hasLength(1));
    expect(delays, isEmpty);
  });
  test('cancellation during backoff prevents the next HTTP attempt', () async {
    final enteredDelay = Completer<void>();
    final releaseDelay = Completer<void>();
    dio.interceptors.clear();
    dio.interceptors.add(
      RetryInterceptor(
        dio,
        delay: (_) {
          enteredDelay.complete();
          return releaseDelay.future;
        },
      ),
    );
    final adapter = StubHttpAdapter((_, _) => jsonResponse({}, status: 503));
    dio.httpClientAdapter = adapter;
    final token = CancelToken();
    final expectation = expectLater(
      dio.get<Object?>('/fact', cancelToken: token),
      throwsA(isA<DioException>()),
    );
    await enteredDelay.future;
    token.cancel();
    await expectation;
    releaseDelay.complete();
    await pumpEventQueue();
    expect(adapter.requests, hasLength(1));
  });
  test('a new request starts with its own retry budget', () async {
    final adapter = StubHttpAdapter(
      (_, attempt) => jsonResponse({}, status: attempt.isOdd ? 503 : 200),
    );
    dio.httpClientAdapter = adapter;
    await dio.get<Object?>('/fact');
    await dio.get<Object?>('/fact');
    expect(adapter.requests.map((r) => r.extra['retryCount'] ?? 0), [
      0,
      1,
      0,
      1,
    ]);
    expect(delays, [
      const Duration(milliseconds: 500),
      const Duration(milliseconds: 500),
    ]);
  });

  test('custom retry budget and delay are enforced', () async {
    dio.interceptors.clear();
    dio.interceptors.add(
      RetryInterceptor(
        dio,
        maxRetries: 1,
        baseDelay: const Duration(milliseconds: 25),
        delay: (d) async {
          delays.add(d);
        },
      ),
    );
    final adapter = StubHttpAdapter((_, _) => jsonResponse({}, status: 503));
    dio.httpClientAdapter = adapter;
    await expectLater(dio.get<Object?>('/fact'), throwsA(isA<DioException>()));
    expect(adapter.requests, hasLength(2));
    expect(delays, [const Duration(milliseconds: 25)]);
  });

  test('a pre-cancelled request never reaches the adapter', () async {
    final adapter = StubHttpAdapter((_, _) => jsonResponse({}));
    dio.httpClientAdapter = adapter;
    final token = CancelToken()..cancel();
    await expectLater(
      dio.get<Object?>('/fact', cancelToken: token),
      throwsA(isA<DioException>()),
    );
    expect(adapter.requests, isEmpty);
    expect(delays, isEmpty);
  });
}
