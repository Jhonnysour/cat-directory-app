part of 'breeds_bloc.dart';

enum BreedsStatus { initial, loading, success, failure }

final class BreedsState {
  BreedsState({
    this.status = BreedsStatus.initial,
    List<Breed> breeds = const [],
    this.query = '',
    this.currentPage = 0,
    this.hasNextPage = true,
    this.isLoadingNextPage = false,
    this.isRefreshing = false,
    this.isRevalidating = false,
    this.isFromCache = false,
    this.isStale = false,
    this.failure,
  }) : breeds = List<Breed>.unmodifiable(breeds);

  factory BreedsState.initial() => BreedsState();

  final BreedsStatus status;
  final List<Breed> breeds;
  final String query;
  final int currentPage;
  final bool hasNextPage;
  final bool isLoadingNextPage;
  final bool isRefreshing;
  final bool isRevalidating;
  final bool isFromCache;
  final bool isStale;
  final Failure? failure;

  bool get hasData => breeds.isNotEmpty;

  bool get isInitialLoading => status == BreedsStatus.loading && !hasData;

  List<Breed> get visibleBreeds {
    final normalizedQuery = query.trim().toLowerCase();
    if (normalizedQuery.isEmpty) {
      return breeds;
    }
    return List<Breed>.unmodifiable(
      breeds.where(
        (breed) => breed.name.toLowerCase().contains(normalizedQuery),
      ),
    );
  }

  BreedsState copyWith({
    BreedsStatus? status,
    List<Breed>? breeds,
    String? query,
    int? currentPage,
    bool? hasNextPage,
    bool? isLoadingNextPage,
    bool? isRefreshing,
    bool? isRevalidating,
    bool? isFromCache,
    bool? isStale,
    Failure? failure,
    bool clearFailure = false,
  }) {
    return BreedsState(
      status: status ?? this.status,
      breeds: breeds ?? this.breeds,
      query: query ?? this.query,
      currentPage: currentPage ?? this.currentPage,
      hasNextPage: hasNextPage ?? this.hasNextPage,
      isLoadingNextPage: isLoadingNextPage ?? this.isLoadingNextPage,
      isRefreshing: isRefreshing ?? this.isRefreshing,
      isRevalidating: isRevalidating ?? this.isRevalidating,
      isFromCache: isFromCache ?? this.isFromCache,
      isStale: isStale ?? this.isStale,
      failure: clearFailure ? null : failure ?? this.failure,
    );
  }
}
