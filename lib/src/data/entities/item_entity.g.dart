// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'item_entity.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ItemEntity _$ItemEntityFromJson(Map<String, dynamic> json) => ItemEntity(
  storyId: (json['story_id'] as num).toInt(),
  title: json['title'] as String,
  createdAtI: (json['created_at_i'] as num).toInt(),
);

Map<String, dynamic> _$ItemEntityToJson(ItemEntity instance) =>
    <String, dynamic>{
      'story_id': instance.storyId,
      'title': instance.title,
      'created_at_i': instance.createdAtI,
    };
