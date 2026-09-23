import 'dart:async';

import 'package:cat_directory_app/core/error/failure.dart';
import 'package:cat_directory_app/features/breeds/data/datasources/breeds_local_datasource.dart';
import 'package:cat_directory_app/features/breeds/data/models/breeds_page_model.dart';
import 'package:cat_directory_app/features/breeds/data/models/cat_fact_model.dart';
import 'package:cat_directory_app/features/breeds/data/repositories/breeds_repository_impl.dart';
import 'package:cat_directory_app/features/breeds/domain/entities/breeds_page.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:dio/dio.dart';
import 'package:mocktail/mocktail.dart';
import '../../../support/fixtures.dart';
import '../../../support/mocks.dart';

void main() {
  late MockLocalSource local;
  late MockRemoteSource remote;
  late MockNetworkInfo network;
  late BreedsRepositoryImpl repository;
  setUpAll(() => registerFallbackValue(modelPage()));
  setUp(() {
    local = MockLocalSource();
    remote = MockRemoteSource();
    network = MockNetworkInfo();
    repository = BreedsRepositoryImpl(remote, local, network);
    when(() => local.readBreeds()).thenAnswer((_) async => null);
    when(() => local.writeBreeds(any())).thenAnswer((_) async {});
    when(() => network.hasConnection).thenAnswer((_) async => true);
    when(
      () => remote.getBreeds(
        page: any(named: 'page'),
        limit: any(named: 'limit'),
      ),
    ).thenAnswer((_) async => modelPage());
  });
  void cache({bool stale = false, int last = 2}) {
    when(() => local.readBreeds()).thenAnswer(
      (_) async => CachedBreedsSnapshot(
        page: modelPage(last: last),
        isStale: stale,
      ),
    );
  }

  test(
    'fresh cache works offline without consulting connectivity or API',
    () async {
      cache();
      when(() => network.hasConnection).thenAnswer((_) async => false);
      final pages = await repository.watchBreeds().toList();
      expect(pages, hasLength(1));
      expect(pages.single.breeds, [korat]);
      expect(pages.single.isFromCache, true);
      expect(pages.single.isStale, false);
      verifyZeroInteractions(remote);
      verifyZeroInteractions(network);
    },
  );

  test(
    'stale cache is emitted before the offline failure and is not deleted',
    () async {
      cache(stale: true);
      when(() => network.hasConnection).thenAnswer((_) async => false);
      await expectLater(
        repository.watchBreeds(),
        emitsInOrder([
          isA<BreedsPage>()
              .having((p) => p.isFromCache, 'cached', true)
              .having((p) => p.isStale, 'stale', true)
              .having((p) => p.breeds, 'cached catalog', [korat]),
          emitsError(const Failure.noConnection()),
          emitsDone,
        ]),
      );
      verifyZeroInteractions(remote);
      verifyNever(() => local.clearBreeds());
    },
  );

  test('stale cache revalidates and replaces the snapshot', () async {
    cache(stale: true);
    final fresh = modelPage(breeds: [siameseModel]);
    when(
      () => remote.getBreeds(page: 1, limit: 10),
    ).thenAnswer((_) async => fresh);
    final pages = await repository.watchBreeds().toList();
    expect(pages.map((p) => p.isFromCache), [true, false]);
    expect(pages.last.breeds, [siamese]);
    expect(pages.last.isStale, false);
    verify(() => local.writeBreeds(fresh)).called(1);
  });

  test(
    'no cache and no network reports a typed failure without HTTP',
    () async {
      when(() => network.hasConnection).thenAnswer((_) async => false);
      await expectLater(
        repository.watchBreeds(),
        emitsError(const Failure.noConnection()),
      );
      verifyZeroInteractions(remote);
    },
  );

  test('a cache read failure still allows fresh data', () async {
    when(() => local.readBreeds()).thenThrow(StateError('storage unavailable'));
    expect((await repository.watchBreeds().single).breeds, [korat]);
    verify(() => remote.getBreeds(page: 1, limit: 10)).called(1);
  });

  test(
    'a cache write failure does not discard a successful HTTP response',
    () async {
      when(() => local.writeBreeds(any())).thenThrow(StateError('disk full'));
      expect((await repository.watchBreeds().single).breeds, [korat]);
    },
  );

  test('connectivity plugin failure falls back to the HTTP client', () async {
    when(
      () => network.hasConnection,
    ).thenThrow(StateError('plugin unavailable'));
    expect((await repository.getBreedsPage(page: 1)).breeds, [korat]);
  });

  test(
    'pagination merges cached names without duplicates and preserves metadata',
    () async {
      cache();
      final updated = koratModel.copyWith(breed: ' KORAT ', country: 'Updated');
      final next = modelPage(page: 2, breeds: [updated, siameseModel]);
      when(
        () => remote.getBreeds(page: 2, limit: 10),
      ).thenAnswer((_) async => next);
      final result = await repository.getBreedsPage(page: 2);
      expect(result.currentPage, 2);
      expect(result.hasNextPage, false);
      final saved =
          verify(() => local.writeBreeds(captureAny())).captured.single
              as BreedsPageModel;
      expect(saved.data, [updated, siameseModel]);
      expect(saved.currentPage, 2);
      expect(saved.lastPage, next.lastPage);
      expect(saved.total, next.total);
    },
  );

  test(
    'a page loaded without a snapshot does not persist a partial catalog',
    () async {
      await repository.getBreedsPage(page: 2);
      verifyNever(() => local.writeBreeds(any()));
    },
  );

  test(
    'refresh bypasses a fresh cache and replaces it with page one',
    () async {
      cache();
      when(
        () => remote.getBreeds(page: 1, limit: 5),
      ).thenAnswer((_) async => modelPage(breeds: [siameseModel]));
      expect((await repository.refreshBreeds(limit: 5)).breeds, [siamese]);
      verify(() => remote.getBreeds(page: 1, limit: 5)).called(1);
      verifyNever(() => local.readBreeds());
      final saved =
          verify(() => local.writeBreeds(captureAny())).captured.single
              as BreedsPageModel;
      expect(saved.data, [siameseModel]);
    },
  );

  test(
    'failed refresh never overwrites or clears the previous cache',
    () async {
      when(
        () => remote.getBreeds(page: 1, limit: 10),
      ).thenThrow(const Failure.timeout());
      await expectLater(
        repository.refreshBreeds(),
        throwsA(const Failure.timeout()),
      );
      verifyNever(() => local.writeBreeds(any()));
      verifyNever(() => local.clearBreeds());
    },
  );

  test('late pagination cannot overwrite a newer refresh snapshot', () async {
    final oldPage = Completer<BreedsPageModel>();
    var persisted = modelPage();
    when(() => local.readBreeds()).thenAnswer(
      (_) async => CachedBreedsSnapshot(page: persisted, isStale: false),
    );
    when(() => local.writeBreeds(any())).thenAnswer((invocation) async {
      persisted = invocation.positionalArguments.single as BreedsPageModel;
    });
    when(
      () => remote.getBreeds(page: 2, limit: 10),
    ).thenAnswer((_) => oldPage.future);
    final pagination = repository.getBreedsPage(page: 2);
    await pumpEventQueue();
    final fresh = modelPage(breeds: [siameseModel]);
    when(
      () => remote.getBreeds(page: 1, limit: 10),
    ).thenAnswer((_) async => fresh);
    await repository.refreshBreeds();
    oldPage.complete(modelPage(page: 2));
    await pagination;

    expect(persisted, fresh);
    expect(persisted.currentPage, 1);
  });

  test('late refresh cannot overwrite a newer refresh snapshot', () async {
    final oldPage = Completer<BreedsPageModel>();
    var persisted = modelPage();
    when(() => local.writeBreeds(any())).thenAnswer((invocation) async {
      persisted = invocation.positionalArguments.single as BreedsPageModel;
    });
    when(
      () => remote.getBreeds(page: 1, limit: 10),
    ).thenAnswer((_) => oldPage.future);
    final firstRefresh = repository.refreshBreeds();
    await pumpEventQueue();
    final fresh = modelPage(breeds: [siameseModel]);
    when(
      () => remote.getBreeds(page: 1, limit: 10),
    ).thenAnswer((_) async => fresh);
    await repository.refreshBreeds();
    oldPage.complete(modelPage());
    await firstRefresh;

    expect(persisted, fresh);
  });

  test('a new snapshot waits for an already submitted storage write', () async {
    final oldWrite = Completer<void>();
    final writesStarted = <BreedsPageModel>[];
    var persisted = modelPage();
    when(() => local.writeBreeds(any())).thenAnswer((invocation) async {
      final page = invocation.positionalArguments.single as BreedsPageModel;
      writesStarted.add(page);
      if (writesStarted.length == 1) {
        await oldWrite.future;
      }
      persisted = page;
    });
    final firstRefresh = repository.refreshBreeds();
    await pumpEventQueue();
    expect(writesStarted, hasLength(1));
    final fresh = modelPage(breeds: [siameseModel]);
    when(
      () => remote.getBreeds(page: 1, limit: 10),
    ).thenAnswer((_) async => fresh);
    final secondRefresh = repository.refreshBreeds();
    await pumpEventQueue();
    expect(writesStarted, hasLength(1));

    oldWrite.complete();
    await Future.wait([firstRefresh, secondRefresh]);
    expect(writesStarted, [modelPage(), fresh]);
    expect(persisted, fresh);
  });

  test('a pending pagination cache read cannot merge over a refresh', () async {
    final oldRead = Completer<CachedBreedsSnapshot?>();
    when(() => local.readBreeds()).thenAnswer((_) => oldRead.future);
    when(
      () => remote.getBreeds(page: 2, limit: 10),
    ).thenAnswer((_) async => modelPage(page: 2));
    final pagination = repository.getBreedsPage(page: 2);
    await pumpEventQueue();
    verify(() => local.readBreeds()).called(1);
    final fresh = modelPage(breeds: [siameseModel]);
    when(
      () => remote.getBreeds(page: 1, limit: 10),
    ).thenAnswer((_) async => fresh);
    final refresh = repository.refreshBreeds();
    await pumpEventQueue();
    oldRead.complete(CachedBreedsSnapshot(page: modelPage(), isStale: false));
    await Future.wait([pagination, refresh]);

    final writes = verify(() => local.writeBreeds(captureAny())).captured;
    expect(writes, [fresh]);
  });

  for (final lookup in [false, true]) {
    final operationName = lookup ? 'cold lookup' : 'stale revalidation';

    test('$operationName cannot persist after a newer refresh', () async {
      cache(stale: true);
      final oldRemote = Completer<BreedsPageModel>();
      when(
        () => remote.getBreeds(page: 1, limit: 10),
      ).thenAnswer((_) => oldRemote.future);
      final Future<Object?> oldOperation = lookup
          ? repository.findBreedByName('Siamese')
          : repository.watchBreeds().toList();
      await pumpEventQueue();
      verify(() => remote.getBreeds(page: 1, limit: 10)).called(1);
      final fresh = modelPage(
        breeds: [koratModel.copyWith(country: 'Updated')],
      );
      when(
        () => remote.getBreeds(page: 1, limit: 10),
      ).thenAnswer((_) async => fresh);
      await repository.refreshBreeds();
      oldRemote.complete(modelPage(breeds: [siameseModel]));
      final result = await oldOperation;

      // Superseding storage does not change the old caller's return contract.
      if (lookup) {
        expect(result, siamese);
      } else {
        expect((result as List<BreedsPage>).last.breeds, [siamese]);
      }
      final writes = verify(() => local.writeBreeds(captureAny())).captured;
      expect(writes, [fresh]);
    });

    test(
      '$operationName with a slow initial cache read stays obsolete',
      () async {
        final oldRead = Completer<CachedBreedsSnapshot?>();
        when(() => local.readBreeds()).thenAnswer((_) => oldRead.future);
        final Future<Object?> oldOperation = lookup
            ? repository.findBreedByName('Siamese')
            : repository.watchBreeds().toList();
        await pumpEventQueue();
        final fresh = modelPage(
          breeds: [koratModel.copyWith(country: 'Updated')],
        );
        when(
          () => remote.getBreeds(page: 1, limit: 10),
        ).thenAnswer((_) async => fresh);
        await repository.refreshBreeds();
        when(
          () => remote.getBreeds(page: 1, limit: 10),
        ).thenAnswer((_) async => modelPage(breeds: [siameseModel]));
        oldRead.complete(
          CachedBreedsSnapshot(page: modelPage(), isStale: true),
        );
        await oldOperation;

        final writes = verify(() => local.writeBreeds(captureAny())).captured;
        expect(writes, [fresh]);
      },
    );
  }

  test('a cache-only lookup does not invalidate a refresh in flight', () async {
    cache();
    final pending = Completer<BreedsPageModel>();
    when(
      () => remote.getBreeds(page: 1, limit: 10),
    ).thenAnswer((_) => pending.future);
    final refresh = repository.refreshBreeds();
    await pumpEventQueue();
    expect(await repository.findBreedByName('Korat'), korat);
    final fresh = modelPage(breeds: [siameseModel]);
    pending.complete(fresh);
    await refresh;

    verify(() => local.writeBreeds(fresh)).called(1);
  });

  test(
    'a failed storage write does not poison the next queued snapshot',
    () async {
      final firstWrite = Completer<void>();
      var writes = 0;
      BreedsPageModel? persisted;
      when(() => local.writeBreeds(any())).thenAnswer((invocation) async {
        writes++;
        if (writes == 1) {
          await firstWrite.future;
        }
        persisted = invocation.positionalArguments.single as BreedsPageModel;
      });
      final firstRefresh = repository.refreshBreeds();
      await pumpEventQueue();
      final fresh = modelPage(breeds: [siameseModel]);
      when(
        () => remote.getBreeds(page: 1, limit: 10),
      ).thenAnswer((_) async => fresh);
      final secondRefresh = repository.refreshBreeds();
      await pumpEventQueue();
      firstWrite.completeError(StateError('disk temporarily unavailable'));
      final results = await Future.wait([firstRefresh, secondRefresh]);

      expect(results.first.breeds, [korat]);
      expect(results.last.breeds, [siamese]);
      expect(writes, 2);
      expect(persisted, fresh);
    },
  );

  test('blank breed name does not access storage or network', () async {
    expect(await repository.findBreedByName('  '), isNull);
    verifyZeroInteractions(local);
    verifyZeroInteractions(remote);
    verifyZeroInteractions(network);
  });

  test('cold lookup normalizes names and uses stale cache offline', () async {
    cache(stale: true);
    when(() => network.hasConnection).thenAnswer((_) async => false);
    expect(await repository.findBreedByName(' KORAT '), korat);
    verifyZeroInteractions(remote);
    verifyZeroInteractions(network);
  });

  test('fresh complete cache can establish that a breed is absent', () async {
    cache(last: 1);
    expect(await repository.findBreedByName('Unknown'), isNull);
    verifyZeroInteractions(remote);
    verifyZeroInteractions(network);
  });

  test(
    'cold lookup paginates, accumulates cache and stops when found',
    () async {
      when(() => remote.getBreeds(page: 2, limit: 10)).thenAnswer(
        (_) async => modelPage(page: 2, last: 3, breeds: [siameseModel]),
      );
      expect(await repository.findBreedByName('siamese'), siamese);
      verifyInOrder([
        () => remote.getBreeds(page: 1, limit: 10),
        () => remote.getBreeds(page: 2, limit: 10),
      ]);
      verifyNoMoreInteractions(remote);
      final saved = verify(
        () => local.writeBreeds(captureAny()),
      ).captured.cast<BreedsPageModel>();
      expect(saved.last.data, [koratModel, siameseModel]);
    },
  );

  test(
    'stale complete cache still rechecks a missing breed remotely',
    () async {
      cache(stale: true, last: 1);
      when(
        () => remote.getBreeds(page: 1, limit: 10),
      ).thenAnswer((_) async => modelPage(last: 1, breeds: [siameseModel]));
      expect(await repository.findBreedByName('Siamese'), siamese);
      verify(() => remote.getBreeds(page: 1, limit: 10)).called(1);
    },
  );

  test(
    'not found is returned only after exhausting successful pages',
    () async {
      when(
        () => remote.getBreeds(page: 2, limit: 10),
      ).thenAnswer((_) async => modelPage(page: 2, breeds: [siameseModel]));
      expect(await repository.findBreedByName('Unknown'), isNull);
      verify(() => remote.getBreeds(page: 2, limit: 10)).called(1);
    },
  );

  test(
    'a failed intermediate lookup page is not mistaken for not found',
    () async {
      when(
        () => remote.getBreeds(page: 2, limit: 10),
      ).thenThrow(const Failure.timeout());
      await expectLater(
        repository.findBreedByName('Unknown'),
        throwsA(const Failure.timeout()),
      );
      verify(() => local.writeBreeds(modelPage())).called(1);
    },
  );

  test(
    'random fact maps to a domain entity without touching the breeds cache',
    () async {
      when(() => remote.getRandomFact()).thenAnswer(
        (_) async => const CatFactModel(fact: 'Cats sleep a lot.', length: 17),
      );
      expect(await repository.getRandomFact(), fact);
      verifyZeroInteractions(local);
    },
  );

  final dioFailures = {
    DioExceptionType.connectionTimeout: const Failure.timeout(),
    DioExceptionType.sendTimeout: const Failure.timeout(),
    DioExceptionType.receiveTimeout: const Failure.timeout(),
    DioExceptionType.transformTimeout: const Failure.timeout(),
    DioExceptionType.connectionError: const Failure.noConnection(),
    DioExceptionType.cancel: const Failure.cancelled(),
    DioExceptionType.badCertificate: const Failure.unexpected(),
    DioExceptionType.unknown: const Failure.unexpected(),
  };
  for (final entry in dioFailures.entries) {
    test('maps ${entry.key} to ${entry.value}', () async {
      when(() => remote.getRandomFact()).thenThrow(
        DioException(requestOptions: RequestOptions(), type: entry.key),
      );
      await expectLater(repository.getRandomFact(), throwsA(entry.value));
    });
  }
  for (final status in <int?>[null, 400, 404, 429, 500, 503]) {
    test('maps HTTP $status to a typed failure', () async {
      final request = RequestOptions();
      when(() => remote.getRandomFact()).thenThrow(
        DioException(
          requestOptions: request,
          type: DioExceptionType.badResponse,
          response: Response<Object?>(
            requestOptions: request,
            statusCode: status,
          ),
        ),
      );
      final expected = status == null
          ? const Failure.unexpected()
          : status >= 500
          ? Failure.server(statusCode: status)
          : Failure.client(statusCode: status);
      await expectLater(repository.getRandomFact(), throwsA(expected));
    });
  }
  test('preserves already typed failures', () async {
    when(() => remote.getRandomFact()).thenThrow(const Failure.cancelled());
    await expectLater(
      repository.getRandomFact(),
      throwsA(const Failure.cancelled()),
    );
  });
  test('invalid response gets an explanatory typed failure', () async {
    when(() => remote.getRandomFact()).thenThrow(const FormatException());
    await expectLater(
      repository.getRandomFact(),
      throwsA(
        const Failure.unexpected(message: 'Respuesta inválida de la API.'),
      ),
    );
  });
  test('unexpected exceptions never escape raw', () async {
    when(() => remote.getRandomFact()).thenThrow(StateError('broken'));
    await expectLater(
      repository.getRandomFact(),
      throwsA(const Failure.unexpected()),
    );
  });
}
