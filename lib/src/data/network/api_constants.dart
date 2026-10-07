final class ApiConstants {
  const ApiConstants._();

  static const String baseUrl = 'https://hn.algolia.com/api/v1';
  static const String searchPath = '/search';

  static const String queryParam = 'query';
  static const String tagsParam = 'tags';
  static const String offsetParam = 'offset';
  static const String lengthParam = 'length';

  static const String storyTag = 'story';

  static const String hitsKey = 'hits';
}
