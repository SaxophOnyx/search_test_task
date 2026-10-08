part of 'search_bloc.dart';

sealed class SearchEvent {
  const new();
}

sealed class _QueryEvent extends SearchEvent {
  final String query;

  const new({required this.query});
}

final class UpdateInput extends _QueryEvent {
  const new({required super.query});
}

final class SubmitQuery extends _QueryEvent {
  const new({required super.query});
}

final class LoadNextPage extends SearchEvent {
  const new();
}

final class RetrySearch extends SearchEvent {
  const new();
}
