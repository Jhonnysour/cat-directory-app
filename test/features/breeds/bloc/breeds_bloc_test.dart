import 'dart:async';
import 'package:bloc_test/bloc_test.dart';
import 'package:cat_directory_app/core/error/failure.dart';
import 'package:cat_directory_app/features/breeds/domain/entities/breeds_page.dart';
import 'package:cat_directory_app/features/breeds/presentation/bloc/breeds_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import '../../../support/fixtures.dart';
import '../../../support/mocks.dart';

void main() {
  late MockRepository repository;
  setUp(() {
    repository = MockRepository();
  });
  BreedsState loaded() => BreedsState(
    status: BreedsStatus.success,
    breeds: [korat],
    currentPage: 1,
  );

  test('initial state is empty and not loading', () async {
    final bloc = BreedsBloc(repository);
    expect(bloc.state.status, BreedsStatus.initial);
    expect(bloc.state.breeds, isEmpty);
    expect(bloc.state.isInitialLoading, isFalse);
    await bloc.close();
  });

  blocTest<BreedsBloc, BreedsState>(
    'loads the first page',
    build: () {
      when(
        () => repository.watchBreeds(),
      ).thenAnswer((_) => Stream.value(pageOf()));
      return BreedsBloc(repository);
    },
    act: (bloc) => bloc.add(const BreedsStarted()),
    expect: () => [
      isA<BreedsState>().having(
        (s) => s.isInitialLoading,
        'initial loading',
        true,
      ),
      isA<BreedsState>()
          .having((s) => s.status, 'status', BreedsStatus.success)
          .having((s) => s.breeds, 'breeds', [korat])
          .having((s) => s.currentPage, 'page', 1),
    ],
  );

  blocTest<BreedsBloc, BreedsState>(
    'emits stale cache before fresh replacement',
    build: () {
      when(() => repository.watchBreeds()).thenAnswer(
        (_) => Stream.fromIterable([
          pageOf(cached: true, stale: true),
          pageOf(breeds: [siamese]),
        ]),
      );
      return BreedsBloc(repository);
    },
    act: (bloc) => bloc.add(const BreedsStarted()),
    expect: () => [
      isA<BreedsState>(),
      isA<BreedsState>().having(
        (s) => s.isRevalidating && s.isFromCache,
        'stale cache',
        true,
      ),
      isA<BreedsState>()
          .having((s) => s.breeds, 'fresh breeds', [siamese])
          .having(
            (s) => s.isStale || s.isRevalidating || s.isFromCache,
            'stale flags cleared',
            false,
          ),
    ],
  );

  for (final error in [
    const Failure.noConnection(),
    StateError('unexpected'),
  ]) {
    blocTest<BreedsBloc, BreedsState>(
      'initial error is typed: $error',
      build: () {
        when(
          () => repository.watchBreeds(),
        ).thenAnswer((_) => Stream.error(error));
        return BreedsBloc(repository);
      },
      act: (bloc) => bloc.add(const BreedsStarted()),
      expect: () => [
        isA<BreedsState>(),
        isA<BreedsState>()
            .having((s) => s.status, 'status', BreedsStatus.failure)
            .having(
              (s) => s.failureSource,
              'source',
              BreedsFailureSource.initialLoad,
            )
            .having(
              (s) => s.failure,
              'failure',
              error is Failure ? error : const Failure.unexpected(),
            ),
      ],
    );
  }

  blocTest<BreedsBloc, BreedsState>(
    'revalidation failure preserves the stale catalog',
    build: () {
      when(() => repository.watchBreeds()).thenAnswer((_) async* {
        yield pageOf(cached: true, stale: true);
        throw const Failure.noConnection();
      });
      return BreedsBloc(repository);
    },
    act: (bloc) => bloc.add(const BreedsStarted()),
    expect: () => [
      isA<BreedsState>(),
      isA<BreedsState>(),
      isA<BreedsState>()
          .having((s) => s.breeds, 'retained', [korat])
          .having((s) => s.status, 'status', BreedsStatus.success)
          .having(
            (s) => s.failureSource,
            'source',
            BreedsFailureSource.revalidation,
          )
          .having((s) => s.isRevalidating, 'loading stopped', false),
    ],
  );

  blocTest<BreedsBloc, BreedsState>(
    'drops concurrent pagination requests and merges normalized names',
    build: () => BreedsBloc(repository),
    seed: loaded,
    act: (bloc) async {
      final pending = Completer<BreedsPage>();
      when(
        () => repository.getBreedsPage(page: 2),
      ).thenAnswer((_) => pending.future);
      bloc.add(const BreedsNextPageRequested());
      await pumpEventQueue();
      for (var i = 0; i < 5; i++) {
        bloc.add(const BreedsNextPageRequested());
      }
      await pumpEventQueue();
      verify(() => repository.getBreedsPage(page: 2)).called(1);
      pending.complete(
        pageOf(
          page: 2,
          breeds: [
            koratModel.copyWith(breed: ' KORAT ').toEntity(),
            siamese,
          ],
        ),
      );
      await pumpEventQueue();
      verifyNever(() => repository.getBreedsPage(page: 2));
    },
    expect: () => [
      isA<BreedsState>().having((s) => s.isLoadingNextPage, 'loading', true),
      isA<BreedsState>()
          .having((s) => s.breeds.map((b) => b.name), 'deduplicated names', [
            ' KORAT ',
            'Siamese',
          ])
          .having((s) => s.hasNextPage, 'last page', false)
          .having((s) => s.isLoadingNextPage, 'loading stopped', false),
    ],
  );

  final blockedStates = <String, BreedsState>{
    'initial': BreedsState.initial(),
    'last page': BreedsState(status: BreedsStatus.success, hasNextPage: false),
    'refreshing': BreedsState(status: BreedsStatus.success, isRefreshing: true),
    'revalidating': BreedsState(
      status: BreedsStatus.success,
      isRevalidating: true,
    ),
    'already loading': BreedsState(
      status: BreedsStatus.success,
      isLoadingNextPage: true,
    ),
  };
  for (final entry in blockedStates.entries) {
    blocTest<BreedsBloc, BreedsState>(
      'does not paginate while ${entry.key}',
      build: () => BreedsBloc(repository),
      seed: () => entry.value,
      act: (bloc) => bloc.add(const BreedsNextPageRequested()),
      expect: () => [],
      verify: (_) => verifyZeroInteractions(repository),
    );
  }

  for (final error in [const Failure.timeout(), StateError('unexpected')]) {
    blocTest<BreedsBloc, BreedsState>(
      'pagination failure preserves data and cursor: $error',
      build: () {
        when(() => repository.getBreedsPage(page: 2)).thenThrow(error);
        return BreedsBloc(repository);
      },
      seed: loaded,
      act: (bloc) => bloc.add(const BreedsNextPageRequested()),
      expect: () => [
        isA<BreedsState>(),
        isA<BreedsState>()
            .having((s) => s.breeds, 'retained', [korat])
            .having((s) => s.currentPage, 'cursor', 1)
            .having(
              (s) => s.failureSource,
              'source',
              BreedsFailureSource.nextPage,
            )
            .having(
              (s) => s.failure,
              'failure',
              error is Failure ? error : const Failure.unexpected(),
            )
            .having((s) => s.isLoadingNextPage, 'loading stopped', false),
      ],
    );
  }

  test(
    'explicit retry requests the failed page and clears its error',
    () async {
      when(
        () => repository.watchBreeds(),
      ).thenAnswer((_) => Stream.value(pageOf()));
      when(
        () => repository.getBreedsPage(page: 2),
      ).thenThrow(const Failure.timeout());
      final bloc = BreedsBloc(repository);
      addTearDown(bloc.close);
      bloc.add(const BreedsStarted());
      await pumpEventQueue();
      bloc.add(const BreedsNextPageRequested());
      await pumpEventQueue();
      expect(bloc.state.failure, const Failure.timeout());
      when(
        () => repository.getBreedsPage(page: 2),
      ).thenAnswer((_) async => pageOf(page: 2, breeds: [siamese]));
      bloc.add(const BreedsNextPageRequested());
      await pumpEventQueue();
      expect(bloc.state.breeds, [korat, siamese]);
      expect(bloc.state.failure, isNull);
      expect(bloc.state.failureSource, isNull);
      verify(() => repository.getBreedsPage(page: 2)).called(2);
    },
  );

  for (final error in [const Failure.timeout(), StateError('unexpected')]) {
    blocTest<BreedsBloc, BreedsState>(
      'refresh failure preserves the current catalog: $error',
      build: () {
        when(() => repository.refreshBreeds()).thenThrow(error);
        return BreedsBloc(repository);
      },
      seed: loaded,
      act: (bloc) => bloc.add(const BreedsRefreshed()),
      expect: () => [
        isA<BreedsState>().having((s) => s.isRefreshing, 'refreshing', true),
        isA<BreedsState>()
            .having((s) => s.breeds, 'retained', [korat])
            .having(
              (s) => s.failureSource,
              'source',
              BreedsFailureSource.refresh,
            )
            .having((s) => s.isRefreshing, 'refreshing stopped', false)
            .having(
              (s) => s.failure,
              'failure',
              error is Failure ? error : const Failure.unexpected(),
            ),
      ],
    );
  }

  for (final fails in [false, true]) {
    test(
      'refresh discards a late pagination ${fails ? 'error' : 'response'}',
      () async {
        final pending = Completer<BreedsPage>();
        when(
          () => repository.watchBreeds(),
        ).thenAnswer((_) => Stream.value(pageOf()));
        when(
          () => repository.getBreedsPage(page: 2),
        ).thenAnswer((_) => pending.future);
        when(
          () => repository.refreshBreeds(),
        ).thenAnswer((_) async => pageOf(breeds: [siamese]));
        final bloc = BreedsBloc(repository);
        addTearDown(bloc.close);
        bloc.add(const BreedsStarted());
        await pumpEventQueue();
        bloc.add(const BreedsNextPageRequested());
        await pumpEventQueue();
        bloc.add(const BreedsRefreshed());
        await pumpEventQueue();
        if (fails) {
          pending.completeError(const Failure.timeout());
        } else {
          pending.complete(pageOf(page: 2));
        }
        await pumpEventQueue();
        expect(bloc.state.breeds, [siamese]);
        expect(bloc.state.currentPage, 1);
        expect(bloc.state.failure, isNull);
        expect(bloc.state.isLoadingNextPage, false);
      },
    );
  }

  test('latest refresh wins even if the previous one finishes later', () async {
    final old = Completer<BreedsPage>();
    when(() => repository.refreshBreeds()).thenAnswer((_) => old.future);
    final bloc = BreedsBloc(repository);
    addTearDown(bloc.close);
    bloc.add(const BreedsRefreshed());
    await pumpEventQueue();
    when(
      () => repository.refreshBreeds(),
    ).thenAnswer((_) async => pageOf(breeds: [siamese]));
    bloc.add(const BreedsRefreshed());
    await pumpEventQueue();
    old.complete(pageOf());
    await pumpEventQueue();
    expect(bloc.state.breeds, [siamese]);
    expect(bloc.state.isRefreshing, false);
  });

  test('refresh supersedes a stale startup stream', () async {
    final startup = StreamController<BreedsPage>();
    when(() => repository.watchBreeds()).thenAnswer((_) => startup.stream);
    when(
      () => repository.refreshBreeds(),
    ).thenAnswer((_) async => pageOf(breeds: [siamese]));
    final bloc = BreedsBloc(repository);
    addTearDown(bloc.close);
    bloc.add(const BreedsStarted());
    await pumpEventQueue();
    startup.add(pageOf(cached: true, stale: true));
    await pumpEventQueue();
    expect(bloc.state.isRevalidating, true);
    bloc.add(const BreedsNextPageRequested());
    await pumpEventQueue();
    verifyNever(() => repository.getBreedsPage(page: any(named: 'page')));
    bloc.add(const BreedsRefreshed());
    await pumpEventQueue();
    startup.add(pageOf());
    await pumpEventQueue();
    await startup.close();
    expect(bloc.state.breeds, [siamese]);
    expect(bloc.state.isRevalidating, false);
  });

  test('restarting the catalog ignores an earlier pending startup', () async {
    final old = Completer<BreedsPage>();
    when(
      () => repository.watchBreeds(),
    ).thenAnswer((_) => Stream.fromFuture(old.future));
    final bloc = BreedsBloc(repository);
    addTearDown(bloc.close);
    bloc.add(const BreedsStarted());
    await pumpEventQueue();
    when(
      () => repository.watchBreeds(),
    ).thenAnswer((_) => Stream.value(pageOf(breeds: [siamese])));
    bloc.add(const BreedsStarted());
    await pumpEventQueue();
    old.complete(pageOf());
    await pumpEventQueue();
    expect(bloc.state.breeds, [siamese]);
    verify(() => repository.watchBreeds()).called(2);
  });

  test(
    'search debounces the latest query and clearing restores the catalog',
    () async {
      when(
        () => repository.watchBreeds(),
      ).thenAnswer((_) => Stream.value(pageOf(breeds: [korat, siamese])));
      final bloc = BreedsBloc(repository);
      addTearDown(bloc.close);
      bloc.add(const BreedsStarted());
      await pumpEventQueue();
      bloc.add(const BreedsSearchChanged('Sia'));
      await Future<void>.delayed(const Duration(milliseconds: 100));
      final filtered = bloc.stream.firstWhere((s) => s.query == ' KOR ');
      bloc.add(const BreedsSearchChanged(' KOR '));
      await Future<void>.delayed(const Duration(milliseconds: 200));
      expect(bloc.state.query, '');
      await filtered.timeout(const Duration(seconds: 5));
      expect(bloc.state.visibleBreeds, [korat]);
      final cleared = bloc.stream.firstWhere((s) => s.query.isEmpty);
      bloc.add(const BreedsSearchChanged(''));
      await cleared.timeout(const Duration(seconds: 5));
      expect(bloc.state.visibleBreeds, [korat, siamese]);
      verify(() => repository.watchBreeds()).called(1);
      verifyNoMoreInteractions(repository);
    },
  );

  test(
    'state protects its catalog against mutation and clears errors explicitly',
    () {
      final input = [korat];
      final state = loaded().copyWith(
        breeds: input,
        failure: const Failure.timeout(),
        failureSource: BreedsFailureSource.nextPage,
      );
      input.clear();
      expect(state.breeds, [korat]);
      expect(() => state.breeds.clear(), throwsUnsupportedError);
      expect(state.copyWith(query: 'missing').visibleBreeds, isEmpty);
      expect(state.copyWith(query: '  ').visibleBreeds, [korat]);
      expect(state.copyWith(query: 'kor').failure, const Failure.timeout());
      expect(state.copyWith(clearFailure: true).failureSource, isNull);
    },
  );
}
