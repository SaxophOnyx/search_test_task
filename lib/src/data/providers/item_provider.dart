import 'package:dio/dio.dart';

import '../data.dart';

class ItemProvider {
  final Dio _dio;

  const new({
    required Dio dio,
  }) : _dio = dio;

  Future<List<ItemEntity>> searchItems({
    required String query,
    required int from,
    required int limit,
  }) async {
    final Response<Map<String, dynamic>> response = await _dio
        .get<Map<String, dynamic>>(
          ApiConstants.searchPath,
          queryParameters: <String, dynamic>{
            ApiConstants.queryParam: query,
            ApiConstants.tagsParam: ApiConstants.storyTag,
            ApiConstants.offsetParam: from,
            ApiConstants.lengthParam: limit,
          },
        );
    final List<dynamic> hits =
        response.data![ApiConstants.hitsKey] as List<dynamic>;

    return hits
        .map((dynamic e) => ItemEntity.fromJson(e as Map<String, dynamic>))
        .toList(growable: false);
  }
}
