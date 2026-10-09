import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:mocktail/mocktail.dart';
import 'package:search_test_task/src/domain/domain.dart';

class MockItemRepository extends Mock implements ItemRepository {}

void main() {
  late MockItemRepository repository;
  late GetIt locator;

  setUp(() {
    repository = MockItemRepository();
    locator = GetIt.asNewInstance()..registerSingleton<ItemRepository>(repository);
    DomainDi.initDependencies(locator);
  });

  tearDown(() async {
    await locator.reset();
  });

  group('DomainDi', () {
    group('initDependencies', () {
      test(
        'wires SearchItemsUseCase to the registered ItemRepository',
        () async {
          when(
            () => repository.searchItems(
              query: any(named: 'query'),
              from: any(named: 'from'),
              limit: any(named: 'limit'),
            ),
          ).thenAnswer((_) async => const <Item>[]);

          await locator<SearchItemsUseCase>().execute(
            const SearchItemsParams(query: 'flutter', from: 0, limit: 10),
          );

          verify(
            () => repository.searchItems(query: 'flutter', from: 0, limit: 10),
          ).called(1);
        },
      );

      test('registers SearchItemsUseCase as a singleton', () {
        expect(
          locator<SearchItemsUseCase>(),
          same(locator<SearchItemsUseCase>()),
        );
      });
    });
  });
}
