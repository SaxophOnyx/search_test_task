import '../domain.dart';

abstract interface class ItemRepository {
  Future<List<Item>> searchItems({
    required String name,
    required int from,
  });
}
