part of 'search_bloc.dart';

sealed class SearchEvent {
  const SearchEvent();
}

final class UpdateSearchString extends SearchEvent {
  final String searchString;

  const new({required this.searchString});
}

final class LoadNextPage extends SearchEvent {
  const new();
}

final class RetrySearch extends SearchEvent {
  const new();
}
