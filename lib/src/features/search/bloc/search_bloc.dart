import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/core.dart';
import '../../../domain/domain.dart';
import 'query_history.dart';

part 'search_event.dart';
part 'search_state.dart';

class SearchBloc extends Bloc<SearchEvent, SearchState> {
  static const int _pageSize = 20;

  final SearchItemsUseCase _searchItemsUseCase;
  final QueryHistory _history;

  int _generation = 0;

  new({
    required SearchItemsUseCase searchItemsUseCase,
    required QueryHistory queryHistory,
  }) : _searchItemsUseCase = searchItemsUseCase,
       _history = queryHistory,
       super(const SearchState.initial()) {
    on<UpdateSearchString>(_onUpdateSearchString, transformer: restartable());
    on<UpdateSuggestions>(_onUpdateSuggestions);
    on<LoadNextPage>(_onLoadNextPage, transformer: droppable());
    on<RetrySearch>(_onRetrySearch, transformer: droppable());
  }

  Future<void> _onUpdateSearchString(
    UpdateSearchString event,
    Emitter<SearchState> emit,
  ) async {
    final String query = QueryHistory.normalize(event.searchString);

    if (query.isEmpty) {
      _generation++;
      emit(SearchState.initial(suggestions: state.suggestions));
      return;
    }

    if (query == state.query &&
        (state.items.isNotEmpty || state.status == .success)) {
      return;
    }

    _generation++;
    emit(
      SearchState.initial(
        suggestions: state.suggestions,
      ).copyWith(query: query, status: .loading),
    );

    await _fetchPage(emit);
  }

  void _onUpdateSuggestions(
    UpdateSuggestions event,
    Emitter<SearchState> emit,
  ) {
    emit(state.copyWith(suggestions: _history.suggest(event.input)));
  }

  Future<void> _onLoadNextPage(
    LoadNextPage event,
    Emitter<SearchState> emit,
  ) async {
    if (state.status != .success || state.hasReachedEnd) {
      return;
    }

    emit(
      state.copyWith(
        status: .loadingMore,
        exception: null,
      ),
    );

    await _fetchPage(emit);
  }

  Future<void> _onRetrySearch(
    RetrySearch event,
    Emitter<SearchState> emit,
  ) async {
    if (state.status != .failure) {
      return;
    }

    emit(
      state.copyWith(
        status: state.items.isEmpty ? .loading : .loadingMore,
        exception: null,
      ),
    );

    await _fetchPage(emit);
  }

  Future<void> _fetchPage(Emitter<SearchState> emit) async {
    final String query = state.query;
    final List<Item> loaded = state.items;
    final int generation = _generation;

    try {
      final List<Item> page = await _searchItemsUseCase.execute(
        SearchItemsParams(query: query, from: loaded.length, limit: _pageSize),
      );

      if (isClosed || generation != _generation) {
        return;
      }

      if (loaded.isEmpty && page.isNotEmpty) {
        _history.save(query);
      }

      emit(
        state.copyWith(
          items: <Item>[...loaded, ...page],
          status: .success,
          hasReachedEnd: page.length < _pageSize,
          exception: null,
        ),
      );
    } on AppException catch (exception) {
      if (isClosed || generation != _generation) {
        return;
      }

      emit(
        state.copyWith(
          status: .failure,
          exception: exception,
        ),
      );
    }
  }
}
