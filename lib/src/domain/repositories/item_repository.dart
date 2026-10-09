import '../domain.dart';

abstract interface class ItemRepository {
  Future<List<Item>> searchItems({
    required String query,
    required int from,
    required int limit,
  });
}
