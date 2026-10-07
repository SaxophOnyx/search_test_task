import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:search_test_task/src/data/data.dart';
import 'package:search_test_task/src/domain/domain.dart';

class MockItemProvider extends Mock implements ItemProvider {}

void main() {
  late MockItemProvider provider;
  late ItemRepositoryImpl repository;

  final RequestOptions requestOptions = RequestOptions(
    path: ApiConstants.searchPath,
  );

  DioException dioException({int? statusCode}) {
    return DioException(
      requestOptions: requestOptions,
      response: statusCode == null
          ? null
          : Response<dynamic>(
              requestOptions: requestOptions,
              statusCode: statusCode,
            ),
    );
  }

  void stubSearch(Future<List<ItemEntity>> Function() answer) {
    when(
      () => provider.searchItems(
        query: any(named: 'query'),
        from: any(named: 'from'),
        limit: any(named: 'limit'),
      ),
    ).thenAnswer((_) => answer());
  }

  Future<List<Item>> search() {
    return repository.searchItems(query: 'flutter', from: 20, limit: 10);
  }

  setUp(() {
    provider = MockItemProvider();
    repository = ItemRepositoryImpl(itemProvider: provider);
  });

  group('ItemRepositoryImpl', () {
    group('searchItems', () {
      test('forwards params to provider and maps entities to items', () async {
        stubSearch(
          () async => const <ItemEntity>[
            ItemEntity(storyId: 1, title: 'First', createdAtI: 0),
            ItemEntity(storyId: 2, title: 'Second', createdAtI: 0),
          ],
        );

        final List<Item> result = await search();

        verify(
          () => provider.searchItems(
            query: 'flutter',
            from: 20,
            limit: 10,
          ),
        ).called(1);
        verifyNoMoreInteractions(provider);
        expect(result.map((Item i) => i.id), <int>[1, 2]);
        expect(result.map((Item i) => i.title), <String>['First', 'Second']);
      });

      final List<(String, Object, Matcher)> failures =
          <(String, Object, Matcher)>[
            (
              'LimitReachedException on a 429 response',
              dioException(statusCode: 429),
              isA<LimitReachedException>(),
            ),
            (
              'FetchFailedException on any other error status',
              dioException(statusCode: 500),
              isA<FetchFailedException>(),
            ),
            (
              'FetchFailedException when Dio has no response',
              dioException(),
              isA<FetchFailedException>(),
            ),
            (
              'UnknownException on a non-Dio error',
              TypeError(),
              isA<UnknownException>(),
            ),
          ];

      for (final (String name, Object error, Matcher matcher) in failures) {
        test('throws $name', () async {
          stubSearch(() async => throw error);

          await expectLater(search(), throwsA(matcher));
        });
      }
    });
  });
}
