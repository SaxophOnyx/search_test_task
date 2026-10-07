import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:search_test_task/src/data/data.dart';
import 'package:search_test_task/src/domain/domain.dart';

void main() {
  const ApiGuard guard = ApiGuard();

  final RequestOptions requestOptions = RequestOptions(
    path: ApiConstants.searchPath,
  );

  DioException dioException({int? statusCode, Object? error}) {
    return DioException(
      requestOptions: requestOptions,
      error: error,
      response: statusCode == null
          ? null
          : Response<dynamic>(
              requestOptions: requestOptions,
              statusCode: statusCode,
            ),
    );
  }

  group('ApiGuard', () {
    group('run', () {
      test('returns the call result on success', () async {
        expect(await guard.run(() async => 42), 42);
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
              'UnknownException when Dio fails to cast the response',
              dioException(error: TypeError()),
              isA<UnknownException>(),
            ),
            (
              'UnknownException on a parse error',
              TypeError(),
              isA<UnknownException>(),
            ),
          ];

      for (final (String name, Object error, Matcher matcher) in failures) {
        test('throws $name', () async {
          await expectLater(
            guard.run<void>(() async => throw error),
            throwsA(matcher),
          );
        });
      }

      test('keeps the original stack trace', () async {
        final StackTrace original = StackTrace.current;

        try {
          await guard.run<void>(
            () async => Error.throwWithStackTrace(dioException(), original),
          );
          fail('Expected an exception');
        } on FetchFailedException catch (_, stackTrace) {
          expect(stackTrace, same(original));
        }
      });
    });
  });
}
