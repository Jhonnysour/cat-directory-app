import 'package:cat_directory_app/core/network/retry_interceptor.dart';
import 'package:dio/dio.dart';

abstract final class DioClient {
  static const baseUrl = 'https://catfact.ninja';
  static const timeout = Duration(seconds: 10);

  static Dio create({RetryDelay? retryDelay}) {
    final dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: timeout,
        sendTimeout: timeout,
        receiveTimeout: timeout,
        headers: const {'Accept': 'application/json'},
      ),
    );

    dio.interceptors.add(RetryInterceptor(dio, delay: retryDelay));
    return dio;
  }
}
