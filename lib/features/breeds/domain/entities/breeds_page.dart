import 'package:cat_directory_app/features/breeds/domain/entities/breed.dart';

final class BreedsPage {
  BreedsPage({
    required List<Breed> breeds,
    required this.currentPage,
    required this.lastPage,
    required this.perPage,
    required this.total,
    this.isFromCache = false,
    this.isStale = false,
  }) : breeds = List<Breed>.unmodifiable(breeds);

  final List<Breed> breeds;
  final int currentPage;
  final int lastPage;
  final int perPage;
  final int total;
  final bool isFromCache;
  final bool isStale;

  bool get hasNextPage => currentPage < lastPage;
}
