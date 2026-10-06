import 'package:dio/dio.dart';

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
    } on AppException {
      rethrow;
    } on DioException catch (e) {
      throw _mapDioException(e);
    } on Exception {
      throw const AppException.unknown();
    }
  }

  AppException _mapDioException(DioException e) {
    return switch (e.type) {
      DioExceptionType.badResponse => switch (e.response?.statusCode) {
        429 => const LimitReachedException(),
        final int code when code >= 400 && code < 600 =>
          const FetchFailedException(),
        _ => const AppException.unknown(),
      },
      DioExceptionType.connectionTimeout ||
      DioExceptionType.sendTimeout ||
      DioExceptionType.receiveTimeout ||
      DioExceptionType.connectionError => const FetchFailedException(),
      _ => const AppException.unknown(),
    };
  }
}
