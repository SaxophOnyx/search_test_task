part of 'search_bloc.dart';

enum SearchStatus { idle, loading, loadingMore, success, failure }

final class SearchState {
  final String query;
  final List<Item> items;
  final SearchStatus status;
  final bool hasReachedEnd;
  final List<String> suggestions;
  final AppException? exception;

  static const Object _unset = Object();

  const new({
    required this.query,
    required this.items,
    required this.status,
    required this.hasReachedEnd,
    required this.suggestions,
    required this.exception,
  });

  const SearchState.initial({
    this.suggestions = const <String>[],
  }) : query = '',
       items = const <Item>[],
       status = .idle,
       hasReachedEnd = false,
       exception = null;

  SearchState copyWith({
    String? query,
    List<Item>? items,
    SearchStatus? status,
    bool? hasReachedEnd,
    List<String>? suggestions,
    Object? exception = _unset,
  }) {
    assert(identical(exception, _unset) || exception is AppException?);

    return SearchState(
      query: query ?? this.query,
      items: items ?? this.items,
      status: status ?? this.status,
      hasReachedEnd: hasReachedEnd ?? this.hasReachedEnd,
      suggestions: suggestions ?? this.suggestions,
      exception: identical(exception, _unset)
          ? this.exception
          : exception as AppException?,
    );
  }
}
