part of 'search_bloc.dart';

class SearchState {
  final List<Item> items;
  final bool isLoading;

  const SearchState({
    required this.items,
    required this.isLoading,
  });

  const SearchState.initial() : items = const <Item>[], isLoading = false;

  SearchState copyWith({
    List<Item>? items,
    bool? isLoading,
  }) {
    return SearchState(
      items: items ?? this.items,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}
