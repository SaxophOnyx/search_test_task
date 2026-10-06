part of 'search_bloc.dart';

enum SearchStatus { idle, loading, loadingMore, success, failure }

class SearchState {
  final String query;
  final List<Item> items;
  final SearchStatus status;
  final bool hasReachedEnd;
  final List<String> suggestions;
  final Exception? exception;

  static const Object _unset = Object();

  const SearchState({
    required this.query,
    required this.items,
    required this.status,
    required this.hasReachedEnd,
    required this.suggestions,
    required this.exception,
  });

  const SearchState.initial()
    : query = '',
      items = const <Item>[],
      status = SearchStatus.idle,
      hasReachedEnd = false,
      suggestions = const <String>[],
      exception = null;

  SearchState copyWith({
    String? query,
    List<Item>? items,
    SearchStatus? status,
    bool? hasReachedEnd,
    List<String>? suggestions,
    Object? exception = _unset,
  }) {
    assert(identical(exception, _unset) || exception is Exception?);

    return SearchState(
      query: query ?? this.query,
      items: items ?? this.items,
      status: status ?? this.status,
      hasReachedEnd: hasReachedEnd ?? this.hasReachedEnd,
      suggestions: suggestions ?? this.suggestions,
      exception: identical(exception, _unset) ? this.exception : exception as Exception?,
    );
  }
}
