import 'package:flutter_test/flutter_test.dart';
import 'package:search_test_task/src/data/data.dart';
import 'package:search_test_task/src/domain/domain.dart';

void main() {
  group('ItemMapper', () {
    group('fromEntity', () {
      test('maps fields and converts createdAtI seconds to UTC', () {
        final Item item = ItemMapper.fromEntity(
          const ItemEntity(
            storyId: 42,
            title: 'Hello HN',
            createdAtI: 1700000000,
          ),
        );

        expect(item.id, 42);
        expect(item.title, 'Hello HN');
        expect(item.createdAt, DateTime.utc(2023, 11, 14, 22, 13, 20));
      });
    });
  });
}
