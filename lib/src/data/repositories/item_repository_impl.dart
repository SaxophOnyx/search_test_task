import 'package:dio/dio.dart';

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
  }) {
    return _guard(() async {
      final List<ItemEntity> entities = await _itemProvider.searchItems(
        query: query,
        from: from,
        limit: limit,
      );
      return entities.map(ItemMapper.fromEntity).toList(growable: false);
    });
  }

  Future<T> _guard<T>(Future<T> Function() call) async {
    try {
      return await call();
    } on DioException catch (e) {
      throw e.response?.statusCode == 429
          ? const LimitReachedException()
          : const FetchFailedException();
    } catch (_) {
      throw const UnknownException();
    }
  }
}
