import 'package:cat_directory_app/features/breeds/domain/entities/cat_fact.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'cat_fact_model.freezed.dart';
part 'cat_fact_model.g.dart';

@freezed
abstract class CatFactModel with _$CatFactModel {
  const CatFactModel._();

  const factory CatFactModel({required String fact, required int length}) =
      _CatFactModel;

  factory CatFactModel.fromJson(Map<String, dynamic> json) =>
      _$CatFactModelFromJson(json);

  CatFact toEntity() => CatFact(text: fact, length: length);
}
