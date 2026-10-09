import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:search_test_task/src/data/data.dart';
import 'package:search_test_task/src/domain/domain.dart';

void main() {
  late GetIt locator;

  setUp(() {
    locator = GetIt.asNewInstance();
    DataDi.initDependencies(locator);
  });

  tearDown(() async {
    await locator.reset();
  });

  group('DataDi', () {
    group('initDependencies', () {
      test('points Dio at the API base url', () {
        expect(locator<Dio>().options.baseUrl, 'https://hn.algolia.com/api/v1');
      });

      test('resolves ApiGuard', () {
        expect(locator<ApiGuard>(), isA<ApiGuard>());
      });

      test('resolves ItemRepository to ItemRepositoryImpl', () {
        expect(locator<ItemRepository>(), isA<ItemRepositoryImpl>());
      });

      test('registers ItemRepository as a singleton', () {
        expect(locator<ItemRepository>(), same(locator<ItemRepository>()));
      });
    });
  });
}
