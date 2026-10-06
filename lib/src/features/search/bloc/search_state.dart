part of 'search_bloc.dart';

enum SearchStatus { idle, loading, loadingMore, success, failure }

class SearchState {
  final String query;
  final List<Item> items;
  final SearchStatus status;
  final bool hasReachedEnd;
  final List<String> suggestions;

  const SearchState({
    required this.query,
    required this.items,
    required this.status,
    required this.hasReachedEnd,
    required this.suggestions,
  });

  const SearchState.initial()
    : query = '',
      items = const <Item>[],
      status = SearchStatus.idle,
      hasReachedEnd = false,
      suggestions = const <String>[];

  SearchState copyWith({
    String? query,
    List<Item>? items,
    SearchStatus? status,
    bool? hasReachedEnd,
    List<String>? suggestions,
  }) {
    return SearchState(
      query: query ?? this.query,
      items: items ?? this.items,
      status: status ?? this.status,
      hasReachedEnd: hasReachedEnd ?? this.hasReachedEnd,
      suggestions: suggestions ?? this.suggestions,
    );
  }
}
