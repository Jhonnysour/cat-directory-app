// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'breeds_page_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_BreedsPageModel _$BreedsPageModelFromJson(Map<String, dynamic> json) =>
    _BreedsPageModel(
      currentPage: (json['current_page'] as num).toInt(),
      data: (json['data'] as List<dynamic>)
          .map((e) => BreedModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      lastPage: (json['last_page'] as num).toInt(),
      perPage: (json['per_page'] as num).toInt(),
      total: (json['total'] as num).toInt(),
      nextPageUrl: json['next_page_url'] as String?,
      previousPageUrl: json['prev_page_url'] as String?,
    );

Map<String, dynamic> _$BreedsPageModelToJson(_BreedsPageModel instance) =>
    <String, dynamic>{
      'current_page': instance.currentPage,
      'data': instance.data.map((e) => e.toJson()).toList(),
      'last_page': instance.lastPage,
      'per_page': instance.perPage,
      'total': instance.total,
      'next_page_url': instance.nextPageUrl,
      'prev_page_url': instance.previousPageUrl,
    };
