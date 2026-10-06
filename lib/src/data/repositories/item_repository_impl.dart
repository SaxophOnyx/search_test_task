import '../../domain/domain.dart';
import '../data.dart';

final class ItemRepositoryImpl implements ItemRepository {
  final ItemProvider _itemProvider;

  const new({
    required ItemProvider itemProvider,
  }) : _itemProvider = itemProvider;

  @override
  Future<List<Item>> searchItems({
    required String name,
    required int from,
    required int limit,
  }) async {
    final List<ItemEntity> entities = await _itemProvider.searchItems(
      query: name,
      from: from,
      limit: limit,
    );
    return entities.map(ItemMapper.fromEntity).toList(growable: false);
  }
}
