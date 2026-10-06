import '../../../core/core.dart';

final class SearchExceptionMapper {
  const SearchExceptionMapper._();

  static String toMessage(Exception exception) {
    return switch (exception) {
      LimitReachedException() => 'Too many requests. Try again in a moment',
      FetchFailedException() => 'Couldn\'t load results. Check your connection',
      _ => 'Something went wrong',
    };
  }
}
