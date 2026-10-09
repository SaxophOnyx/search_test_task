import '../../core/core.dart';
import '../../domain/domain.dart';
import '../data.dart';

final class ItemRepositoryImpl implements ItemRepository {
  final ItemProvider _itemProvider;

  const new({
    required ItemProvider itemProvider,
  }) : _itemProvider = itemProvider;

  @override
  Future<List<Item>> searchItems({
    required String query,
    required int from,
    required int limit,
  }) async {
    try {
      final List<ItemEntity> entities = await _itemProvider.searchItems(
        query: query,
        from: from,
        limit: limit,
      );
      return entities.map(ItemMapper.fromEntity).toList(growable: false);
    } on AppException {
      rethrow;
    } catch (_, stackTrace) {
      Error.throwWithStackTrace(const UnknownException(), stackTrace);
    }
  }
}
