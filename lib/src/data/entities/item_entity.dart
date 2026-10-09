import 'package:json_annotation/json_annotation.dart';

part 'item_entity.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake)
class ItemEntity {
  final int storyId;
  final String title;
  final int createdAtI;

  const new({
    required this.storyId,
    required this.title,
    required this.createdAtI,
  });

  factory ItemEntity.fromJson(Map<String, dynamic> json) => _$ItemEntityFromJson(json);

  Map<String, dynamic> toJson() => _$ItemEntityToJson(this);
}
