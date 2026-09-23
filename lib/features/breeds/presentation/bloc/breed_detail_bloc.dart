import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:cat_directory_app/core/error/failure.dart';
import 'package:cat_directory_app/features/breeds/domain/entities/breed.dart';
import 'package:cat_directory_app/features/breeds/domain/entities/cat_fact.dart';
import 'package:cat_directory_app/features/breeds/domain/repositories/breeds_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'breed_detail_event.dart';
part 'breed_detail_state.dart';

final class BreedDetailBloc extends Bloc<BreedDetailEvent, BreedDetailState> {
  BreedDetailBloc(this._repository) : super(const BreedDetailInitial()) {
    on<BreedDetailStarted>(_onStarted, transformer: restartable());
    on<BreedFactRequested>(_onFactRequested, transformer: droppable());
  }

  final BreedsRepository _repository;

  Future<void> _onStarted(
    BreedDetailStarted event,
    Emitter<BreedDetailState> emit,
  ) async {
    emit(const BreedDetailLoading());

    try {
      final breed =
          event.initialBreed ?? await _repository.findBreedByName(event.name);
      if (emit.isDone) {
        return;
      }
      if (breed == null) {
        emit(BreedDetailNotFound(event.name));
        return;
      }

      emit(BreedDetailLoaded(breed: breed));
      add(const BreedFactRequested());
    } on Failure catch (failure) {
      if (!emit.isDone) {
        emit(BreedDetailFailure(failure));
      }
    } on Object {
      if (!emit.isDone) {
        emit(const BreedDetailFailure(Failure.unexpected()));
      }
    }
  }

  Future<void> _onFactRequested(
    BreedFactRequested event,
    Emitter<BreedDetailState> emit,
  ) async {
    final current = state;
    if (current is! BreedDetailLoaded) {
      return;
    }

    emit(
      current.copyWith(
        factStatus: BreedFactStatus.loading,
        clearFact: true,
        clearFactFailure: true,
      ),
    );

    try {
      final fact = await _repository.getRandomFact();
      if (emit.isDone || state is! BreedDetailLoaded) {
        return;
      }
      emit(
        (state as BreedDetailLoaded).copyWith(
          factStatus: BreedFactStatus.success,
          fact: fact,
          clearFactFailure: true,
        ),
      );
    } on Failure catch (failure) {
      if (!emit.isDone && state is BreedDetailLoaded) {
        emit(
          (state as BreedDetailLoaded).copyWith(
            factStatus: BreedFactStatus.failure,
            factFailure: failure,
          ),
        );
      }
    } on Object {
      if (!emit.isDone && state is BreedDetailLoaded) {
        emit(
          (state as BreedDetailLoaded).copyWith(
            factStatus: BreedFactStatus.failure,
            factFailure: const Failure.unexpected(),
          ),
        );
      }
    }
  }
}
