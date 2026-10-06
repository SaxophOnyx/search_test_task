import '../domain.dart';

final class SearchItemsParams {
  final String name;
  final int from;
  final int limit;

  const new({
    required this.name,
    required this.from,
    required this.limit,
  });
}

class SearchItemsUseCase
    implements FutureUseCase<SearchItemsParams, List<Item>> {
  final ItemRepository _itemRepository;

  const new({
    required ItemRepository itemRepository,
  }) : _itemRepository = itemRepository;

  @override
  Future<List<Item>> execute(SearchItemsParams input) {
    return _itemRepository.searchItems(
      name: input.name,
      from: input.from,
      limit: input.limit,
    );
  }
}
