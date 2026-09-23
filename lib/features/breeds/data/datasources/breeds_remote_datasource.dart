import 'package:cat_directory_app/features/breeds/data/models/breeds_page_model.dart';
import 'package:cat_directory_app/features/breeds/data/models/cat_fact_model.dart';
import 'package:dio/dio.dart';

abstract interface class BreedsRemoteDataSource {
  Future<BreedsPageModel> getBreeds({required int page, required int limit});

  Future<CatFactModel> getRandomFact();
}

final class BreedsRemoteDataSourceImpl implements BreedsRemoteDataSource {
  BreedsRemoteDataSourceImpl(this._dio);

  final Dio _dio;

  @override
  Future<BreedsPageModel> getBreeds({
    required int page,
    required int limit,
  }) async {
    final response = await _dio.get<Object?>(
      '/breeds',
      queryParameters: {'page': page, 'limit': limit},
    );
    return BreedsPageModel.fromJson(_jsonObject(response.data));
  }

  @override
  Future<CatFactModel> getRandomFact() async {
    final response = await _dio.get<Object?>('/fact');
    return CatFactModel.fromJson(_jsonObject(response.data));
  }

  Map<String, dynamic> _jsonObject(Object? data) {
    if (data case final Map<String, dynamic> json) {
      return json;
    }
    if (data case final Map<Object?, Object?> json) {
      return json.map((key, value) => MapEntry(key.toString(), value));
    }
    throw const FormatException('Expected a JSON object response.');
  }
}
