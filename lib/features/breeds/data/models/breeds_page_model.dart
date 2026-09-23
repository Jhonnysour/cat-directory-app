import 'package:cat_directory_app/features/breeds/data/models/breed_model.dart';
import 'package:cat_directory_app/features/breeds/domain/entities/breeds_page.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'breeds_page_model.freezed.dart';
part 'breeds_page_model.g.dart';

@freezed
abstract class BreedsPageModel with _$BreedsPageModel {
  const BreedsPageModel._();

  @JsonSerializable(explicitToJson: true)
  const factory BreedsPageModel({
    @JsonKey(name: 'current_page') required int currentPage,
    required List<BreedModel> data,
    @JsonKey(name: 'last_page') required int lastPage,
    @JsonKey(name: 'per_page') required int perPage,
    required int total,
    @JsonKey(name: 'next_page_url') String? nextPageUrl,
    @JsonKey(name: 'prev_page_url') String? previousPageUrl,
  }) = _BreedsPageModel;

  factory BreedsPageModel.fromJson(Map<String, dynamic> json) =>
      _$BreedsPageModelFromJson(json);

  BreedsPage toEntity({bool isFromCache = false, bool isStale = false}) =>
      BreedsPage(
        breeds: data.map((breed) => breed.toEntity()).toList(growable: false),
        currentPage: currentPage,
        lastPage: lastPage,
        perPage: perPage,
        total: total,
        isFromCache: isFromCache,
        isStale: isStale,
      );
}
