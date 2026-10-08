import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:search_test_task/src/core/core.dart';
import 'package:search_test_task/src/domain/domain.dart';
import 'package:search_test_task/src/features/search/bloc/search_bloc.dart';
import 'package:search_test_task/src/features/search/services/query_history.dart';

class MockSearchItemsUseCase extends Mock implements SearchItemsUseCase {}

class MockQueryHistory extends Mock implements QueryHistory {}

void main() {
  late MockSearchItemsUseCase useCase;
  late MockQueryHistory history;

  late List<List<Item>> served;

  late List<Completer<List<Item>>> pending;

  const List<String> historySuggestions = <String>['flutter', 'flutter web'];

  List<Item> itemsFor(String query, int count, {int from = 0}) {
    return List<Item>.generate(
      count,
      (int i) => Item(
        id: from + i,
        title: '$query #${from + i}',
        createdAt: DateTime.utc(2024),
      ),
    );
  }

  final List<Item> loaded = itemsFor('flutter', 3);

  SearchBloc build() {
    return SearchBloc(searchItemsUseCase: useCase, queryHistory: history);
  }

  SearchState seeded({
    String query = 'flutter',
    List<Item> items = const <Item>[],
    SearchStatus status = .success,
    bool hasReachedEnd = false,
    AppException? exception,
    List<String> suggestions = const <String>[],
  }) {
    return const SearchState.initial().copyWith(
      query: query,
      items: items,
      status: status,
      hasReachedEnd: hasReachedEnd,
      exception: exception,
      suggestions: suggestions,
    );
  }

  Matcher isState({
    SearchStatus? status,
    String? query,
    List<Item>? items,
    bool? hasReachedEnd,
    List<String>? suggestions,
    Matcher? exception,
  }) {
    TypeMatcher<SearchState> matcher = isA<SearchState>();
    if (status != null) {
      matcher = matcher.having((SearchState s) => s.status, 'status', status);
    }
    if (query != null) {
      matcher = matcher.having((SearchState s) => s.query, 'query', query);
    }
    if (items != null) {
      matcher = matcher.having(
        (SearchState s) => s.items,
        'items',
        orderedEquals(items),
      );
    }
    if (hasReachedEnd != null) {
      matcher = matcher.having(
        (SearchState s) => s.hasReachedEnd,
        'hasReachedEnd',
        hasReachedEnd,
      );
    }
    if (suggestions != null) {
      matcher = matcher.having(
        (SearchState s) => s.suggestions,
        'suggestions',
        orderedEquals(suggestions),
      );
    }
    if (exception != null) {
      matcher = matcher.having(
        (SearchState s) => s.exception,
        'exception',
        exception,
      );
    }
    return matcher;
  }

  final Matcher suggested = isState(suggestions: historySuggestions);

  Matcher isParams({required String query, required int from}) {
    return isA<SearchItemsParams>()
        .having((SearchItemsParams p) => p.query, 'query', query)
        .having((SearchItemsParams p) => p.from, 'from', from);
  }

  List<SearchItemsParams> capturedParams() {
    return verify(
      () => useCase.execute(captureAny()),
    ).captured.cast<SearchItemsParams>();
  }

  void stubSearch(
    Future<List<Item>> Function(SearchItemsParams params) answer,
  ) {
    when(() => useCase.execute(any()))
        .thenAnswer((Invocation invocation) async {
          final List<Item> page = await answer(
            invocation.positionalArguments.single as SearchItemsParams,
          );
          served.add(page);
          return page;
        });
  }

  Future<List<Item>> fullPage(SearchItemsParams params) async {
    return itemsFor(params.query, params.limit, from: params.from);
  }

  Future<List<Item>> lastPage(SearchItemsParams params) async {
    return itemsFor(params.query, params.limit - 1, from: params.from);
  }

  void stubFailure(AppException exception) {
    stubSearch((SearchItemsParams _) async => throw exception);
  }

  void stubPending() {
    stubSearch((SearchItemsParams _) {
      final Completer<List<Item>> completer = Completer<List<Item>>();
      pending.add(completer);
      return completer.future;
    });
  }

  setUpAll(() {
    registerFallbackValue(
      const SearchItemsParams(query: '', from: 0, limit: 0),
    );
  });

  setUp(() {
    useCase = MockSearchItemsUseCase();
    history = MockQueryHistory();
    served = <List<Item>>[];
    pending = <Completer<List<Item>>>[];
    when(() => history.suggest(any())).thenReturn(historySuggestions);
  });

  group('SearchBloc', () {
    test('starts idle with nothing loaded', () {
      final SearchBloc bloc = build();
      addTearDown(bloc.close);

      expect(
        bloc.state,
        isState(
          status: .idle,
          query: '',
          items: const <Item>[],
          hasReachedEnd: false,
          suggestions: const <String>[],
          exception: isNull,
        ),
      );
    });

    group('SubmitQuery', () {
      blocTest<SearchBloc, SearchState>(
        'emits loading, then success with the first page',
        setUp: () => stubSearch(lastPage),
        build: build,
        act: (SearchBloc bloc) {
          bloc.add(const SubmitQuery(query: 'flutter'));
        },
        expect: () => <Matcher>[
          suggested,
          isState(
            status: .loading,
            query: 'flutter',
            items: const <Item>[],
            exception: isNull,
          ),
          isState(
            status: .success,
            query: 'flutter',
            items: served.single,
            exception: isNull,
          ),
        ],
        verify: (SearchBloc _) {
          expect(capturedParams(), <Matcher>[
            isParams(query: 'flutter', from: 0),
          ]);
        },
      );

      blocTest<SearchBloc, SearchState>(
        'trims and collapses whitespace in the query',
        setUp: () => stubSearch(lastPage),
        build: build,
        act: (SearchBloc bloc) {
          bloc.add(
            const SubmitQuery(query: '  flutter \t  dart\n'),
          );
        },
        expect: () => <Matcher>[
          suggested,
          isState(status: .loading, query: 'flutter dart'),
          isState(status: .success, query: 'flutter dart'),
        ],
        verify: (SearchBloc _) {
          expect(capturedParams(), <Matcher>[
            isParams(query: 'flutter dart', from: 0),
          ]);
        },
      );

      blocTest<SearchBloc, SearchState>(
        'expects more pages after a full page',
        setUp: () => stubSearch(fullPage),
        build: build,
        act: (SearchBloc bloc) {
          bloc.add(const SubmitQuery(query: 'flutter'));
        },
        expect: () => <Matcher>[
          suggested,
          isState(status: .loading),
          isState(status: .success, items: served.single, hasReachedEnd: false),
        ],
      );

      blocTest<SearchBloc, SearchState>(
        'reaches the end after a short page',
        setUp: () => stubSearch(lastPage),
        build: build,
        act: (SearchBloc bloc) {
          bloc.add(const SubmitQuery(query: 'flutter'));
        },
        expect: () => <Matcher>[
          suggested,
          isState(status: .loading),
          isState(status: .success, items: served.single, hasReachedEnd: true),
        ],
      );

      blocTest<SearchBloc, SearchState>(
        'succeeds with no items and reaches the end when nothing is found',
        setUp: () => stubSearch((SearchItemsParams _) async => <Item>[]),
        build: build,
        act: (SearchBloc bloc) {
          bloc.add(const SubmitQuery(query: 'flutter'));
        },
        expect: () => <Matcher>[
          suggested,
          isState(status: .loading),
          isState(
            status: .success,
            items: const <Item>[],
            hasReachedEnd: true,
            exception: isNull,
          ),
        ],
      );

      for (final AppException exception in const <AppException>[
        LimitReachedException(),
        FetchFailedException(),
        UnknownException(),
      ]) {
        blocTest<SearchBloc, SearchState>(
          'emits failure carrying ${exception.runtimeType}',
          setUp: () => stubFailure(exception),
          build: build,
          act: (SearchBloc bloc) {
            bloc.add(const SubmitQuery(query: 'flutter'));
          },
          expect: () => <Matcher>[
            suggested,
            isState(status: .loading, query: 'flutter'),
            isState(
              status: .failure,
              query: 'flutter',
              items: const <Item>[],
              exception: same(exception),
            ),
          ],
        );
      }

      for (final String input in <String>['', '   ', '\n\t ']) {
        blocTest<SearchBloc, SearchState>(
          'resets to idle and keeps suggestions on blank input '
          '${input.codeUnits}',
          build: build,
          seed: () => seeded(
            items: loaded,
            hasReachedEnd: true,
            suggestions: historySuggestions,
          ),
          act: (SearchBloc bloc) {
            bloc.add(SubmitQuery(query: input));
          },
          expect: () => <Matcher>[
            suggested,
            isState(
              status: .idle,
              query: '',
              items: const <Item>[],
              hasReachedEnd: false,
              suggestions: historySuggestions,
              exception: isNull,
            ),
          ],
          verify: (SearchBloc _) => verifyZeroInteractions(useCase),
        );
      }

      blocTest<SearchBloc, SearchState>(
        'discards the response when the input is cleared mid-request',
        setUp: stubPending,
        build: build,
        act: (SearchBloc bloc) async {
          bloc.add(const SubmitQuery(query: 'flutter'));
          await pumpEventQueue();
          bloc.add(const SubmitQuery(query: ''));
          await pumpEventQueue();
          pending.single.complete(itemsFor('flutter', 2));
          await pumpEventQueue();
        },
        expect: () => <Matcher>[
          suggested,
          isState(status: .loading, query: 'flutter'),
          suggested,
          isState(status: .idle, query: '', items: const <Item>[]),
        ],
        verify: (SearchBloc _) => verifyNever(() => history.save(any())),
      );

      final List<(String, SearchState)> alreadyShown = <(String, SearchState)>[
        ('loaded results', seeded(items: loaded)),
        ('an empty result', seeded(hasReachedEnd: true)),
        (
          'results while the next page loads',
          seeded(items: loaded, status: .loading),
        ),
        (
          'results whose next page failed',
          seeded(
            items: loaded,
            status: .failure,
            exception: const FetchFailedException(),
          ),
        ),
      ];

      for (final (String name, SearchState seed) in alreadyShown) {
        for (final String input in <String>['flutter', '  flutter  ']) {
          blocTest<SearchBloc, SearchState>(
            'ignores the same query "$input" when showing $name',
            build: build,
            seed: () => seed,
            act: (SearchBloc bloc) {
              bloc.add(SubmitQuery(query: input));
            },
            expect: () => <Matcher>[suggested],
            verify: (SearchBloc _) => verifyZeroInteractions(useCase),
          );
        }
      }

      blocTest<SearchBloc, SearchState>(
        'refetches the same query after its first page failed',
        setUp: () => stubSearch(lastPage),
        build: build,
        seed: () => seeded(
          status: .failure,
          exception: const FetchFailedException(),
        ),
        act: (SearchBloc bloc) {
          bloc.add(const SubmitQuery(query: 'flutter'));
        },
        expect: () => <Matcher>[
          suggested,
          isState(status: .loading, exception: isNull),
          isState(status: .success, items: served.single, exception: isNull),
        ],
        verify: (SearchBloc _) {
          expect(capturedParams(), <Matcher>[
            isParams(query: 'flutter', from: 0),
          ]);
        },
      );

      blocTest<SearchBloc, SearchState>(
        'starts over from the first page when the query changes',
        setUp: () => stubSearch(lastPage),
        build: build,
        seed: () => seeded(items: loaded, hasReachedEnd: true),
        act: (SearchBloc bloc) {
          bloc.add(const SubmitQuery(query: 'dart'));
        },
        expect: () => <Matcher>[
          suggested,
          isState(
            status: .loading,
            query: 'dart',
            items: const <Item>[],
            hasReachedEnd: false,
          ),
          isState(status: .success, query: 'dart', items: served.single),
        ],
        verify: (SearchBloc _) {
          expect(capturedParams(), <Matcher>[
            isParams(query: 'dart', from: 0),
          ]);
        },
      );

      for (final bool staleArrivesFirst in <bool>[true, false]) {
        final List<Item> stale = itemsFor('flu', 2);
        final List<Item> fresh = itemsFor('flutter', 2);

        blocTest<SearchBloc, SearchState>(
          'shows only the latest query when the previous response arrives '
          '${staleArrivesFirst ? 'first' : 'last'}',
          setUp: stubPending,
          build: build,
          act: (SearchBloc bloc) async {
            bloc.add(const SubmitQuery(query: 'flu'));
            await pumpEventQueue();
            bloc.add(const SubmitQuery(query: 'flutter'));
            await pumpEventQueue();
            final (
              Completer<List<Item>> previous,
              Completer<List<Item>> latest,
            ) = (
              pending[0],
              pending[1],
            );
            if (staleArrivesFirst) {
              previous.complete(stale);
              await pumpEventQueue();
              latest.complete(fresh);
            } else {
              latest.complete(fresh);
              await pumpEventQueue();
              previous.complete(stale);
            }
            await pumpEventQueue();
          },
          expect: () => <Matcher>[
            suggested,
            isState(status: .loading, query: 'flu'),
            suggested,
            isState(status: .loading, query: 'flutter', items: const <Item>[]),
            isState(status: .success, query: 'flutter', items: fresh),
          ],
          verify: (SearchBloc _) {
            verify(() => history.save('flutter')).called(1);
            verifyNever(() => history.save('flu'));
          },
        );
      }

      blocTest<SearchBloc, SearchState>(
        'keeps existing suggestions while searching',
        setUp: () => stubSearch(lastPage),
        build: build,
        seed: () => seeded(
          query: '',
          status: .idle,
          suggestions: historySuggestions,
        ),
        act: (SearchBloc bloc) {
          bloc.add(const SubmitQuery(query: 'flutter'));
        },
        expect: () => <Matcher>[
          suggested,
          isState(status: .loading, suggestions: historySuggestions),
          isState(status: .success, suggestions: historySuggestions),
        ],
      );

      group('history', () {
        blocTest<SearchBloc, SearchState>(
          'saves the normalized query once its first page has results',
          setUp: () => stubSearch(lastPage),
          build: build,
          act: (SearchBloc bloc) {
            bloc.add(const SubmitQuery(query: ' flutter  dart '));
          },
          verify: (SearchBloc _) {
            verify(() => history.save('flutter dart')).called(1);
          },
        );

        blocTest<SearchBloc, SearchState>(
          'does not save a query that found nothing',
          setUp: () => stubSearch((SearchItemsParams _) async => <Item>[]),
          build: build,
          act: (SearchBloc bloc) {
            bloc.add(const SubmitQuery(query: 'flutter'));
          },
          verify: (SearchBloc _) => verifyNever(() => history.save(any())),
        );

        blocTest<SearchBloc, SearchState>(
          'does not save a query that failed',
          setUp: () => stubFailure(const FetchFailedException()),
          build: build,
          act: (SearchBloc bloc) {
            bloc.add(const SubmitQuery(query: 'flutter'));
          },
          verify: (SearchBloc _) => verifyNever(() => history.save(any())),
        );
      });
    });

    group('UpdateInput', () {
      const Duration debounce = Duration(milliseconds: 550);

      blocTest<SearchBloc, SearchState>(
        'emits history suggestions at once and leaves the results untouched',
        build: build,
        seed: () => seeded(items: loaded, hasReachedEnd: true),
        act: (SearchBloc bloc) {
          bloc.add(const UpdateInput(query: 'flu'));
        },
        expect: () => <Matcher>[
          isState(
            suggestions: historySuggestions,
            status: .success,
            query: 'flutter',
            items: loaded,
            hasReachedEnd: true,
            exception: isNull,
          ),
        ],
        verify: (SearchBloc _) => verifyZeroInteractions(useCase),
      );

      blocTest<SearchBloc, SearchState>(
        'passes the raw input, so a trailing space can mark a finished word',
        build: build,
        act: (SearchBloc bloc) {
          bloc.add(const UpdateInput(query: ' Flutter '));
        },
        verify: (SearchBloc _) {
          verify(() => history.suggest(' Flutter ')).called(1);
        },
      );

      blocTest<SearchBloc, SearchState>(
        'searches once the input settles',
        setUp: () => stubSearch(lastPage),
        build: build,
        act: (SearchBloc bloc) {
          bloc.add(const UpdateInput(query: 'flutter'));
        },
        wait: debounce,
        expect: () => <Matcher>[
          suggested,
          isState(status: .loading, query: 'flutter'),
          isState(status: .success, query: 'flutter', items: served.single),
        ],
        verify: (SearchBloc _) {
          expect(capturedParams(), <Matcher>[
            isParams(query: 'flutter', from: 0),
          ]);
        },
      );

      blocTest<SearchBloc, SearchState>(
        'searches only the last of rapid inputs',
        setUp: () => stubSearch(lastPage),
        build: build,
        act: (SearchBloc bloc) async {
          for (final String input in <String>['f', 'flu', 'flutter']) {
            bloc.add(UpdateInput(query: input));
            await Future<void>.delayed(const Duration(milliseconds: 50));
          }
        },
        wait: debounce,
        expect: () => <Matcher>[
          suggested,
          suggested,
          suggested,
          isState(status: .loading, query: 'flutter'),
          isState(status: .success, query: 'flutter', items: served.single),
        ],
        verify: (SearchBloc _) {
          expect(capturedParams(), <Matcher>[
            isParams(query: 'flutter', from: 0),
          ]);
        },
      );

      blocTest<SearchBloc, SearchState>(
        'drops a pending input when a query is submitted',
        setUp: () => stubSearch(lastPage),
        build: build,
        act: (SearchBloc bloc) {
          bloc
            ..add(const UpdateInput(query: 'flu'))
            ..add(const SubmitQuery(query: 'flutter'));
        },
        wait: debounce,
        expect: () => <Matcher>[
          suggested,
          suggested,
          isState(status: .loading, query: 'flutter'),
          isState(status: .success, query: 'flutter', items: served.single),
        ],
        verify: (SearchBloc _) {
          expect(capturedParams(), <Matcher>[
            isParams(query: 'flutter', from: 0),
          ]);
        },
      );

      final List<Item> fresh = itemsFor('dart', 2);

      blocTest<SearchBloc, SearchState>(
        'discards an in-flight response when new input arrives',
        setUp: stubPending,
        build: build,
        act: (SearchBloc bloc) async {
          bloc.add(const SubmitQuery(query: 'flutter'));
          await pumpEventQueue();
          bloc.add(const UpdateInput(query: 'dart'));
          await pumpEventQueue();
          pending.single.complete(itemsFor('flutter', 2));
          await Future<void>.delayed(debounce);
          pending.last.complete(fresh);
          await pumpEventQueue();
        },
        expect: () => <Matcher>[
          suggested,
          isState(status: .loading, query: 'flutter'),
          isState(
            status: .loading,
            query: 'flutter',
            suggestions: historySuggestions,
          ),
          isState(status: .loading, query: 'dart', items: const <Item>[]),
          isState(status: .success, query: 'dart', items: fresh),
        ],
        verify: (SearchBloc _) {
          verifyNever(() => history.save('flutter'));
        },
      );
    });

    group('LoadNextPage', () {
      final List<(String, SearchState)> notReady = <(String, SearchState)>[
        ('idle', const SearchState.initial()),
        ('the first page is loading', seeded(status: .loading)),
        (
          'the next page is already loading',
          seeded(items: loaded, status: .loading),
        ),
        (
          'the last request failed',
          seeded(
            items: loaded,
            status: .failure,
            exception: const FetchFailedException(),
          ),
        ),
        ('the end is reached', seeded(items: loaded, hasReachedEnd: true)),
      ];

      for (final (String name, SearchState seed) in notReady) {
        blocTest<SearchBloc, SearchState>(
          'does nothing when $name',
          build: build,
          seed: () => seed,
          act: (SearchBloc bloc) => bloc.add(const LoadNextPage()),
          expect: () => isEmpty,
          verify: (SearchBloc _) => verifyZeroInteractions(useCase),
        );
      }

      blocTest<SearchBloc, SearchState>(
        'emits loading, then appends the next page',
        setUp: () => stubSearch(fullPage),
        build: build,
        seed: () => seeded(items: loaded),
        act: (SearchBloc bloc) => bloc.add(const LoadNextPage()),
        expect: () => <Matcher>[
          isState(status: .loading, query: 'flutter', items: loaded),
          isState(
            status: .success,
            query: 'flutter',
            items: <Item>[...loaded, ...served.single],
            hasReachedEnd: false,
            exception: isNull,
          ),
        ],
        verify: (SearchBloc _) {
          expect(capturedParams(), <Matcher>[
            isParams(query: 'flutter', from: loaded.length),
          ]);
        },
      );

      blocTest<SearchBloc, SearchState>(
        'reaches the end after a short page',
        setUp: () => stubSearch(lastPage),
        build: build,
        seed: () => seeded(items: loaded),
        act: (SearchBloc bloc) => bloc.add(const LoadNextPage()),
        expect: () => <Matcher>[
          isState(status: .loading),
          isState(
            status: .success,
            items: <Item>[...loaded, ...served.single],
            hasReachedEnd: true,
          ),
        ],
      );

      blocTest<SearchBloc, SearchState>(
        'keeps the loaded items and reaches the end after an empty page',
        setUp: () => stubSearch((SearchItemsParams _) async => <Item>[]),
        build: build,
        seed: () => seeded(items: loaded),
        act: (SearchBloc bloc) => bloc.add(const LoadNextPage()),
        expect: () => <Matcher>[
          isState(status: .loading),
          isState(status: .success, items: loaded, hasReachedEnd: true),
        ],
      );

      blocTest<SearchBloc, SearchState>(
        'keeps the loaded items when the next page fails',
        setUp: () => stubFailure(const LimitReachedException()),
        build: build,
        seed: () => seeded(items: loaded),
        act: (SearchBloc bloc) => bloc.add(const LoadNextPage()),
        expect: () => <Matcher>[
          isState(status: .loading, items: loaded),
          isState(
            status: .failure,
            query: 'flutter',
            items: loaded,
            exception: isA<LimitReachedException>(),
          ),
        ],
      );

      blocTest<SearchBloc, SearchState>(
        'requests the next page once when scrolled repeatedly',
        setUp: stubPending,
        build: build,
        seed: () => seeded(items: loaded),
        act: (SearchBloc bloc) async {
          bloc
            ..add(const LoadNextPage())
            ..add(const LoadNextPage());
          await pumpEventQueue();
          bloc.add(const LoadNextPage());
          await pumpEventQueue();
          pending.single.complete(itemsFor('flutter', 2, from: loaded.length));
          await pumpEventQueue();
        },
        expect: () => <Matcher>[
          isState(status: .loading),
          isState(status: .success, items: <Item>[...loaded, ...served.single]),
        ],
        verify: (SearchBloc _) {
          verify(() => useCase.execute(any())).called(1);
        },
      );

      blocTest<SearchBloc, SearchState>(
        'loads the next page of a new query while a stale one is in flight',
        setUp: stubPending,
        build: build,
        seed: () => seeded(items: loaded),
        act: (SearchBloc bloc) async {
          bloc.add(const LoadNextPage());
          await pumpEventQueue();
          bloc.add(const SubmitQuery(query: 'dart'));
          await pumpEventQueue();
          pending[1].complete(itemsFor('dart', 20));
          await pumpEventQueue();
          bloc.add(const LoadNextPage());
          await pumpEventQueue();
        },
        verify: (SearchBloc _) {
          expect(capturedParams(), <Matcher>[
            isParams(query: 'flutter', from: loaded.length),
            isParams(query: 'dart', from: 0),
            isParams(query: 'dart', from: 20),
          ]);
        },
      );

      for (final bool staleArrivesFirst in <bool>[true, false]) {
        final List<Item> fresh = itemsFor('dart', 2);

        blocTest<SearchBloc, SearchState>(
          'discards a next page that arrives '
          '${staleArrivesFirst ? 'before' : 'after'} a new query resolves',
          setUp: stubPending,
          build: build,
          seed: () => seeded(items: loaded),
          act: (SearchBloc bloc) async {
            bloc.add(const LoadNextPage());
            await pumpEventQueue();
            bloc.add(const SubmitQuery(query: 'dart'));
            await pumpEventQueue();
            final (
              Completer<List<Item>> nextPage,
              Completer<List<Item>> search,
            ) = (
              pending[0],
              pending[1],
            );
            final List<Item> stale = itemsFor(
              'flutter',
              2,
              from: loaded.length,
            );
            if (staleArrivesFirst) {
              nextPage.complete(stale);
              await pumpEventQueue();
              search.complete(fresh);
            } else {
              search.complete(fresh);
              await pumpEventQueue();
              nextPage.complete(stale);
            }
            await pumpEventQueue();
          },
          expect: () => <Matcher>[
            isState(status: .loading, query: 'flutter'),
            suggested,
            isState(status: .loading, query: 'dart', items: const <Item>[]),
            isState(status: .success, query: 'dart', items: fresh),
          ],
        );
      }

      blocTest<SearchBloc, SearchState>(
        'discards a failed next page once a new query is loading',
        setUp: stubPending,
        build: build,
        seed: () => seeded(items: loaded),
        act: (SearchBloc bloc) async {
          bloc.add(const LoadNextPage());
          await pumpEventQueue();
          bloc.add(const SubmitQuery(query: 'dart'));
          await pumpEventQueue();
          pending[0].completeError(const FetchFailedException());
          await pumpEventQueue();
        },
        expect: () => <Matcher>[
          isState(status: .loading, query: 'flutter'),
          suggested,
          isState(status: .loading, query: 'dart', exception: isNull),
        ],
      );

      blocTest<SearchBloc, SearchState>(
        'discards a next page that arrives after the input is cleared',
        setUp: stubPending,
        build: build,
        seed: () => seeded(items: loaded),
        act: (SearchBloc bloc) async {
          bloc.add(const LoadNextPage());
          await pumpEventQueue();
          bloc.add(const SubmitQuery(query: ''));
          await pumpEventQueue();
          pending.single.complete(itemsFor('flutter', 2, from: loaded.length));
          await pumpEventQueue();
        },
        expect: () => <Matcher>[
          isState(status: .loading),
          suggested,
          isState(status: .idle, query: '', items: const <Item>[]),
        ],
      );

      blocTest<SearchBloc, SearchState>(
        'does not save the query to history again',
        setUp: () => stubSearch(fullPage),
        build: build,
        seed: () => seeded(items: loaded),
        act: (SearchBloc bloc) => bloc.add(const LoadNextPage()),
        verify: (SearchBloc _) => verifyNever(() => history.save(any())),
      );
    });

    group('RetrySearch', () {
      final List<(String, SearchState)> nothingFailed = <(String, SearchState)>[
        ('idle', const SearchState.initial()),
        ('loading', seeded(status: .loading)),
        ('loading more', seeded(items: loaded, status: .loading)),
        ('showing results', seeded(items: loaded)),
      ];

      for (final (String name, SearchState seed) in nothingFailed) {
        blocTest<SearchBloc, SearchState>(
          'does nothing when $name',
          build: build,
          seed: () => seed,
          act: (SearchBloc bloc) => bloc.add(const RetrySearch()),
          expect: () => isEmpty,
          verify: (SearchBloc _) => verifyZeroInteractions(useCase),
        );
      }

      blocTest<SearchBloc, SearchState>(
        'retries a failed first page as a fresh load',
        setUp: () => stubSearch(lastPage),
        build: build,
        seed: () => seeded(
          status: .failure,
          exception: const FetchFailedException(),
        ),
        act: (SearchBloc bloc) => bloc.add(const RetrySearch()),
        expect: () => <Matcher>[
          isState(
            status: .loading,
            query: 'flutter',
            items: const <Item>[],
            exception: isNull,
          ),
          isState(status: .success, items: served.single, exception: isNull),
        ],
        verify: (SearchBloc _) {
          expect(capturedParams(), <Matcher>[
            isParams(query: 'flutter', from: 0),
          ]);
          verify(() => history.save('flutter')).called(1);
        },
      );

      blocTest<SearchBloc, SearchState>(
        'retries a failed next page and keeps the loaded items',
        setUp: () => stubSearch(lastPage),
        build: build,
        seed: () => seeded(
          items: loaded,
          status: .failure,
          exception: const FetchFailedException(),
        ),
        act: (SearchBloc bloc) => bloc.add(const RetrySearch()),
        expect: () => <Matcher>[
          isState(status: .loading, items: loaded, exception: isNull),
          isState(
            status: .success,
            items: <Item>[...loaded, ...served.single],
            exception: isNull,
          ),
        ],
        verify: (SearchBloc _) {
          expect(capturedParams(), <Matcher>[
            isParams(query: 'flutter', from: loaded.length),
          ]);
          verifyNever(() => history.save(any()));
        },
      );

      const LimitReachedException retryException = LimitReachedException();

      blocTest<SearchBloc, SearchState>(
        'reports the new error when the retry fails too',
        setUp: () => stubFailure(retryException),
        build: build,
        seed: () => seeded(
          status: .failure,
          exception: const FetchFailedException(),
        ),
        act: (SearchBloc bloc) => bloc.add(const RetrySearch()),
        expect: () => <Matcher>[
          isState(status: .loading, exception: isNull),
          isState(
            status: .failure,
            items: const <Item>[],
            exception: same(retryException),
          ),
        ],
      );

      blocTest<SearchBloc, SearchState>(
        'retries once when tapped repeatedly',
        setUp: stubPending,
        build: build,
        seed: () => seeded(
          status: .failure,
          exception: const FetchFailedException(),
        ),
        act: (SearchBloc bloc) async {
          bloc
            ..add(const RetrySearch())
            ..add(const RetrySearch());
          await pumpEventQueue();
          pending.single.complete(loaded);
          await pumpEventQueue();
        },
        expect: () => <Matcher>[
          isState(status: .loading),
          isState(status: .success, items: loaded),
        ],
        verify: (SearchBloc _) {
          verify(() => useCase.execute(any())).called(1);
        },
      );

      blocTest<SearchBloc, SearchState>(
        'discards a retried page once a new query is loading',
        setUp: stubPending,
        build: build,
        seed: () => seeded(
          status: .failure,
          exception: const FetchFailedException(),
        ),
        act: (SearchBloc bloc) async {
          bloc.add(const RetrySearch());
          await pumpEventQueue();
          bloc.add(const SubmitQuery(query: 'dart'));
          await pumpEventQueue();
          pending[0].complete(loaded);
          await pumpEventQueue();
        },
        expect: () => <Matcher>[
          isState(status: .loading, query: 'flutter'),
          suggested,
          isState(status: .loading, query: 'dart', items: const <Item>[]),
        ],
        verify: (SearchBloc _) => verifyNever(() => history.save(any())),
      );

      blocTest<SearchBloc, SearchState>(
        'retries a new query while a stale retry is still in flight',
        setUp: stubPending,
        build: build,
        seed: () => seeded(
          status: .failure,
          exception: const FetchFailedException(),
        ),
        act: (SearchBloc bloc) async {
          bloc.add(const RetrySearch());
          await pumpEventQueue();
          bloc.add(const SubmitQuery(query: 'dart'));
          await pumpEventQueue();
          pending[1].completeError(const FetchFailedException());
          await pumpEventQueue();
          bloc.add(const RetrySearch());
          await pumpEventQueue();
        },
        verify: (SearchBloc _) {
          expect(capturedParams(), <Matcher>[
            isParams(query: 'flutter', from: 0),
            isParams(query: 'dart', from: 0),
            isParams(query: 'dart', from: 0),
          ]);
        },
      );
    });

    group('close', () {
      final List<(String, void Function(Completer<List<Item>>))> outcomes =
          <(String, void Function(Completer<List<Item>>))>[
            (
              'succeeds',
              (Completer<List<Item>> c) => c.complete(loaded),
            ),
            (
              'fails',
              (Completer<List<Item>> c) =>
                  c.completeError(const FetchFailedException()),
            ),
          ];

      for (final (String name, void Function(Completer<List<Item>>) resolve)
          in outcomes) {
        test('ignores a request that $name after the bloc is closed', () async {
          stubPending();
          final SearchBloc bloc = build();
          final List<SearchState> states = <SearchState>[];
          final StreamSubscription<SearchState> subscription = bloc.stream
              .listen(states.add);

          bloc.add(const SubmitQuery(query: 'flutter'));
          await pumpEventQueue();
          await bloc.close();
          resolve(pending.single);
          await pumpEventQueue();
          await subscription.cancel();

          expect(states, <Matcher>[suggested, isState(status: .loading)]);
          expect(bloc.state, isState(status: .loading));
          verifyNever(() => history.save(any()));
        });
      }
    });
  });
}
