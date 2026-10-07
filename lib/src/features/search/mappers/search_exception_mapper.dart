import '../../../core/core.dart';
import '../../../domain/domain.dart';

final class SearchExceptionMapper {
  const SearchExceptionMapper._();

  static const String _unknownMessage = 'Something went wrong';

  static String toMessage(AppException exception) {
    return switch (exception) {
      LimitReachedException() => 'Too many requests. Try again in a moment',
      FetchFailedException() => 'Couldn\'t load results. Check your connection',
      UnknownException() => _unknownMessage,
      // AppException isn't sealed, so subtypes added later land here.
      _ => _unknownMessage,
    };
  }
}
