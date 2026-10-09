import '../domain.dart';

final class SearchItemsParams {
  final String query;
  final int from;
  final int limit;

  const new({
    required this.query,
    required this.from,
    required this.limit,
  });
}

class SearchItemsUseCase implements FutureUseCase<SearchItemsParams, List<Item>> {
  final ItemRepository _itemRepository;

  const new({
    required ItemRepository itemRepository,
  }) : _itemRepository = itemRepository;

  @override
  Future<List<Item>> execute(SearchItemsParams input) async {
    return _itemRepository.searchItems(
      query: input.query,
      from: input.from,
      limit: input.limit,
    );
  }
}
