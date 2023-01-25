import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../../../../domain/models/post/post_list.dart';
import '../../constants/endpoints.dart';
import '../../dio_client.dart';
import '../../rest_client.dart';

class PostApi {
  // dio instance
  final DioClient _dioClient;

  // rest-client instance
  final RestClient _restClient;

  // injecting dio instance
  PostApi(this._dioClient, this._restClient);

  /// Returns list of post in response
  Future<PostList> getPosts() async {
    try {
      final res = await _dioClient.get(Endpoints.getPosts);
      return PostList.fromJson(res);
    } catch (e) {
      if (kDebugMode) {
        print(e.toString());
      }
      rethrow;
    }
  }

}
