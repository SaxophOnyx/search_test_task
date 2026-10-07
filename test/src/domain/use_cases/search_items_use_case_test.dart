import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:search_test_task/src/domain/domain.dart';

class MockItemRepository extends Mock implements ItemRepository {}

void main() {
  late MockItemRepository repository;
  late SearchItemsUseCase useCase;

  const SearchItemsParams params = SearchItemsParams(
    query: 'flutter',
    from: 20,
    limit: 10,
  );

  void stubSearch(Future<List<Item>> Function() answer) {
    when(
      () => repository.searchItems(
        query: any(named: 'query'),
        from: any(named: 'from'),
        limit: any(named: 'limit'),
      ),
    ).thenAnswer((_) => answer());
  }

  setUp(() {
    repository = MockItemRepository();
    useCase = SearchItemsUseCase(itemRepository: repository);
  });

  group('SearchItemsUseCase', () {
    group('execute', () {
      test('forwards params to repository and returns its items', () async {
        final List<Item> items = <Item>[
          Item(id: 1, title: 'First', createdAt: DateTime.utc(2024)),
        ];
        stubSearch(() async => items);

        final List<Item> result = await useCase.execute(params);

        verify(
          () => repository.searchItems(
            query: 'flutter',
            from: 20,
            limit: 10,
          ),
        ).called(1);
        verifyNoMoreInteractions(repository);
        expect(result, same(items));
      });

      test('propagates repository exceptions', () async {
        stubSearch(() async => throw const LimitReachedException());

        await expectLater(
          useCase.execute(params),
          throwsA(isA<LimitReachedException>()),
        );
      });
    });
  });
}
