import 'package:cat_directory_app/features/breeds/data/datasources/breeds_remote_datasource.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import '../../../support/fixtures.dart';
import '../../../support/http_adapter.dart';

void main() {
  late Dio dio;
  late BreedsRemoteDataSourceImpl source;
  setUp(() {
    dio = Dio(BaseOptions(baseUrl: 'https://catfact.ninja'));
    source = BreedsRemoteDataSourceImpl(dio);
  });
  tearDown(() => dio.close(force: true));
  test(
    'requests the exact page and limit and parses Laravel pagination',
    () async {
      final expected = modelPage(page: 2).copyWith(
        nextPageUrl: null,
        previousPageUrl: 'https://catfact.ninja/breeds?page=1',
      );
      final adapter = StubHttpAdapter(
        (_, _) => jsonResponse(expected.toJson()),
      );
      dio.httpClientAdapter = adapter;
      expect(await source.getBreeds(page: 2, limit: 5), expected);
      final request = adapter.requests.single;
      expect(request.method, 'GET');
      expect(request.path, '/breeds');
      expect(request.queryParameters, {'page': 2, 'limit': 5});
    },
  );
  test('fact request has no breed parameter', () async {
    final adapter = StubHttpAdapter(
      (_, _) => jsonResponse({'fact': 'Cats sleep a lot.', 'length': 17}),
    );
    dio.httpClientAdapter = adapter;
    expect((await source.getRandomFact()).toEntity(), fact);
    expect(adapter.requests.single.path, '/fact');
    expect(adapter.requests.single.queryParameters, isEmpty);
  });
  for (final payload in <Object?>[
    null,
    ['wrong shape'],
    'not an object',
  ]) {
    test('rejects non-object response: $payload', () async {
      dio.httpClientAdapter = StubHttpAdapter((_, _) => jsonResponse(payload));
      await expectLater(source.getRandomFact(), throwsFormatException);
    });
  }
  test('missing required fields fail instead of inventing data', () async {
    dio.httpClientAdapter = StubHttpAdapter(
      (_, _) => jsonResponse({'fact': 'Missing length'}),
    );
    await expectLater(source.getRandomFact(), throwsA(isA<TypeError>()));
  });
  test('HTTP errors propagate to the repository for typed mapping', () async {
    dio.httpClientAdapter = StubHttpAdapter(
      (_, _) => jsonResponse({}, status: 503),
    );
    await expectLater(
      source.getBreeds(page: 1, limit: 10),
      throwsA(
        isA<DioException>().having(
          (e) => e.response?.statusCode,
          'status',
          503,
        ),
      ),
    );
  });
}
