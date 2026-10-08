import '../../../core/core.dart';
import '../../../domain/domain.dart';
import '../../../shared_ui/shared_ui.dart';

final class SearchExceptionMapper {
  const SearchExceptionMapper._();

  static String toMessage(AppLocalizations l10n, AppException exception) {
    return switch (exception) {
      LimitReachedException() => l10n.errorTooManyRequests,
      FetchFailedException() => l10n.errorFetchFailed,
      UnknownException() => l10n.errorUnknown,
      _ => l10n.errorUnknown,
    };
  }
}
