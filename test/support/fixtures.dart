import 'package:cat_directory_app/features/breeds/data/models/breed_model.dart';
import 'package:cat_directory_app/features/breeds/data/models/breeds_page_model.dart';
import 'package:cat_directory_app/features/breeds/domain/entities/breed.dart';
import 'package:cat_directory_app/features/breeds/domain/entities/breeds_page.dart';
import 'package:cat_directory_app/features/breeds/domain/entities/cat_fact.dart';

const koratModel = BreedModel(
  breed: 'Korat',
  country: 'Thailand',
  origin: 'Natural',
  coat: 'Short',
  pattern: 'Solid',
);
const siameseModel = BreedModel(
  breed: 'Siamese',
  country: 'Thailand',
  origin: 'Natural',
  coat: 'Short',
  pattern: 'Point',
);
final korat = koratModel.toEntity();
final siamese = siameseModel.toEntity();
const fact = CatFact(text: 'Cats sleep a lot.', length: 17);

BreedsPageModel modelPage({
  int page = 1,
  int last = 2,
  List<BreedModel> breeds = const [koratModel],
}) => BreedsPageModel(
  currentPage: page,
  lastPage: last,
  perPage: 10,
  total: 20,
  data: breeds,
);

BreedsPage pageOf({
  int page = 1,
  int last = 2,
  List<Breed>? breeds,
  bool cached = false,
  bool stale = false,
}) => BreedsPage(
  breeds: breeds ?? [korat],
  currentPage: page,
  lastPage: last,
  perPage: 10,
  total: 20,
  isFromCache: cached,
  isStale: stale,
);
