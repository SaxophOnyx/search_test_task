import '../../domain/domain.dart';
import '../data.dart';

final class ItemMapper {
  const ItemMapper._();

  static Item fromEntity(ItemEntity entity) {
    return Item(
      id: entity.storyId,
      title: entity.title,
      createdAt: DateTime.fromMillisecondsSinceEpoch(
        entity.createdAtI * 1000,
        isUtc: true,
      ),
    );
  }
}
