import 'package:cat_directory_app/core/error/failure.dart';
import 'package:cat_directory_app/core/network/network_info.dart';
import 'package:cat_directory_app/features/breeds/data/datasources/breeds_local_datasource.dart';
import 'package:cat_directory_app/features/breeds/data/datasources/breeds_remote_datasource.dart';
import 'package:cat_directory_app/features/breeds/data/models/breed_model.dart';
import 'package:cat_directory_app/features/breeds/data/models/breeds_page_model.dart';
import 'package:cat_directory_app/features/breeds/domain/entities/breed.dart';
import 'package:cat_directory_app/features/breeds/domain/entities/breeds_page.dart';
import 'package:cat_directory_app/features/breeds/domain/entities/cat_fact.dart';
import 'package:cat_directory_app/features/breeds/domain/repositories/breeds_repository.dart';
import 'package:dio/dio.dart';

final class BreedsRepositoryImpl implements BreedsRepository {
  BreedsRepositoryImpl(
    this._remoteDataSource,
    this._localDataSource,
    this._networkInfo,
  );

  final BreedsRemoteDataSource _remoteDataSource;
  final BreedsLocalDataSource _localDataSource;
  final NetworkInfo _networkInfo;

  @override
  Stream<BreedsPage> watchBreeds({int limit = 10}) async* {
    final cached = await _readCache();
    if (cached != null) {
      yield cached.page.toEntity(isFromCache: true, isStale: cached.isStale);
      if (!cached.isStale) {
        return;
      }
    }

    await _requireConnection();
    final freshPage = await _remote(
      () => _remoteDataSource.getBreeds(page: 1, limit: limit),
    );
    await _writeCacheBestEffort(freshPage);
    yield freshPage.toEntity();
  }

  @override
  Future<BreedsPage> getBreedsPage({required int page, int limit = 10}) async {
    await _requireConnection();
    final remotePage = await _remote(
      () => _remoteDataSource.getBreeds(page: page, limit: limit),
    );

    if (page == 1) {
      await _writeCacheBestEffort(remotePage);
    } else {
      final cached = await _readCache();
      if (cached != null) {
        await _writeCacheBestEffort(_mergePages(cached.page, remotePage));
      }
    }

    return remotePage.toEntity();
  }

  @override
  Future<BreedsPage> refreshBreeds({int limit = 10}) =>
      getBreedsPage(page: 1, limit: limit);

  @override
  Future<Breed?> findBreedByName(String name, {int limit = 10}) async {
    final normalizedName = _normalizeName(name);
    if (normalizedName.isEmpty) {
      return null;
    }

    final cached = await _readCache();
    final cachedBreed = _findBreed(
      cached?.page.data ?? const [],
      normalizedName,
    );
    if (cachedBreed != null) {
      return cachedBreed.toEntity();
    }
    if (cached != null &&
        !cached.isStale &&
        cached.page.currentPage >= cached.page.lastPage) {
      return null;
    }

    await _requireConnection();
    BreedsPageModel? accumulated;
    var page = 1;

    while (true) {
      final remotePage = await _remote(
        () => _remoteDataSource.getBreeds(page: page, limit: limit),
      );
      accumulated = accumulated == null
          ? remotePage
          : _mergePages(accumulated, remotePage);
      await _writeCacheBestEffort(accumulated);

      final breed = _findBreed(remotePage.data, normalizedName);
      if (breed != null) {
        return breed.toEntity();
      }
      if (remotePage.currentPage >= remotePage.lastPage) {
        return null;
      }
      page = remotePage.currentPage + 1;
    }
  }

  @override
  Future<CatFact> getRandomFact() async {
    final fact = await _remote(_remoteDataSource.getRandomFact);
    return fact.toEntity();
  }

  Future<CachedBreedsSnapshot?> _readCache() async {
    try {
      return await _localDataSource.readBreeds();
    } on Object {
      return null;
    }
  }

  Future<void> _writeCacheBestEffort(BreedsPageModel page) async {
    try {
      await _localDataSource.writeBreeds(page);
    } on Object {
      // Persistence is secondary to returning fresh network data.
    }
  }

  Future<void> _requireConnection() async {
    try {
      if (!await _networkInfo.hasConnection) {
        throw const Failure.noConnection();
      }
    } on Failure {
      rethrow;
    } on Object {
      // If connectivity detection itself fails, Dio remains the source of truth.
    }
  }

  Future<T> _remote<T>(Future<T> Function() request) async {
    try {
      return await request();
    } on Failure {
      rethrow;
    } on DioException catch (error) {
      throw _mapDioFailure(error);
    } on FormatException {
      throw const Failure.unexpected(message: 'Respuesta inválida de la API.');
    } on Object {
      throw const Failure.unexpected();
    }
  }

  Failure _mapDioFailure(DioException error) {
    return switch (error.type) {
      DioExceptionType.connectionTimeout ||
      DioExceptionType.sendTimeout ||
      DioExceptionType.receiveTimeout ||
      DioExceptionType.transformTimeout => const Failure.timeout(),
      DioExceptionType.connectionError => const Failure.noConnection(),
      DioExceptionType.cancel => const Failure.cancelled(),
      DioExceptionType.badResponse => _responseFailure(
        error.response?.statusCode,
      ),
      DioExceptionType.badCertificate ||
      DioExceptionType.unknown => const Failure.unexpected(),
    };
  }

  Failure _responseFailure(int? statusCode) {
    if (statusCode == null) {
      return const Failure.unexpected();
    }
    if (statusCode >= 500) {
      return Failure.server(statusCode: statusCode);
    }
    return Failure.client(statusCode: statusCode);
  }

  BreedsPageModel _mergePages(BreedsPageModel current, BreedsPageModel next) {
    final merged = <BreedModel>[];
    final indexesByName = <String, int>{};

    for (final breed in [...current.data, ...next.data]) {
      final key = _normalizeName(breed.breed);
      final existingIndex = indexesByName[key];
      if (existingIndex == null) {
        indexesByName[key] = merged.length;
        merged.add(breed);
      } else {
        merged[existingIndex] = breed;
      }
    }

    return next.copyWith(data: merged);
  }

  BreedModel? _findBreed(List<BreedModel> breeds, String normalizedName) {
    for (final breed in breeds) {
      if (_normalizeName(breed.breed) == normalizedName) {
        return breed;
      }
    }
    return null;
  }

  String _normalizeName(String value) => value.trim().toLowerCase();
}
