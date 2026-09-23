part of 'breeds_bloc.dart';

sealed class BreedsEvent {
  const BreedsEvent();
}

final class BreedsStarted extends BreedsEvent {
  const BreedsStarted();
}

final class BreedsNextPageRequested extends BreedsEvent {
  const BreedsNextPageRequested();
}

final class BreedsRefreshed extends BreedsEvent {
  const BreedsRefreshed();
}

final class BreedsSearchChanged extends BreedsEvent {
  const BreedsSearchChanged(this.query);

  final String query;
}
