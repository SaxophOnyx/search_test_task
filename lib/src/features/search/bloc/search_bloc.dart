import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../domain/domain.dart';

part 'search_event.dart';
part 'search_state.dart';

class SearchBloc extends Bloc<SearchEvent, SearchState> {
  static const int _pageSize = 20;

  final SearchItemsUseCase _searchItemsUseCase;

  SearchBloc({
    required SearchItemsUseCase searchItemsUseCase,
  }) : _searchItemsUseCase = searchItemsUseCase,
       super(const SearchState.initial()) {
    on<UpdateSearchString>(_onUpdateSearchString, transformer: restartable());
    on<LoadNextPage>(_onLoadNextPage, transformer: droppable());
    on<RetrySearch>(_onRetrySearch, transformer: droppable());
  }

  Future<void> _onUpdateSearchString(
    UpdateSearchString event,
    Emitter<SearchState> emit,
  ) async {
    final String query = event.searchString.trim();

    if (query.isEmpty) {
      emit(const SearchState.initial());
      return;
    }

    await _loadFirstPage(query, emit);
  }

  Future<void> _onLoadNextPage(
    LoadNextPage event,
    Emitter<SearchState> emit,
  ) async {
    if (state.isLoading ||
        state.isLoadingMore ||
        state.hasReachedEnd ||
        state.hasError ||
        state.query.isEmpty) {
      return;
    }

    await _loadNextPage(emit);
  }

  Future<void> _onRetrySearch(
    RetrySearch event,
    Emitter<SearchState> emit,
  ) async {
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
    emit(const SearchState.initial().copyWith(query: query, isLoading: true));

    try {
      final List<Item> items = await _fetchPage(query, from: 0);
      if (state.query != query) return;

      emit(
        state.copyWith(
          items: items,
          isLoading: false,
          hasReachedEnd: items.length < _pageSize,
        ),
      );
    } catch (_) {
      if (state.query != query) return;

      emit(state.copyWith(isLoading: false, hasError: true));
    }
  }

  Future<void> _loadNextPage(Emitter<SearchState> emit) async {
    final String query = state.query;

    emit(state.copyWith(isLoadingMore: true, hasError: false));

    try {
      final List<Item> items = await _fetchPage(
        query,
        from: state.items.length,
      );
      if (state.query != query) return;

      emit(
        state.copyWith(
          items: <Item>[...state.items, ...items],
          isLoadingMore: false,
          hasReachedEnd: items.length < _pageSize,
        ),
      );
    } catch (_) {
      if (state.query != query) return;

      emit(state.copyWith(isLoadingMore: false, hasError: true));
    }
  }

  Future<List<Item>> _fetchPage(String query, {required int from}) {
    return _searchItemsUseCase.execute(
      SearchItemsParams(name: query, from: from, limit: _pageSize),
    );
  }
}
