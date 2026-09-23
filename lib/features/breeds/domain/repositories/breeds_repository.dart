import 'package:cat_directory_app/core/error/failure.dart';
import 'package:cat_directory_app/features/breeds/domain/entities/breed.dart';
import 'package:cat_directory_app/features/breeds/domain/entities/breeds_page.dart';
import 'package:cat_directory_app/features/breeds/domain/entities/cat_fact.dart';

abstract interface class BreedsRepository {
  /// Emits a cached snapshot first and revalidates it when its TTL has expired.
  ///
  /// Throws a typed [Failure] if fresh data cannot be obtained.
  Stream<BreedsPage> watchBreeds({int limit = 10});

  /// Loads one remote page and appends it to the persisted snapshot.
  Future<BreedsPage> getBreedsPage({required int page, int limit = 10});

  /// Reloads page one and replaces the persisted snapshot after success.
  Future<BreedsPage> refreshBreeds({int limit = 10});

  /// Resolves a breed from cache first, then paginates the API if necessary.
  ///
  /// Returns `null` only after every remote page was fetched successfully.
  Future<Breed?> findBreedByName(String name, {int limit = 10});

  Future<CatFact> getRandomFact();
}
