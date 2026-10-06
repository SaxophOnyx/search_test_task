part of 'search_bloc.dart';

class SearchState {
  final String query;
  final List<Item> items;
  final bool isLoading;
  final bool isLoadingMore;
  final bool hasReachedEnd;
  final bool hasError;

  const SearchState({
    required this.query,
    required this.items,
    required this.isLoading,
    required this.isLoadingMore,
    required this.hasReachedEnd,
    required this.hasError,
  });

  const SearchState.initial()
    : query = '',
      items = const <Item>[],
      isLoading = false,
      isLoadingMore = false,
      hasReachedEnd = false,
      hasError = false;

  SearchState copyWith({
    String? query,
    List<Item>? items,
    bool? isLoading,
    bool? isLoadingMore,
    bool? hasReachedEnd,
    bool? hasError,
  }) {
    return SearchState(
      query: query ?? this.query,
      items: items ?? this.items,
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      hasReachedEnd: hasReachedEnd ?? this.hasReachedEnd,
      hasError: hasError ?? this.hasError,
    );
  }
}
