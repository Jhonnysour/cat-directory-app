part of 'breed_detail_bloc.dart';

sealed class BreedDetailState {
  const BreedDetailState();
}

final class BreedDetailInitial extends BreedDetailState {
  const BreedDetailInitial();
}

final class BreedDetailLoading extends BreedDetailState {
  const BreedDetailLoading();
}

final class BreedDetailNotFound extends BreedDetailState {
  const BreedDetailNotFound(this.requestedName);

  final String requestedName;
}

final class BreedDetailFailure extends BreedDetailState {
  const BreedDetailFailure(this.failure);

  final Failure failure;
}

enum BreedFactStatus { initial, loading, success, failure }

final class BreedDetailLoaded extends BreedDetailState {
  const BreedDetailLoaded({
    required this.breed,
    this.factStatus = BreedFactStatus.initial,
    this.fact,
    this.factFailure,
  });

  final Breed breed;
  final BreedFactStatus factStatus;
  final CatFact? fact;
  final Failure? factFailure;

  BreedDetailLoaded copyWith({
    BreedFactStatus? factStatus,
    CatFact? fact,
    Failure? factFailure,
    bool clearFact = false,
    bool clearFactFailure = false,
  }) {
    return BreedDetailLoaded(
      breed: breed,
      factStatus: factStatus ?? this.factStatus,
      fact: clearFact ? null : fact ?? this.fact,
      factFailure: clearFactFailure ? null : factFailure ?? this.factFailure,
    );
  }
}
