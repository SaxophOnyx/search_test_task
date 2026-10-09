import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:search_test_task/src/core/core.dart';
import 'package:search_test_task/src/domain/domain.dart';
import 'package:search_test_task/src/features/search/services/search_exception_mapper.dart';
import 'package:search_test_task/src/shared_ui/shared_ui.dart';

final class _OtherException extends AppException {
  const _OtherException();
}

void main() {
  final AppLocalizations l10n = lookupAppLocalizations(const Locale('en'));

  group('SearchExceptionMapper', () {
    test('maps LimitReachedException to the too-many-requests message', () {
      expect(
        SearchExceptionMapper.toMessage(l10n, const LimitReachedException()),
        l10n.errorTooManyRequests,
      );
    });

    test('maps FetchFailedException to the fetch-failed message', () {
      expect(
        SearchExceptionMapper.toMessage(l10n, const FetchFailedException()),
        l10n.errorFetchFailed,
      );
    });

    test('maps UnknownException to the unknown message', () {
      expect(
        SearchExceptionMapper.toMessage(l10n, const UnknownException()),
        l10n.errorUnknown,
      );
    });

    test('falls back to the unknown message for other exceptions', () {
      expect(
        SearchExceptionMapper.toMessage(l10n, const _OtherException()),
        l10n.errorUnknown,
      );
    });
  });
}
