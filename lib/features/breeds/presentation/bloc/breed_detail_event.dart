part of 'breed_detail_bloc.dart';

sealed class BreedDetailEvent {
  const BreedDetailEvent();
}

final class BreedDetailStarted extends BreedDetailEvent {
  const BreedDetailStarted({required this.name, this.initialBreed});

  final String name;
  final Breed? initialBreed;
}

final class BreedFactRequested extends BreedDetailEvent {
  const BreedFactRequested();
}
