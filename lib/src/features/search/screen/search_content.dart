import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../domain/domain.dart';
import '../../../shared_ui/shared_ui.dart';
import '../bloc/search_bloc.dart';
import '../services/search_exception_mapper.dart';
import '../widgets/error_tile.dart';
import '../widgets/item_tile.dart';
import '../widgets/loading_tile.dart';
import '../widgets/search_field.dart';
import '../widgets/status_sliver.dart';

class SearchContent extends StatelessWidget {
  static const double _loadMoreThreshold = 200;

  const SearchContent({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: NotificationListener<ScrollMetricsNotification>(
        onNotification: (ScrollMetricsNotification n) => _onScrollMetrics(context, n),
        child: CustomScrollView(
          keyboardDismissBehavior: .onDrag,
          slivers: <Widget>[
            SliverAppBar(
              floating: true,
              title: BlocSelector<SearchBloc, SearchState, List<String>>(
                selector: (SearchState state) => state.suggestions,
                builder: (BuildContext context, List<String> suggestions) {
                  return SearchField(
                    suggestions: suggestions,
                    onChanged: (String value) =>
                        context.read<SearchBloc>().add(UpdateInput(query: value)),
                    onSubmitted: (String value) =>
                        context.read<SearchBloc>().add(SubmitQuery(query: value)),
                  );
                },
              ),
            ),
            BlocBuilder<SearchBloc, SearchState>(
              buildWhen: (SearchState previous, SearchState current) =>
                  previous.items != current.items ||
                  previous.status != current.status ||
                  previous.exception != current.exception,
              builder: (BuildContext context, SearchState state) {
                final AppLocalizations l10n = context.l10n;
                final String errorMessage = SearchExceptionMapper.toMessage(
                  l10n,
                  state.exception ?? const UnknownException(),
                );

                if (state.items.isEmpty) {
                  return switch (state.status) {
                    SearchStatus.idle => StatusSliver.message(
                      message: l10n.searchIdleMessage,
                    ),
                    SearchStatus.loading => const StatusSliver.loading(),
                    SearchStatus.success => StatusSliver.message(
                      message: l10n.searchEmptyMessage,
                    ),
                    SearchStatus.failure => StatusSliver.message(
                      message: errorMessage,
                      onPressed: () => context.read<SearchBloc>().add(const RetrySearch()),
                    ),
                  };
                }

                final Widget? footer = switch (state.status) {
                  SearchStatus.loading => const LoadingTile(),
                  SearchStatus.failure => ErrorTile(
                    message: errorMessage,
                    onRetry: () => context.read<SearchBloc>().add(const RetrySearch()),
                  ),
                  SearchStatus.idle || SearchStatus.success => null,
                };

                return SliverMainAxisGroup(
                  slivers: <Widget>[
                    SliverList.separated(
                      itemCount: state.items.length,
                      itemBuilder: (BuildContext context, int index) =>
                          ItemTile(item: state.items[index], index: index),
                      separatorBuilder: (_, _) => const Divider(),
                    ),
                    if (footer != null) SliverToBoxAdapter(child: footer),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  bool _onScrollMetrics(BuildContext context, ScrollMetricsNotification n) {
    if (n.metrics.extentAfter >= _loadMoreThreshold) {
      return false;
    }

    final SearchBloc bloc = context.read<SearchBloc>();
    final SearchState state = bloc.state;

    if (state.status == .success && !state.hasReachedEnd) {
      bloc.add(const LoadNextPage());
    }

    return false;
  }
}
