import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:cat_directory_app/core/error/failure.dart';
import 'package:cat_directory_app/features/breeds/domain/entities/breed.dart';
import 'package:cat_directory_app/features/breeds/domain/entities/breeds_page.dart';
import 'package:cat_directory_app/features/breeds/domain/repositories/breeds_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:stream_transform/stream_transform.dart';

part 'breeds_event.dart';
part 'breeds_state.dart';

final class BreedsBloc extends Bloc<BreedsEvent, BreedsState> {
  BreedsBloc(this._repository) : super(BreedsState.initial()) {
    on<BreedsStarted>(_onStarted, transformer: restartable());
    on<BreedsNextPageRequested>(_onNextPageRequested, transformer: droppable());
    on<BreedsRefreshed>(_onRefreshed, transformer: restartable());
    on<BreedsSearchChanged>(
      _onSearchChanged,
      transformer: _debounceSwitchMap(_searchDebounce),
    );
  }

  static const _searchDebounce = Duration(milliseconds: 300);

  final BreedsRepository _repository;
  int _catalogRevision = 0;

  Future<void> _onStarted(
    BreedsStarted event,
    Emitter<BreedsState> emit,
  ) async {
    final revision = ++_catalogRevision;
    emit(
      state.copyWith(
        status: BreedsStatus.loading,
        isLoadingNextPage: false,
        isRefreshing: false,
        isRevalidating: false,
        clearFailure: true,
      ),
    );

    try {
      await for (final page in _repository.watchBreeds()) {
        if (revision != _catalogRevision) {
          return;
        }
        emit(_replaceCatalog(page));
      }
    } on Failure catch (failure) {
      if (revision == _catalogRevision) {
        _emitFailure(
          emit,
          failure,
          source: state.hasData
              ? BreedsFailureSource.revalidation
              : BreedsFailureSource.initialLoad,
        );
      }
    } on Object {
      if (revision == _catalogRevision) {
        _emitFailure(
          emit,
          const Failure.unexpected(),
          source: state.hasData
              ? BreedsFailureSource.revalidation
              : BreedsFailureSource.initialLoad,
        );
      }
    }
  }

  Future<void> _onNextPageRequested(
    BreedsNextPageRequested event,
    Emitter<BreedsState> emit,
  ) async {
    if (state.status != BreedsStatus.success ||
        state.isLoadingNextPage ||
        state.isRefreshing ||
        state.isRevalidating ||
        !state.hasNextPage) {
      return;
    }

    final revision = _catalogRevision;
    final nextPage = state.currentPage + 1;
    emit(state.copyWith(isLoadingNextPage: true, clearFailure: true));

    try {
      final page = await _repository.getBreedsPage(page: nextPage);
      if (revision != _catalogRevision) {
        return;
      }

      emit(
        state.copyWith(
          status: BreedsStatus.success,
          breeds: _mergeBreeds(state.breeds, page.breeds),
          currentPage: page.currentPage,
          hasNextPage: page.hasNextPage,
          isLoadingNextPage: false,
          isRevalidating: false,
          isFromCache: false,
          isStale: false,
          clearFailure: true,
        ),
      );
    } on Failure catch (failure) {
      if (revision == _catalogRevision) {
        _emitFailure(
          emit,
          failure,
          source: BreedsFailureSource.nextPage,
        );
      }
    } on Object {
      if (revision == _catalogRevision) {
        _emitFailure(
          emit,
          const Failure.unexpected(),
          source: BreedsFailureSource.nextPage,
        );
      }
    }
  }

  Future<void> _onRefreshed(
    BreedsRefreshed event,
    Emitter<BreedsState> emit,
  ) async {
    final revision = ++_catalogRevision;
    emit(
      state.copyWith(
        status: state.hasData ? BreedsStatus.success : BreedsStatus.loading,
        isLoadingNextPage: false,
        isRefreshing: state.hasData,
        isRevalidating: false,
        clearFailure: true,
      ),
    );

    try {
      final page = await _repository.refreshBreeds();
      if (revision != _catalogRevision) {
        return;
      }
      emit(_replaceCatalog(page));
    } on Failure catch (failure) {
      if (revision == _catalogRevision) {
        _emitFailure(
          emit,
          failure,
          source: BreedsFailureSource.refresh,
        );
      }
    } on Object {
      if (revision == _catalogRevision) {
        _emitFailure(
          emit,
          const Failure.unexpected(),
          source: BreedsFailureSource.refresh,
        );
      }
    }
  }

  void _onSearchChanged(BreedsSearchChanged event, Emitter<BreedsState> emit) {
    emit(state.copyWith(query: event.query, clearFailure: state.hasData));
  }

  BreedsState _replaceCatalog(BreedsPage page) {
    return state.copyWith(
      status: BreedsStatus.success,
      breeds: page.breeds,
      currentPage: page.currentPage,
      hasNextPage: page.hasNextPage,
      isLoadingNextPage: false,
      isRefreshing: false,
      isRevalidating: page.isStale,
      isFromCache: page.isFromCache,
      isStale: page.isStale,
      clearFailure: true,
    );
  }

  void _emitFailure(
    Emitter<BreedsState> emit,
    Failure failure, {
    required BreedsFailureSource source,
  }) {
    emit(
      state.copyWith(
        status: state.hasData ? BreedsStatus.success : BreedsStatus.failure,
        isLoadingNextPage: false,
        isRefreshing: false,
        isRevalidating: false,
        failure: failure,
        failureSource: source,
      ),
    );
  }

  List<Breed> _mergeBreeds(List<Breed> current, List<Breed> incoming) {
    final merged = <String, Breed>{
      for (final breed in current) _normalize(breed.name): breed,
    };
    for (final breed in incoming) {
      merged[_normalize(breed.name)] = breed;
    }
    return merged.values.toList(growable: false);
  }

  String _normalize(String value) => value.trim().toLowerCase();
}

EventTransformer<Event> _debounceSwitchMap<Event>(Duration duration) {
  return (events, mapper) => events.debounce(duration).switchMap(mapper);
}
