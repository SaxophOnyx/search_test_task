part of 'search_bloc.dart';

sealed class SearchEvent {
  const SearchEvent();
}

final class UpdateSearchString extends SearchEvent {
  final String searchString;

  const new({required this.searchString});
}
