import 'package:flutter_test/flutter_test.dart';
import 'package:search_test_task/src/data/data.dart';

void main() {
  final Map<String, dynamic> json = <String, dynamic>{
    'story_id': 42,
    'title': 'Hello HN',
    'created_at_i': 1700000000,
  };

  group('ItemEntity', () {
    group('fromJson', () {
      test('parses snake_case keys and ignores unknown ones', () {
        final ItemEntity entity = ItemEntity.fromJson(<String, dynamic>{
          ...json,
          'author': 'pg',
          '_tags': <String>['story'],
        });

        expect(entity.storyId, 42);
        expect(entity.title, 'Hello HN');
        expect(entity.createdAtI, 1700000000);
      });

      final List<(String, Map<String, dynamic>)> invalid =
          <(String, Map<String, dynamic>)>[
            (
              'a required field is missing',
              Map<String, dynamic>.of(json)..remove('title'),
            ),
            (
              'a required field is null',
              <String, dynamic>{...json, 'story_id': null},
            ),
            (
              'a field has the wrong type',
              <String, dynamic>{...json, 'created_at_i': '1700000000'},
            ),
          ];

      for (final (String name, Map<String, dynamic> payload) in invalid) {
        test('throws when $name', () {
          expect(() => ItemEntity.fromJson(payload), throwsA(isA<TypeError>()));
        });
      }
    });
  });
}
