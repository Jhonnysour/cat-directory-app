import 'package:cat_directory_app/features/breeds/domain/entities/breed.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'breed_model.freezed.dart';
part 'breed_model.g.dart';

@freezed
abstract class BreedModel with _$BreedModel {
  const BreedModel._();

  const factory BreedModel({
    required String breed,
    required String country,
    required String origin,
    required String coat,
    required String pattern,
  }) = _BreedModel;

  factory BreedModel.fromJson(Map<String, dynamic> json) =>
      _$BreedModelFromJson(json);

  Breed toEntity() => Breed(
    name: breed,
    country: country,
    origin: origin,
    coat: coat,
    pattern: pattern,
  );
}
