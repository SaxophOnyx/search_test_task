import 'package:flutter_test/flutter_test.dart';
import 'package:search_test_task/src/features/search/services/query_history.dart';

void main() {
  late QueryHistory history;

  void saveAll(List<String> queries) {
    queries.forEach(history.save);
  }

  setUp(() {
    history = QueryHistory();
  });

  group('QueryHistory', () {
    group('normalize', () {
      test('trims and collapses whitespace', () {
        expect(
          QueryHistory.normalize('  flutter \t\n web   app '),
          'flutter web app',
        );
      });

      test('turns blank input into an empty string', () {
        expect(QueryHistory.normalize(' \t\n '), isEmpty);
      });
    });

    group('save', () {
      test('stores the normalized query', () {
        history.save('  flutter    web ');

        expect(history.suggest(''), <String>['flutter web']);
      });

      for (final String query in <String>[
        '',
        '   ',
        'a',
        ' b ',
        '!!!',
        '- ?',
      ]) {
        test('ignores too short or wordless input "$query"', () {
          history.save(query);

          expect(history.suggest(''), isEmpty);
        });
      }

      test('moves a repeated query to the front with its latest casing', () {
        saveAll(<String>['Flutter', 'dart', 'FLUTTER ']);

        expect(history.suggest(''), <String>['FLUTTER', 'dart']);
      });

      test('evicts the oldest queries once full', () {
        final List<String> queries = List<String>.generate(
          200,
          (int i) => 'query $i',
        );
        saveAll(queries);

        final List<String> kept = history.suggest('', limit: queries.length);

        expect(kept, isNotEmpty);
        expect(kept.length, lessThan(queries.length));
        expect(kept.first, queries.last);
        expect(kept, isNot(contains(queries.first)));
      });
    });

    group('suggest', () {
      test('returns nothing before anything is saved', () {
        expect(history.suggest(''), isEmpty);
        expect(history.suggest('flu'), isEmpty);
      });

      for (final String input in <String>['', '   ']) {
        test('returns the most recent queries for blank input "$input"', () {
          saveAll(<String>['first', 'second', 'third']);

          expect(history.suggest(input, limit: 2), <String>['third', 'second']);
        });
      }

      test('excludes the query that matches the input exactly', () {
        saveAll(<String>['flutter', 'flutter web']);

        expect(history.suggest(' Flutter'), <String>['flutter web']);
      });

      test('matches case-insensitively and keeps the saved casing', () {
        history.save('Flutter Web');

        expect(history.suggest('fLU'), <String>['Flutter Web']);
      });

      test('ranks prefix matches above word matches, newest first', () {
        saveAll(<String>['flutter web', 'flutter bloc', 'dart flutter']);

        expect(history.suggest('flu'), <String>[
          'flutter bloc',
          'flutter web',
          'dart flutter',
        ]);
      });

      test('matches words in any order', () {
        history.save('flutter web');

        expect(history.suggest('web flu'), <String>['flutter web']);
      });

      test('requires every input word to match', () {
        history.save('flutter web');

        expect(history.suggest('flutter ios'), isEmpty);
      });

      test('matches only from the start of a word', () {
        history.save('dart flutter');

        expect(history.suggest('utter'), isEmpty);
      });

      test('treats a trailing space as a finished word', () {
        saveAll(<String>['flutterflow', 'dart flutter', 'flutter web']);

        expect(history.suggest('flutter'), <String>[
          'flutter web',
          'flutterflow',
          'dart flutter',
        ]);
        expect(history.suggest('flutter '), <String>[
          'flutter web',
          'dart flutter',
        ]);
      });

      test('splits words on punctuation', () {
        history.save('node.js streams');

        expect(history.suggest('js'), <String>['node.js streams']);
      });

      test('matches non-ASCII letters', () {
        saveAll(<String>['Café crème', 'привет мир']);

        expect(history.suggest('crè'), <String>['Café crème']);
        expect(history.suggest('мир'), <String>['привет мир']);
      });

      test('returns no more than the limit', () {
        saveAll(List<String>.generate(10, (int i) => 'flutter $i'));

        expect(history.suggest('flu', limit: 3), hasLength(3));
      });
    });
  });
}
