import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../domain/domain.dart';
import 'query_history.dart';

part 'search_event.dart';
part 'search_state.dart';

class SearchBloc extends Bloc<SearchEvent, SearchState> {
  static const int _pageSize = 20;

  final SearchItemsUseCase _searchItemsUseCase;
  final QueryHistory _history = QueryHistory();

  String _input = '';

  SearchBloc({
    required SearchItemsUseCase searchItemsUseCase,
  }) : _searchItemsUseCase = searchItemsUseCase,
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
      emit(_resetState());
      return;
    }

    if (query == state.query &&
        (state.items.isNotEmpty || state.status == SearchStatus.success)) {
      return;
    }

    await _loadFirstPage(query, emit);
  }

  void _onUpdateSuggestions(
    UpdateSuggestions event,
    Emitter<SearchState> emit,
  ) {
    _input = event.input;
    emit(state.copyWith(suggestions: _history.suggest(_input)));
  }

  Future<void> _onLoadNextPage(
    LoadNextPage event,
    Emitter<SearchState> emit,
  ) async {
    if (state.status != SearchStatus.success ||
        state.hasReachedEnd ||
        state.query.isEmpty) {
      return;
    }

    await _loadNextPage(emit);
  }

  Future<void> _onRetrySearch(
    RetrySearch event,
    Emitter<SearchState> emit,
  ) async {
    if (state.status != SearchStatus.failure) return;

    if (state.items.isEmpty) {
      await _loadFirstPage(state.query, emit);
    } else {
      await _loadNextPage(emit);
    }
  }

  Future<void> _loadFirstPage(
    String query,
    Emitter<SearchState> emit,
  ) async {
    emit(_resetState().copyWith(query: query, status: SearchStatus.loading));

    try {
      final List<Item> items = await _fetchPage(query, from: 0);
      if (state.query != query) return;

      if (items.isNotEmpty) _history.save(query);

      emit(
        state.copyWith(
          items: items,
          status: SearchStatus.success,
          hasReachedEnd: items.length < _pageSize,
          suggestions: _history.suggest(_input),
        ),
      );
    } on Exception catch (exception) {
      if (state.query != query) return;

      emit(
        state.copyWith(status: SearchStatus.failure, exception: exception),
      );
    }
  }

  Future<void> _loadNextPage(Emitter<SearchState> emit) async {
    final String query = state.query;

    emit(state.copyWith(status: SearchStatus.loadingMore, exception: null));

    try {
      final List<Item> items = await _fetchPage(
        query,
        from: state.items.length,
      );
      if (state.query != query) return;

      emit(
        state.copyWith(
          items: <Item>[...state.items, ...items],
          status: SearchStatus.success,
          hasReachedEnd: items.length < _pageSize,
        ),
      );
    } on Exception catch (exception) {
      if (state.query != query) return;

      emit(
        state.copyWith(status: SearchStatus.failure, exception: exception),
      );
    }
  }

  Future<List<Item>> _fetchPage(String query, {required int from}) {
    return _searchItemsUseCase.execute(
      SearchItemsParams(query: query, from: from, limit: _pageSize),
    );
  }

  SearchState _resetState() {
    return const SearchState.initial().copyWith(suggestions: state.suggestions);
  }
}
