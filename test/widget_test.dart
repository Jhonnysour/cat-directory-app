import 'package:cat_directory_app/core/error/failure.dart';
import 'package:cat_directory_app/core/network/network_info.dart';
import 'package:cat_directory_app/features/breeds/domain/entities/breed.dart';
import 'package:cat_directory_app/features/breeds/domain/entities/breeds_page.dart';
import 'package:cat_directory_app/features/breeds/domain/entities/cat_fact.dart';
import 'package:cat_directory_app/features/breeds/domain/repositories/breeds_repository.dart';
import 'package:cat_directory_app/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('shows the breeds directory', (tester) async {
    await tester.pumpWidget(
      MyApp(
        repository: _FakeBreedsRepository(),
        networkInfo: _FakeNetworkInfo(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Directorio de razas'), findsOneWidget);
    expect(find.text('Abyssinian'), findsOneWidget);
    expect(find.text('Egypt'), findsOneWidget);
  });

  testWidgets('pagination snackbar expires and keeps loaded breeds', (
    tester,
  ) async {
    await tester.pumpWidget(
      MyApp(
        repository: _PaginationFailureRepository(),
        networkInfo: _FakeNetworkInfo(),
      ),
    );
    await tester.pumpAndSettle();

    await tester.drag(find.byType(ListView), const Offset(0, -700));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    expect(find.text('No se pudieron cargar más razas'), findsOneWidget);
    expect(find.text('Breed 7'), findsOneWidget);

    await tester.pump(const Duration(seconds: 6));
    await tester.pumpAndSettle();

    expect(find.text('No se pudieron cargar más razas'), findsNothing);
    expect(find.text('Breed 7'), findsOneWidget);
  });
}

final class _FakeNetworkInfo implements NetworkInfo {
  @override
  Future<bool> get hasConnection async => true;

  @override
  Stream<bool> get onConnectionChanged => const Stream.empty();
}

final class _FakeBreedsRepository implements BreedsRepository {
  static const _breed = Breed(
    name: 'Abyssinian',
    country: 'Egypt',
    origin: 'Natural',
    coat: 'Short',
    pattern: 'Ticked',
  );

  @override
  Stream<BreedsPage> watchBreeds({int limit = 10}) async* {
    yield BreedsPage(
      breeds: const [_breed],
      currentPage: 1,
      lastPage: 1,
      perPage: 10,
      total: 1,
    );
  }

  @override
  Future<Breed?> findBreedByName(String name, {int limit = 10}) async => _breed;

  @override
  Future<BreedsPage> getBreedsPage({required int page, int limit = 10}) {
    throw UnimplementedError();
  }

  @override
  Future<CatFact> getRandomFact() {
    throw UnimplementedError();
  }

  @override
  Future<BreedsPage> refreshBreeds({int limit = 10}) {
    throw UnimplementedError();
  }
}

final class _PaginationFailureRepository implements BreedsRepository {
  static final _breeds = List<Breed>.generate(
    7,
    (index) => Breed(
      name: 'Breed ${index + 1}',
      country: 'Country ${index + 1}',
      origin: 'Origin',
      coat: 'Short',
      pattern: 'Solid',
    ),
    growable: false,
  );

  @override
  Stream<BreedsPage> watchBreeds({int limit = 10}) async* {
    yield BreedsPage(
      breeds: _breeds,
      currentPage: 1,
      lastPage: 2,
      perPage: 10,
      total: 14,
    );
  }

  @override
  Future<BreedsPage> getBreedsPage({required int page, int limit = 10}) async {
    throw const Failure.noConnection();
  }

  @override
  Future<Breed?> findBreedByName(String name, {int limit = 10}) async => null;

  @override
  Future<CatFact> getRandomFact() {
    throw UnimplementedError();
  }

  @override
  Future<BreedsPage> refreshBreeds({int limit = 10}) {
    throw UnimplementedError();
  }
}
