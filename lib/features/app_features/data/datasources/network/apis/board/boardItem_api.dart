import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../../../../domain/models/boardItem/boardItem.dart';
import '../../../../../domain/models/boardItem/boardItem_list.dart';
import '../../dio_client.dart';

class BoardItemApi {
  // dio instance
  final DioClient _dioClient;

  // injecting dio instance
  BoardItemApi(this._dioClient);

  /// Returns list of organization in response
  Future<BoardItemList> getBoardItems(int boardId) async {
    try {
      //final res = await _dioClient.get(Endpoints.getBoards);
      //return BoardList.fromJson(res);

      // Fake API
      List<BoardItem> boardItems = [];

      List<BoardItem> filteredItems =
          boardItems.where((item) => item.boardId == boardId).toList();

      BoardItemList boardItemList = BoardItemList(boardItemList: filteredItems);

      return await Future.delayed(const Duration(seconds: 1), () => boardItemList);
    } catch (e) {
      if (kDebugMode) {
        print(e.toString());
      }
      rethrow;
    }
  }

  Future<BoardItem> insertBoard(int boardId, String title, String description) async {
    try {
      //final res = await _dioClient.post(Endpoints.getOrganization + organization.id.toString());
      //return OrganizationList.fromJson(res);

      BoardItem brdItem = BoardItem(
          id: DateTime.now().millisecond,
          title: title,
          description: description,
          boardId: boardId);

      return await Future.delayed(const Duration(seconds: 2), () => brdItem);
    } catch (e) {
      rethrow;
    }
  }

  Future<int> deleteBoardItem(int boardItemId) async {
    try {
      //final res = await _dioClient.delete(Endpoints.deleteBoard + boardId.toString());
      //return Board.fromJson(res);

      return await Future.delayed(const Duration(seconds: 2), () => boardItemId);
    } catch (e) {
      rethrow;
    }
  }
}
