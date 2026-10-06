import 'package:dio/dio.dart';

import '../data.dart';

class ItemProvider {
  final Dio _dio = Dio(BaseOptions(baseUrl: 'http://hn.algolia.com/api/v1'));

  Future<List<ItemEntity>> searchItems({
    required String query,
    required int from,
  }) async {
    final Response<dynamic> response = await _dio.get('/search?query=foo&tags=story');
    final dynamic data = response.data;
    final List<dynamic> hits = data['hits'];

    return hits.map((dynamic e) => ItemEntity.fromJson(e)).toList(growable: false);
  }
}
