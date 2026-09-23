// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cat_fact_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_CatFactModel _$CatFactModelFromJson(Map<String, dynamic> json) =>
    _CatFactModel(
      fact: json['fact'] as String,
      length: (json['length'] as num).toInt(),
    );

Map<String, dynamic> _$CatFactModelToJson(_CatFactModel instance) =>
    <String, dynamic>{'fact': instance.fact, 'length': instance.length};
