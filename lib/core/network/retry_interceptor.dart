import 'package:dio/dio.dart';

typedef RetryDelay = Future<void> Function(Duration duration);

/// Retries transient failures for idempotent requests with exponential backoff.
final class RetryInterceptor extends Interceptor {
  RetryInterceptor(
    this._dio, {
    this.maxRetries = 3,
    this.baseDelay = const Duration(milliseconds: 500),
    RetryDelay? delay,
  }) : assert(maxRetries >= 0),
       assert(!baseDelay.isNegative),
       _delay = delay ?? Future<void>.delayed;

  static const _retryCountKey = 'retryCount';
  static const _retryableMethods = {'GET', 'HEAD'};
  static const _retryableStatusCodes = {408, 429, 500, 502, 503, 504};

  final Dio _dio;
  final int maxRetries;
  final Duration baseDelay;
  final RetryDelay _delay;

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    final request = err.requestOptions;
    final retryCount = request.extra[_retryCountKey] as int? ?? 0;

    if (!_shouldRetry(err) || retryCount >= maxRetries) {
      handler.next(err);
      return;
    }

    final canContinue = await _waitBeforeRetry(
      baseDelay * (1 << retryCount),
      request.cancelToken,
    );
    if (!canContinue) {
      handler.next(err);
      return;
    }

    request.extra[_retryCountKey] = retryCount + 1;

    try {
      final response = await _dio.fetch<dynamic>(request);
      handler.resolve(response);
    } on DioException catch (retryError) {
      handler.next(retryError);
    } on Object catch (retryError, stackTrace) {
      handler.next(
        DioException(
          requestOptions: request,
          error: retryError,
          stackTrace: stackTrace,
          type: DioExceptionType.unknown,
        ),
      );
    }
  }

  bool _shouldRetry(DioException error) {
    final request = error.requestOptions;
    if (!_retryableMethods.contains(request.method.toUpperCase()) ||
        (request.cancelToken?.isCancelled ?? false)) {
      return false;
    }

    return switch (error.type) {
      DioExceptionType.connectionTimeout ||
      DioExceptionType.sendTimeout ||
      DioExceptionType.receiveTimeout ||
      DioExceptionType.connectionError => true,
      DioExceptionType.badResponse => _retryableStatusCodes.contains(
        error.response?.statusCode,
      ),
      DioExceptionType.cancel ||
      DioExceptionType.badCertificate ||
      DioExceptionType.transformTimeout ||
      DioExceptionType.unknown => false,
    };
  }

  Future<bool> _waitBeforeRetry(
    Duration duration,
    CancelToken? cancelToken,
  ) async {
    if (cancelToken == null) {
      await _delay(duration);
      return true;
    }
    if (cancelToken.isCancelled) {
      return false;
    }

    final wasCancelled = await Future.any<bool>([
      _delay(duration).then((_) => false),
      cancelToken.whenCancel.then((_) => true),
    ]);
    return !wasCancelled;
  }
}
