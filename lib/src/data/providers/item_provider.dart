import 'package:dio/dio.dart';

import '../data.dart';

class ItemProvider {
  final Dio _dio;
  final ApiGuard _guard;

  const new({
    required Dio dio,
    required ApiGuard guard,
  }) : _dio = dio,
       _guard = guard;

  Future<List<ItemEntity>> searchItems({
    required String query,
    required int from,
    required int limit,
  }) {
    return _guard.run(() async {
      final Response<Map<String, dynamic>> response = await _dio.get<Map<String, dynamic>>(
        ApiConstants.searchPath,
        queryParameters: <String, dynamic>{
          ApiConstants.queryParam: query,
          ApiConstants.tagsParam: ApiConstants.storyTag,
          ApiConstants.offsetParam: from,
          ApiConstants.lengthParam: limit,
        },
      );

      return (response.data![ApiConstants.hitsKey] as List<dynamic>)
          .map((dynamic e) => ItemEntity.fromJson(e as Map<String, dynamic>))
          .toList(growable: false);
    });
  }
}
