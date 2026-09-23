import 'dart:async';
import 'package:bloc_test/bloc_test.dart';
import 'package:cat_directory_app/core/error/failure.dart';
import 'package:cat_directory_app/features/breeds/domain/entities/breed.dart';
import 'package:cat_directory_app/features/breeds/domain/entities/cat_fact.dart';
import 'package:cat_directory_app/features/breeds/presentation/bloc/breed_detail_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import '../../../support/fixtures.dart';
import '../../../support/mocks.dart';

void main() {
  late MockRepository repository;
  setUp(() {
    repository = MockRepository();
    when(() => repository.getRandomFact()).thenAnswer((_) async => fact);
    when(
      () => repository.findBreedByName(any()),
    ).thenAnswer((_) async => korat);
  });

  blocTest<BreedDetailBloc, BreedDetailState>(
    'uses the provided breed without looking it up',
    build: () => BreedDetailBloc(repository),
    act: (bloc) =>
        bloc.add(BreedDetailStarted(name: 'Korat', initialBreed: korat)),
    expect: () => [
      isA<BreedDetailLoading>(),
      isA<BreedDetailLoaded>().having((s) => s.breed, 'breed', korat),
      isA<BreedDetailLoaded>().having(
        (s) => s.factStatus,
        'fact loading',
        BreedFactStatus.loading,
      ),
      isA<BreedDetailLoaded>()
          .having((s) => s.fact, 'fact', fact)
          .having((s) => s.factStatus, 'status', BreedFactStatus.success),
    ],
    verify: (_) {
      verifyNever(() => repository.findBreedByName(any()));
      verify(() => repository.getRandomFact()).called(1);
    },
  );
  blocTest<BreedDetailBloc, BreedDetailState>(
    'cold link resolves the name before fetching a fact',
    build: () => BreedDetailBloc(repository),
    act: (bloc) => bloc.add(const BreedDetailStarted(name: 'Korat')),
    verify: (bloc) {
      expect((bloc.state as BreedDetailLoaded).breed, korat);
      verifyInOrder([
        () => repository.findBreedByName('Korat'),
        () => repository.getRandomFact(),
      ]);
    },
  );
  blocTest<BreedDetailBloc, BreedDetailState>(
    'absent breed does not fetch a fact',
    build: () {
      when(
        () => repository.findBreedByName('Unknown'),
      ).thenAnswer((_) async => null);
      return BreedDetailBloc(repository);
    },
    act: (bloc) => bloc.add(const BreedDetailStarted(name: 'Unknown')),
    expect: () => [
      isA<BreedDetailLoading>(),
      isA<BreedDetailNotFound>().having(
        (s) => s.requestedName,
        'name',
        'Unknown',
      ),
    ],
    verify: (_) => verifyNever(() => repository.getRandomFact()),
  );
  for (final error in [
    const Failure.noConnection(),
    StateError('unexpected'),
  ]) {
    blocTest<BreedDetailBloc, BreedDetailState>(
      'lookup error is not not-found: $error',
      build: () {
        when(() => repository.findBreedByName(any())).thenThrow(error);
        return BreedDetailBloc(repository);
      },
      act: (bloc) => bloc.add(const BreedDetailStarted(name: 'Korat')),
      expect: () => [
        isA<BreedDetailLoading>(),
        isA<BreedDetailFailure>().having(
          (s) => s.failure,
          'typed error',
          error is Failure ? error : const Failure.unexpected(),
        ),
      ],
      verify: (_) => verifyNever(() => repository.getRandomFact()),
    );
    blocTest<BreedDetailBloc, BreedDetailState>(
      'fact error keeps breed information: $error',
      build: () {
        when(() => repository.getRandomFact()).thenThrow(error);
        return BreedDetailBloc(repository);
      },
      seed: () => BreedDetailLoaded(breed: korat),
      act: (bloc) => bloc.add(const BreedFactRequested()),
      expect: () => [
        isA<BreedDetailLoaded>(),
        isA<BreedDetailLoaded>()
            .having((s) => s.breed, 'retained breed', korat)
            .having((s) => s.factStatus, 'status', BreedFactStatus.failure)
            .having(
              (s) => s.factFailure,
              'typed error',
              error is Failure ? error : const Failure.unexpected(),
            ),
      ],
    );
  }
  blocTest<BreedDetailBloc, BreedDetailState>(
    'fact request is ignored before a breed is loaded',
    build: () => BreedDetailBloc(repository),
    act: (bloc) => bloc.add(const BreedFactRequested()),
    expect: () => [],
    verify: (_) => verifyZeroInteractions(repository),
  );
  blocTest<BreedDetailBloc, BreedDetailState>(
    'retry clears old fact failure and succeeds independently',
    build: () => BreedDetailBloc(repository),
    seed: () => BreedDetailLoaded(
      breed: korat,
      factStatus: BreedFactStatus.failure,
      factFailure: const Failure.timeout(),
    ),
    act: (bloc) => bloc.add(const BreedFactRequested()),
    expect: () => [
      isA<BreedDetailLoaded>()
          .having((s) => s.factFailure, 'error cleared', isNull)
          .having((s) => s.factStatus, 'loading', BreedFactStatus.loading),
      isA<BreedDetailLoaded>()
          .having((s) => s.fact, 'fact', fact)
          .having((s) => s.breed, 'breed', korat),
    ],
  );
  test('drops concurrent fact requests but allows a later new fact', () async {
    final pending = Completer<CatFact>();
    when(() => repository.getRandomFact()).thenAnswer((_) => pending.future);
    final bloc = BreedDetailBloc(repository);
    addTearDown(bloc.close);
    bloc.add(BreedDetailStarted(name: 'Korat', initialBreed: korat));
    await pumpEventQueue();
    expect(
      (bloc.state as BreedDetailLoaded).factStatus,
      BreedFactStatus.loading,
    );
    for (var i = 0; i < 5; i++) {
      bloc.add(const BreedFactRequested());
    }
    await pumpEventQueue();
    verify(() => repository.getRandomFact()).called(1);
    pending.complete(fact);
    await pumpEventQueue();
    when(
      () => repository.getRandomFact(),
    ).thenAnswer((_) async => const CatFact(text: 'Another fact', length: 12));
    bloc.add(const BreedFactRequested());
    await pumpEventQueue();
    expect((bloc.state as BreedDetailLoaded).fact!.text, 'Another fact');
    verify(() => repository.getRandomFact()).called(1);
  });
  for (final fails in [false, true]) {
    test(
      'new route ignores the superseded lookup ${fails ? 'error' : 'result'}',
      () async {
        final old = Completer<Breed?>();
        when(
          () => repository.findBreedByName('Old'),
        ).thenAnswer((_) => old.future);
        when(
          () => repository.findBreedByName('Siamese'),
        ).thenAnswer((_) async => siamese);
        final bloc = BreedDetailBloc(repository);
        addTearDown(bloc.close);
        bloc.add(const BreedDetailStarted(name: 'Old'));
        await pumpEventQueue();
        bloc.add(const BreedDetailStarted(name: 'Siamese'));
        await pumpEventQueue();
        if (fails) {
          old.completeError(const Failure.timeout());
        } else {
          old.complete(korat);
        }
        await pumpEventQueue();
        expect((bloc.state as BreedDetailLoaded).breed, siamese);
        verify(() => repository.getRandomFact()).called(1);
      },
    );
  }
  test('late fact cannot replace a not-found screen', () async {
    final pending = Completer<CatFact>();
    when(() => repository.getRandomFact()).thenAnswer((_) => pending.future);
    when(
      () => repository.findBreedByName('Unknown'),
    ).thenAnswer((_) async => null);
    final bloc = BreedDetailBloc(repository);
    addTearDown(bloc.close);
    bloc.add(BreedDetailStarted(name: 'Korat', initialBreed: korat));
    await pumpEventQueue();
    bloc.add(const BreedDetailStarted(name: 'Unknown'));
    await pumpEventQueue();
    pending.complete(fact);
    await pumpEventQueue();
    expect(bloc.state, isA<BreedDetailNotFound>());
  });
  test('copyWith can clear fact and error without changing the breed', () {
    final state = BreedDetailLoaded(
      breed: korat,
      fact: fact,
      factFailure: const Failure.timeout(),
    );
    final cleared = state.copyWith(clearFact: true, clearFactFailure: true);
    expect(cleared.breed, korat);
    expect(cleared.fact, isNull);
    expect(cleared.factFailure, isNull);
    expect(state.copyWith().fact, fact);
  });
}
