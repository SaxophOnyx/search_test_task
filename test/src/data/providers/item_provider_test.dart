import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:search_test_task/src/data/data.dart';

class MockDio extends Mock implements Dio {}

void main() {
  late MockDio dio;
  late ItemProvider provider;

  final RequestOptions requestOptions = RequestOptions(path: '/search');

  Map<String, dynamic> hit(int id) {
    return <String, dynamic>{
      'story_id': id,
      'title': 'Story $id',
      'created_at_i': 1700000000,
    };
  }

  void stubGet(Future<Response<Map<String, dynamic>>> Function() answer) {
    when(
      () => dio.get<Map<String, dynamic>>(
        any(),
        queryParameters: any(named: 'queryParameters'),
      ),
    ).thenAnswer((_) => answer());
  }

  void stubData(Map<String, dynamic>? data) {
    stubGet(
      () async => Response<Map<String, dynamic>>(
        requestOptions: requestOptions,
        data: data,
      ),
    );
  }

  Future<List<ItemEntity>> search() {
    return provider.searchItems(query: 'flutter', from: 20, limit: 10);
  }

  setUp(() {
    dio = MockDio();
    provider = ItemProvider(dio: dio);
  });

  group('ItemProvider', () {
    group('searchItems', () {
      test(
        'requests stories by query, offset and length, and parses hits',
        () async {
          stubData(<String, dynamic>{
            'hits': <dynamic>[hit(1), hit(2)],
          });

          final List<ItemEntity> result = await search();

          verify(
            () => dio.get<Map<String, dynamic>>(
              '/search',
              queryParameters: <String, dynamic>{
                'query': 'flutter',
                'tags': 'story',
                'offset': 20,
                'length': 10,
              },
            ),
          ).called(1);
          verifyNoMoreInteractions(dio);
          expect(result.map((ItemEntity e) => e.storyId), <int>[1, 2]);
        },
      );

      test('returns an empty list when there are no hits', () async {
        stubData(<String, dynamic>{'hits': <dynamic>[]});

        expect(await search(), isEmpty);
      });

      test('rethrows DioException unchanged', () async {
        final DioException exception = DioException(
          requestOptions: requestOptions,
        );
        stubGet(() async => throw exception);

        await expectLater(search(), throwsA(same(exception)));
      });

      final List<(String, Map<String, dynamic>?)> malformed =
          <(String, Map<String, dynamic>?)>[
            ('the body is null', null),
            ('the hits key is missing', <String, dynamic>{'nbHits': 0}),
            (
              'a hit is not a map',
              <String, dynamic>{
                'hits': <dynamic>['not a map'],
              },
            ),
          ];

      for (final (String name, Map<String, dynamic>? data) in malformed) {
        test('throws TypeError when $name', () async {
          stubData(data);

          await expectLater(search(), throwsA(isA<TypeError>()));
        });
      }
    });
  });
}
