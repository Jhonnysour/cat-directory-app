import 'package:cat_directory_app/features/breeds/data/models/breed_model.dart';
import 'package:cat_directory_app/features/breeds/data/models/breeds_page_model.dart';
import 'package:cat_directory_app/features/breeds/data/models/cat_fact_model.dart';
import 'package:cat_directory_app/features/breeds/domain/entities/breed.dart';
import 'package:cat_directory_app/features/breeds/domain/entities/breeds_page.dart';
import 'package:cat_directory_app/features/breeds/domain/entities/cat_fact.dart';
import 'package:flutter_test/flutter_test.dart';
import '../../../support/fixtures.dart';

void main() {
  test('breed maps all five fields and round trips JSON', () {
    final json = {
      'breed': 'Korat',
      'country': 'Thailand',
      'origin': 'Natural',
      'coat': 'Short',
      'pattern': 'Solid',
    };
    final model = BreedModel.fromJson(json);
    expect(model.toJson(), json);
    expect(
      model.toEntity(),
      const Breed(
        name: 'Korat',
        country: 'Thailand',
        origin: 'Natural',
        coat: 'Short',
        pattern: 'Solid',
      ),
    );
  });
  test('empty API strings are preserved without made-up values', () {
    expect(koratModel.copyWith(country: '').toEntity().country, '');
  });
  test('page maps API keys, metadata and cache provenance', () {
    final model = modelPage(
      page: 2,
    ).copyWith(previousPageUrl: 'previous', nextPageUrl: 'next');
    expect(BreedsPageModel.fromJson(model.toJson()), model);
    final page = model.toEntity(isFromCache: true, isStale: true);
    expect(page.currentPage, 2);
    expect(page.lastPage, 2);
    expect(page.perPage, 10);
    expect(page.total, 20);
    expect(page.hasNextPage, false);
    expect(page.isFromCache, true);
    expect(page.isStale, true);
    expect(page.breeds, [korat]);
  });
  test('first and empty pages expose the correct pagination state', () {
    expect(modelPage().toEntity().hasNextPage, true);
    final empty = modelPage(last: 1, breeds: []).toEntity();
    expect(empty.breeds, isEmpty);
    expect(empty.hasNextPage, false);
  });
  test('page owns an immutable copy of its breed list', () {
    final input = [korat];
    final page = BreedsPage(
      breeds: input,
      currentPage: 1,
      lastPage: 1,
      perPage: 10,
      total: 1,
    );
    input.clear();
    expect(page.breeds, [korat]);
    expect(() => page.breeds.add(siamese), throwsUnsupportedError);
  });
  test('fact maps text and length and round trips JSON', () {
    final json = {'fact': 'Cats sleep a lot.', 'length': 17};
    final model = CatFactModel.fromJson(json);
    expect(model.toEntity(), fact);
    expect(model.toJson(), json);
  });
  test('domain entities use value equality and consistent hash codes', () {
    final copy = koratModel.toEntity();
    expect(copy, korat);
    expect(copy.hashCode, korat.hashCode);
    expect(copy, isNot(siamese));
    expect(const CatFact(text: 'Cats sleep a lot.', length: 17), fact);
    expect(
      const CatFact(text: 'Cats sleep a lot.', length: 17).hashCode,
      fact.hashCode,
    );
    expect(const CatFact(text: 'Other', length: 5), isNot(fact));
  });
}
